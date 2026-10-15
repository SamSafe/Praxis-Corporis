# Study workspace verification

Recorded on the America/Edmonton client date 2026-10-15. Final private runtime:
`8a44cdb861e044b23b8fa73f2cd5ca6ba8f597e5`, Godot
`4.7.2.stable.official.ed1daf0bf`. Usage and scope are in the
[study workspace guide](../STUDY_WORKSPACE.md).

## Implemented behavior

- Portable JSON view/note export and previewed import, preserving existing libraries,
  renaming collisions, skipping unchanged duplicates and incompatible references.
- Fifteen source-checked draft heart/lung cards with explicit related structures,
  primary-source links and pending medical-review status.
- Six guided chest steps in both HRA bodies, including separated supplied chambers,
  with exact starting-state and history restoration on completion.
- Remembered panel/resolution/label preferences and 100/115/130% text; source/mesh
  details can be expanded separately from learning text.
- Four independent HRA spinal studies: 108 source meshes, with original geometry,
  source indices, coordinates, missing metadata and separate coverage records.

## Evidence

| Check | Result and retained evidence |
|---|---|
| Python tools/content | All 41 checks pass. [Log](study-workspace-python.log.txt). Profiling tools preserve older eight-workload artifacts and bind the expanded sixteen-workload plan to committed source metadata. |
| Engine source checks | Eighteen smoke scripts pass across development, including portable saves, damaged/stale imports, preferences, real guide restoration, existing exploration/loading and small-surface picking. [Indexed logs and hashes](study-workspace-development-qa.json). Exact final packaged checks are recorded separately below. |
| Picking precision | Actual physics rays and first-hit labels pass for all four spinal sources. Every triangle is retained; sampled inverse-normalized vertices differ from mesh faces by at most 0.0000000601 metres. [Precision log](study-workspace-spinal_picking_smoke.log.txt). |
| Real GUI menu regressions | Actual root input passes for all seven references, two workspace modes, two window sizes and Native/50% rendering: 56 combinations. Strict surface-anchor checks pass, alongside hide/fade, stale selection, loading guards, Move, undo/redo and restoration. [Log](study-workspace-part_actions_smoke.log.txt). |
| Exported offline resources | Linux QA runtime and Mac embedded content pass all seven references, plus view/note transfer, guide restoration, preferences, source search, failed replacements and existing workflows. Missing-content handling and exported-resource boundaries pass. Mac content is checked with the development engine. [Build log](study-workspace-build.log.txt), [fixed build report](study-workspace-build-report.json). |
| Actual Windows | The exact final Windows archive passes native AMD OpenGL rendering and workflows for all seven references. All 86 captures were reviewed through seven reference contact sheets. The female cord action menu, female guided view and expanded female vertebra menu were also inspected individually at full size. [Report and image hashes](study-workspace-windows-qa.json), [raw runtime log](study-workspace-windows-runtime.log.txt). |
| Compact text | Linux rendered screens at 1100 × 720 and 130% text were inspected, including the long unresolved source record. These are readability checks, not accessibility acceptance or performance evidence. [Capture log](study-workspace-compact-render.log.txt), [selected image hashes](study-workspace-selected-captures.json). |
| Short native profiler | Sixteen one-second samples and seven loads pass raw-data, workload and artifact validation at an actual 1920 × 1080 expanded/native buffer. All samples retained focus. This is a short diagnostic, not sustained performance acceptance. [Validated summary](STUDY_WORKSPACE_PROFILE_SMOKE.md), [raw data](study-workspace-profile-raw.json), [native evidence](study-workspace-profile-report.json). |
| Archive identity | CRCs, executable architectures, notices, source hashes, Windows companion anatomy and Mac embedded-content/seal checks pass. [Fixed artifact audit](study-workspace-artifact-audit.json). |

The new cards use original short summaries of the primary sources linked in the
app/catalogue. Source checking is separate from qualified medical review and does
not establish the completeness of mesh interiors.

## Initial failed trial and correction

The `acee078` Windows trial passed both original HRA bodies and the bone study, then
failed on female spinal-cord surface labels. The unmodified failed log is
[retained](study-workspace-initial-failed-windows.log.txt); its archives/report remain
under `dist/study-improvements-initial/` and are not the current builds.

Source-frame probes found zero ray hits on those small triangles with the original
metre-scale collision representation. A 100× picking representation and inverse
collision-node transform restored hits without changing display meshes, triangle
topology or source coordinates. The prepared batches record this scale, and the
runtime rejects incompatible caches before replacing the live reference. Original
HRA/BodyParts3D picking resources retain scale 1. The final normalized resources pass
both the strict development anchor tests and the actual Windows trial.

## Selected screens

- [Female guided chambers](../prototype/study-workspace-guided-female.png) and
  [male guided chambers](../prototype/study-workspace-guided-male.png).
- [Corrected female cord surface actions](../prototype/study-workspace-cord-actions.png).
- [Expanded vertebra actions](../prototype/study-workspace-vertebra-actions.png).
- [Large study text](../prototype/study-workspace-large-text.png),
  [unresolved source metadata](../prototype/study-workspace-metadata-gap.png), and
  [duplicate import preview](../prototype/study-workspace-import-preview.png).

Contact sheets: [female](../prototype/study-workspace-contact-female.png),
[male](../prototype/study-workspace-contact-male.png),
[bone study](../prototype/study-workspace-contact-bodyparts-male-bones-study.png),
[female cord](../prototype/study-workspace-contact-hra-v1-2-female-cord-study.png),
[female vertebrae](../prototype/study-workspace-contact-hra-v1-2-female-vertebrae-study.png),
[male cord](../prototype/study-workspace-contact-hra-v1-2-male-cord-study.png),
[male vertebrae](../prototype/study-workspace-contact-hra-v1-2-male-vertebrae-study.png).

## Packages and limits

Current archives are under `dist/study-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| Windows x64 | 328,074,341 | `2196875b10942fefb4810805af278284f874f762fa42b3b6dda38f01704ef645` |
| macOS Universal | 350,520,504 | `5549a61a59d5fe9f8ef391780720e06139e79ab0e1b508fb581bef2f712515be` |

Anatomy pack: 624,166,432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

Archives remain local/private. Windows is unsigned; Mac is ad-hoc signed and not
notarized. Actual Mac execution, human mouse/trackpad/clipboard/picker trials,
assistive-technology acceptance and qualified medical review remain open. The new
spinal studies do not complete or register a whole skeleton within either United
body. The earlier sustained profile retains its original source identity; this
short diagnostic does not replace it or establish representative hardware coverage.
