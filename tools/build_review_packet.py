#!/usr/bin/env python3
"""Write a version-specific human content-review packet for one private build.

The packet freezes the exact study JSON the build contains, lists every authored
item with its text and sources in reviewer-readable form, and supplies a blank
results template. It never records review outcomes itself: every item starts
"not reviewed", and assistant cross-checks are not reviewer evidence.
"""

import argparse
import hashlib
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
STUDY = "content/study_content.json"
SYSTEM_ORDER = ["circulatory", "respiratory", "nervous", "digestive", "urinary", "reproductive",
                "lymphatic", "skeletal", "muscular", "integumentary"]


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def mapping_list(value):
    return value if isinstance(value, list) else [value]


def references():
    pack = json.loads((ROOT / "content/sample_pack.json").read_text())
    manifest = {f.get("body_id"): f["sha256"] for f in json.loads((ROOT / "content/source_manifest.json").read_text())["files"]}
    rows = [(b["id"], len(b["structures"]), manifest[b["id"]]) for b in pack["bodies"]]
    bone = json.loads((ROOT / "content/bodyparts3d_bone_study.json").read_text())
    rows.append((bone["id"], len(bone["structures"]), bone["sha256"]))
    for study in json.loads((ROOT / "content/spinal_studies.json").read_text())["bodies"]:
        rows.append((study["id"], len(study["structures"]), study.get("sha256", "")))
    return pack, rows


def card_structures(content, pack, identity):
    """Labels the reviewer will see for a card in each adult body."""
    card = content["cards"][identity]
    out = {}
    for body in pack["bodies"]:
        index = {s["id"]: s for s in body["structures"]}
        if "geometry" not in card:
            ids = [identity] if identity in index else []
        else:
            ids = [m["id"] for m in mapping_list(card["geometry"].get(body["id"], [])) if m]
        out[body["id"]] = [index[i] for i in ids if i in index]
    return out


def system_of(pack, structure):
    """Nearest anatomy.system.* ancestor in the female (else male) catalogue."""
    for body in pack["bodies"]:
        index = {s["id"]: s for s in body["structures"]}
        current = index.get(structure)
        while current:
            if current["id"].startswith("anatomy.system."):
                return current["id"].removeprefix("anatomy.system.")
            current = index.get(current.get("parent"))
    return "other"


def card_system(content, pack, identity):
    labelled = card_structures(content, pack, identity)
    for body in ("female", "male"):
        if labelled.get(body):
            return system_of(pack, labelled[body][0]["id"])
    return "other"


def source_lines(content, ids):
    return [f"  - `{s}`: [{content['sources'][s]['title']}]({content['sources'][s]['url']})" for s in ids]


def write(args):
    report = json.loads(pathlib.Path(args.build_report).read_text())
    identity = report["build_identity"]
    revision = report["source_revision"]
    short = revision[:7]
    study_path = ROOT / STUDY
    study_hash = sha256(study_path)
    if report["source_hashes"].get(STUDY) != study_hash:
        raise SystemExit("content/study_content.json differs from the build record; check out the built revision first")
    content = json.loads(study_path.read_text())
    pack, refs = references()
    reviews = ROOT / "docs/reviews"
    reviews.mkdir(parents=True, exist_ok=True)
    frozen = reviews / f"{short}-study-content.json"
    frozen.write_bytes(study_path.read_bytes())

    groups = {}
    for cid in content["cards"]:
        groups.setdefault(card_system(content, pack, cid), []).append(cid)
    ordered = [g for g in SYSTEM_ORDER if g in groups] + sorted(g for g in groups if g not in SYSTEM_ORDER)

    # Reviewer-readable text
    text = [f"# Study text for review: build `{short}`", "",
            f"Every card, condition and route in study revision `{content['revision']}`, as shipped in private build "
            f"`{identity['build_id']}`. The [frozen JSON]({frozen.name}) is the authoritative copy. "
            "All items are drafts: an assistant compared each statement with its cited page, which is not reviewer evidence.", "",
            "**What to check for each item:** whether each statement is correct and supported by the cited source, whether "
            "anything important is missing or misleading, whether the related anatomy is right, and whether the named "
            "3D parts are the right structures.", ""]
    text += ["## Cards", ""]
    for group in ordered:
        text += [f"### {group.capitalize()}", ""]
        for cid in groups[group]:
            card = content["cards"][cid]
            labelled = card_structures(content, pack, cid)
            text.append(f"#### `{cid}`")
            text.append("")
            for body in ("female", "male"):
                names = ", ".join(s["label"] for s in labelled.get(body, [])) or "not in this body"
                text.append(f"- **3D parts ({body}):** {names}")
            text += [f"- **Overview:** {card['overview']}", f"- **Function:** {card['function']}"]
            if card["related"]:
                text.append("- **Related:** " + ", ".join(f"`{r}`" for r in card["related"]))
            text.append("- **Sources:**")
            text += source_lines(content, card["source_ids"])
            text.append("")
    text += ["## Conditions", "",
             "Conditions only locate the healthy reference anatomy; no disease geometry is shown. Check the summary, "
             "the reference location text, the focus part, the parts it is listed on, and the stated depiction limit.", ""]
    for cid, cond in content["conditions"].items():
        text += [f"### {cond['title']} (`{cid}`)", "", f"- **Summary:** {cond['summary']}",
                 f"- **Reference location:** {cond['location']}", f"- **Focus:** `{cond['focus_id']}`",
                 "- **Requires:** " + ", ".join(f"`{a}`" for a in cond["related_anatomy"]),
                 "- **Listed on:** " + ", ".join(f"`{a}`" for a in cond["display_on"]),
                 f"- **Not depicted:** {cond.get('not_depicted', 'Disease-related tissue changes, motion and flow are not depicted.')}",
                 "- **Sources:**", *source_lines(content, cond["source_ids"]), ""]
    text += ["## Routes", ""]
    for rid, route in content.get("routes", {}).items():
        text += [f"### {route['title']} (`{rid}`)", "", route["scope"], ""]
        for nid, node in route["nodes"].items():
            gap = f" Gap: {node['gap']}" if node.get("gap") else ""
            text.append(f"- `{nid}` — **{node['title']}**: {node['text']}{gap} Next: {', '.join(node['next'])}.")
        text += ["", "- **Sources:**", *source_lines(content, route["source_ids"]), ""]
    (reviews / f"{short}-reviewer-text.md").write_text("\n".join(text))

    # Blank results template
    items = [("Card", c) for c in content["cards"]] + [("Condition", c) for c in content["conditions"]] + \
            [("Route", r) for r in content.get("routes", {})]
    tpl = [f"# Human content-review result: {short}", "",
           "Uncompleted template. Every item below starts **not reviewed**. Copy to a dated record and complete only the "
           "scope actually inspected.", "",
           "- Reviewer name:", "- Relevant qualifications / role:", "- Review date:",
           "- Role in this record: human source check / qualified medical review / both (specify scope).",
           f"- Expected source revision: `{revision}`.", f"- Expected build ID: `{identity['build_id']}`.",
           "- Actual app archive and SHA-256:", "- Actual app build ID / source shown in Sources:",
           "- Device / OS / input method used for visual checks:", f"- Frozen study SHA-256: `{study_hash}`.",
           "- Other exact content/catalogue/geometry versions checked:", "- Review scope and exclusions:",
           "- Sources or references used:", "",
           f"Use the [review packet](../CONTENT_REVIEW_PACKET.md), the [reviewer text]({short}-reviewer-text.md) and the "
           f"[frozen JSON]({frozen.name}). For each column use **not reviewed**, **changes required** or **accepted "
           "unchanged**, with finding/evidence IDs. If text or visuals need changes, approval requires review of the "
           "corrected version. Blank cells do not record approval.", "",
           f"## Authored items ({len(items)})", "",
           "| Type | Item ID | Human source check | Qualified review, including applicable visuals | Finding / evidence IDs |",
           "| --- | --- | --- | --- | --- |"]
    tpl += [f"| {kind} | `{item}` | not reviewed | not reviewed | |" for kind, item in items]
    tpl += ["", "## Reference and mapping scope", "",
            "List every catalogue ID or attached exact ID inventory that was inspected. A row cannot imply approval of "
            "all records from a reference when only a subset was seen.", "",
            "| Reference ID | Exact reviewed catalogue IDs / inventory | Outcome | Finding / evidence IDs |",
            "| --- | --- | --- | --- |"]
    tpl += [f"| `{ref}` | | not reviewed | |" for ref, _, _ in refs]
    tpl += ["", "## Findings", "", "| Finding ID | Item / catalogue ID | Exact wording or observation | Source / evidence | Required correction |",
            "| --- | --- | --- | --- | --- |", "| | | | | |", ""]
    (reviews / f"{short.upper()}_TEMPLATE.md").write_text("\n".join(tpl))

    # Packet
    artifacts = "\n".join(f"| {a['file']} | `{a['sha256']}` |" for a in report["artifacts"])
    ref_rows = "\n".join(f"| `{ref}` | {count} | `{digest}` |" for ref, count, digest in refs)
    cards, conditions = len(content["cards"]), len(content["conditions"])
    counts = {}
    for body in pack["bodies"]:
        index = {s["id"]: s for s in body["structures"]}
        def present(a):
            if a in index:
                return True
            card = content["cards"].get(a, {})
            return any(m["id"] in index for v in card.get("geometry", {}).values() for m in mapping_list(v) if v)
        counts[body["id"]] = sum(all(present(a) for a in c["related_anatomy"]) for c in content["conditions"].values())
    packet = f"""# Current private candidate: content-review packet

Prepared {args.date}. Review is pending. This packet identifies the exact draft
study material in one private build and supplies a
[results template](reviews/{short.upper()}_TEMPLATE.md) for a human source checker or
qualified medical reviewer. A completed review applies only to its recorded items,
reference mappings and exact versions. The broader release scope in
[SCOPE.md](SCOPE.md) still includes unresolved content and capabilities.

The previous packet, for build `c86cfba` and its 15 chest cards, is kept at
[reviews/C86CFBA_PACKET.md](reviews/C86CFBA_PACKET.md).

## Exact material

- Application source: `{revision}`.
- Private build ID: `{identity['build_id']}`.
- Application version: `{identity['application_version']}`.
- Source snapshot SHA-256: `{identity['source_snapshot_sha256']}`.
- Engine: `{identity['engine']}`.
- Study-content revision: `{content['revision']}`.
- Frozen study JSON SHA-256: `{study_hash}`.

| Artifact | SHA-256 |
| --- | --- |
{artifacts}

The app's Sources dialog and START_HERE file show the build ID; check that it
matches before reviewing. Use [native setup](NATIVE_BUILDS.md) and the
[backup procedure](PRIVATE_UPDATE_TRIAL.md) for an isolated private trial.

## What to review

- **[Reviewer text](reviews/{short}-reviewer-text.md):** every item in readable
  form, grouped by body system, with the 3D part names shown in each body and
  every source link. Start here.
- **[Frozen JSON](reviews/{short}-study-content.json):** the authoritative copy of
  the same material.
- **[Results template](reviews/{short.upper()}_TEMPLATE.md):** one row per item.

The build contains **{cards} cards, {conditions} condition summaries and
{len(content.get('routes', {}))} route**, all marked draft with human source review
and expert review pending. The female body offers {counts.get('female')} conditions
and the male body {counts.get('male')}; the rest need anatomy only one body has.

For each card, check every statement against its cited source, the related-anatomy
links, and that the named 3D parts are the structures the card describes. For each
condition, check the summary, the reference-location text, the focus part, the
parts it is listed on, and that the "not depicted" statement is accurate: the app
locates healthy reference anatomy only and shows no disease geometry. For the
route, check every node, transition, branch and stated gap.

Paired or split parts (both eyes, both knees, separate atlas pieces of one brain
region) share one card; any listed part shows it. Some source parts had no name
in the model files, and the app derives one from the source node name (for
example "Thalamus, left"); those names are part of the label review below.

## Reference, label and mapping review

Approving authored text does not establish that imported labels, grouping,
geometry or placement are anatomically correct. Record the exact reference and
catalogue IDs inspected, any omitted regions and unresolved source metadata.
Counts include grouping records and do not establish completeness.

| Reference ID | Catalogue records | Geometry source SHA-256 |
| --- | ---: | --- |
{ref_rows}

Review the HRA bodies separately. The bone and spinal studies keep separate
coordinates and pending registration/metadata questions. Catalogue paths are
`content/sample_pack.json`, `content/bodyparts3d_bone_study.json` and
`content/spinal_studies.json`. Obtain the exact file with, for example:

```sh
git show {revision}:content/sample_pack.json
```

## Record findings and review boundaries

Copy the results template to a dated review record. Enter the reviewer's identity,
relevant qualifications or role, date, the actual archive inspected, reviewed IDs
and supporting evidence. A user usability trial and an assistant cross-check are
separate from human source checking and qualified medical review, as specified in
[the data model](DATA_MODEL.md#review-evidence).

List unreviewed material explicitly. Give findings with exact wording or catalogue
IDs, reproduction steps, source addresses and the required correction. Any later
change to a claim, mapping or geometry invalidates the affected approval and needs
another version-specific review. Repository content stays draft until applicable
human evidence is recorded and the change is reviewed.

Asset/application rights, device usability, accessibility and release distribution
have separate gates in [the production checkpoint](PRODUCTION_READINESS.md).
"""
    (ROOT / "docs/CONTENT_REVIEW_PACKET.md").write_text(packet)
    print(f"Packet for {short}: {cards} cards, {conditions} conditions, {len(items)} template rows")


def main():
    parser = argparse.ArgumentParser(description="Write a version-specific human content-review packet for one private build.")
    parser.add_argument("--build-report", required=True)
    parser.add_argument("--date", required=True, help="Preparation date, YYYY-MM-DD")
    write(parser.parse_args())


if __name__ == "__main__":
    main()
