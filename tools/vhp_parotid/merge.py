"""Merge one structure's masks from overlapping CT sections onto a common grid.

Where sections overlap, a voxel is kept if any section traced it, so a structure
that one section only partly traced near its edge is completed by the other; specks
are removed later when meshing.
usage: merge.py OUT_DIR SECTION_DIR [SECTION_DIR ...]
Each SECTION_DIR holds one segmentation run's <structure>.nii.gz masks."""
import sys, pathlib, numpy as np, nibabel as nib
from scipy.ndimage import affine_transform
out = pathlib.Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
sections = [pathlib.Path(p) for p in sys.argv[2:]]
names = sorted({p.name[:-7] for s in sections for p in s.glob("*.nii.gz")})
heads = [nib.load(next(s.glob("*.nii.gz"))) for s in sections]
vox = float(heads[0].header.get_zooms()[0])
lo = np.min([h.affine[:3, 3] for h in heads], 0)
hi = np.max([h.affine[:3, 3] + np.array(h.shape) * vox for h in heads], 0)
shape = tuple(np.ceil((hi - lo) / vox).astype(int))
affine = np.diag([vox, vox, vox, 1.0]); affine[:3, 3] = lo
kept = 0
for name in names:
    merged = np.zeros(shape, np.uint8)
    for i, s in enumerate(sections):
        p = s / (name + ".nii.gz")
        if not p.exists():
            continue
        im = nib.load(p); d = np.asarray(im.dataobj) > 0
        if not d.any():
            continue
        # common voxel -> section voxel
        M = np.linalg.inv(im.affine) @ affine
        r = affine_transform(d.astype(np.uint8), M[:3, :3], M[:3, 3], output_shape=shape, order=0)
        merged |= r
    if merged.any():
        nib.save(nib.Nifti1Image(merged, affine), str(out / (name + ".nii.gz"))); kept += 1
print("merged", kept, "structures from", len(sections), "sections; grid", shape)
