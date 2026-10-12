# Initial feasibility results

Date: 2026-10-11. Scope: private viewer prototype and two pinned HRA v1.1 samples.
This record documents actual checks; it does not close the full Stage 1 gate.

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`, Standard Linux x86_64 build.
- Official binary ZIP SHA-256:
  `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`.
- Linux 6.6.87.2 Microsoft WSL2 host; 12 logical CPUs visible to Python.
- Compatibility renderer, OpenGL 4.5, Mesa 25.2.8, llvmpipe software rendering
  (LLVM 20.1.2, 256 bits). The driver could not change V-Sync mode.
- Rendered desktop reference size: 1440 × 900.
- Godot user/editor data redirected to /tmp during automated development tests;
  the rendered save test used its own temporary saved-view slot.

Software rendering permits visual inspection here; it is not a representative
Windows or Mac GPU benchmark. RAM usage, sustained FPS and target-device usability
have not been measured against the release targets.

## Results

| Check | Result |
|---|---|
| Source downloads and integrity | Both original GLBs and retained licence/README verified against pinned sizes and SHA-256 hashes. |
| Python ingestion checks | Four checks passed: malformed GLBs/external buffers, invalid hierarchy, modified files/path escape, and both-body catalogue references/sampling-site exclusion. |
| Real geometry import | Female: 801 anatomy mesh nodes; male: 788. The separate sampling-site roots are excluded. |
| Multi-mesh inspection | Heart components move together; selected/group restoration returns the original bounds and transforms. |
| Undo and saved states | Visibility and displacements recover together; invalid states leave the body unchanged. |
| Actual ray picking | Visible skin is picked; hidden skin no longer intercepts; exposed heart components map correctly; faded isolated anatomy is click-through. Passed for both bodies. |
| Selection appearance | Group meshes highlight correctly after normalization of JSON numeric indices. |
| Desktop input routing | Native UI mouse clicks reach 3D selection; viewport dragging changes camera orbit and explicit Move mode displaces selected anatomy. |
| Saved-view UI workflow | A moved, partially revealed scene survives Save view, restoration, and Load view. The test used an isolated file and removed it afterward. |
| Visual inspection | Whole-body female view, both chest views, female orbit and displaced-heart views inspected. Geometry stays in the continuous body scene. |

The tests use [viewer_smoke.gd](../tests/viewer_smoke.gd),
[capture_viewer.gd](../tests/capture_viewer.gd) and
[test_content_tools.py](../tests/test_content_tools.py). Setup and commands are in
[PROTOTYPE.md](PROTOTYPE.md).

## Loading observations

In the successful preparation run:

| Operation | Female | Male |
|---|---:|---:|
| Raw GLB parsing | 163.20 s | 172.76 s |
| Full preparation, including scene/collisions/cache save | 173.29 s | 180.43 s |
| Compiled scene size | 173,598,694 bytes | 177,219,068 bytes |
| Prepared-scene load, final headless integration trial | 5.42 s | 4.98 s |
| Prepared-scene load, a successful rendered workflow trial | 5.30 s | 4.95 s |

Load timing begins after source hash verification. These are development observations,
not controlled cold/warm-start benchmarks. Some trials ran concurrently. They show
why raw runtime GLB parsing is unsuitable as the normal start path for these samples.
The local compiled cache is a useful prototype step; region loading, packaging,
smaller collision representations and geometry optimization still need evaluation.

## Rendered artifacts

- [Whole-body female reference](prototype/whole-body-female.png).
- [Female chest selection](prototype/chest-female.png).
- [Female chest after orbit](prototype/chest-female-orbit.png).
- [Female heart moved for inspection](prototype/heart-moved-female.png).
- [Male chest selection](prototype/chest-male.png).

These are actual app captures, distinct from the earlier schematic wireframes.
Models are credited under [ATTRIBUTIONS.md](../ATTRIBUTIONS.md); source licences and
modification notices apply to these views. Screenshots are not medical review evidence.

## Remaining gate work

Comprehensive geometry for both reference bodies, reviewed source labels/interiors,
qualified medical review, guided routes/separation, prepared cutaways, condition
content, larger-text/accessibility checks, trackpad hardware trials, representative
Windows/Mac performance, native exports/signing and save migration/recovery remain
open. There is no public-release claim or complete-atlas claim.
