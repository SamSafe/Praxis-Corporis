"""Split the traced intervertebral discs into one mask per level, named by the body's vertebrae.

usage: discs.py DISC_MASK SPINE_FIT ANCHORS.npz OUT_DIR
The vertebrae_body task traces all discs as one label. Each connected piece is placed
in the body by the spine fit and named by the body's vertebrae directly above and below
it, so the names follow the body's own count (the female HRA body has six lumbar
vertebrae). Pieces at one level are joined; specks under 0.3 cm3 are dropped. Writes
OUT_DIR/disc_<A>_<B>.nii.gz and OUT_DIR/levels.json (top to bottom)."""
import json, pathlib, sys
import numpy as np, nibabel as nib
from scipy import ndimage

mask, fitfile, anchors, out = sys.argv[1], sys.argv[2], sys.argv[3], pathlib.Path(sys.argv[4])
out.mkdir(parents=True, exist_ok=True)
for old in out.glob("disc_*.nii.gz"):
    old.unlink()
im = nib.load(mask); d = np.asarray(im.dataobj) > 0
f = json.loads(pathlib.Path(fitfile).read_text())
s, R, t = f["scale"], np.array(f["R"]), np.array(f["t"])
tgt = dict(np.load(anchors))
order = [f"C{i}" for i in range(1, 8)] + [f"T{i}" for i in range(1, 13)] + [f"L{i}" for i in range(1, 7)] + ["sacrum"]
show = lambda n: "S1" if n == "sacrum" else n  # the disc above the sacrum is L5-S1 (L6-S1)
vert = {k: tgt[k].mean(0) for k in order if k in tgt}
names = list(vert)
heights = np.array([vert[k][1] for k in names])
vox = float(np.prod(im.header.get_zooms()))

lab, k = ndimage.label(d)
levels = {}
for i in range(1, k + 1):
    piece = lab == i
    if piece.sum() * vox / 1000 < 0.3:
        continue
    c = nib.affines.apply_affine(im.affine, np.argwhere(piece).mean(0))
    c = s * (R @ (np.array([-c[0], c[2], c[1]]) / 1000.0)) + t
    above = [n for n, h in zip(names, heights) if h > c[1]]
    below = [n for n, h in zip(names, heights) if h <= c[1]]
    if not above or not below:
        print("piece outside the spine, dropped: %.1f cm3" % (piece.sum() * vox / 1000)); continue
    a = min(above, key=lambda n: vert[n][1]); b = max(below, key=lambda n: vert[n][1])
    if names.index(b) != names.index(a) + 1:  # neighbours among the body's own vertebrae
        print(f"piece between {a} and {b}, not neighbours, dropped"); continue
    key = f"{a}_{b}"
    levels[key] = levels.get(key, np.zeros_like(d)) | piece

result = []
for key in sorted(levels, key=lambda n: order.index(n.split("_")[0])):
    m = levels[key]
    a, b = map(show, key.split("_"))
    key = f"{a}_{b}"
    nib.save(nib.Nifti1Image(m.astype(np.uint8), im.affine), str(out / f"disc_{key}.nii.gz"))
    cm3 = m.sum() * vox / 1000
    result.append({"mask": f"disc_{key}", "node": f"intervertebral_disc_{key}", "label": f"Intervertebral disc {a}-{b}", "cm3": round(cm3, 1)})
    print(f"{key}: {cm3:.1f} cm3")
(out / "levels.json").write_text(json.dumps(result, indent=1), encoding="utf-8")
print(len(result), "levels")
