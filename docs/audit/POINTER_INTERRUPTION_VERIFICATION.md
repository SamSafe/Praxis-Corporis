# Interrupted pointer gestures

Source `2c20e864886fca91e4318d4bf87ec2984e169749` stops interrupted orbit, pan
and Move gestures. Checked on 2026-10-16.

Previously, a missing mouse-release event left the camera's active button set.
Later pointer motion could continue navigating or moving anatomy even without
that button held. Window/application focus loss did not clear the gesture, and a
canceled release could request a selection.

The camera now clears gesture bookkeeping on focus loss, canceled button events
and motion that no longer includes its active button. Leaving the 3D control's
keyboard focus also cancels its gesture. Camera position, existing anatomy edits,
selection, histories and the chosen Move setting remain. A new deliberate Move
drag starts a separate undo checkpoint.

Godot documents [window/application focus notifications](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-constant-notification-wm-window-focus-out)
and [canceled mouse-button events](https://docs.godotengine.org/en/stable/classes/class_inputeventmousebutton.html#class-inputeventmousebutton-property-canceled).
The motion guard uses the event's [held-button mask](https://docs.godotengine.org/en/stable/classes/class_inputeventmouse.html#class-inputeventmouse-property-button-mask).

## Source evidence

The [camera check](../../tests/pointer_interruption_smoke.gd) fails against the
previous committed camera and passes against the new one. It exercises missing
releases for left/right/middle navigation and Move, mismatched and combined button
masks, both focus-loss notifications, canceled clicks, continued valid drags and
fresh undo checkpoints. The retained red run has 11 failed assertions; these are
regression observations, not 11 separate user-reported defects.
[Before](pointer-interruption-before.log.txt), [after](pointer-interruption-after.log.txt).

The [workspace check](../../tests/pointer_workspace_smoke.gd) passes real source
geometry for all seven references, workspace and expanded layouts, and 100%/50%
rendering resolution. It sends button/motion events through the root GUI and
SceneSurface. Each layout/resolution exercises missing release, window focus,
application focus, control focus and canceled release. It checks no continued
movement or unintended selection, a fresh deliberate drag, and two exact undo
steps back to the starting anatomy. Canceled taps preserve the source view and
navigation histories. [Workspace log](pointer-workspace.log.txt).

Existing screen-density picking/orbit/pan/Move, selection-bound Actions and Find
anatomy checks pass. All 66 Python checks pass, including rejection of native
reports missing a pointer-interruption marker for any reference.
[Display](pointer-scene-display.log.txt), [Actions](pointer-part-actions.log.txt),
[Find](pointer-find.log.txt), [Python](pointer-python.log.txt),
[check identities](pointer-development-qa.json).

To reproduce the red camera check, write
`git show d1d81892a2926b2303ed81392410300e8fcb1d56:scripts/orbit_camera.gd`
to a disposable `.gd` file. Run the current camera check with
`-- --orbit-script=/absolute/path/to/that/file.gd`.

## Private packages

The build retains unchanged runtime inputs and passes the Mac embedded-content
boundary, all seven references and their interruption checks, plus initial and
replacement loading shutdowns on the development engine.
[Build report](pointer-build-report.json), [log](pointer-build.log.txt).

The exact Windows archive passes native AMD OpenGL verification of all seven
references. Its interruption checks cover 20 rounds per reference across the two
layouts, two resolutions and five interruption cases, plus canceled taps. The
existing bundled workflows pass and retain 94 capture identities. Four normal
launches check reference/window restoration and unavailable-reference fallback.
Two separate early-close processes check owned-resource cleanup, staged-scene
release and unchanged user-file bytes, modification times and file identities.
No runtime error or ObjectDB leak is reported. The successful generated session
was removed and independently checked absent.
[Native report](pointer-windows-qa.json), [runtime log](pointer-windows-runtime.log.txt),
[normal launches](pointer-normal-lifecycle.json),
[initial close](pointer-native-initial-anatomy.log.txt),
[replacement close](pointer-native-replacement-selection.log.txt).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Artifact audit](pointer-artifact-audit.json),
[evidence identities](pointer-evidence.json).

Private archives are under `dist/pointer-interruption-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328140938 | `40a5d9cfd68f9f02d9b8189e4457bb7ed1beb7aaf533137cb259571319694649` |
| PraxisCorporis-macOS-universal-private.zip | 350586842 | `971fb7963383b7bf1407486fe709b3af7b7b158ad3b2027cbc6df0616235e181` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Focus notifications and pointer events are injected by scripted checks; actual
Alt-Tab, native capture loss, unusual input devices and human interaction remain
manual trial work. The private trial guide now includes interruption tasks.
Actual Mac execution remains pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Medical content, anatomy/source identity and
saved-view formats are unchanged, with human source and expert review pending.
