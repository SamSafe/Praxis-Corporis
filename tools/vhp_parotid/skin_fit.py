"""Refine a regional fit by the skin around a group of superficial parts.

The donors were scanned lying down and frozen in a slightly different pose, so a fit
made from deep anchors (vertebrae, eyes, organs) can leave muscles that lie just under
the skin partly outside it: the sternocleidomastoid and trapezius at the neck, the
pectoralis major at the chest. This is shoulder_fit.py for any group of parts: a rigid
ICP of the CT's own skin near the parts onto the body's skin near them.

usage: skin_fit.py VOLUME.nii.gz[,VOLUME...] BASE_FIT.json SKIN.npz OUT.json MASK.nii.gz[,MASK...] [NEAR_MM]
VOLUME: CT volumes (HU) covering the parts; BASE_FIT: the region's fit (fit.py form);
SKIN.npz: the body's skin vertices under "skin" (landmarks.py). Skin points within
NEAR_MM (default 50) of the parts' surfaces in the CT, and within NEAR_MM + 30 in the
body, are matched. Writes OUT.json in fit.py form, with before/after skin distances.
"""
import sys, json, pathlib, numpy as np, nibabel as nib
from scipy import ndimage
from scipy.spatial import cKDTree

volumes, base = sys.argv[1].split(","), json.load(open(sys.argv[2]))
skin = np.load(sys.argv[3])["skin"].astype(np.float64)
out, masks = sys.argv[4], sys.argv[5].split(",")
rest = [a for a in sys.argv[6:] if not a.startswith("--")]
near = float(rest[0]) / 1000 if rest else 0.05
s0, R0, t0 = base["scale"], np.array(base["R"]), np.array(base["t"])
to = lambda p: (s0 * (R0 @ (np.stack([-p[:, 0], p[:, 2], p[:, 1]], 1) / 1000).T)).T + t0


def ct_skin(path):
    im = nib.load(path); hu = np.asarray(im.dataobj).astype(np.float32)
    body = hu > -500
    lab, k = ndimage.label(body)
    body = lab == 1 + np.argmax(ndimage.sum(body, lab, range(1, k + 1)))
    for z in range(body.shape[2]):  # fill air spaces (airway, lungs) slice by slice
        body[:, :, z] = ndimage.binary_fill_holes(body[:, :, z])
    shell = body & ~ndimage.binary_erosion(body)
    shell[:, :, :2] = False; shell[:, :, -2:] = False  # cut faces of the volume
    return to(nib.affines.apply_affine(im.affine, np.argwhere(shell)))


def mask_points(path):
    im = nib.load(path); d = np.asarray(im.dataobj) > 0
    shell = d & ~ndimage.binary_erosion(d)
    return to(nib.affines.apply_affine(im.affine, np.argwhere(shell)))


scaled = "--scale" in sys.argv  # similarity instead of rigid: also fit a size change


def rigid(src, dst):
    ms, md = src.mean(0), dst.mean(0)
    U, S, Vt = np.linalg.svd((dst - md).T @ (src - ms))
    D = np.eye(3); D[2, 2] = np.sign(np.linalg.det(U @ Vt))
    R = U @ D @ Vt
    c = (S * np.diag(D)).sum() / ((src - ms) ** 2).sum() if scaled else 1.0
    return c * R, md - c * R @ ms


ct = np.concatenate([ct_skin(p) for p in volumes])
ct = ct[:: max(1, len(ct) // 400000)]
part = np.concatenate([mask_points(m) for m in masks])
tree_part = cKDTree(part[:: max(1, len(part) // 200000)])
src = ct[tree_part.query(ct, distance_upper_bound=near)[0] < near]
dst = skin[tree_part.query(skin, distance_upper_bound=near + 0.03)[0] < near + 0.03]
tree = cKDTree(dst); R, t = np.eye(3), np.zeros(3)
before = np.median(tree.query(src)[0])
for _ in range(60):
    moved = src @ R.T + t
    d, i = tree.query(moved); k = d < np.percentile(d, 80)
    dR, dt = rigid(moved[k], dst[i[k]]); R, t = dR @ R, dR @ t + dt
after = np.median(tree.query(src @ R.T + t)[0])
c = np.cbrt(np.linalg.det(R)); Rn = R / c  # size change and pure rotation
angle = np.degrees(np.arccos(np.clip((np.trace(Rn) - 1) / 2, -1, 1)))
shift = np.linalg.norm((part.mean(0) @ R.T + t) - part.mean(0))
print(f"{pathlib.Path(out).stem}: {len(src)} CT skin points, {len(dst)} body skin points; skin distance "
      f"{before*1000:.1f} -> {after*1000:.1f} mm; rotation {angle:.1f} deg, scale {c:.3f}, part shift {shift*1000:.1f} mm")
fit = {"scale": s0 * c, "R": (Rn @ R0).tolist(), "t": (R @ t0 + t).tolist(), "base": sys.argv[2],
       "skin_median_mm": [round(before * 1000, 1), round(after * 1000, 1)],
       "rotation_deg": round(float(angle), 1), "size_change": round(float(c), 3), "part_shift_mm": round(float(shift * 1000), 1)}
pathlib.Path(out).write_text(json.dumps(fit, indent=1))
