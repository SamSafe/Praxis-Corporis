"""Gland masks -> smoothed closed meshes in the fitted body frame, written as a GLB with
one node per gland carrying its label and ontology ID in node extras.
usage: mesh.py SEG_DIR FIT.json OUT.glb mask=node_name=Label=ONTOLOGY:ID ..."""
import sys, json, pathlib, struct, numpy as np, nibabel as nib, trimesh
from skimage import measure
from scipy import ndimage
seg, fit, out = pathlib.Path(sys.argv[1]), json.load(open(sys.argv[2])), sys.argv[3]
s, R, t = fit["scale"], np.array(fit["R"]), np.array(fit["t"])
to = lambda p: (s * (R @ (np.stack([-p[:, 0], p[:, 2], p[:, 1]], 1) / 1000).T)).T + t
sc = trimesh.Scene(); extras = {}
for arg in sys.argv[4:]:
    mask, node, label, ontology = arg.split("=")
    extras[node] = {"label": label, "ontologyid": ontology}
    im = nib.load(next(seg.rglob(mask + ".nii.gz"))); d = np.asarray(im.dataobj) > 0
    lab, k = ndimage.label(d); d = lab == 1 + np.argmax(ndimage.sum(d, lab, range(1, k + 1)))  # largest piece
    d = ndimage.binary_fill_holes(ndimage.binary_closing(d, iterations=1))
    sm = ndimage.gaussian_filter(np.pad(d, 3).astype(np.float32), 1.0)
    v, f, *_ = measure.marching_cubes(sm, 0.5)
    m = trimesh.Trimesh(to(nib.affines.apply_affine(im.affine, v - 3)), f, process=True)
    trimesh.smoothing.filter_taubin(m, iterations=20)
    m = m.simplify_quadric_decimation(face_count=6000); trimesh.repair.fix_normals(m)
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
