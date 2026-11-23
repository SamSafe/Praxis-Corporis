"""Stack Visible Human GE Genesis CT slices into one RAS NIfTI on a common grid.

Each slice's corner coordinates (tlhc, trhc, brhc: GE patient R/A/S in mm, image header
offsets 154-186) place it, so series with different fields of view share one grid.
usage: build_volume.py SRC_DIR OUT.nii.gz DEPTH_MM R0 R1 A0 A1 VOXEL_MM
"""
import struct, sys, pathlib, subprocess, numpy as np, nibabel as nib
from scipy.ndimage import map_coordinates
src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
depth, r0, r1, a0, a1, vox = map(float, sys.argv[3:9])
slices = []
for name in (src / "list.txt").read_text().split():
    p = src / name
    if not p.exists():
        break
    d = subprocess.run(["gzip", "-dc", str(p)], capture_output=True, check=True).stdout
    u = lambda o: struct.unpack(">I", d[o:o + 4])[0]
    im = u(148)
    f = lambda o: struct.unpack(">f", d[im + o:im + o + 4])[0]
    w, h = u(8), u(12)
    tl, tr, br = (f(154), f(158), f(162)), (f(166), f(170), f(174)), (f(178), f(182), f(186))
    pix = np.frombuffer(d[u(4):u(4) + w * h * 2], ">i2").reshape(h, w).astype(np.float32)
    slices.append((tl[2], tl, tr, br, w, h, pix))
    if slices[0][0] - tl[2] > depth:
        break
offset = 1024.0 if min(s[6].min() for s in slices) >= 0 else 0.0
R = np.arange(r0, r1, vox); A = np.arange(a0, a1, vox)
RR, AA = np.meshgrid(R, A, indexing="ij")
planes, locs = [], []
for loc, tl, tr, br, w, h, pix in slices:
    cu = (np.array(tr[:2]) - np.array(tl[:2])) / (w - 1)   # one column step
    rv = (np.array(br[:2]) - np.array(tr[:2])) / (h - 1)   # one row step
    rel = np.stack([RR - tl[0], AA - tl[1]], -1) @ np.linalg.inv(np.array([cu, rv]).T).T
    planes.append(map_coordinates(pix - offset, [rel[..., 1], rel[..., 0]], order=1, cval=-1024)); locs.append(loc)
locs = np.array(locs); order = np.argsort(locs); locs = locs[order]; stack = np.stack([planes[i] for i in order])
zs = np.arange(locs[0], locs[-1] + 1e-3, vox)
k = np.interp(zs, locs, np.arange(len(locs)))
vol = np.empty((len(R), len(A), len(zs)), np.int16)
for n, kk in enumerate(k):
    a = int(np.floor(kk)); b = min(a + 1, len(locs) - 1); t = kk - a
    vol[..., n] = np.clip((1 - t) * stack[a] + t * stack[b], -1024, 3071)
affine = np.diag([vox, vox, vox, 1.0]); affine[:3, 3] = [R[0], A[0], zs[0]]
nib.save(nib.Nifti1Image(vol, affine), str(out))
print(len(slices), "slices", locs[-1], "to", locs[0], "grid", vol.shape)
