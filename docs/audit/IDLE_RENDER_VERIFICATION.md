# Reuse unchanged anatomy frames

Source `9dcc16c5c19435e60da91d1c1abbd64089ce79c9` reuses the last 3D frame while the anatomy is still. Camera,
model-appearance and display changes request a fresh frame. The implementation is
small: camera and appearance signals, their viewer connections, and one redraw
request in the existing display-change handler. Checked on 2026-10-17
(America/Edmonton).

Appearance invalidation includes original-position overlays, direct appearance
refreshes and reference clearing. Using only the existing model-state signal would
miss the overlay toggle. Requests within one frame coalesce naturally. Current
anatomy, materials and lighting are static; future animation needs a corresponding
rendering policy. Godot's [viewport implementation](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/servers/rendering/renderer_viewport.cpp)
turns a one-time viewport update off after drawing and totals draw counts for the
viewports drawn in that frame.
The [node getter](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/scene/main/viewport.cpp)
retains the requested mode; idle draw counts provide the renderer-side check.
Each request sets that mode unconditionally; the cached node property must not
suppress a new request after the rendering server has consumed the previous one.

## Initial measurement

Before changing application code, a development-engine probe compared the female
whole-body view with continuous rendering, a cached frame, and continuous rendering
again. Global draw calls were **977 → 176 → 977**, removing the repeated 801-mesh
scene draw. All three PNG files are byte-identical, SHA-256
`3117a595413f80e040c8ef7961572d1ded0dd9453c2a6eab7b08cb79c52514ea`.
The image was visually inspected and contains the supplied whole-body reference.
[Probe](idle-render-software-probe.gd.txt), [log](idle-render-software.log.txt),
[samples](idle-render-software.json), [continuous](idle-render-software-always.png),
[cached](idle-render-software-cached.png), [continuous again](idle-render-software-always-again.png).

This probe used llvmpipe software rendering and explicit draw calls. Its JSON
`pixels_sha256` hashes the hex-encoded pixel bytes; the PNG file identity above is
a separate byte-level check. Frame intervals are not hardware-performance evidence.
An earlier attempt against the hardened Windows export could not override its main
script; that isolated normal-app window was closed and its marked session removed.

## Development checks

The [redraw check](../../tests/scene_render_smoke.gd) passes all seven real references.
It exercises workspace/expanded layouts, native/50% scene resolution, 100%/130% text,
and 1100×720/1440×900 windows. Actions cover orbit, pan, zoom, clearing/highlighting,
context/isolation, movement, original-position overlays, Undo/Redo, Fade/Hide,
part restoration, saved-view restoration and the two HRA study flows.
Fade/Hide use a visible source leaf with the isolation mask removed.
[Development log](idle-render-development.log.txt).

The [checker](../../scripts/scene_render_verification.gd) verifies immediate redraw
requests for camera/model actions. Display changes can settle through deferred
layout; a no-op display action preserves any redraw already requested by setup.
Native comparisons wait for layout, compare raw image bytes against continuous
rendering, then resume caching. Image dimensions and formats must agree.

Existing density/picking and expanded-control checks pass, as does profile-option
validation. All 83 Python checks pass, including rejection of missing reference
markers, missing/different pixel evidence and incomplete/non-reduced idle counts.
[Display log](idle-render-display.log.txt), [profile log](idle-render-profile.log.txt),
[Python](idle-render-python.log.txt), [check identities](idle-render-development-qa.json).

The [negative control](idle-render-negative.gd.txt) deliberately disconnects camera
and model redraw signals. Both cases are rejected. Its
[expected-error log](idle-render-negative.log.txt) is separate from passing runtime logs.

## Native Windows and private packages

The final exact Windows archive is checked with the pinned native runtime and AMD
OpenGL renderer. The retained report binds each comparison and draw sample to its
reference and source archive.

All **543 raw image pairs match**: 79 per main HRA reference and 77 per separate
bone/spinal reference. Each comparison retains its action, layout, quality, text
scale, dimensions and both raw pixel hashes. The table uses the minimum continuous
and maximum cached global draw calls across 12 idle samples per mode.

| Reference | Identical pixel pairs | Continuous minimum | Cached maximum |
| --- | ---: | ---: | ---: |
| [female](idle-render-scene-render-female.json) | 79 | 314 | 175 |
| [male](idle-render-scene-render-male.json) | 79 | 346 | 177 |
| [bodyparts-male-bones-study](idle-render-scene-render-bodyparts-male-bones-study.json) | 77 | 579 | 173 |
| [hra-v1-2-female-cord-study](idle-render-scene-render-hra-v1-2-female-cord-study.json) | 77 | 229 | 171 |
| [hra-v1-2-female-vertebrae-study](idle-render-scene-render-hra-v1-2-female-vertebrae-study.json) | 77 | 221 | 171 |
| [hra-v1-2-male-cord-study](idle-render-scene-render-hra-v1-2-male-cord-study.json) | 77 | 231 | 171 |
| [hra-v1-2-male-vertebrae-study](idle-render-scene-render-hra-v1-2-male-vertebrae-study.json) | 77 | 219 | 171 |

The existing workflow also passes with 107 capture identities. A
[chest capture](../prototype/idle-render-chest-windows.png) was visually inspected:
anatomy, selected-heart highlighting, labels and study controls remain rendered.
Four normal launches pass reference/window restoration and unavailable-reference
fallback. Two early-close processes collect owned resources while preserving
user-file bytes, times and identities. The main runtime reports no error, decoder
replacement diagnostic or ObjectDB leak. The marked QA session was removed and
independently checked absent.
[Native report](idle-render-windows-qa.json), [runtime](idle-render-windows-runtime.log.txt),
[normal launches](idle-render-normal-lifecycle.json),
[initial close](idle-render-native-initial-anatomy.log.txt),
[replacement close](idle-render-native-replacement-selection.log.txt).

The final build passes its embedded Mac resource boundary, all seven headless
reference workflows and both shutdown cases using the development engine.
Committed runtime hashes remain unchanged during the build. Archive CRCs,
architectures, notices, source hashes, unchanged anatomy fingerprint and Mac resource
seal presence pass the independent artifact audit.
[Build report](idle-render-build-report.json), [build log](idle-render-build.log.txt),
[audit](idle-render-artifact-audit.json), [evidence identities](idle-render-evidence.json).

Private archives are under `dist/idle-render-final/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328197216 | `3c36c4b04bdd76f4b3cf07710e7be14a68b142aef09ed5385ff96eae716ff0e0` |
| PraxisCorporis-macOS-universal-private.zip | 350643158 | `767841e0bba6388babd446b3106bd3f54ea62ed6fedee7d95506c3b60de9a5c0` |

Draw counts measure submitted rendering work for these static scenes. They do not
measure GPU time, power, battery life, presentation latency or representative-laptop
performance. Normal UI processing continues. Selected scene resolution is retained.

The embedded Mac-resource workflow runs on the Linux development engine and does
not establish actual Mac execution. Mac device trials, human input/accessibility
acceptance, representative hardware and public-release gates remain open. The
separate Linux release-template popup qualification remains open. Geometry,
medical text, review stages, source identities and saved-view format are unchanged.
