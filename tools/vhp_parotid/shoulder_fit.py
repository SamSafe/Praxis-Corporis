"""Fit each shoulder's bones by the skin around them.

The body has no shoulder or arm bones to anchor a fit, and the shoulders and arms are
posed differently in the CT and in the frozen body, so the thorax fit leaves the
shoulder blades, collarbones and upper-arm bones partly outside the skin. This refines
the thorax fit per side and per bone group with a rigid ICP of the CT's own skin surface
near those bones onto the body's skin.

usage: shoulder_fit.py SECTION.nii.gz[,SECTION...] MASK_DIR THORAX_FIT.json SKIN.npz OUT_PREFIX
SKIN.npz holds the body's skin vertices under the key "skin" (see landmarks.py).
Writes OUT_PREFIX-<side>-<group>.json (same form as fit.py) for side left/right and
group girdle (scapula, clavicle) and humerus.
"""
import sys, json, pathlib, numpy as np, nibabel as nib
from scipy import ndimage
from scipy.spatial import cKDTree

sections = sys.argv[1].split(",")
masks, base = pathlib.Path(sys.argv[2]), json.load(open(sys.argv[3]))
skin = np.load(sys.argv[4])["skin"].astype(np.float64)
prefix = sys.argv[5]
s0, R0, t0 = base["scale"], np.array(base["R"]), np.array(base["t"])
to = lambda p: (s0 * (R0 @ (np.stack([-p[:, 0], p[:, 2], p[:, 1]], 1) / 1000).T)).T + t0


def ct_skin(path):
    im = nib.load(path); hu = np.asarray(im.dataobj).astype(np.float32)
    body = hu > -500
    lab, k = ndimage.label(body)
    body = lab == 1 + np.argmax(ndimage.sum(body, lab, range(1, k + 1)))
    for z in range(body.shape[2]):  # fill air spaces (lungs, bowel) slice by slice
        body[:, :, z] = ndimage.binary_fill_holes(body[:, :, z])
    shell = body & ~ndimage.binary_erosion(body)
    # Drop the first and last slices: the section's cut faces are not skin.
    shell[:, :, :2] = False; shell[:, :, -2:] = False
    return to(nib.affines.apply_affine(im.affine, np.argwhere(shell)))


def mask_points(name):
    im = nib.load(masks / f"{name}.nii.gz"); d = np.asarray(im.dataobj) > 0
    shell = d & ~ndimage.binary_erosion(d)
    return to(nib.affines.apply_affine(im.affine, np.argwhere(shell)))


def rigid(src, dst):
    ms, md = src.mean(0), dst.mean(0)
    U, _, Vt = np.linalg.svd((dst - md).T @ (src - ms))
    D = np.eye(3); D[2, 2] = np.sign(np.linalg.det(U @ Vt))
    R = U @ D @ Vt
    return R, md - R @ ms


ct = np.concatenate([ct_skin(p) for p in sections])
ct = ct[:: max(1, len(ct) // 400000)]
skin_tree = cKDTree(skin)
groups = {"girdle": ("scapula", "clavicula"), "humerus": ("humerus",)}
for side in ("left", "right"):
    for group, names in groups.items():
        bone = np.concatenate([mask_points(f"{n}_{side}") for n in names])
        src = ct[cKDTree(bone).query(ct, distance_upper_bound=0.05)[0] < 0.05]
        dst = skin[cKDTree(bone).query(skin, distance_upper_bound=0.08)[0] < 0.08]
        tree = cKDTree(dst); R, t = np.eye(3), np.zeros(3)
        before = np.median(tree.query(src)[0])
        for _ in range(60):
            moved = src @ R.T + t
            d, i = tree.query(moved); k = d < np.percentile(d, 80)
            dR, dt = rigid(moved[k], dst[i[k]]); R, t = dR @ R, dR @ t + dt
        after = np.median(tree.query(src @ R.T + t)[0])
        angle = np.degrees(np.arccos(np.clip((np.trace(R) - 1) / 2, -1, 1)))
        shift = np.linalg.norm((bone.mean(0) @ R.T + t) - bone.mean(0))
        # Share of bone surface outside the skin, approximated by the nearest skin point
        # lying nearer the body's centre line than the bone point.
        print(f"{side} {group}: {len(src)} CT skin points, {len(dst)} body skin points; "
              f"skin distance {before*1000:.1f} -> {after*1000:.1f} mm; rotation {angle:.1f} deg, bone shift {shift*1000:.1f} mm")
        fit = {"scale": s0, "R": (R @ R0).tolist(), "t": (R @ t0 + t).tolist(),
               "base": sys.argv[3], "skin_median_mm": [round(before * 1000, 1), round(after * 1000, 1)],
               "rotation_deg": round(float(angle), 1), "bone_shift_mm": round(float(shift * 1000), 1)}
        pathlib.Path(f"{prefix}-{side}-{group}.json").write_text(json.dumps(fit, indent=1))
