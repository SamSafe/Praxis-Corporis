"""Inventory the official BodyParts3D archive without integrating it into an atlas.

Reads archive members in place. The legacy OBJ licence comments are kept as evidence
alongside the current official grant; this is a technical audit, not legal/medical review.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import math
import pathlib
import re
import zipfile


def obj_inventory(stream) -> dict:
    positions = []
    triangles = 0
    headers = {}
    face_indices = []
    for raw in stream:
        line = raw.decode("utf-8").strip() if isinstance(raw, bytes) else raw.strip()
        if line.startswith("#"):
            match = re.match(r"#\s*(File ID|Representation ID|Concept ID|English name|Bounds\(mm\))\s*:\s*(.*)", line)
            if match:
                headers[match[1]] = match[2]
            if "license for this database" in line:
                headers["license_comment"] = line.removeprefix("#").strip()
        elif line.startswith("v "):
            components = line.split()[1:]
            if len(components) != 3:
                raise ValueError("Expected three OBJ vertex coordinates")
            point = tuple(float(value) for value in components)
            if not all(math.isfinite(value) for value in point):
                raise ValueError("Non-finite OBJ coordinate")
            positions.append(point)
        elif line.startswith("f "):
            values = line.split()[1:]
            if len(values) < 3:
                raise ValueError("Invalid OBJ face")
            resolved = []
            for value in values:
                index = int(value.split("/")[0])
                if index == 0:
                    raise ValueError("OBJ indices are one-based")
                resolved.append(index - 1 if index > 0 else len(positions) + index)
            face_indices.extend(resolved)
            triangles += len(values) - 2
    if not positions or not triangles:
        raise ValueError("OBJ has no triangle geometry")
    if any(index < 0 or index >= len(positions) for index in face_indices):
        raise ValueError("OBJ face refers outside its vertex array")
    return {"headers": headers, "vertices": len(positions), "triangles": triangles,
            "minimum_mm": [min(point[axis] for point in positions) for axis in range(3)],
            "maximum_mm": [max(point[axis] for point in positions) for axis in range(3)]}


def audit(folder: pathlib.Path) -> dict:
    rows = list(csv.DictReader((folder / "isa_element_parts.txt").open(), delimiter="\t"))
    concepts = {}
    for row in rows:
        concepts.setdefault(row["concept id"], {"label": row["name"], "elements": set()})["elements"].add(row["element file id"])
    chosen = ["FMA5018", "FMA7574", "FMA9914", "FMA52734", "FMA23130", "FMA23131", "FMA24474", "FMA24475", "FMA65132", "FMA5022"]
    archive_path = folder / "isa_BP3D_4.0_obj_99.zip"
    result = {"audit_date": "2026-10-12", "source": "BodyParts3D, official LSDB archive",
              "dataset_version": "4.0", "reduction_label": "99% polygon reduction (source label)",
              "reference": "Adult male, separate from both HRA references",
              "review_status": "technical_inventory",
              "archive": {"bytes": archive_path.stat().st_size,
                          "sha256": hashlib.sha256(archive_path.read_bytes()).hexdigest()},
              "current_official_license": "CC BY 4.0, official licence page/README updated 2025",
              "legacy_header_license": "CC BY-SA 2.1 Japan, retained in the downloaded OBJ comments",
              "license_evidence_note": "Both records must be retained. No app integration or public distribution is established by this audit.",
              "units_evidence": "Inspected OBJ comments explicitly label Bounds(mm). Raw positions are inventoried without registration.",
              "concepts": {}, "meshes": {}}
    with zipfile.ZipFile(archive_path) as archive:
        if archive.testzip() is not None:
            raise ValueError("Archive CRC failure")
        names = {pathlib.PurePosixPath(name).stem: name for name in archive.namelist() if name.endswith(".obj")}
        if len(names) != len(archive.namelist()):
            raise ValueError("Expected unique OBJ-only archive members")
        result["obj_files"] = len(names)
        needed = set()
        for concept in chosen:
            data = concepts[concept]
            present = data["elements"] & names.keys()
            result["concepts"][concept] = {"label": data["label"], "declared_elements": len(data["elements"]),
                                           "present_elements": len(present), "elements": sorted(present)}
            needed.update(present)
        for element in sorted(needed):
            with archive.open(names[element]) as source:
                result["meshes"][element] = obj_inventory(source)
    result["inspected_meshes"] = len(result["meshes"])
    bone_meshes = [result["meshes"][element] for element in result["concepts"]["FMA5018"]["elements"]]
    result["bone_organ_group"] = {
        "source_meshes": len(bone_meshes), "triangles": sum(mesh["triangles"] for mesh in bone_meshes),
        "minimum_mm": [min(mesh["minimum_mm"][axis] for mesh in bone_meshes) for axis in range(3)],
        "maximum_mm": [max(mesh["maximum_mm"][axis] for mesh in bone_meshes) for axis in range(3)],
        "scope": "Source bone-organ membership, not a validated complete skeleton or a count of distinct reviewed bones."}
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=pathlib.Path)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    args = parser.parse_args()
    result = audit(args.folder)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Audited {result['obj_files']} OBJ files; inspected {result['inspected_meshes']} meshes; bone group {result['bone_organ_group']['source_meshes']} source meshes.")
