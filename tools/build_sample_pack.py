"""Generate a draft source catalogue, preserving source indices and explicit shared IDs."""

from __future__ import annotations

import json
import pathlib
import re

from glb_inventory import descendants, inventory, read_glb

ROOT = pathlib.Path(__file__).resolve().parents[1]

# These correspondences are explicit, limited to identified source nodes. Other
# source IDs are body-specific until their canonical anatomical mapping is reviewed.
SHARED = {
    "skin": ("anatomy.skin", "Skin of body"),
    "heart": ("anatomy.heart", "Heart"),
    "lungs": ("anatomy.lungs", "Lungs"),
    "lungs_L": ("anatomy.lung.left", "Left lung"),
    "left_lungs_L": ("anatomy.lung.left", "Left lung"),
    "lungs_R": ("anatomy.lung.right", "Right lung"),
    "left_cardiac_atrium": ("anatomy.heart.atrium.left", "Left cardiac atrium"),
    "right_cardiac_atrium": ("anatomy.heart.atrium.right", "Right cardiac atrium"),
    "mitral_valve": ("anatomy.heart.valve.mitral", "Mitral valve"),
    "tricuspid_valve": ("anatomy.heart.valve.tricuspid", "Tricuspid valve"),
    "aortic_valve": ("anatomy.heart.valve.aortic", "Aortic valve"),
    "pulmonary_valve": ("anatomy.heart.valve.pulmonary", "Pulmonary valve"),
    "heart_valve": ("anatomy.heart.valves", "Heart valves"),
    "valve": ("anatomy.heart.valves", "Heart valves"),
    "cardiac_chamber": ("anatomy.heart.chambers", "Cardiac chambers"),
    "heart_left_ventricle": ("anatomy.heart.ventricle.left", "Left ventricle"),
    "left_ventricle": ("anatomy.heart.ventricle.left", "Left ventricle"),
    "heart_right_ventricle": ("anatomy.heart.ventricle.right", "Right ventricle"),
    "right_ventricle": ("anatomy.heart.ventricle.right", "Right ventricle"),
    "interventricular_septum": ("anatomy.heart.septum", "Interventricular septum"),
    "papillary_muscle_of_heart": ("anatomy.heart.papillary-muscles", "Papillary muscles"),
    "circulatory_system": ("anatomy.system.circulatory", "Circulatory system"),
    "integumentary_system": ("anatomy.system.integumentary", "Skin / integumentary system"),
    "nervous_system": ("anatomy.system.nervous", "Nervous system"),
    "muscular_system": ("anatomy.system.muscular", "Muscular system"),
    "skeletal_system": ("anatomy.system.skeletal", "Skeletal system"),
    "respiratory_system": ("anatomy.system.respiratory", "Respiratory system"),
    "digestive_system": ("anatomy.system.digestive", "Digestive system"),
    "urinary_system": ("anatomy.system.urinary", "Urinary system"),
    "lymphatic_system": ("anatomy.system.lymphatic", "Lymphatic system"),
}


def source_label(node: dict) -> str:
    label = str(node.get("extras", {}).get("label") or "").strip()
    # Some source nodes carry a literal "-" placeholder instead of a label.
    if label and label != "-":
        return label.replace("\n", " ").capitalize()
    # Cosmetic fallback only; no ontology or medical correspondence is inferred.
    name = re.sub(r"^(VH_[MF]|Allen|Yao)_", "", node.get("name", "Unnamed source node"))
    name = name.replace("_HTH", "_hypothalamus")
    side = re.search(r"_([LR])$", name)
    if side:
        name = name[:-2] + (", left" if side.group(1) == "L" else ", right")
    return name.replace("_", " ").strip().capitalize()


def build_body(record: dict) -> tuple[dict, dict]:
    # A supplemented body is the United file plus later HRA organs appended after its
    # own nodes (tools/build_hra_supplements.py); United node indices are unchanged.
    path = ROOT / record.get("supplemented_path", record["local_path"])
    document = read_glb(path)
    audit = inventory(path, record["anatomy_root"])
    indices = descendants(document, audit["anatomy_root"])
    parents = {}
    for index in indices:
        for child in document["nodes"][index].get("children", []):
            parents[child] = index
    records = []
    ids = {}
    prefix = "VH_M_" if record["body_id"] == "male" else "VH_F_"
    for index in indices:
        node = document["nodes"][index]
        name = node.get("name", "")
        suffix = name.removeprefix(prefix)
        concept, label = SHARED.get(suffix, (
            f"source.hra-v1-1.{record['body_id']}.n{index}", source_label(node)))
        if index == audit["anatomy_root"]:
            concept, label = "anatomy.body", "Body"
        if concept in ids.values():
            raise ValueError(f"Duplicate correspondence: {concept}")
        ids[index] = concept
        members = descendants(document, index)
        mesh_indices = [i for i in members if "mesh" in document["nodes"][i]]
        records.append({
            "id": concept,
            "label": label,
            "source_node": index,
            "source_name": name,
            "ontology": node.get("extras", {}).get("ontologyid", ""),
            "mesh_nodes": mesh_indices,
            "children": node.get("children", []),
            "parent": parents.get(index),
            "review_status": "draft",
        })
    for node in records:
        node["children"] = [ids[i] for i in node["children"]]
        node["parent"] = ids.get(node["parent"], "")
    return {
        "id": record["body_id"],
        "label": record["label"],
        "asset_path": record.get("supplemented_path", record["local_path"]),
        "sha256": record.get("supplemented_sha256", record["sha256"]),
        "bytes": record.get("supplemented_bytes", record["bytes"]),
        "root_id": "anatomy.body",
        "structures": records,
        "coordinates": "Original glTF metre coordinates and Y-up axes; no registration or scaling applied.",
        "coverage": "Partial atlas. Skeleton, muscles and peripheral nerves cover selected regions.",
    }, audit


def main() -> None:
    manifest = json.loads((ROOT / "content/source_manifest.json").read_text(encoding="utf-8"))
    bodies = []
    audits = {}
    for record in manifest["files"]:
        if "body_id" in record:
            body, audit = build_body(record)
            if audit["sha256"] != record.get("supplemented_sha256", record["sha256"]):
                raise ValueError("Source hash differs from the pinned manifest")
            bodies.append(body)
            audits[body["id"]] = audit
    outputs = {
        "content/sample_pack.json": {
            "schema_version": 1,
            "id": "hra-united-v1-1-prototype-1",
            "source_commit": manifest["source_commit"],
            "review_status": "draft",
            "bodies": bodies,
        },
        "docs/audit/hra-v1-1-inventory.json": audits,
    }
    for name, data in outputs.items():
        path = ROOT / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="\n")
        print(name)


if __name__ == "__main__":
    main()
