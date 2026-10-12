"""Prepare an unregistered BodyParts3D bone study, separate from the HRA references."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import pathlib
import re
import struct
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]


def index_value(text: str, count: int) -> int:
    value = int(text)
    resolved = value - 1 if value > 0 else count + value
    if value == 0 or not 0 <= resolved < count:
        raise ValueError("OBJ index outside its declared array")
    return resolved


def read_geometry(stream) -> tuple[dict, list, list, list]:
    positions, normals, faces, headers = [], [], [], {}
    for raw in stream:
        line = raw.decode().strip()
        match = re.match(r"#\s*(File ID|Concept ID|English name|Bounds\(mm\))\s*:\s*(.*)", line)
        if match:
            headers[match[1]] = match[2]
        if line.startswith(("v ", "vn ")):
            values = line.split()
            vector = tuple(float(value) for value in values[1:])
            if len(vector) != 3 or not all(math.isfinite(value) for value in vector):
                raise ValueError("Invalid OBJ vector")
            (positions if values[0] == "v" else normals).append(vector)
        elif line.startswith("f "):
            values = line.split()[1:]
            if len(values) != 3:
                raise ValueError("Study conversion requires original triangular faces")
            corners = []
            for value in values:
                parts = value.split("/")
                point_index = index_value(parts[0], len(positions))
                normal_index = index_value(parts[2], len(normals)) if len(parts) == 3 and parts[2] else -1
                corners.append((point_index, normal_index))
            faces.append(corners)
    if not faces or "Bounds(mm)" not in headers:
        raise ValueError("Source lacks triangle geometry or explicit millimetre evidence")
    vertices, output_normals, indices, lookup = [], [], [], {}
    for face in faces:
        if any(corner[1] < 0 for corner in face):
            raise ValueError("Source normals must be present; do not invent a smoothing convention")
        for key in face:
            if key not in lookup:
                lookup[key] = len(vertices)
                x, y, z = positions[key[0]]
                vertices.append((x * 0.001, z * 0.001, -y * 0.001))
                x, y, z = normals[key[1]]
                length = math.sqrt(x*x + y*y + z*z)
                if length == 0:
                    raise ValueError("Zero source normal")
                output_normals.append((x / length, z / length, -y / length))
            indices.append(lookup[key])
    return headers, vertices, output_normals, indices


def build(folder: pathlib.Path, output: pathlib.Path, catalogue: pathlib.Path) -> None:
    manifest = json.loads((ROOT / "content/bodyparts3d_source_manifest.json").read_text())
    for record in manifest["files"]:
        if record["local_path"].endswith((".zip", "isa_element_parts.txt")):
            path = folder / pathlib.Path(record["local_path"]).name
            if path.stat().st_size != record["bytes"] or hashlib.sha256(path.read_bytes()).hexdigest() != record["sha256"]:
                raise ValueError("Source input differs from the pinned audit: " + path.name)
    archive_record = next(row for row in manifest["files"] if row["local_path"].endswith(".zip"))
    archive_path = folder / pathlib.Path(archive_record["local_path"]).name
    if hashlib.sha256(archive_path.read_bytes()).hexdigest() != archive_record["sha256"]:
        raise ValueError("Archive differs from the pinned audit")
    elements = sorted({row["element file id"] for row in csv.DictReader((folder / "isa_element_parts.txt").open(), delimiter="\t") if row["concept id"] == "FMA5018"})
    if len(elements) != 203:
        raise ValueError("Bone-organ membership differs from the audited source")
    binary = bytearray()
    document = {"asset": {"version": "2.0", "generator": "Praxis Corporis unregistered bone study"},
                "scene": 0, "scenes": [{"nodes": [0]}],
                "nodes": [{"name": "BoneStudyBody", "children": [1]}, {"name": "BoneOrgans", "children": []}],
                "meshes": [], "buffers": [], "bufferViews": [], "accessors": [],
                "materials": [{"name": "Study bone colour", "pbrMetallicRoughness": {"baseColorFactor": [0.88, 0.85, 0.78, 1], "metallicFactor": 0, "roughnessFactor": 0.75}}],
                "extras": {"source_archive_sha256": archive_record["sha256"],
                           "source_units": "OBJ comments explicitly label Bounds(mm)",
                           "conversion": "[x,z,-y] * 0.001; millimetres to glTF metres and Z-up to Y-up; source normals retained",
                           "registration": "No registration to HRA; standalone male study",
                           "current_license_url": manifest["license_url"],
                           "legacy_obj_notice": manifest["legacy_obj_comments"]}}
    records = []

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
            # Accessor bounds describe the actual stored float32 values.
            entry.update({"min": list(struct.unpack("<3f", struct.pack("<3f", *minimum))),
                          "max": list(struct.unpack("<3f", struct.pack("<3f", *maximum)))})
        document["accessors"].append(entry)
        return len(document["accessors"]) - 1

    with zipfile.ZipFile(archive_path) as archive:
        names = {pathlib.PurePosixPath(name).stem: name for name in archive.namelist()}
        for element in elements:
            with archive.open(names[element]) as stream:
                headers, vertices, normals, indices = read_geometry(stream)
            if headers["File ID"] != element:
                raise ValueError("Source file identity mismatch")
            minimum = [min(row[axis] for row in vertices) for axis in range(3)]
            maximum = [max(row[axis] for row in vertices) for axis in range(3)]
            position_accessor = accessor(vertices, 5126, "VEC3", minimum, maximum)
            normal_accessor = accessor(normals, 5126, "VEC3")
            index_accessor = accessor(indices, 5125, "SCALAR")
            mesh_index = len(document["meshes"])
            document["meshes"].append({"name": element, "primitives": [{"attributes": {"POSITION": position_accessor, "NORMAL": normal_accessor}, "indices": index_accessor, "material": 0, "mode": 4}]})
            source_index = len(document["nodes"])
            label = headers["English name"]
            document["nodes"].append({"name": element, "mesh": mesh_index, "extras": {"label": label, "ontologyid": headers["Concept ID"]}})
            document["nodes"][1]["children"].append(source_index)
            records.append({"id": "source.bodyparts3d-v4-male." + element, "label": label,
                            "source_node": source_index, "source_name": element, "ontology": headers["Concept ID"],
                            "mesh_nodes": [source_index], "children": [], "parent": "anatomy.system.skeletal", "review_status": "draft"})
    document["buffers"] = [{"byteLength": len(binary)}]
    json_bytes = json.dumps(document, separators=(",", ":")).encode()
    json_bytes += b" " * (-len(json_bytes) % 4)
    binary.extend(b"\0" * (-len(binary) % 4))
    glb = struct.pack("<4sII", b"glTF", 2, 28 + len(json_bytes) + len(binary)) + struct.pack("<II", len(json_bytes), 0x4E4F534A) + json_bytes + struct.pack("<II", len(binary), 0x004E4942) + binary
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(glb)
    indices = [record["source_node"] for record in records]
    root = {"id": "anatomy.body", "label": "BodyParts3D male bone study", "source_node": 0, "source_name": "BoneStudyBody", "ontology": "", "mesh_nodes": indices, "children": ["anatomy.system.skeletal"], "parent": "", "review_status": "draft"}
    skeleton = {"id": "anatomy.system.skeletal", "label": "Bone-organ source group (study)", "source_node": 1, "source_name": "BoneOrgans", "ontology": "FMA5018", "mesh_nodes": indices, "children": [record["id"] for record in records], "parent": "anatomy.body", "review_status": "draft"}
    body = {"id": "bodyparts-male-bones-study", "label": "BodyParts3D male bones · unregistered study",
            "short_label": "Male bones · BodyParts3D study", "study": True,
            "asset_path": output.relative_to(ROOT).as_posix(), "sha256": hashlib.sha256(glb).hexdigest(), "bytes": len(glb),
            "root_id": "anatomy.body", "structures": [root, skeleton, *records],
            "coordinates": document["extras"]["conversion"],
            "coverage": "203 source bone meshes, not a reviewed complete skeleton. No alignment to HRA or female geometry."}
    body["coverage_notes"] = {"audit_date": "2026-10-12", "source_label": "BodyParts3D v4.0 bone study", "reference_ids": [body["id"]],
                              "notice": "Separate adult male bone study. No registration to the HRA references or female anatomy. Imported geometry and names remain unreviewed.",
                              "systems": [{"id": "skeletal", "label": "Source bone-organ group", "roots": {body["id"]: "anatomy.system.skeletal"},
                                           "supplied": {body["id"]: "203 source bone meshes from the official BodyParts3D v4.0 archive."},
                                           "gaps": "Only the source bone-organ membership is included. This does not establish a complete reviewed skeleton, soft tissue, interiors, disease views, or alignment to another reference body."}]}
    catalogue.parent.mkdir(parents=True, exist_ok=True)
    catalogue.write_text(json.dumps(body, indent=2) + "\n")
    print(f"Prepared separate bone study: {len(records)} meshes, {len(glb):,} GLB bytes")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=pathlib.Path)
    parser.add_argument("--output", type=pathlib.Path, default=ROOT / "assets/bodyparts3d/bone-study.glb")
    parser.add_argument("--catalogue", type=pathlib.Path, default=ROOT / "content/bodyparts3d_bone_study.json")
    args = parser.parse_args()
    build(args.folder, args.output.resolve(), args.catalogue.resolve())
