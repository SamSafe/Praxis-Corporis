# Fine wheel zoom and reciprocal steps

Source `b30b065b161e601089b017c466dec91c45ff8f04` improves wheel, keyboard and pinch zoom. Checked
on 2026-10-16 (America/Edmonton); exact source and artifact identities are below.

Previously, wheel input ignored its reported amount: four quarter-step events
zoomed four full steps. Keyboard/wheel zoom used 0.88 inward and 1.12 outward,
so opposite steps accumulated drift. The camera reproduction starts at distance
2.8 and ends at 1.56742158862171 after 40 keyboard in/out pairs.

Wheel input now honors its amount's magnitude and button direction; an unsupported
zero amount keeps one ordinary step. Keyboard and wheel share reciprocal factors.
The zoom-in step stays 0.88. Finite step amounts are capped before exponentiation,
and the existing near/far distance limits remain. Pinch accepts finite positive
factors without substituting a 0.1 floor; invalid factors leave the view unchanged.
Reversal checks run away from the distance limits.

Godot documents [high-precision wheel amounts and the zero fallback](https://docs.godotengine.org/en/stable/classes/class_inputeventmousebutton.html#class-inputeventmousebutton-property-factor)
and [pinch scale factors](https://docs.godotengine.org/en/stable/classes/class_inputeventmagnifygesture.html#class-inputeventmagnifygesture-property-factor).

## Development evidence

The [camera check](../../tests/camera_zoom_smoke.gd) fails against the previous
camera and passes against the new one. It checks repeated keyboard/fine-wheel
reversal, quarter/multiple/signed/zero wheel amounts, canceled/release events,
non-finite input, both bounds, valid/invalid pinch and suspended input. Zoom emits
no anatomy selection/movement/checkpoint signal and preserves camera target and
orientation. The retained red run has 15 failed assertions, not 15 separate
reported defects. [Before](camera-zoom-before.log.txt), [after](camera-zoom-after.log.txt).

The [workspace check](../../tests/zoom_workspace_smoke.gd) passes all seven real
references in workspace/expanded layouts at 100%/50% rendering resolution.
It sends keyboard, fractional wheel and pinch events through the root GUI and
SceneSurface. It checks equivalent wheel/key steps, reversal without drift,
pointer zoom preserving Move mode, invalid pinch rejection and unchanged anatomy,
selection, isolation, labels and both histories. It restores the exact starting
camera and layout. [Workspace log](camera-zoom-workspace.log.txt).

Existing keyboard workspace and density/picking/orbit/pan/Move checks pass.
All 68 Python checks pass, including rejection of native logs missing camera-zoom
evidence for any reference. [Keyboard](camera-zoom-keyboard.log.txt),
[display](camera-zoom-display.log.txt), [Python](camera-zoom-python.log.txt),
[check identities](camera-zoom-development-qa.json).

To reproduce the red check, save the previous committed `scripts/orbit_camera.gd`
to a disposable `.gd` file and run the current camera check with
`-- --orbit-script=/absolute/path/to/that/file.gd`. The check index records that
commit and camera SHA-256.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, every reference workflow including camera zoom, and two loading
shutdowns on the development engine.
[Build report](camera-zoom-build-report.json), [log](camera-zoom-build.log.txt).

The exact Windows archive passes native AMD OpenGL zoom verification on all seven
references, through both layouts and rendering resolutions. The runtime checks
keyboard/wheel equivalence and reversal, fine amounts, valid/invalid pinch,
preserved Move mode for pointer zoom, and unchanged anatomy and histories.
The existing workflows retain 94 capture identities. Four normal launches pass
reference/window restoration and unavailable-reference fallback. Two separate
early-close processes pass owned-resource cleanup and staged-scene release while
preserving user-file bytes, modification times and file identities.
No runtime error or ObjectDB leak is reported. The successful generated session
was removed and independently checked absent.
[Native report](camera-zoom-windows-qa.json), [runtime log](camera-zoom-windows-runtime.log.txt),
[normal launches](camera-zoom-normal-lifecycle.json),
[initial close](camera-zoom-native-initial-anatomy.log.txt),
[replacement close](camera-zoom-native-replacement-selection.log.txt).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](camera-zoom-artifact-audit.json),
[evidence identities](camera-zoom-evidence.json).

Private archives are under `dist/camera-zoom-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328147578 | `a6b119db35b371678f01d9cf8133caa1fa87c769d5eff3f80ad0e7de5ee90948` |
| PraxisCorporis-macOS-universal-private.zip | 350593607 | `955c976375443724a7f38e25c8a1cf1c2f17de60880cada653cdee61642c0541` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks inject input events; actual device sensitivity, driver behavior and
human trackpad/pinch acceptance remain trial work. Actual Mac execution remains
pending. The independent [Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md)
remains open; Linux is not a release target. Medical content, anatomy/source
identities and saved-view formats are unchanged, with human source and expert
review pending.
