"""Build the complete BodyParts3D male body: every source mesh once, in an organ tree.

The PART-OF tree gives the composition (organ -> parts) for 1,258 source meshes. Meshes
listed only in the IS-A tree (mostly individual muscles, smaller vessels, nerves, teeth
and brain structures) are grouped by their IS-A ancestry. Source duplicates, meshes the
archive repeats under another file ID, are kept once. Geometry conversion matches the
bone study: millimetres to metres, Z-up to Y-up, source normals kept. No registration
to the HRA bodies is applied.
"""

from __future__ import annotations

import argparse
import csv
import collections
import hashlib
import json
import pathlib
import re
import struct
import zipfile

from build_bone_study import read_geometry

ROOT = pathlib.Path(__file__).resolve().parents[1]
BODY_ID = "bodyparts-male-complete"
PREFIX = "source.bodyparts3d-v4-complete."

# Source concepts that are the same structure as a study card, by FMA preferred name.
# The structure then uses the card's ID, so its card and conditions apply directly.
CARD_CONCEPTS = {
    "anatomy.skin": "skin", "anatomy.heart": "heart", "anatomy.brain": "brain",
    "anatomy.liver": "liver", "anatomy.gallbladder": "gallbladder", "anatomy.pancreas": "pancreas",
    "anatomy.small-intestine": "small intestine", "anatomy.rectum": "rectum", "anatomy.trachea": "trachea",
    "anatomy.lung.left": "left lung", "anatomy.lung.right": "right lung",
    "anatomy.kidney.left": "left kidney", "anatomy.kidney.right": "right kidney",
    "anatomy.bladder": "urinary bladder", "anatomy.prostate": "prostate", "anatomy.thymus": "thymus",
    "anatomy.aorta": "aorta", "anatomy.aorta.ascending": "ascending aorta", "anatomy.aorta.arch": "arch of aorta",
    "anatomy.vena-cava.superior": "superior vena cava", "anatomy.vena-cava.inferior": "inferior vena cava",
    "anatomy.pelvis": "pelvis", "anatomy.spleen": "spleen", "anatomy.appendix": "appendix",
    "anatomy.diaphragm": "diaphragm",
    "anatomy.stomach": "stomach", "anatomy.esophagus": "esophagus", "anatomy.spinal-cord": "spinal cord",
    "anatomy.pituitary": "pituitary gland", "anatomy.tongue": "tongue", "anatomy.skull": "skull",
    "anatomy.vertebral-column": "vertebral column",
}

# Groups for meshes outside the PART-OF tree, chosen from IS-A ancestor names in order.
EXTRA_GROUPS = [
    ("teeth", "Teeth", ("tooth",)),
    ("nerves", "Nerves", ("nerve", "ganglion", "plexus")),
    ("brain", "Brain structures", ("brain", "nucleus", "thalam", "gyrus", "fornix", "colliculus", "choroid plexus", "tract")),
    ("muscles", "Muscles", ("muscle", "musculature", "tendon", "aponeurosis")),
    ("veins", "Veins", ("vein", "venous")),
    ("arteries", "Arteries", ("arter", "anastomosis")),
    ("other", "Other source parts", ("",)),
]


def table(path: pathlib.Path) -> list[dict]:
    return list(csv.DictReader(path.open(encoding="utf-8"), delimiter="\t"))


def verify_inputs(folder: pathlib.Path, manifest: dict) -> None:
    for record in manifest["files"]:
        path = folder / pathlib.Path(record["local_path"]).name
        if path.suffix in (".zip", ".txt") and (not path.exists() or path.stat().st_size != record["bytes"]
                                                or hashlib.sha256(path.read_bytes()).hexdigest() != record["sha256"]):
            raise ValueError("Source input differs from the pinned manifest: " + path.name)


def box_overlap(a: dict, b: dict) -> float:
    inside = 1.0
    for axis in range(3):
        inside *= max(0.0, min(a["max"][axis], b["max"][axis]) - max(a["min"][axis], b["min"][axis]))
    volume = lambda box: max(1e-12, (box["max"][0] - box["min"][0]) * (box["max"][1] - box["min"][1]) * (box["max"][2] - box["min"][2]))
    return inside / (volume(a) + volume(b) - inside) if inside else 0.0


def build(folder: pathlib.Path, output: pathlib.Path, catalogue: pathlib.Path) -> None:
    manifest = json.loads((ROOT / "content/bodyparts3d_source_manifest.json").read_text())
    verify_inputs(folder, manifest)
    partof_rel = table(folder / "partof_inclusion_relation_list.txt")
    partof_parts = table(folder / "partof_element_parts.txt")
    isa_rel = table(folder / "isa_inclusion_relation_list.txt")
    names, parent = {}, {}
    for row in partof_rel:
        names[row["parent id"]] = row["parent name"]
        names[row["child id"]] = row["child name"]
        if row["child id"] in parent and parent[row["child id"]] != row["parent id"]:
            raise ValueError("PART-OF concept with two parents: " + row["child id"])
        parent[row["child id"]] = row["parent id"]
    roots = {concept for concept in names if concept not in parent}
    if roots != {"FMA20394"}:
        raise ValueError("Unexpected PART-OF roots: " + ", ".join(sorted(roots)))
    partof_files = {row["element file id"] for row in partof_parts}
    isa_parents = collections.defaultdict(set)
    isa_names = {}
    for row in isa_rel:
        isa_parents[row["child id"]].add(row["parent id"])
        isa_names[row["parent id"]] = row["parent name"]
        isa_names[row["child id"]] = row["child name"]

    # Read every source mesh once.
    archive_record = next(row for row in manifest["files"] if row["local_path"].endswith("isa_BP3D_4.0_obj_99.zip"))
    elements = {}
    with zipfile.ZipFile(folder / pathlib.Path(archive_record["local_path"]).name) as archive:
        for member in sorted(archive.namelist()):
            if not member.endswith(".obj"):
                continue
            with archive.open(member) as stream:
                headers, vertices, normals, indices = read_geometry(stream)
            file_id = pathlib.PurePosixPath(member).stem
            if headers.get("File ID") != file_id:
                raise ValueError("Source file identity mismatch: " + member)
            box = {"min": [min(v[axis] for v in vertices) for axis in range(3)],
                   "max": [max(v[axis] for v in vertices) for axis in range(3)]}
            elements[file_id] = {"headers": headers, "vertices": vertices, "normals": normals,
                                 "indices": indices, "box": box, "partof": file_id in partof_files}

    # Drop repeated source meshes: near-identical bounds and vertex counts. Keep the
    # PART-OF copy, then a file without the mirrored "M" suffix, then the lower ID.
    rank = lambda fid: (not elements[fid]["partof"], fid.endswith("M"), int(re.sub(r"\D", "", fid)))
    order = sorted(elements, key=rank)
    kept, duplicates = [], {}
    for file_id in order:
        item = elements[file_id]
        for other in kept:
            reference = elements[other]
            count, other_count = len(item["vertices"]), len(reference["vertices"])
            if abs(count - other_count) <= 0.05 * max(count, other_count) and box_overlap(item["box"], reference["box"]) >= 0.97:
                duplicates[file_id] = other
                break
        else:
            kept.append(file_id)

    # Tree: PART-OF chains for PART-OF meshes, IS-A groups for the rest.
    concept_children = collections.defaultdict(list)
    leaf_parent = {}
    used_concepts = set()
    for file_id in kept:
        concept = elements[file_id]["headers"].get("Concept ID", "")
        if elements[file_id]["partof"] and concept in names:
            leaf_parent[file_id] = concept
            node = concept
            while node in parent:
                used_concepts.add(node)
                node = parent[node]
            used_concepts.add(node)
        elif elements[file_id]["partof"]:
            # A PART-OF mesh whose own concept is not a tree node: attach to its smallest owner.
            owners = [row["concept id"] for row in partof_parts if row["element file id"] == file_id and row["concept id"] in names]
            if not owners:
                raise ValueError("PART-OF mesh without a tree concept: " + file_id)
            sizes = collections.Counter(row["concept id"] for row in partof_parts)
            owner = min(owners, key=lambda c: sizes[c])
            leaf_parent[file_id] = owner
            node = owner
            while node in parent:
                used_concepts.add(node)
                node = parent[node]
            used_concepts.add(node)
        else:
            ancestry, frontier = [], [concept]
            seen = set()
            while frontier:
                current = frontier.pop(0)
                for up in sorted(isa_parents.get(current, ())):
                    if up not in seen:
                        seen.add(up)
                        ancestry.append(isa_names.get(up, "").lower())
                        frontier.append(up)
            own = elements[file_id]["headers"].get("English name", "").lower()
            text = " | ".join([own] + ancestry)
            group = next(key for key, _label, words in EXTRA_GROUPS if any(word in text for word in words))
            leaf_parent[file_id] = "extra:" + group
    for concept in used_concepts:
        if concept in parent:
            concept_children[parent[concept]].append(concept)
    for file_id, owner in leaf_parent.items():
        concept_children[owner].append(file_id)

    concept_id_for = {}
    by_name = {names[c].lower(): c for c in used_concepts}
    leaf_by_name = collections.defaultdict(list)
    for file_id in kept:
        leaf_by_name[elements[file_id]["headers"].get("English name", "").lower()].append(file_id)
    for card, concept_name in CARD_CONCEPTS.items():
        concept = by_name.get(concept_name)
        if concept:
            concept_id_for[concept] = card
        elif len(leaf_by_name.get(concept_name, [])) == 1:
            # A single source mesh outside the PART-OF tree, such as the spleen.
            concept_id_for[leaf_by_name[concept_name][0]] = card

    # Top level: body systems first, then the source's regional branches, then the
    # meshes grouped from the IS-A tree, so browsing starts from familiar systems.
    top = concept_children["FMA20394"]
    systems = [c for c in top if re.search(r"system|integument", names.get(c, ""), re.I)]
    regions = [c for c in top if c not in systems]
    concept_children["FMA20394"] = systems + (["group:regions"] if regions else [])
    concept_children["group:regions"] = regions
    concept_children["group:extras"] = []
    structure_id = lambda node: concept_id_for.get(node) or (
        "anatomy.body" if node == "FMA20394" else
        ("source.bodyparts3d-complete.group." + node.split(":", 1)[1] if ":" in node else PREFIX + node))

    # glTF: one node per kept mesh under one container; structures carry the tree.
    binary = bytearray()
    document = {"asset": {"version": "2.0", "generator": "Praxis Corporis complete BodyParts3D body"},
                "scene": 0, "scenes": [{"nodes": [0]}],
                "nodes": [{"name": "CompleteBody", "children": []}],
                "meshes": [], "buffers": [], "bufferViews": [], "accessors": [],
                "materials": [{"name": "Source part", "pbrMetallicRoughness": {"baseColorFactor": [0.8, 0.74, 0.68, 1], "metallicFactor": 0, "roughnessFactor": 0.6}}],
                "extras": {"source_archive_sha256": archive_record["sha256"],
                           "source_units": "OBJ comments explicitly label Bounds(mm)",
                           "conversion": "[x,z,-y] * 0.001; millimetres to glTF metres and Z-up to Y-up; source normals retained",
                           "registration": "No registration to HRA; standalone male body",
                           "duplicates_removed": duplicates}}

    def accessor(values, component_type, kind, minimum=None, maximum=None):
        nonlocal binary
        binary.extend(b"\0" * (-len(binary) % 4))
        start = len(binary)
        flat = [value for row in values for value in row] if kind == "VEC3" else values
        binary.extend(struct.pack("<" + ("f" if component_type == 5126 else "I") * len(flat), *flat))
        view = len(document["bufferViews"])
        document["bufferViews"].append({"buffer": 0, "byteOffset": start, "byteLength": len(binary) - start})
        entry = {"bufferView": view, "componentType": component_type, "count": len(values), "type": kind}
        if minimum is not None:
            entry.update({"min": list(struct.unpack("<3f", struct.pack("<3f", *minimum))),
                          "max": list(struct.unpack("<3f", struct.pack("<3f", *maximum)))})
        document["accessors"].append(entry)
        return len(document["accessors"]) - 1

    node_for = {}
    for file_id in sorted(kept, key=lambda f: int(re.sub(r"\D", "", f))):
        item = elements[file_id]
        vertices = item["vertices"]
        minimum = [min(v[axis] for v in vertices) for axis in range(3)]
        maximum = [max(v[axis] for v in vertices) for axis in range(3)]
        position = accessor(vertices, 5126, "VEC3", minimum, maximum)
        normal = accessor(item["normals"], 5126, "VEC3")
        index = accessor(item["indices"], 5125, "SCALAR")
        mesh = len(document["meshes"])
        document["meshes"].append({"name": file_id, "primitives": [{"attributes": {"POSITION": position, "NORMAL": normal}, "indices": index, "material": 0, "mode": 4}]})
        node = len(document["nodes"])
        document["nodes"].append({"name": file_id, "mesh": mesh, "extras": {"label": item["headers"].get("English name", file_id), "ontologyid": item["headers"].get("Concept ID", "")}})
        document["nodes"][0]["children"].append(node)
        node_for[file_id] = node

    records = []
    def meshes_under(node: str) -> list[int]:
        if node in node_for:
            return [node_for[node]]
        found = []
        for child in concept_children.get(node, ()):
            found.extend(meshes_under(child))
        return sorted(set(found))

    def label_for(node: str) -> str:
        if node in node_for:
            text = elements[node]["headers"].get("English name", node)
        elif node.startswith("extra:"):
            text = next(label for key, label, _ in EXTRA_GROUPS if key == node[6:])
        elif node == "group:regions":
            text = "By region (source groupings)"
        elif node == "group:extras":
            text = "More source parts (muscles, vessels, nerves, teeth)"
        else:
            text = names[node]
        return text[:1].upper() + text[1:]

    def add(node: str, parent_id: str) -> str:
        identity = concept_id_for.get(node) or (structure_id(node) if node not in node_for else PREFIX + node)
        children = sorted(concept_children.get(node, ()), key=lambda c: label_for(c).lower())
        record = {"id": identity, "label": label_for(node),
                  "source_node": node_for.get(node, 0), "source_name": node if node in node_for else ("CompleteBody" if node == "FMA20394" else node),
                  "ontology": (elements[node]["headers"].get("Concept ID", "") if node in node_for else ("" if ":" in node else node)),
                  "mesh_nodes": meshes_under(node), "children": [], "parent": parent_id, "review_status": "draft"}
        records.append(record)
        record["children"] = [add(child, identity) for child in children]
        return identity

    concept_children["group:extras"] = ["extra:" + key for key, _, _ in EXTRA_GROUPS
                                         if any(owner == "extra:" + key for owner in leaf_parent.values())]
    concept_children["FMA20394"].append("group:extras")
    add("FMA20394", "")
    ids = [record["id"] for record in records]
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate structure IDs")
    records = [record for record in records if record["mesh_nodes"]]

    # Scripted checks need a leaf that owns its mesh: the stomach's source mesh.
    by_id = {record["id"]: record for record in records}
    stomach = by_id.get("anatomy.stomach", {})
    qa_leaf = next((child for child in stomach.get("children", []) if by_id[child]["source_node"] in by_id[child]["mesh_nodes"]), "anatomy.stomach")
    document["buffers"] = [{"byteLength": len(binary)}]
    json_bytes = json.dumps(document, separators=(",", ":")).encode()
    json_bytes += b" " * (-len(json_bytes) % 4)
    binary.extend(b"\0" * (-len(binary) % 4))
    glb = struct.pack("<4sII", b"glTF", 2, 28 + len(json_bytes) + len(binary)) + struct.pack("<II", len(json_bytes), 0x4E4F534A) + json_bytes + struct.pack("<II", len(binary), 0x004E4942) + binary
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(glb)
    body = {"id": BODY_ID, "label": "BodyParts3D complete male body · unregistered study",
            "short_label": "Complete male body · BodyParts3D", "study": True, "study_kind": "bodyparts3d-complete",
            "asset_path": output.relative_to(ROOT).as_posix(), "sha256": hashlib.sha256(glb).hexdigest(), "bytes": len(glb),
            "root_id": "anatomy.body", "qa_leaf_id": qa_leaf, "structures": records,
            "coordinates": document["extras"]["conversion"],
            "coverage": f"{len(kept)} source meshes from the official BodyParts3D v4.0 archive ({len(duplicates)} repeated source meshes kept once). Adult male only; no alignment to the HRA bodies."}
    body["coverage_notes"] = {
        "audit_date": "2026-11-21", "source_label": "BodyParts3D v4.0 complete body", "reference_ids": [BODY_ID],
        "notice": "Separate adult male body built from every BodyParts3D v4.0 source mesh. No registration to the HRA references or female anatomy. Imported geometry and names remain unreviewed.",
        "systems": [{"id": "complete", "label": "Source part-of tree and grouped extras", "roots": {BODY_ID: "anatomy.body"},
                     "supplied": {BODY_ID: f"{len(kept)} source meshes: organs, bones, muscles, vessels and nerves."},
                     "gaps": "The source has no thyroid gland, tonsils, parotid glands, breasts or scrotum, and no female anatomy. The archive is the 99% polygon-reduced version. Presence does not establish completeness, interiors or clinical suitability."}]}
    catalogue.parent.mkdir(parents=True, exist_ok=True)
    catalogue.write_text(json.dumps(body, indent=2) + "\n")
    print(f"Complete body: {len(kept)} meshes ({len(duplicates)} duplicates removed), {len(records)} structures, "
          f"{len(concept_id_for)} card-named organs, {len(glb):,} GLB bytes")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=pathlib.Path)
    parser.add_argument("--output", type=pathlib.Path, default=ROOT / "assets/bodyparts3d/complete-body.glb")
    parser.add_argument("--catalogue", type=pathlib.Path, default=ROOT / "content/bodyparts3d_complete_body.json")
    args = parser.parse_args()
    build(args.folder, args.output.resolve(), args.catalogue.resolve())
