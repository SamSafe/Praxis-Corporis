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
| Fit all regions, mesh and label | `build_body_parts.py BODY WORK OUT [SKIP]` | one GLB per group |
| Mesh (called by the above) | `mesh.py` | labelled GLB |
| Check against skin and organs | `check.py` | outside-skin and overlap shares |
| Check renders | `render.py` | PNG |
| Register with the bodies and cards | `integrate_ct_parts.py PARTS` then `--map` after `build_sample_pack.py` | manifest groups, card mappings |

After registering: `tools/build_hra_supplements.py`, update the supplemented hashes in
`content/source_manifest.json` and `content/reference_frames.json`,
`tools/build_sample_pack.py`, `integrate_ct_parts.py --map`, coverage notes, then
`tools/prepare_assets.gd`.
