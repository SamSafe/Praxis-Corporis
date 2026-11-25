"""Join masks of one structure traced on different volumes into one mask.

The trapezius runs from the skull to T12: headneck_muscles traces its upper part on the
0.75 mm head-and-neck volume and abdominal_muscles its lower part on the 1.5 mm trunk
sections. The masks share scanner coordinates, so they are resampled (nearest
neighbour) onto one grid with the first mask's voxel size, spanning all of them, and
a voxel traced in either is kept.

usage: union.py OUT.nii.gz MASK.nii.gz MASK.nii.gz [...]
"""
import sys, numpy as np, nibabel as nib
from scipy import ndimage

out, paths = sys.argv[1], sys.argv[2:]
ims = [nib.load(p) for p in paths]
first = ims[0]
# Axis-aligned grids only (build_volume.py and build_region.py write diagonal affines).
for im in ims:
    if not np.allclose(im.affine[:3, :3], np.diag(np.diag(im.affine[:3, :3]))):
        sys.exit(f"union.py: non-diagonal affine in {im.get_filename()}")
step = np.diag(first.affine)[:3]
lo = np.full(3, np.inf); hi = np.full(3, -np.inf)
for im in ims:
    d = np.asarray(im.dataobj) > 0
    if not d.any():
        continue
    idx = np.argwhere(d); ends = nib.affines.apply_affine(im.affine, np.array([idx.min(0), idx.max(0)]))
    lo = np.minimum(lo, ends.min(0)); hi = np.maximum(hi, ends.max(0))
lo -= 3 * np.abs(step); hi += 3 * np.abs(step)
origin = np.where(step > 0, lo, hi)
shape = np.ceil((hi - lo) / np.abs(step)).astype(int) + 1
affine = np.diag(np.r_[step, 1.0]); affine[:3, 3] = origin
result = np.zeros(shape, bool)
grid = np.indices(shape).reshape(3, -1).T
world = nib.affines.apply_affine(affine, grid)
for im in ims:
    d = (np.asarray(im.dataobj) > 0).astype(np.uint8)
    if not d.any():
        continue
    src = nib.affines.apply_affine(np.linalg.inv(im.affine), world)
    v = ndimage.map_coordinates(d, src.T, order=0, mode="constant", cval=0)
    result |= v.reshape(shape) > 0
    print(f"{im.get_filename()}: {d.sum() * np.prod(np.abs(np.diag(im.affine)[:3])) / 1000:.1f} cm3")
print(f"union: {result.sum() * np.prod(np.abs(step)) / 1000:.1f} cm3, grid {tuple(shape)}")
nib.save(nib.Nifti1Image(result.astype(np.uint8), affine), out)
