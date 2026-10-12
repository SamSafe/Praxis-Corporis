"""Inventory hash-pinned HRA spinal candidates; does not register or admit anatomy."""

import argparse
import hashlib
import json
import math
from pathlib import Path

from glb_inventory import inventory, read_glb


def audit(folder: Path, downloads: dict) -> dict:
    records = []
    for source in downloads["records"]:
        path = folder / Path(source["source_path"]).name
        data = path.read_bytes()
        if len(data) != source["bytes"] or hashlib.sha256(data).hexdigest() != source["sha256"]:
            raise ValueError(f"Candidate differs from verified download: {path.name}")
        document = read_glb(path)
        roots = document["scenes"][document.get("scene", 0)]["nodes"]
        if len(roots) != 1:
            raise ValueError("Expected one source spinal root")
        root = roots[0]
        if any(any(key in node for key in ["matrix", "translation", "rotation", "scale"]) for node in document["nodes"]):
            raise ValueError("Transformed nodes require an explicit world-coordinate audit")
        minimums, maximums, structures = [], [], []
        for index, node in enumerate(document["nodes"]):
            if "mesh" not in node:
                continue
            for primitive in document["meshes"][node["mesh"]]["primitives"]:
                accessor = document["accessors"][primitive["attributes"]["POSITION"]]
                low, high = accessor["min"], accessor["max"]
                if len(low) != 3 or len(high) != 3 or any(not math.isfinite(v) for v in low + high) or any(a > b for a, b in zip(low, high)):
                    raise ValueError("Invalid declared position bounds")
                minimums.append(low)
                maximums.append(high)
            metadata = node.get("extras", {})
            structures.append({"source_node": index, "source_name": node.get("name"),
                               "source_label": metadata.get("label"), "ontologyid": metadata.get("ontologyid"),
                               "representation_of": metadata.get("representation_of"),
                               "source_spatial_entity": metadata.get("source_spatial_entity")})
        record = dict(source)
        record.update(inventory(path, document["nodes"][root]["name"]))
        record["root_name"] = document["nodes"][root]["name"]
        record["declared_position_bounds"] = {
            "min": [min(v[i] for v in minimums) for i in range(3)],
            "max": [max(v[i] for v in maximums) for i in range(3)],
            "scope": "Accessor declarations; no node transforms. Not a clinical registration or interior validation.",
        }
        record["structures"] = structures
        record["metadata_gaps"] = [entry for entry in structures if entry["source_label"] in [None, "", "-"] or entry["ontologyid"] in [None, "", "-"]]
        records.append(record)
    return {"audit_date": "2026-10-12", "source_commit": downloads["source_commit"],
            "status": "Technical candidate inventory only; not installed in the viewer or qualified medical review.",
            "records": records}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--downloads", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.folder, json.loads(args.downloads.read_text()))
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    for record in report["records"]:
        print(f"{record['root_name']}: {record['anatomy_mesh_nodes']} source meshes, {record['anatomy_triangles']} triangles, {len(record['metadata_gaps'])} metadata gaps")


if __name__ == "__main__":
    main()
