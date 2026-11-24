"""Gland masks -> smoothed closed meshes in the fitted body frame, written as a GLB with
one node per gland carrying its label and ontology ID in node extras.
usage: mesh.py SEG_DIR FIT.json OUT.glb mask=node_name=Label=ONTOLOGY:ID[=FACES[=PART_FIT.json]] ...
Pieces smaller than 5% of the largest are dropped (specks); larger separate pieces, such
as individual costal cartilages, are kept."""
import sys, json, pathlib, struct, numpy as np, nibabel as nib, trimesh
from skimage import measure
from scipy import ndimage
seg, fit, out = pathlib.Path(sys.argv[1]), json.load(open(sys.argv[2])), sys.argv[3]
s, R, t = fit["scale"], np.array(fit["R"]), np.array(fit["t"])
to = lambda p: (s * (R @ (np.stack([-p[:, 0], p[:, 2], p[:, 1]], 1) / 1000).T)).T + t
def taubin(m, iterations=20, lamb=0.5, mu=-0.53):
    """Taubin smoothing with uniform neighbour weights from the edge graph.

    trimesh's filters can diverge at non-manifold edges and throw vertices far away;
    this form averages over directly connected vertices only."""
    import scipy.sparse as sp
    e = m.edges_unique; n = len(m.vertices)
    A = sp.coo_matrix((np.ones(2 * len(e)), (np.r_[e[:, 0], e[:, 1]], np.r_[e[:, 1], e[:, 0]])), shape=(n, n)).tocsr()
    W = sp.diags(1 / np.maximum(np.asarray(A.sum(1)).ravel(), 1)) @ A
    x = m.vertices.copy()
    for _ in range(iterations):
        for k in (lamb, mu):
            x = x + k * (W @ x - x)
    return trimesh.Trimesh(x, m.faces, process=False)


sc = trimesh.Scene(); extras = {}
for arg in sys.argv[4:]:
    mask, node, label, ontology, *rest = arg.split("=")
    faces = int(rest[0]) if rest else 6000
    # An optional sixth field names a fit for this part alone (per-side shoulder fits).
    f = json.load(open(rest[1])) if len(rest) > 1 else fit
    s, R, t = f["scale"], np.array(f["R"]), np.array(f["t"])
    extras[node] = {"label": label, "ontologyid": ontology}
    im = nib.load(next(seg.rglob(mask + ".nii.gz"))); d = np.asarray(im.dataobj) > 0
    lab, k = ndimage.label(d); sizes = ndimage.sum(d, lab, range(1, k + 1))
    d = np.isin(lab, 1 + np.flatnonzero(sizes >= 0.05 * sizes.max()))
    d = ndimage.binary_fill_holes(ndimage.binary_closing(d, iterations=1))
    sm = ndimage.gaussian_filter(np.pad(d, 3).astype(np.float32), 1.0)
    v, f, *_ = measure.marching_cubes(sm, 0.5)
    m = trimesh.Trimesh(to(nib.affines.apply_affine(im.affine, v - 3)), f, process=True)
    m = taubin(m)
    if len(m.faces) > faces:
        # Aggressive quadric simplification can leave long needle triangles; use a gentle
        # setting and keep the unsimplified mesh if a needle remains.
        simple = m.simplify_quadric_decimation(face_count=faces, aggression=2)
        L = simple.edges_unique_length
        m = simple if L.max() < 10 * np.median(L) else m
    trimesh.repair.fix_normals(m)
    if m.volume < 0:  # simplification can leave an open mesh wound inward
        m.invert()
    print(node, "faces", len(m.faces), "watertight", m.is_watertight, "volume cm3 %.1f" % (m.volume * 1e6),
          "mask cm3 %.1f" % (d.sum() * np.prod(im.header.get_zooms()) / 1000))
    sc.add_geometry(m, node_name=node, geom_name=node)
data = sc.export(file_type="glb")
# Add labels and ontology IDs to the nodes; trimesh does not write node extras.
n = struct.unpack_from("<I", data, 12)[0]; doc = json.loads(data[20:20 + n]); rest = data[20 + n:]
for node in doc["nodes"]:
    if node.get("name") in extras:
        node["extras"] = extras[node["name"]]
payload = json.dumps(doc, separators=(",", ":")).encode(); payload += b" " * (-len(payload) % 4)
pathlib.Path(out).write_bytes(struct.pack("<4sII", b"glTF", 2, 20 + len(payload) + len(rest)) + struct.pack("<II", len(payload), 0x4E4F534A) + payload + rest)
