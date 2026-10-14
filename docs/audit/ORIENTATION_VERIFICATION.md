# Source orientation and camera views

Runtime snapshot: `cc705b82e65de49bf3418d8403c2d0a05990ff87`, Godot
`4.7.2.stable.official.ed1daf0bf`. Recorded on the America/Edmonton client date
2026-10-14; source/development checks began on 2026-10-13. Packages remain local and private.

Camera views now offers Front, Back, From body left/right and angled Above/Below
around the current focus. The persistent direction cue follows camera rotation;
left/right refer to the body. Presets preserve the focus point and distance,
selection, labels, isolation, anatomy edits and inspection undo. They leave Move
mode and participate in Back/Forward. Labels avoid the cue's rectangle, and loading
guards block camera actions during reference replacement.

Direction metadata must match the reference fingerprint and define an orthonormal
frame with the expected handedness. Missing, stale or invalid metadata disables
named views and displays Orientation unavailable. [Source checks](REFERENCE_ORIENTATION.md)
record 23 actual-vertex landmark comparisons and the official BodyParts3D diagram;
they corroborate technical directions without supplying qualified medical review.

## Verification

- All 36 Python checks pass, including source mirrors, transforms, ambiguous
  landmarks, changed hashes and mandatory orientation metadata in package records.
- Real-geometry tests exercise all six views in both workspace modes at Native
  and 50%, across female, male and the separate bone study. They check preserved
  focus/distance, isolation, edits/undo, history, menu keyboard access/dismissal,
  loading guards and label clearance. Invalid reflected, nonunit, nonfinite,
  missing and stale frames are rejected. Existing display/picking/saved-view
  regression checks also pass.
- Six compact development captures were inspected. [Development record](orientation-development-qa.json)
  retains logs/hashes. Those tests use the `0f5997e` implementation; `cc705b8`
  subsequently corrects developer-verifier feedback after restoring its camera.
- Both packages pass exported Linux offline/missing-content checks. The Mac pack
  passes embedded-content and independent resource-boundary checks on the development
  engine, including every reference and its directions. This does not run macOS.
- The actual Windows release passes all six presets for each reference and the
  existing inspection, label/resolution, notes, source search, failed replacement,
  keyboard, saved-view and credited screenshot workflows. All 27 Windows captures
  were inspected. [Native record](windows-orientation-viewer-qa.json),
  [runtime log](windows-orientation-viewer-runtime.log.txt).
- Both ZIPs pass CRC, architecture, source, notice and anatomy-fingerprint checks.
  [Build record](windows-orientation-build-report.json), [artifact audit](windows-orientation-artifact-audit.json),
  [final exported-runtime log](orientation-native-build-final.log.txt).

## Inspect the result

- [Female side view](../prototype/windows-orientation-native-orientation-female.png)
- [Male side view](../prototype/windows-orientation-native-orientation-male.png)
- [Bone-study side view](../prototype/windows-orientation-native-orientation-bodyparts-male-bones-study.png)
- [Compact cue](../prototype/orientation-compact-bodyparts-male-bones-study.png)
  and [camera menu](../prototype/orientation-compact-menu-bodyparts-male-bones-study.png)

## Packages and remaining work

| Archive | Bytes | SHA-256 |
|---|---:|---|
| Windows x64 | 290,849,928 | `1c2e8e2bb2dcba5c839b6fed35f961fee32fab23152eab6a27223543f37674a8` |
| macOS Universal | 313,296,087 | `5440d1239fb9b7a9c2711de6da6bd42c567eacee044a70011a73f4dd7a6f909b` |

The anatomy pack remains 543,019,684 bytes, SHA-256
`d0ac48d536a2ff02c55d4416c366441160977c9d881f634ab7978bcd395d013b`.
Windows remains unsigned; Mac remains ad-hoc signed and not notarized.

No new sustained rendering trial was run. The [full-HD profile](WINDOWS_FULLHD_PROFILE.md)
stays bound to the preceding `ae60019` runtime and its recorded artifact.
Native Windows verification uses AMD Radeon graphics and isolated user data;
it supplies scripted functional evidence, not human input/accessibility acceptance
or actual Mac execution. Development software-renderer timings are not performance
evidence. Medical review, broader anatomy and public-release requirements remain open.

[Remaining implementation](../IMPLEMENTATION_BACKLOG.md) includes part-level menus,
portable saved views, coverage admission, guided separation, source-backed medical
content and explicit pathways. These can progress alongside
[human/platform trials](../PRIVATE_TRIAL_GUIDE.md).
