# HRA v1.1 sample audit

Date: 2026-10-11. This is a technical source inventory and private prototype input.
It is not a completed anatomy coverage audit or medical review.

## Selected material

The prototype uses the male and female United GLB files from the
[Human Reference Atlas / HuBMAP source repository](https://github.com/hubmapconsortium/ccf-3d-reference-object-library),
under source commit `f1a3a63f110e27ff0736047d52d04dba5d3087f9`:

- `VH_Female/v1.1/VH_F_United.glb`
- `VH_Male/v1.1/VH_M_United.glb`

These are deliberately pinned samples, not a claim to use the latest atlas release.
Both files were downloaded and their full SHA-256 hashes recorded in
[source_manifest.json](../../content/source_manifest.json).
The repository's [CC BY 4.0 licence](../../third_party/HRA-LICENSE.txt) and
[README](../../third_party/HRA-README.md) are preserved. The README's example paths
have different capitalization/version paths from the actual downloaded tree;
the manifest records the exact working paths rather than relying on those examples.

## Observed inventory

| Measurement | Female sample | Male sample |
|---|---:|---:|
| Original GLB size | 76,147,432 bytes | 78,514,500 bytes |
| Source anatomy nodes, including groups | 970 | 961 |
| Source anatomy mesh nodes | 801 | 788 |
| Triangle primitives within the anatomy root | 3,523,547 | 3,612,750 |
| Sampling-site nodes outside that root, excluded | 115 | 115 |

These are source mesh/node counts. A mesh can represent a surface, region,
component, or marker rather than a complete anatomical structure. They must not be
advertised as a count of reviewed anatomical structures. Reproduce the per-system
counts with [glb_inventory.py](../../tools/glb_inventory.py); the generated record
is [hra-v1-1-inventory.json](hra-v1-1-inventory.json).

The source contains no node translation, rotation, scale, or matrix properties.
Source vertices already share their body's spatial frame. The prototype preserves
the glTF metre coordinates and Y-up axes without fitting or mixing the two bodies.
This technical placement check does not validate anatomical orientation or alignment.

## Useful supplied geometry

- Exterior skin for each body and separately grouped heart geometry.
- Named atrial, ventricular, valve, and papillary-muscle components.
- Separately grouped left/right lungs, lobes, regional meshes, and airway geometry.
- Vessel meshes, digestive and urinary organs, pelvic/lower-limb skeletal geometry,
  reproductive geometry, and selected nervous/lymphatic/muscular geometry.
- Labels and ontology fields on many source nodes, useful as draft import metadata.

The source also names Allen brain and Yao lymph-node contributions. Treat this as
a composite reference collection; do not describe every mesh as originating from
one Visible Human donor. Preserve the atlas's supplied provenance and credits.

## Material gaps and follow-up work

| Area | Finding / remaining work |
|---|---|
| Skeleton | Source hierarchy includes pelvis/lower limbs, with a male hyoid. It does not supply a comprehensive skull, spine, rib cage, or upper-limb skeleton in these samples. Source region names and meshes still need visual/anatomical checking. |
| Muscles | Mainly eye/knee groups and male laryngeal groups; no comprehensive superficial/deep whole-body muscle atlas. |
| Nerves | Brain, eye-related geometry, and related groups do not establish a whole-body peripheral nerve collection. |
| Heart interiors | Distinct source components are present; completeness, cavity surfaces, clinically useful cutaways, and labels require inspection/review. |
| Heart–lung connections | Vessel geometry is present. No reviewed flow graph, direction, waypoint sequence, or pathway text has been authored. |
| Endocrine and other missing detail | Not established by this import. Audit individually and seek supplemental sources. |
| Metadata | Group names and source labels can contain abbreviations, spelling differences, or partial-region names. Do not treat automatic normalization as medical source checking. |
| Commercial use | Selected files use the repository's CC BY 4.0 licence. Required credits and modification notices are recorded; additional assets require their own review. |

The original files remain unchanged. The viewer excludes the separate sampling-site
roots, converts geometry into a local Godot cache, and applies temporary selection
colours, transparency, and inspection displacements. No disease models or anatomical
reconstructions have been created.

## Decision

Accept these files provisionally for testing both reference bodies, the continuous
scene, selection, visibility, and restoration. Retain the comprehensive two-body
requirement. These samples are not an accepted complete atlas and do not close the
Stage 1 feasibility gate. Supplemental geometry, medical review, baseline-device
performance, accessibility, and Windows/macOS trials remain necessary.
