"""Collect world-space vertices of named subtrees from a GLB into an .npz.
usage: landmarks.py BODY.glb OUT.npz NODE [NODE ...]"""
import sys, trimesh, numpy as np, networkx as nx
sc = trimesh.load(sys.argv[1], force="scene"); G = sc.graph.to_networkx(); out = {}
for root in sys.argv[3:]:
    pts = []
    for n in nx.descendants(G, root) | {root}:
        if n in sc.graph.nodes_geometry:
            T, g = sc.graph[n]; pts.append(trimesh.transformations.transform_points(sc.geometry[g].vertices, T))
    out[root] = np.concatenate(pts).astype(np.float32)
    print(root, len(out[root]), np.round(out[root].mean(0), 4))
np.savez_compressed(sys.argv[2], **out)
