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
- [Female heart with local labels](prototype/heart-labels-female.png).
- [Male heart with local labels](prototype/heart-labels-male.png).
- [Smaller-window label view](prototype/heart-labels-compact.png).
- [Whole-heart inspection, female](prototype/heart-inspection-female.png).
- [Supplied mitral valve inspection, female](prototype/valve-inspection-female.png).
- [Return to female chest context](prototype/inspection-return-female.png).
- [Whole-heart inspection, male](prototype/heart-inspection-male.png).
- [Supplied mitral valve inspection, male](prototype/valve-inspection-male.png).
- [Return to male chest context](prototype/inspection-return-male.png).
- [In-app source coverage comparison](prototype/coverage-skeleton.png).

These are actual app captures, distinct from the earlier schematic wireframes.
Models are credited under [ATTRIBUTIONS.md](../ATTRIBUTIONS.md); source licences and
modification notices apply to these views. Screenshots are not medical review evidence.

## Remaining gate work

Comprehensive geometry for both reference bodies, reviewed source labels/interiors,
qualified medical review, guided routes/separation, prepared cutaways, condition
content, larger-text/accessibility checks, trackpad hardware trials, representative
Windows/Mac performance, public signing/distribution and save migration/recovery remain
open. There is no public-release claim or complete-atlas claim.

## Follow-up inspection and packaging trial

The updated viewer adds redo, branching inspection history, Escape/Whole body exit
from Move mode, and optional original-position overlays. Both-body integration
passed: overlays retain baseline bounds, do not intercept actual physics picking,
and disappear on restoration. Rendered mouse movement, undo/redo and saved-view
checks passed. The captures above now show these controls and the blue overlays.

Seven Python checks passed, including archive path containment, target architecture
inspection and preservation of Mac executable metadata. The local Godot editor
import completed without script errors.

Private Windows x64 and Mac Universal archives were generated from the verified
source snapshot. Both include runtime, anatomy and notices. Latest artifact/source hashes are
retained in [native-build-report.json](audit/native-build-report.json).

The exported Linux QA runtime loaded both bodies from the companion content package
outside the source project, verified inspection restoration, and rejected a missing
package. The Mac core resource pack also loaded both bodies using the development
engine. Anatomy is embedded before the Mac app is ad-hoc signed, preserving access
when the app location changes. This is content verification, not a Mac device run.
Windows/Mac hardware, performance, trackpad behaviour and public signing/notarization
remain unverified. See [NATIVE_BUILDS.md](NATIVE_BUILDS.md) for setup and limits.

## Local labels and view history trial

Both-body exploration checks passed with zero failures. Heart sets use the 14
supplied physical component meshes; only parts with a found, exposed opaque surface
receive a label. Each tested leader terminates on the named structure's actual
first-hit geometry. Opaque skin suppresses heart labels; hidden and faded anatomy
has no surface labels. Pills stay inside the viewport without overlapping, respect
density limits and prioritize the selected local component. Covered components
remain selectable through the tree. These technical checks do not validate the
source's anatomical names.

Back/Forward recovered selected structures and camera states, including an orbit
performed before leaving the view. Navigation preserved current moved/hidden anatomy
and inspection undo history. New navigation discarded the old forward branch, body
switching cleared history, and component selection retained its heart label context.
Saved views recovered local label context/density; earlier schema-1 views remained
compatible. Malformed density and unrelated organ contexts were rejected before
altering the current view.

The rendered desktop check clicked a component label through the actual UI and
returned to the heart with Back. A scrolling details panel fixed toolbar overflow;
the toolbar containment check also passed at the smaller 1100 × 720 window setting.
Long status messages no longer expand the toolbar; their full text is in tooltips.
The captures above were refreshed. This trial uses the same Linux software renderer
and does not establish Windows/Mac accessibility or performance.

Checks are in [exploration_smoke.gd](../tests/exploration_smoke.gd) and
[capture_viewer.gd](../tests/capture_viewer.gd). Existing both-body geometry integration
and all seven Python checks passed, and editor import reported no script errors.

The private desktop packages were rebuilt from source commit `a093b91`. The exported
Linux QA runtime and embedded Mac resource pack passed both-body restoration,
selection/camera history and heart-catalogue checks. Both ZIPs passed CRC validation,
contained the current notices and new control instructions, and matched the retained
source file hashes. See [the build report](audit/native-build-report.json).
Mac resource verification still uses the Linux development engine, rather than a
Mac device; both target-platform hardware trials remain pending.

## Supplied-part inspection trial — 2026-10-12

The source-based local parts list and Inspect alone/Return to context workflow passed
on both reference samples with zero part-inspection failures. Isolation reveals only
the chosen supplied meshes at their existing body coordinates, including parts whose
ordinary view is hidden or faded. It changes no stored visibility or displacements
and adds no inspection undo checkpoint. Labels, active pick collisions and baseline
overlays agree with the temporary mask.

Tests selected the otherwise hidden mitral valve through the part-list signal, picked
it using actual mesh collision, moved it, undid/redid that move, and returned to the
exact prior camera/selection. The original hidden setting returned and movement edits
remained. History restored the isolated view with its return action. Saves recovered
the mask, return context and stored body edits; malformed return anatomy/cameras and
mismatched selections were rejected before mutating or switching the body. Older
saves loaded with no temporary mask. Whole body, Show chest, Restore all and body
switching left isolation according to their documented scopes.

The rendered workflow clicked Inspect alone, selected the supplied valve in the
scrollable parts tree, moved it through viewport input, and clicked Return to context
for both bodies. The smaller-window toolbar check also passed. Captures above show
the actual source geometry, with no generated interior or clinical-function claim.

The expanded tests exposed and fixed two implementation issues: an untyped empty
array in the selection-label path when local labels were off, and a crash from a
deferred scroll holding a TreeItem that rapid navigation had freed. Label initialization
now uses a typed array; scrolling resolves the current selection after layout, without
queuing item pointers. Both-body exploration and geometry integration checks passed,
all seven Python checks passed, and final editor import reported no script errors.

The new workflow checks are in
[part_inspection_smoke.gd](../tests/part_inspection_smoke.gd). Desktop input verification
is in [capture_viewer.gd](../tests/capture_viewer.gd). Qualified anatomy review,
target-device testing, authored cutaways/separation and verified pathways remain open.

The packages were rebuilt from source commit `6b99a57`. The Windows ZIP is
275,648,793 bytes; the Mac ZIP is 298,094,039 bytes. The exported Linux QA runtime
and the Mac embedded resource pack passed both-body isolation and Return to context
checks as well as the existing offline checks. Both archives passed CRC validation
and retained matching licence/attribution files and updated controls instructions.
Exact current artifact and source hashes are in
[native-build-report.json](audit/native-build-report.json). The Mac check still uses
the Linux development engine; Windows/Mac device trials remain pending.

## Coverage browser and first native Windows trial — 2026-10-12

Coverage notes now map every supplied system root in both catalogues, with a separate
unestablished-coverage entry. The app shows recorded gaps before source counts and
compares both references. Its exploration shortcut resolves the active body's source
group; unestablished groups have no shortcut. The notes are bound to the pinned pack
and source commit and distinguish technical inventory from qualified medical review.
Eight Python checks and both-body coverage UI checks passed. The coverage window was
rendered at the smaller window setting and its layout inspected.

The actual Windows x64 private executable from source commit `6b99a57` ran on the
local Windows NT 10.0.26300.0 host through WSL interop. Both bundled samples loaded
(801 female meshes, 788 male), and the native process passed its inspection/restoration,
history, isolation/return and offline-content checks with exit code 0. Prepared-scene
load observations were 2.38 s female / 2.62 s male, beginning after source verification.
These are uncontrolled single-run observations, not minimum-hardware benchmarks.

The successful trial used a dedicated Windows temporary folder with APPDATA and
LOCALAPPDATA redirected to isolated test directories; no saved view was accessed.
An earlier launch from the Linux UNC share did not start the app and produced no
runtime log. A local Windows staging folder resolved that launch issue. Native Windows
rendering/input, laptop performance and Mac execution are still separate gate work.
Evidence and exact artifact identity are in
[windows-native-qa.json](audit/windows-native-qa.json).
