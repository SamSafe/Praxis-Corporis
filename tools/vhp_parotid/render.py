"""Small shaded z-buffer renderer for checks.
usage: render.py OUT.png YAW_DEG Y0 Y1 HALF_WIDTH file.glb[@node,node]:r,g,b ..."""
import sys, numpy as np, trimesh, networkx as nx
from skimage import draw, io
out, yaw, y0, y1, hw = sys.argv[1], *map(float, sys.argv[2:6])
W = 900; H = int(W * (y1 - y0) / (2 * hw))
img = np.full((H, W, 3), 18, np.float32); zb = np.full((H, W), -1e9)
a = np.radians(yaw); Ry = np.array([[np.cos(a), 0, np.sin(a)], [0, 1, 0], [-np.sin(a), 0, np.cos(a)]])
light = np.array([0.3, 0.5, 0.8]); light /= np.linalg.norm(light); cache = {}
for spec in sys.argv[6:]:
    path, col = spec.rsplit(":", 1); col = np.array([float(c) for c in col.split(",")])
    path, _, sel = path.partition("@")
    sc = cache.setdefault(path, trimesh.load(path, force="scene")); G = sc.graph.to_networkx(); nodes = set()
    for r in (sel.split(",") if sel else sc.graph.nodes_geometry):
        if r in G: nodes |= {r} | nx.descendants(G, r)
    for n in nodes & set(sc.graph.nodes_geometry):
        T, g = sc.graph[n]; m = sc.geometry[g]
        v = trimesh.transformations.transform_points(m.vertices, T) @ Ry.T
        if v[:, 1].max() < y0 or v[:, 1].min() > y1: continue
        tri = v[m.faces]; nrm = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
        nrm /= np.linalg.norm(nrm, axis=1, keepdims=True) + 1e-12; shade = 0.25 + 0.75 * np.abs(nrm @ light)
        px = (tri[..., 0] + hw) / (2 * hw) * W; py = (y1 - tri[..., 1]) / (y1 - y0) * H; z = tri[..., 2].mean(1)
        for k in np.argsort(z):
            rr, cc = draw.polygon(py[k], px[k], (H, W))
            ok = zb[rr, cc] < z[k]; rr, cc = rr[ok], cc[ok]; zb[rr, cc] = z[k]; img[rr, cc] = col * shade[k]
io.imsave(out, np.clip(img, 0, 255).astype(np.uint8))
