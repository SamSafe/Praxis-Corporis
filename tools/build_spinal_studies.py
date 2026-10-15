"""Admit pinned spinal files as separate private source studies, without registration."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from glb_inventory import descendants, inventory, read_glb

ROOT = Path(__file__).resolve().parents[1]


def build(record: dict, root: Path = ROOT) -> dict:
    path = root / record["local_path"]
    if not path.resolve().is_relative_to(root.resolve()):
        raise ValueError("Study source must stay inside the project")
    if path.stat().st_size != record["bytes"] or hashlib.sha256(path.read_bytes()).hexdigest() != record["sha256"]:
        raise ValueError("Spinal study differs from its pinned source")
    document = read_glb(path)
    roots = document["scenes"][document.get("scene", 0)]["nodes"]
    if len(roots) != 1 or any(any(key in node for key in ["matrix", "translation", "rotation", "scale"]) for node in document["nodes"]):
        raise ValueError("Spinal studies require the audited untransformed source frame")
    source_root = roots[0]
    audit = inventory(path, document["nodes"][source_root]["name"])
    sex = "female" if "VH_F_" in path.name else "male"
    region = "cord" if "Spinal_Cord" in path.name else "vertebrae"
    reference_id = f"hra-v1-2-{sex}-{region}-study"
    title = f"{sex.capitalize()} {'spinal cord' if region == 'cord' else 'vertebrae'} · HRA source study"
    indices = descendants(document, source_root)
    ids = {index: ("anatomy.body" if index == source_root else f"source.{reference_id}.n{index}") for index in indices}
    parents = {child: index for index in indices for child in document["nodes"][index].get("children", [])}
    structures = []
    for index in indices:
        node = document["nodes"][index]
        metadata = node.get("extras", {})
        label = metadata.get("label", "")
        gap = index != source_root and (label in ["", "-", None] or metadata.get("ontologyid") in ["", "-", None])
        if index == source_root:
            label = title
        elif label in ["", "-", None]:
            label = "Unlabelled source: " + node.get("name", str(index))
        structures.append({"id": ids[index], "label": str(label).replace("\n", " "),
                           "source_node": index, "source_name": node.get("name", ""),
                           "ontology": metadata.get("ontologyid", ""),
                           "source_label": metadata.get("label", ""), "metadata_gap": gap,
                           "mesh_nodes": [i for i in descendants(document, index) if "mesh" in document["nodes"][i]],
                           "children": [ids[i] for i in node.get("children", [])],
                           "parent": ids.get(parents.get(index), ""), "review_status": "draft"})
    leaves = [s for s in structures if s["mesh_nodes"] == [s["source_node"]]]
    gap_notice = " Female source VH_F_lumbar_vertebra_6 has no supplied label/ontology; its interpretation is unresolved." if any(s["metadata_gap"] for s in leaves) else ""
    coverage = f"Separate pinned v1.2 {sex} {region} source geometry; {audit['anatomy_mesh_nodes']} meshes. No registration to the HRA United bodies or other studies. Anatomical completeness and medical review pending." + gap_notice
    short_label = f"{sex.capitalize()} {'cord' if region == 'cord' else 'vertebrae'} · HRA study"
    return {"id": reference_id, "label": title, "short_label": short_label, "study": True,
            "study_kind": "hra-spinal", "asset_path": record["local_path"], "sha256": record["sha256"],
            "bytes": record["bytes"], "root_id": "anatomy.body", "inspection_root": "anatomy.body", "picking_scale": 100.0,
            "qa_leaf_id": leaves[0]["id"], "structures": structures,
            "coordinates": "Untouched source glTF metre/Y-up coordinates. No fitting, warping, relabelling or body registration.",
            "source_url": record["url"], "coverage": coverage,
            "coverage_notes": {"notice": coverage, "audit_date": "2026-10-15", "reference_ids": [reference_id],
                               "source_label": "HRA separate v1.2 source file", "systems": [
                                   {"label": "Supplied spinal source geometry", "roots": {reference_id: "anatomy.body"},
                                    "supplied": {reference_id: f"{audit['anatomy_mesh_nodes']} unchanged source meshes, {audit['anatomy_triangles']} triangles."},
                                    "gaps": "This isolated source study does not complete a whole-body skeleton, establish registration, or supply reviewed neural connections." + gap_notice}]}}


def main() -> None:
    manifest = json.loads((ROOT / "content/spinal_source_manifest.json").read_text())
    studies = [build(record) for record in manifest["files"]]
    (ROOT / "content/spinal_studies.json").write_text(json.dumps({"schema_version": 1, "source_commit": manifest["source_commit"], "bodies": studies}, indent=2) + "\n")
    for study in studies:
        print(study["label"], "·", len(study["structures"]) - 1, "source records")


if __name__ == "__main__":
    main()
