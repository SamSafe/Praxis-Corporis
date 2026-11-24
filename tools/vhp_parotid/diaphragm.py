"""Diaphragm mask from TotalSegmentator's trunk cavities.

No free task traces the diaphragm itself, but the trunk_cavities task traces the
thoracic and abdominal cavities on either side of it. The diaphragm is taken as the
sheet where the two cavities meet: voxels within GAP mm of both.
usage: diaphragm.py CAVITY_DIR [GAP_MM]  (writes CAVITY_DIR/diaphragm.nii.gz)"""
import sys, pathlib, numpy as np, nibabel as nib
from scipy import ndimage
d = pathlib.Path(sys.argv[1]); gap = float(sys.argv[2]) if len(sys.argv) > 2 else 4.0
th = nib.load(d / "thoracic_cavity.nii.gz"); ab = nib.load(d / "abdominal_cavity.nii.gz")
assert np.allclose(th.affine, ab.affine) and th.shape == ab.shape
vox = float(th.header.get_zooms()[0])
dist_t = ndimage.distance_transform_edt(~(np.asarray(th.dataobj) > 0)) * vox
dist_a = ndimage.distance_transform_edt(~(np.asarray(ab.dataobj) > 0)) * vox
sheet = (dist_t <= gap) & (dist_a <= gap)
print("diaphragm voxels", int(sheet.sum()), "volume cm3 %.0f" % (sheet.sum() * vox ** 3 / 1000))
nib.save(nib.Nifti1Image(sheet.astype(np.uint8), th.affine), str(d / "diaphragm.nii.gz"))
