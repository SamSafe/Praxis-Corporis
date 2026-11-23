"""Register reviewed CT-traced parts with the supplement manifest and study cards.

usage: integrate_ct_parts.py PARTS_DIR
Copies each <body>-<group>.glb into assets/vhp-ct/, adds one supplement group per file
to content/hra_supplements_manifest.json, and maps the existing study cards to the new
parts on the female and male bodies. Run tools/build_hra_supplements.py and
tools/build_sample_pack.py afterwards; card mappings are written with the node names
and resolved to catalogue IDs by the second pass (--map).
"""
import hashlib, json, pathlib, shutil, sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
GROUPS = {  # group -> (label for multi-part groups or None, card it maps to)
    "stomach": (None, "anatomy.stomach"),
    "esophagus": (None, "anatomy.esophagus"),
    "thyroid-gland": (None, "anatomy.thyroid"),
    "adrenal-glands": ("Adrenal glands", "anatomy.adrenal-glands"),
    "ribs": ("Ribs and costal cartilages", "anatomy.ribs"),
    "sternum": (None, "anatomy.sternum"),
    "gluteal-muscles": ("Gluteal muscles", None),
    "iliopsoas": ("Iliopsoas muscles", None),
    "deep-back-muscles": ("Deep back muscles", None),
}
SOURCE = {"female": "Visible Human female normal CT (NLM), traced; tools/vhp_parotid",
          "male": "Visible Human male normal CT (NLM), traced; tools/vhp_parotid"}


def register(parts: pathlib.Path) -> None:
    manifest_path = ROOT / "content/hra_supplements_manifest.json"
    manifest = json.loads(manifest_path.read_text())
    (ROOT / "assets/vhp-ct").mkdir(exist_ok=True)
    (ROOT / "assets/vhp-ct/.gdignore").write_text("\n")
    for body in manifest["bodies"]:
        b = body["body_id"]; X = "VH_M" if b == "male" else "VH_F"
        body["groups"] = [g for g in body["groups"] if "vhp-ct/" not in g["files"][0]["local_path"]]
        for group, (label, _) in GROUPS.items():
            src = parts / f"{b}-{group}.glb"
            if not src.exists():
                continue
            dst = ROOT / "assets/vhp-ct" / src.name
            shutil.copyfile(src, dst)
            data = dst.read_bytes()
            record = {"source": SOURCE[b],
                      "license": "Derived from NLM Visible Human Project data under the NLM Terms and Conditions (acknowledge the National Library of Medicine)",
                      "derivation": "TotalSegmentator 2.18.0 total task (Apache-2.0); regional similarity fit to shared anatomy; see docs/audit/VHP_CT_PARTS.md",
                      "files": [{"local_path": str(dst.relative_to(ROOT)), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}]}
            if label:
                record = {"node_name": f"{X}_{group.replace('-', '_')}", "label": label, **record}
            body["groups"].append(record)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")


def map_cards() -> None:
    """Point the existing cards at the new parts, by catalogue record."""
    pack = json.loads((ROOT / "content/sample_pack.json").read_text())
    names = {b["id"]: {s["source_name"]: s for s in b["structures"]} for b in pack["bodies"]}
    path = ROOT / "content/study_content.json"
    content = json.loads(path.read_text())
    cards = content["cards"]
    want = {"anatomy.stomach": ["stomach"], "anatomy.esophagus": ["esophagus"], "anatomy.thyroid": ["thyroid_gland"],
            "anatomy.adrenal-glands": ["adrenal_glands"], "anatomy.ribs": ["ribs_and_costal_cartilages", "ribs"],
            "anatomy.sternum": ["sternum"], "anatomy.gluteus-maximus": ["gluteus_maximus_L", "gluteus_maximus_R"]}
    for card, nodes in want.items():
        for b in ("female", "male"):
            X = "VH_M" if b == "male" else "VH_F"
            found = [names[b][f"{X}_{n}"] for n in nodes if f"{X}_{n}" in names[b]]
            if card == "anatomy.ribs":
                found = found[:1]
            if not found:
                cards[card].get("geometry", {}).pop(b, None)
                continue
            mapping = [{"id": s["id"], "source_name": s["source_name"], "ontology": s["ontology"]} for s in found]
            cards[card].setdefault("geometry", {})[b] = mapping[0] if len(mapping) == 1 else mapping
    path.write_text(json.dumps(content, indent=2, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    if sys.argv[1] == "--map":
        map_cards()
    else:
        register(pathlib.Path(sys.argv[1]))
