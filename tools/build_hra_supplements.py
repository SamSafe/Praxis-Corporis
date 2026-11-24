"""Append later HRA reference organs to the United v1.1 bodies.

The HRA 3D Reference Object Library publishes some organs only after United v1.1:
mammary glands (v1.3), palatine tonsils (v1.4), and the spinal cord and vertebrae
(v1.2). They share the United bodies' coordinate frame (checked against shared
landmarks; see docs/audit/HRA_SUPPLEMENTS.md). This tool appends their nodes, meshes,
materials and buffer data after the United body's own, so every existing node index,
and so every catalogue ID, stays the same. Source files are unchanged; the
supplemented body is a derived file.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import struct

from glb_inventory import read_glb

ROOT = pathlib.Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "content/hra_supplements_manifest.json"


def chunks(path: pathlib.Path) -> tuple[dict, bytes]:
    data = path.read_bytes()
    document = read_glb(path)
    offset, binary = 12, b""
    while offset < len(data):
        size, kind = struct.unpack_from("<II", data, offset)
        offset += 8
        if kind == 0x004E4942:
            binary = data[offset:offset + size]
        offset += size
    return document, binary


def verified(path: pathlib.Path, record: dict) -> None:
    payload = path.read_bytes()
    if len(payload) != record["bytes"] or hashlib.sha256(payload).hexdigest() != record["sha256"]:
        raise ValueError("Pinned file differs from the manifest: " + record["local_path"])


def append(base: dict, binary: bytearray, document: dict, extra: bytes) -> list[int]:
    """Append one supplement GLB to base; return its scene root node indices."""
    if len(document.get("buffers", [])) != 1 or any(key in document for key in ("images", "textures", "samplers", "skins", "animations")):
        raise ValueError("Supplements must be single-buffer, untextured static meshes")
    binary.extend(b"\0" * (-len(binary) % 4))
    shift = {key: len(base.get(key, [])) for key in ("bufferViews", "accessors", "meshes", "materials", "nodes")}
    start = len(binary)
    binary.extend(extra)
    for view in document.get("bufferViews", []):
        view = dict(view, buffer=0, byteOffset=view.get("byteOffset", 0) + start)
        base.setdefault("bufferViews", []).append(view)
    for accessor in document.get("accessors", []):
        accessor = dict(accessor)
        if "bufferView" in accessor:
            accessor["bufferView"] += shift["bufferViews"]
        if "sparse" in accessor:
            raise ValueError("Sparse accessors are unsupported")
        base.setdefault("accessors", []).append(accessor)
    base.setdefault("materials", []).extend(document.get("materials", []))
    for mesh in document.get("meshes", []):
        mesh = json.loads(json.dumps(mesh))
        for primitive in mesh["primitives"]:
            primitive["attributes"] = {name: index + shift["accessors"] for name, index in primitive["attributes"].items()}
            if "indices" in primitive:
                primitive["indices"] += shift["accessors"]
            if "material" in primitive:
                primitive["material"] += shift["materials"]
            if "targets" in primitive:
                raise ValueError("Morph targets are unsupported")
        base["meshes"].append(mesh)
    for node in document["nodes"]:
        node = json.loads(json.dumps(node))
        if "mesh" in node:
            node["mesh"] += shift["meshes"]
        if "children" in node:
            node["children"] = [child + shift["nodes"] for child in node["children"]]
        base["nodes"].append(node)
    return [root + shift["nodes"] for root in document["scenes"][document.get("scene", 0)]["nodes"]]


def build(body_id: str, anatomy_root: str) -> pathlib.Path:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    target = next(row for row in manifest["bodies"] if row["body_id"] == body_id)
    source = json.loads((ROOT / "content/source_manifest.json").read_text(encoding="utf-8"))
    united = next(row for row in source["files"] if row.get("body_id") == body_id)
    verified(ROOT / united["local_path"], united)
    base, base_binary = chunks(ROOT / united["local_path"])
    binary = bytearray(base_binary)
    root_index = next(i for i, node in enumerate(base["nodes"]) if node.get("name") == anatomy_root)
    for group in target["groups"]:
        roots = []
        for record in group["files"]:
            path = ROOT / record["local_path"]
            verified(path, record)
            document, extra = chunks(path)
            roots += append(base, binary, document, extra)
        if group.get("node_name"):
            base["nodes"].append({"name": group["node_name"], "children": roots,
                                  "extras": {"label": group["label"], "supplement_source": group["source"]}})
            roots = [len(base["nodes"]) - 1]
        base["nodes"][root_index].setdefault("children", []).extend(roots)
    binary.extend(b"\0" * (-len(binary) % 4))
    base["buffers"] = [{"byteLength": len(binary)}]
    base.setdefault("extras", {})["supplements"] = {"base_sha256": united["sha256"],
        "files": [record["local_path"].rsplit("/", 1)[1] for group in target["groups"] for record in group["files"]]}
    payload = json.dumps(base, separators=(",", ":")).encode()
    payload += b" " * (-len(payload) % 4)
    glb = (struct.pack("<4sII", b"glTF", 2, 28 + len(payload) + len(binary))
           + struct.pack("<II", len(payload), 0x4E4F534A) + payload
           + struct.pack("<II", len(binary), 0x004E4942) + bytes(binary))
    output = ROOT / target["output"]
    output.write_bytes(glb)
    print(f"{target['output']}: {len(base['nodes'])} nodes, {len(glb):,} bytes, sha256 {hashlib.sha256(glb).hexdigest()}")
    return output


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--body", choices=["female", "male"], action="append")
    args = parser.parse_args()
    roots = {"female": "VH_F", "male": "VH_M"}
    for body in args.body or ["female", "male"]:
        build(body, roots[body])
