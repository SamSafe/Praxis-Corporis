"""Similarity fit of CT structures (RAS mm) into an HRA body frame (x left, y up,
z anterior; metres) from shared structures, then surface ICP on the same structures.
usage: fit.py SEG_DIR TARGET.npz OUT.json ct_mask=target_key ..."""
import sys, json, pathlib, numpy as np, nibabel as nib
from skimage import measure
from scipy.spatial import cKDTree
seg, tnpz, out = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
pairs = [a.split("=") for a in sys.argv[4:]]; tgt = dict(np.load(tnpz))
def ct_axes(v):
    return np.stack([-v[:, 0], v[:, 2], v[:, 1]], 1) / 1000.0  # RAS mm -> left, up, anterior m
def surface(name):
    path = next(seg.rglob(name + ".nii.gz")); im = nib.load(path)
    v, *_ = measure.marching_cubes((np.asarray(im.dataobj) > 0).astype(np.uint8), 0.5)
    return ct_axes(nib.affines.apply_affine(im.affine, v))
def umeyama(src, dst):
    ms, md = src.mean(0), dst.mean(0); a, b = src - ms, dst - md
    U, S, Vt = np.linalg.svd(b.T @ a / len(src)); D = np.eye(3)
    if np.linalg.det(U @ Vt) < 0: D[2, 2] = -1
    R = U @ D @ Vt; s = np.trace(np.diag(S) @ D) / a.var(0).sum()
    return s, R, md - s * R @ ms
src = [surface(c) for c, _ in pairs]; dst = [tgt[t] for _, t in pairs]
s, R, t = umeyama(np.array([v.mean(0) for v in src]), np.array([w.mean(0) for w in dst]))
ap = lambda p: (s * (R @ p.T)).T + t
res = {c: round(float(np.linalg.norm(ap(v.mean(0)[None])[0] - w.mean(0)) * 1000), 1) for (c, _), v, w in zip(pairs, src, dst)}
for _ in range(30):
    S_, D_ = [], []
    for v, w in zip(src, dst):
        vv = v[:: max(1, len(v) // 3000)]; d, i = cKDTree(w).query(ap(vv)); k = d < np.percentile(d, 90)
        S_.append(vv[k]); D_.append(w[i[k]])
    s, R, t = umeyama(np.concatenate(S_), np.concatenate(D_))
surf = {c: round(float(np.median(cKDTree(w).query(ap(v))[0]) * 1000), 1) for (c, _), v, w in zip(pairs, src, dst)}
print("centroid fit residual mm", res); print("after ICP: scale %.4f, median surface distance mm" % s, surf)
json.dump({"scale": float(s), "R": R.tolist(), "t": t.tolist(), "centroid_residual_mm": res, "surface_median_mm": surf}, open(out, "w"), indent=1)
