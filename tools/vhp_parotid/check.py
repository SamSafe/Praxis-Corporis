"""Check traced meshes against the body: share of each new part's vertices that lie
outside the skin, and inside existing organs (signed by the nearest face normal, so
the body meshes need not be watertight).
usage: check.py BODY.glb NEW.glb[,NEW.glb...] SKIN_NODE ORGAN_NODE [ORGAN_NODE ...]"""
import sys, trimesh, numpy as np, networkx as nx
body = trimesh.load(sys.argv[1], force="scene")
G = body.graph.to_networkx()
def merged(sc, root):
    parts = []
    for n in nx.descendants(sc.graph.to_networkx(), root) | {root}:
        if n in sc.graph.nodes_geometry:
            T, g = sc.graph[n]; m = sc.geometry[g].copy(); m.apply_transform(T); parts.append(m)
    return trimesh.util.concatenate(parts)
def inside(mesh, pts):
    # Small batches keep trimesh's candidate-face search within memory on large meshes.
    q = trimesh.proximity.ProximityQuery(mesh); result = []
    for i in range(0, len(pts), 50):
        c, d, tri = q.on_surface(pts[i:i + 50])
        result.append(np.einsum("ij,ij->i", pts[i:i + 50] - c, mesh.face_normals[tri]) < 0)
    return np.concatenate(result)
def light(mesh, faces=60000):
    return mesh.simplify_quadric_decimation(face_count=faces) if len(mesh.faces) > faces else mesh
skin = merged(body, sys.argv[3]); organs = {n: light(merged(body, n)) for n in sys.argv[4:]}
rng = np.random.default_rng(0)
for path in sys.argv[2].split(","):
  new = trimesh.load(path, force="scene")
  for n in sorted(new.graph.nodes_geometry):
      T, g = new.graph[n]; m = new.geometry[g].copy(); m.apply_transform(T)
      pts = m.vertices[rng.choice(len(m.vertices), min(400, len(m.vertices)), replace=False)]
      out = 1 - inside(skin, pts).mean()
      hits = {k: round(float(inside(o, pts).mean()), 2) for k, o in organs.items()
              if np.all(pts.min(0) < o.bounds[1]) and np.all(pts.max(0) > o.bounds[0])}
      hits = {k: v for k, v in hits.items() if v >= 0.05}
      print(f"{n}: outside skin {out:.0%}; inside existing {hits or 'none'}")
