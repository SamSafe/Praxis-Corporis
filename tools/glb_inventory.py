"""Inspect the pinned glTF 2.0 samples without third-party Python dependencies."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import struct


def read_glb(path: pathlib.Path) -> dict:
    data = path.read_bytes()
    if len(data) < 20:
        raise ValueError(f"{path}: truncated GLB")
    magic, version, length = struct.unpack_from("<4sII", data)
    if magic != b"glTF" or version != 2 or length != len(data):
        raise ValueError(f"{path}: invalid GLB header or length")
    offset = 12
    document = None
    while offset < length:
        if offset + 8 > length:
            raise ValueError(f"{path}: truncated chunk header")
        size, kind = struct.unpack_from("<II", data, offset)
        offset += 8
        if size % 4 or offset + size > length:
            raise ValueError(f"{path}: invalid chunk size")
        if document is None:
            if kind != 0x4E4F534A:
                raise ValueError(f"{path}: JSON must be the first chunk")
            document = json.loads(data[offset : offset + size])
        offset += size
    if not isinstance(document, dict) or document.get("asset", {}).get("version") != "2.0":
        raise ValueError(f"{path}: expected glTF 2.0")
    if any("uri" in buffer for buffer in document.get("buffers", [])):
        raise ValueError(f"{path}: external buffers are unsupported in this sample pack")
    return document


def descendants(document: dict, root: int) -> list[int]:
    nodes = document["nodes"]
    pending = [root]
    result = []
    seen = set()
    while pending:
        index = pending.pop()
        if index in seen or not 0 <= index < len(nodes):
            raise ValueError("Invalid, cyclic, or multiply parented node hierarchy")
        seen.add(index)
        result.append(index)
        pending.extend(reversed(nodes[index].get("children", [])))
    return result


def node_triangles(document: dict, index: int) -> int:
    node = document["nodes"][index]
    if "mesh" not in node:
        return 0
    total = 0
    for primitive in document["meshes"][node["mesh"]]["primitives"]:
        if primitive.get("mode", 4) != 4:
            raise ValueError("Sample renderer expects triangle primitives")
        accessor = primitive.get("indices", primitive["attributes"]["POSITION"])
        total += document["accessors"][accessor]["count"] // 3
    return total


def inventory(path: pathlib.Path, root_name: str) -> dict:
    document = read_glb(path)
    matches = [i for i, node in enumerate(document["nodes"]) if node.get("name") == root_name]
    if len(matches) != 1:
        raise ValueError(f"Expected one anatomy root named {root_name}")
    indices = descendants(document, matches[0])
    systems = []
    for index in document["nodes"][matches[0]].get("children", []):
        members = descendants(document, index)
        systems.append({
            "source_name": document["nodes"][index]["name"],
            "mesh_nodes": sum("mesh" in document["nodes"][i] for i in members),
            "triangles": sum(node_triangles(document, i) for i in members),
        })
    return {
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "bytes": path.stat().st_size,
        "generator": document["asset"].get("generator"),
        "anatomy_root": matches[0],
        "total_nodes": len(document["nodes"]),
        "anatomy_nodes": len(indices),
        "anatomy_mesh_nodes": sum("mesh" in document["nodes"][i] for i in indices),
        "anatomy_triangles": sum(node_triangles(document, i) for i in indices),
        "excluded_nodes": len(document["nodes"]) - len(indices),
        "systems": systems,
        "note": "Source node counts are not verified anatomical coverage or clinical review.",
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=pathlib.Path)
    parser.add_argument("--root", required=True)
    args = parser.parse_args()
    print(json.dumps(inventory(args.file, args.root), indent=2))
