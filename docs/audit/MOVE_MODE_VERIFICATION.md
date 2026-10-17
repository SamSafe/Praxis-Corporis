# Start a fresh gesture after changing Move mode

Source `0ac05d5f8ceacf487556dff9cf1a45fdbb760908` ends the held pointer gesture when Move is switched on or off.
Checked on 2026-10-17 (America/Edmonton).

Previously, pressing M during an orbit drag left the button active. Continuing
with the same held button began moving anatomy. Switching off Move during a drag
similarly turned its remaining motion into camera orbit. The
[probe](move-mode-before.gd.txt), [before](move-mode-before.log.txt) and
[after](move-mode-after.log.txt) show both transitions changing from active drag 1
to 0, with anatomy and camera staying at their switch-time positions.

The shared Move toggle now cancels the drag and clears its pending movement
checkpoint before applying the chosen mode. Keyboard, toolbar and part/expanded
actions share this handler. A fresh press begins the chosen move or camera
gesture. Completed inspection edits and their histories remain intact.

## Development checks

The [mode-switch check](../../tests/move_mode_smoke.gd) passes all seven real
references in workspace/expanded layouts at 100%/50% 3D resolution, in both switch
directions: 56 gesture-transition cases. It sends real M key events during a held
drag, checks that later held-button motion and release leave the view unchanged,
then checks a fresh gesture's camera/anatomy effect and edit-history boundary.
The original exploration, histories, layout, quality and Move setting are restored.
[Workspace log](move-mode-workspace.log.txt).

Existing keyboard movement and pointer-interruption checks pass in sequential
runs. All 74 Python checks pass, including rejection of native results missing
mode-switch gesture evidence for any reference.
[Keyboard](move-mode-keyboard.log.txt), [pointer](move-mode-pointer.log.txt),
[Python](move-mode-python.log.txt), [check identities](move-mode-development-qa.json).

Medical content/review stages, source geometry/identities, saved-view formats,
movement amounts and edit-history limits are unchanged.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, every reference workflow including both mode-switch directions, and two
loading-shutdown cases on the development engine. This does not establish Mac
device execution. [Build report](move-mode-build-report.json),
[build log](move-mode-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, both layouts and rendering resolutions, including both mode-switch
directions. Held-button motion and release preserve the switch-time view; fresh
gestures apply the chosen camera/anatomy behavior and correct history boundary.
The workflow retains 103 capture identities. Four normal launches pass reference/
window restoration and unavailable-reference fallback. Two early-close processes
pass resource cleanup while preserving user-file bytes, modification times and
identities. No runtime error or ObjectDB leak is reported. The successful isolated
session was removed and independently checked absent.
[Native report](move-mode-windows-qa.json), [runtime log](move-mode-windows-runtime.log.txt),
[normal launches](move-mode-normal-lifecycle.json),
[initial close](move-mode-native-initial-anatomy.log.txt),
[replacement close](move-mode-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](move-mode-artifact-audit.json).
[Evidence identities](move-mode-evidence.json) bind the retained results.

Private archives are under `dist/move-mode-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328167203 | `3f4b0610883822d3528db2ccc54d1bfe8934d58d90bcb74e63e34fff1407bef1` |
| PraxisCorporis-macOS-universal-private.zip | 350612941 | `dc81b5413cba6ff602a5cccfb10869e3686689515d1c80dc6f6edc7c390c7f4e` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks inject input events. Human keyboard/device and accessibility acceptance,
representative laptop trials and actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human source and expert medical review remain pending.
