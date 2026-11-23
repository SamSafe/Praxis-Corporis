"""Collect world-space vertices of named subtrees from a GLB into an .npz.
usage: landmarks.py BODY.glb OUT.npz SPEC [SPEC ...]
SPEC is a node name, or KEY=node+node+... to combine several subtrees under one key."""
import sys, trimesh, numpy as np, networkx as nx
sc = trimesh.load(sys.argv[1], force="scene"); G = sc.graph.to_networkx(); out = {}
for spec in sys.argv[3:]:
    key, _, roots = spec.partition("=")
    pts = []
    for root in (roots or key).split("+"):
        if root not in G:
            raise SystemExit("missing node " + root)
        for n in nx.descendants(G, root) | {root}:
            if n in sc.graph.nodes_geometry:
                T, g = sc.graph[n]; pts.append(trimesh.transformations.transform_points(sc.geometry[g].vertices, T))
    out[key] = np.concatenate(pts).astype(np.float32)
    print(key, len(out[key]), np.round(out[key].mean(0), 4))
np.savez_compressed(sys.argv[2], **out)
