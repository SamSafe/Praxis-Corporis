"""Stack a depth range of Visible Human GE Genesis CT slices into one RAS NIfTI.

Slices are placed by their corner coordinates (tlhc/trhc/brhc, GE patient R/A/S in mm),
resampled onto one grid covering every slice's field of view, then cropped to the body
(HU > -500, 10 mm margin).
usage: build_region.py SRC_DIR OUT.nii.gz FROM_MM TO_MM VOXEL_MM
FROM/TO are depths below the first (most superior) slice of the series. Only the first
continuous pass is used: the Visible Human series continue with leg passes whose table
coordinates restart."""
import struct, sys, pathlib, subprocess, numpy as np, nibabel as nib
from scipy.ndimage import map_coordinates
src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
z_from, z_to, vox = map(float, sys.argv[3:6])


def read(name):
    d = subprocess.run(["gzip", "-dc", str(src / name)], capture_output=True, check=True).stdout
    u = lambda o: struct.unpack(">I", d[o:o + 4])[0]
    im = u(148)
    f = lambda o: struct.unpack(">f", d[im + o:im + o + 4])[0]
    w, h = u(8), u(12)
    corners = (f(154), f(158), f(162)), (f(166), f(170), f(174)), (f(178), f(182), f(186))
    return corners, w, h, d, u(4)


names = [n for n in (src / "list.txt").read_text().split() if (src / n).exists()]
top = read(names[0])[0][0][2]
slices = []
previous = top + 1
for name in names:
    (tl, tr, br), w, h, d, off = read(name)
    # Later passes (the legs) restart the table coordinates; use only the first,
    # continuous head-to-thigh pass so positions never repeat.
    if tl[2] >= previous:
        break
    previous = tl[2]
    depth = top - tl[2]
    if depth < z_from - 3 or depth > z_to + 3:
        continue
    pix = np.frombuffer(d[off:off + w * h * 2], ">i2").reshape(h, w).astype(np.float32)
    slices.append((tl[2], tl, tr, br, w, h, pix))
assert len(slices) > 2, "no slices in range"
offset = 1024.0 if min(s[6].min() for s in slices) >= 0 else 0.0
rs = [c for s in slices for c in (s[1][0], s[2][0])]; as_ = [c for s in slices for c in (s[2][1], s[3][1])]
R = np.arange(min(rs), max(rs), vox); A = np.arange(min(as_), max(as_), vox)
RR, AA = np.meshgrid(R, A, indexing="ij")
planes, locs = [], []
for loc, tl, tr, br, w, h, pix in slices:
    cu = (np.array(tr[:2]) - np.array(tl[:2])) / (w - 1)
    rv = (np.array(br[:2]) - np.array(tr[:2])) / (h - 1)
    rel = np.stack([RR - tl[0], AA - tl[1]], -1) @ np.linalg.inv(np.array([cu, rv]).T).T
    planes.append(map_coordinates(pix - offset, [rel[..., 1], rel[..., 0]], order=1, cval=-1024).astype(np.float32)); locs.append(loc)
locs = np.array(locs); order = np.argsort(locs); locs = locs[order]; stack = np.stack([planes[i] for i in order])
del planes
zs = np.arange(max(locs[0], top - z_to), min(locs[-1], top - z_from) + 1e-3, vox)
k = np.interp(zs, locs, np.arange(len(locs)))
vol = np.empty((len(R), len(A), len(zs)), np.int16)
for n, kk in enumerate(k):
    a = int(np.floor(kk)); b = min(a + 1, len(locs) - 1); t = kk - a
    vol[..., n] = np.clip((1 - t) * stack[a] + t * stack[b], -1024, 3071)
body = vol > -500
ix = [np.where(body.any(axis=tuple(j for j in range(3) if j != i)))[0] for i in range(3)]
m = int(10 / vox)
sl = [slice(max(0, a[0] - m), a[-1] + m + 1) for a in ix[:2]] + [slice(None)]
vol = vol[tuple(sl)]
affine = np.diag([vox, vox, vox, 1.0]); affine[:3, 3] = [R[sl[0].start], A[sl[1].start], zs[0]]
nib.save(nib.Nifti1Image(vol, affine), str(out))
print(out.name, len(slices), "slices, depth", z_from, "-", z_to, "grid", vol.shape, "spacing in range", np.round(np.diff(locs).max(), 1))
