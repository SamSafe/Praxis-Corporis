# Visible Human CT tracing tools

Parts traced from the Visible Human Project CT scans for the female and male HRA bodies.
The folder began with the parotid glands and now holds the whole pipeline; its name is
kept because the supplement manifest and body files record it.

Audits: [parotid glands](../../docs/audit/VHP_PAROTID.md) and
[organs, bones and muscles](../../docs/audit/VHP_CT_PARTS.md).

## Environment

A private Python environment with CPU PyTorch, TotalSegmentator 2.18.0, scikit-image,
trimesh, fast-simplification, networkx and rtree, under `build/parotid-work/venv`. Set
`TOTALSEG_HOME_DIR` to a folder whose `config.json` has `"send_usage_stats": false`.
Segmentation peaks near 4.8 GB of memory: run one heavy step at a time.

On Windows the venv is `build\parotid-work\venv\Scripts\`. Start TotalSegmentator with
`Start-Process -RedirectStandardOutput/-RedirectStandardError` rather than
`& TotalSegmentator ... *> log`: Windows PowerShell 5.1 with `$ErrorActionPreference =
"Stop"` turns its progress bars on stderr into an error, stopping the script and
orphaning a worker process. `build_hra_supplements.py` and `build_sample_pack.py` import
sibling modules, so run them without `-I`. `build_volume.py` decompresses the `.Z`
slices with `gzip`; Git for Windows has one in `C:\Program Files\Git\usr\bin`.

`build_body_parts.py` re-meshes every group. To keep already-reviewed groups byte for
byte, restore their committed GLBs from `assets/vhp-ct/` into the parts folder before
`integrate_ct_parts.py`, and remove GLBs of groups that the skip list now empties.

## Order

| Step | Tool | Output |
|---|---|---|
| Download slices (retries; records missing ones) | `download.py male\|female DIR COUNT` | `.fre.Z` slices, `list.txt`, `missing.txt` |
| Head volume for the parotid glands | `build_volume.py` | 0.75 mm head NIfTI |
| Trunk sections (first head-to-thigh pass only) | `build_region.py` | 1.5 mm section NIfTIs |
| Trace | `TotalSegmentator` (`head_glands_cavities`; `total` with `--roi_subset`) | masks per section |
| Merge overlapping sections | `merge.py` | one mask per structure |
| Body anchors | `landmarks.py` | `<body>-anchors.npz` |
| Fit (one region) | `fit.py` | similarity transform JSON |
| Second round: other free tasks (`head_muscles`, `craniofacial_structures`, `headneck_muscles`, `headneck_bones_vessels`, `abdominal_muscles`, `trunk_cavities`) | `TotalSegmentator -ta TASK` | masks under `seg-<body>/extra`, merged to `abd` and `cav` |
| Head-and-neck volume for `headneck_muscles` (it runs at 0.75 mm and crops to the clavicles and C1-T4) | `build_volume.py ct-<body> <body>-headneck.nii.gz 400 -180 180 A0 A1 0.75` (A0 A1 as for the head volume), then `TotalSegmentator -ta headneck_muscles` | `seg-<body>/extra/headneck-headneck_muscles` |
| Neck vessels (third round) | `TotalSegmentator --roi_subset` (carotid, subclavian, brachiocephalic vessels) on the 0-330 and 230-630 sections, merged with `merge.py` into `seg-<body>/vessels`; `-ta headneck_bones_vessels` on the head-and-neck volume | vessel masks |
| Diaphragm (second round) | `diaphragm.py CAVITY_DIR` | `diaphragm.nii.gz` between the two cavities |
| Body skin (second round) | `landmarks.py BODY.glb SKIN.npz skin=<X>_skin` | skin vertices |
| Fit all regions, mesh and label | `build_body_parts.py BODY WORK OUT [SKIP]` | one GLB per group; shoulder groups wait for the next step |
| Per-side shoulder fits (second round) | `shoulder_fit.py SECTIONS MERGED THORAX_FIT SKIN.npz PREFIX`, then `build_body_parts.py` again | fit JSON per side and bone group |
| Join one structure traced on two volumes (third round: the trapezius) | `union.py OUT MASK MASK...` | one mask on the first mask's voxel size |
| Refit superficial parts by the skin around them (third round) | `skin_fit.py VOLUMES BASE_FIT SKIN.npz OUT.json MASKS [NEAR_MM] [--scale]`; list the fits in `<body>-refits.json` (`{"mask": {"fit": FIT.json, "mask": MASK.nii.gz}}`) before `build_body_parts.py` | fit JSON per pair or side |
| Mesh (called by the above) | `mesh.py` | labelled GLB |
| Check against skin and organs | `check.py` | outside-skin and overlap shares |
| Check renders | `render.py` | PNG |
| Register with the bodies and cards | `integrate_ct_parts.py PARTS` then `--map` after `build_sample_pack.py` | manifest groups, card mappings |

After registering: `tools/build_hra_supplements.py`, update the supplemented hashes in
`content/source_manifest.json` and `content/reference_frames.json`,
`tools/build_sample_pack.py`, `integrate_ct_parts.py --map`, coverage notes, then
`tools/prepare_assets.gd`.
