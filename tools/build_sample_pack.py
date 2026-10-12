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
}


def source_label(node: dict) -> str:
    label = node.get("extras", {}).get("label")
    if label:
        return str(label).strip().replace("\n", " ").capitalize()
    # Cosmetic fallback only; no ontology or medical correspondence is inferred.
    name = re.sub(r"^VH_[MF]_", "", node.get("name", "Unnamed source node"))
    return name.replace("_", " ").strip().capitalize()


def build_body(record: dict) -> tuple[dict, dict]:
    path = ROOT / record["local_path"]
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
        "asset_path": record["local_path"],
        "sha256": record["sha256"],
        "bytes": record["bytes"],
        "root_id": "anatomy.body",
        "structures": records,
        "coordinates": "Original glTF metre coordinates and Y-up axes; no registration or scaling applied.",
        "coverage": "Partial atlas. Skeleton, muscles and peripheral nerves cover selected regions.",
    }, audit


def main() -> None:
    manifest = json.loads((ROOT / "content/source_manifest.json").read_text())
    bodies = []
    audits = {}
    for record in manifest["files"]:
        if "body_id" in record:
            body, audit = build_body(record)
            if audit["sha256"] != record["sha256"]:
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
        path.write_text(json.dumps(data, indent=2) + "\n")
        print(name)


if __name__ == "__main__":
    main()
