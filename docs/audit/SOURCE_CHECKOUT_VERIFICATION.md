# Fresh source setup verification

Checked 2026-10-19. The documented source setup passes from a clean archived Git
tree on the Linux development engine. No application change was needed. Mac
execution remains deferred at the user's request.

## Identity and isolation

- Source revision: `5f66a58cc198fbb22397bddf86c022ddb79de7e4`.
- Engine: `4.7.2.stable.official.ed1daf0bf`, Linux, headless.
- All 1,675 tracked files were extracted with `git archive`; no prior `.godot`
  directory, prepared geometry or downloaded anatomy was included.
- Pinned source files were copied from separately size/hash-verified local
  downloads. The fetch commands verified and reused them. This run did not test
  a new HTTP download.
- The 79 export inputs match the existing `c86cfba` private candidate exactly:
  fingerprint `72347b3bb7ef35baf9eae06dd7cb5bb10f3fa8ca6e7064e63eb3353e10af4bb0`.
- Engine data/config/cache and test saves used the temporary copy's isolated
  directories. No personal library or clipboard was accessed.

## Results

The two-body setup prepared 801 female and 788 male meshes directly from raw GLBs
without existing geometry caches. Initial preparation took 304.616 seconds on this
host. A second preparation reused the generated files without changing their
bytes or modification times.

The optional setup reproduced the 203-mesh bone study's pinned GLB and catalogue
exactly, then prepared all seven references. The four spinal studies contain
29, 25, 30 and 24 meshes respectively. The complete prepared set has 1,900 meshes;
the supplemental studies remain unregistered to either whole-body reference.

Existing integration checks passed against this copy:

- `viewer_smoke.gd`: real-body selection, visibility, movement/restoration and
  physics picking for both HRA references.
- `build_identity_smoke.gd`: development-checkout identity and Sources behavior.
- `study_workspace_smoke.gd`: core study/guide/transfer checks before adding studies,
  then the same workflow with the four spinal references available.
- `reference_startup_smoke.gd`: remembered reference, failed-switch preservation
  and unavailable-reference fallback with the supplemental content installed.
- `saved_views_smoke.gd`: saved-view persistence/restoration for both HRA bodies
  and the regenerated bone study.

All retained commands exited zero with no runtime errors or object leaks. After
setup and checks, every tracked file remained byte-identical to the recorded Git
tree. The temporary source, geometry and user-data directories were removed and
their absence was checked independently.

[The report](source-checkout-report.json) retains source hashes, exact reference
counts, timings and the sizes/hashes of all twelve command logs. This verifies
the development source workflow; it does not execute macOS, establish device
usability/performance acceptance or supply qualified anatomical review.

Follow [source setup](../PROTOTYPE.md#requirements-and-setup), including the
[Mac commands](../PROTOTYPE.md#mac-source-checkout), for a later checkout. Record
that checkout's actual revision with any trial observations.
