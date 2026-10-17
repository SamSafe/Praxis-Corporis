# Keep pointer drags and keyboard movement independently reversible

Source `32b740ad99a479f4292208f758ea6626bb05588e` ends a held pointer gesture
before applying a deliberate keyboard movement step. Checked on 2026-10-17
(America/Edmonton).

Previously, moving anatomy with the mouse, pressing a movement key while still
holding the button, then continuing the drag folded that later mouse motion into
the keyboard step. The [probe](nudge-gesture-before.gd.txt),
[before](nudge-gesture-before.log.txt) and [after](nudge-gesture-after.log.txt)
show active drag changing from 1 to 0 after the key press. Later held motion now
preserves the stepped position. Both versions can undo to the first mouse change;
the fix gives the keyboard step a stable end position.

The shared keyboard movement handler cancels the pointer drag and clears its
pending checkpoint before attempting the step. Move stays selected. Release and
press again to start another drag. A key press at the movement limit also ends
the gesture while retaining an existing Redo branch.

## Development checks

The [mixed-input check](../../tests/nudge_gesture_smoke.gd) passes all seven real
references in workspace/expanded layouts at 100%/50% 3D resolution, with 5 mm and
1 mm key steps: 56 mixed-input cases. It sends actual movement and Undo/Redo key
events, checks that continued held-button motion is inert, starts a fresh drag,
then independently undoes and redoes all three edits. Boundary cases retain Redo.
It restores the original exploration, histories, layout, quality and Move setting.
[Workspace log](nudge-gesture-workspace.log.txt).

Existing keyboard movement and pointer-interruption checks pass in sequential
runs. All 75 Python checks pass, including rejection of native results missing
mixed-input evidence for any reference.
[Keyboard](nudge-gesture-keyboard.log.txt), [pointer](nudge-gesture-pointer.log.txt),
[Python](nudge-gesture-python.log.txt), [check identities](nudge-gesture-development-qa.json).

Medical content/review stages, source geometry/identities, saved-view formats,
movement amounts and edit-history limits are unchanged.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, every reference workflow including mixed-input movement, and two
loading-shutdown cases on the development engine. This does not establish Mac
device execution. [Build report](nudge-gesture-build-report.json),
[build log](nudge-gesture-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, both layouts and rendering resolutions, including both keyboard step
sizes during held Move drags. Continued held motion is inert; a fresh drag, the
keyboard step and the first drag undo/redo independently. Boundary steps retain
Redo. The workflow retains 103 capture identities. Four normal launches pass
reference/window restoration and unavailable-reference fallback. Two early-close
processes pass resource cleanup while preserving user-file bytes, modification
times and identities. No runtime error or ObjectDB leak is reported. The successful
isolated session was removed and independently checked absent.
[Native report](nudge-gesture-windows-qa.json),
[runtime log](nudge-gesture-windows-runtime.log.txt),
[normal launches](nudge-gesture-normal-lifecycle.json),
[initial close](nudge-gesture-native-initial-anatomy.log.txt),
[replacement close](nudge-gesture-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](nudge-gesture-artifact-audit.json).
[Evidence identities](nudge-gesture-evidence.json) bind the retained results.

Private archives are under `dist/nudge-gesture-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328168095 | `e0efaa9ab6f25c77036bd76f1d48f76cba1e3c76acfd0a46a4895760517b40da` |
| PraxisCorporis-macOS-universal-private.zip | 350614109 | `2049674ff1eb3fa7e5bf039bacae2e55a0329f32b15d64574e01febc03ebf292` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks inject input events. Human keyboard/device and accessibility acceptance,
representative laptop trials and actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human source and expert medical review remain pending.
