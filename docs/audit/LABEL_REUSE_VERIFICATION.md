# Reuse stable label placements

Source `9d249d27fee3342a81cce63375e97020ad2b38dd` avoids repeating label placement
and surface queries while the scene and relevant controls are unchanged. The
existing periodic path compares camera/display state, label settings, action
control geometry and visible exclusion rectangles. Model appearance and theme
changes invalidate the result. Explicit placement requests remain immediate and
leave one periodic check after physics/layout settles. Checked on 2026-10-17
(America/Edmonton).

The placement algorithm, candidate/ray budgets and update interval during changes
are retained. Labels continue to use first-hit opaque source surfaces. This adds
no anatomical text, geometry or review promotion.

## Paired idle measurement

Two explicit development-engine runs use the same female chest view, 1440×900
window and 828×657 scene buffer. A counting subclass wraps the actual placement
method. The baseline inherits the unmodified label code from source
`f0a8c28cb021be8688645a340577fbd42178ba9b`; the comparison inherits the current code.
Each run settles for one second, then observes three seconds of physics frames.

| Observation | Original | Reuse |
| --- | ---: | ---: |
| Placement passes | 25 | 0 |
| Placement ray queries | 2,925 | 0 |
| Time inside placement calls | 179,439 µs | 0 µs |

Camera state, anatomy fingerprint, visible IDs, label anchors/rectangles and action
placement are identical. The timed scope excludes the lightweight input comparison
and other application work. This is a development-engine physics/layout observation,
not a GPU, overall-CPU, frame-rate, battery-life or representative-hardware claim.
[Comparison](label-reuse-idle-comparison.json), [baseline](label-reuse-baseline.log.txt),
[reuse](label-reuse-cached.log.txt), [probe](label-reuse-probe.gd.txt),
[counter](label-reuse-counter.gd.txt), [baseline counter](label-reuse-counter-before.gd.txt),
[baseline label source](label-reuse-before.gd.txt).

## Placement and picking checks

The [placement check](../../tests/label_reuse_smoke.gd) passes 112 cases per
reference, **784 total**. Four contexts cover workspace/expanded anatomy, 100%/130%
text and native/50% scene resolution. Cases include camera orbit/pan/zoom, label
toggles/density, leaf selection, raw appearance changes, visibility, action-control
visibility/fallback/minimum size, moving/showing/hiding an exclusion overlay,
suspension/resumption and resizing.

After physics/layout settles, each case advances the existing periodic path,
captures its output and compares it with a fresh solve. Visible anchors are checked
against real first-hit opaque meshes belonging to the named source structure.
Mesh indices are normalized to integers, matching the placement implementation.
The oracle is followed by re-priming the cache before the next mutation, so its
forced update cannot conceal a missing invalidation. Leaf setup/reset/show cases
must have a real visible label. Model, camera, preferences and histories are restored.
[Development log](label-reuse-development.log.txt).

Density/picking, orientation/exclusion, part-action placement and tiny spinal
source-face checks pass. All 86 Python checks pass, including rejection of missing
reference markers, placement rows, wrong contexts, differing hashes, invalid hits
and empty leaf evidence.
[Display](label-reuse-display.log.txt), [orientation](label-reuse-orientation.log.txt),
[actions](label-reuse-actions.log.txt), [spinal precision](label-reuse-spinal.log.txt),
[Python](label-reuse-python.log.txt), [check identities](label-reuse-development-qa.json).

The [negative control](label-reuse-negative.gd.txt) disconnects appearance
invalidation, then moves real geometry without a camera change. The checker rejects
the stale placement. Its [expected-error log](label-reuse-negative.log.txt) is separate
from passing runtime logs. No clipboard operation occurs.

## Private packages

The exact Windows archive passes all **784 placement pairs** with valid first
hits on the native AMD OpenGL renderer. Each retained case records its action,
layout, quality, text scale, visible count and matching cached/fresh hashes.

| Reference | Placement pairs |
| --- | ---: |
| [female](label-reuse-female.json) | 112 |
| [male](label-reuse-male.json) | 112 |
| [bodyparts-male-bones-study](label-reuse-bodyparts-male-bones-study.json) | 112 |
| [hra-v1-2-female-cord-study](label-reuse-hra-v1-2-female-cord-study.json) | 112 |
| [hra-v1-2-female-vertebrae-study](label-reuse-hra-v1-2-female-vertebrae-study.json) | 112 |
| [hra-v1-2-male-cord-study](label-reuse-hra-v1-2-male-cord-study.json) | 112 |
| [hra-v1-2-male-vertebrae-study](label-reuse-hra-v1-2-male-vertebrae-study.json) | 112 |

The run also passes 543 cached/continuous scene-image comparisons and retains 107
capture identities. A [chest capture](../prototype/label-reuse-chest-windows.png)
was visually inspected: anatomy, labels, selected-part actions and study controls
remain visible and readable. Four normal launches pass reference/window
restoration and unavailable-reference fallback. Two early-close processes collect
owned resources while preserving user-file bytes, times and identities. No runtime
error, Unicode replacement diagnostic or ObjectDB leak is reported. The marked QA
session was removed and independently checked absent.
[Native report](label-reuse-windows-qa.json), [runtime](label-reuse-windows-runtime.log.txt),
[normal launches](label-reuse-normal-lifecycle.json),
[initial close](label-reuse-native-initial-anatomy.log.txt),
[replacement close](label-reuse-native-replacement-selection.log.txt).

The build checks unchanged runtime inputs, the embedded Mac resource boundary,
all seven workflows and both shutdown cases on the development engine. The full
embedded-content workflow now has a bounded five-minute limit; the previous
120-second limit stopped it during the final reference without a passing completion.
The independent archive audit passes committed runtime hashes, ZIP-entry CRCs,
notices, architectures, unchanged anatomy identity and Mac resource-seal presence.
[Build report](label-reuse-build-report.json), [build log](label-reuse-build.log.txt),
[audit](label-reuse-artifact-audit.json), [evidence identities](label-reuse-evidence.json).

Private archives are under `dist/label-reuse-verified/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328213429 | `5a82efc41617d39bddb455f8b7bcd4dc7cbd544bea938604255fb6e82e9d90cb` |
| PraxisCorporis-macOS-universal-private.zip | 350658983 | `d823740f22908457b9899f935e749b9f92df3bfe1a74c06b2dab82ab0157efc0` |

Actual Mac execution, human OS-input/accessibility acceptance, representative
hardware and public-release gates remain open. The embedded Mac-resource check uses
the development engine. The separate Linux release-template popup qualification
remains open. Geometry identities, medical text/review stages, saved views and note
behavior are unchanged.
