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
- [Native Windows female chest](prototype/windows-native-chest-female.png).
- [Native Windows male chest](prototype/windows-native-chest-male.png).
- [Separate BodyParts3D bone preview](prototype/bodyparts-male-bone-study.png).
- [Bone study in the full viewer](prototype/study-viewer-bones.png).
- [Selected source femur](prototype/study-viewer-femur.png).
- [Femur inspected alone](prototype/study-viewer-femur-alone.png).
- [Bone study at the smaller window setting](prototype/study-viewer-compact.png).

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

## Native Windows rendering trial — 2026-10-12

The current exported Windows application, from source commit `018c586`, passed its
desktop rendering check on the local Windows NT 10.0.26300.0 host. The Compatibility
renderer used OpenGL 3.3 core and AMD Radeon(TM) Graphics; the observed driver string
was 25.10.37.03.260407. Both 1440 × 900 chest captures were inspected. Surface labels
had real physics hits, and the scripted offline/inspection checks passed with process
exit code 0. APPDATA/LOCALAPPDATA remained isolated in the temporary QA folder.

Prepared-scene loading observations were 4.80 s female / 4.79 s male after source
verification. This was one uncontrolled trial and measures neither sustained FPS
nor peak memory. Native human mouse/trackpad testing, accessibility acceptance and
representative student-laptop benchmarks remain open. The Mac core pack continues
to pass development-engine checks, with Mac hardware execution pending.

[windows-rendered-qa.json](audit/windows-rendered-qa.json) records the tested artifact
identity, renderer, captures and limits. The current [build report](audit/native-build-report.json)
records both refreshed package hashes, including the Coverage window.

## Separate bone-study reference — 2026-10-12

The official BodyParts3D v4.0 archive was downloaded, hash-pinned and CRC-checked.
The bone-organ definition contains 203 available source mesh files with 505,532
triangles. The audit includes 552 selected meshes from bone, muscle and nerve groups.
[Source findings](audit/BODYPARTS3D_FINDINGS.md) record actual bounds, source/licence
evidence and the restricted admission scope.

A deterministic converter preserves supplied normals, converts declared mm/Z-up
coordinates to metre/Y-up, and prepares a 12,895,068-byte bone GLB. It is a separate
male study with no HRA/female registration. The viewer discovers it when its geometry
is prepared, presents its own source/coverage record, frames the source body without
requiring skin, and disables absent skin/chest actions. Source IDs remain independent;
both original HRA catalogues are unchanged.

Study workflow checks passed: actual geometry selection, femur focus, displacement,
isolation/return, exact restoration, reference switching, hash-bound saved views and
atomic rejection of an incompatible source hash. Both-body HRA exploration and part
inspection checks still passed. Twelve Python ingestion/conversion/packaging checks
passed. The three-reference scripted rendering check passed on the development
display, and full-viewer captures were inspected at normal/smaller window settings.

The bone source adds useful geometry without closing comprehensive two-body coverage,
medical review, source registration, authored cutaway/pathway or public-release gates.

The packages from source commit `1875028` include all three prepared references.
Their archive CRCs, content notices, source snapshots and SHA-256 hashes were verified.
The actual Windows executable passed native AMD desktop rendering, surface-label and
inspection/restoration checks for 801 female, 788 male and 203 bone-study meshes,
with exit code 0. All three 1440 × 900 captures were produced; the separate skeleton
capture was inspected. This is scripted device evidence, without a sustained FPS
or human-input acceptance claim. The Mac embedded content passed on the development
engine; Mac device execution is still open. Exact evidence is recorded in
[windows-study-rendered-qa.json](audit/windows-study-rendered-qa.json) and
[native-build-report.json](audit/native-build-report.json).

## Named local exploration views — 2026-10-12

The app now retains multiple named setups in a local library. Each snapshot binds
its reference geometry and preserves selection, camera, label settings, visibility,
displacement, isolation and the prior context. Restore leaves explicit Move mode.
The previous quick-save slot remains accessible. Rename and confirmed deletion are
available, with full-precision JSON output and a prior-library backup. Invalid reads
block writes; explicit backup recovery retains the damaged original. Open libraries
detect external changes before writing.

Workflow checks passed across both HRA bodies and the separate bone study, including
reopen/restore, original float32 displacement precision, isolated-part return,
invalid/unavailable geometry rejection, duplicates, stale edits, deletion, corrupted
metadata recovery and write failure. The earlier both-body quick-save/inspection
suite still passed. Twelve Python source/packaging checks passed. The rendering/input
check saved both a chest view and an isolated femur, restored the chest through the
button, and verified compact popup bounds. Its [capture](prototype/saved-views-library.png)
was inspected. The capture test accounts for Godot's logical viewport coordinates
when the desktop window is scaled; this corrected a test-input routing error.

The developer bundle verifier additionally exercises local write/reopen/restore with
random temporary filenames. It passed all three prepared references on the development
engine. Native package evidence remains tied to the source revisions recorded in the
build reports; package refresh is separate from these source-workflow checks.

The packages from source commit `03f0369` subsequently passed exported Linux and
Mac embedded-content checks, including local write/reopen/restore for every bundled
reference. Archive hashes, CRCs, source snapshots and updated instructions matched.
The actual Windows release executable also passed all three native AMD rendering
and local persistence checks with exit code 0. The QA process kept the user's library
and quick-save slot untouched. Its 500 ms process observations are recorded separately
from any scene benchmark in [windows-saved-views-qa.json](audit/windows-saved-views-qa.json).
The [private trial guide](PRIVATE_TRIAL_GUIDE.md) provides the next human-input tasks.

## Rendering measurement tool — 2026-10-12

The explicit developer profile measures eight scenes across the three prepared
references, after a one-second warmup per scene. It records five seconds of scripted
orbit frame intervals, retains every raw sample, and includes source/viewport/renderer
identity. Its summary tool independently recomputes duration, cadence, nearest-rank
percentiles and slow-frame counts; deliberately inconsistent measurements were rejected.
Headless profiling is explicitly rejected before anatomy loading.

The development display's Mesa llvmpipe software-rendered run completed and its raw
measurements passed validation. Whole HRA bodies observed approximately 1.2–1.3
frame-cadence FPS, faded-lung chest views 3.2–3.4, isolated parts about 42, and the
whole bone study 9.2. These verify measurement behaviour on software rendering,
not AMD performance or a student-laptop baseline. The target Windows graphics
measurement and representative sustained 1080p acceptance remain separate work.

The package from source commit `5770d1d` then completed the actual Windows AMD trial
on an AMD Ryzen 5 PRO 6650U host with 15,859,003,392 bytes of reported physical RAM
and 12 logical processors. All eight short scenes observed 59.7–59.9 frame-cadence
FPS; p95 frame intervals were 17.24–17.60 ms with VSync enabled. These results describe
the measured renderer/window setup, not unbounded GPU throughput. Raw samples,
source/viewport/driver identity, artifact hash and separately sampled process-memory
observations are retained in [windows-render-profile.json](audit/windows-render-profile.json).
The independent summary validator passed every raw scene measurement.

Both packages' source snapshots, CRCs and hashes matched. Exported Linux/Mac embedded
content and temporary saved-view checks passed. The [performance protocol](PERFORMANCE_PROTOCOL.md)
specifies longer 1080p repeated trials and distinguishes memory, load, cadence and
hardware acceptance. The native short trial leaves representative laptop/Mac,
human-input and sustained-performance gates open.

## Keyboard camera and workspace panels — 2026-10-12

The 3D view can receive Tab/click focus, indicated by a teal border and keyboard hint.
Arrows orbit, Shift-arrows pan, +/- zoom, F fits selection and Home returns body context.
Camera keys leave Move mode and preserve inspection edits/undo. Text fields and the
anatomy tree retain their ordinary arrows; Alt-history still works from the scene.
The Panels menu independently collapses/reopens either side without resetting
camera, selection, source reference, isolation or body edits.

Workflow checks passed for HRA and the separate study, including keyboard routing,
history, source-frame fitting, inspection preservation and actual viewport expansion.
Rendered checks exercised keyboard input, compact collapsed layout and source femur
selection after resizing. Both-body exploration/label checks still passed. The native
bundle verifier now also checks keyboard navigation and panel collapse for each
reference. [Keyboard focus](prototype/workspace-keyboard-focus.png) and
[expanded scene](prototype/workspace-open-scene.png) captures were inspected. Actual
target-device evidence remains tied to the packaged revisions.

The packages from source commit `78dde16` passed exported Linux and Mac embedded
content, saved-view and keyboard/panel checks for all three references. The actual
Windows release executable passed the same scripted workspace checks on AMD graphics,
produced all three native captures and exited with code 0. Archive CRCs, SHA-256/source
snapshots and updated keyboard/panel instructions matched. Exact Windows evidence is
in [windows-keyboard-workspace-qa.json](audit/windows-keyboard-workspace-qa.json).
Human device acceptance remains distinct from these injected input events.

## Local credited screenshot export — 2026-10-12

The Screenshot action captures the current rendered workspace and adds a source/status
footer inside the PNG. Source/licence URLs, creator attribution, display modifications
and review status remain visible even when panels are hidden. The separate study
retains its required BodyParts3D creator credit and lack of HRA/female alignment.
The app requests a native PNG save picker; capture is local and leaves view/inspection
state unchanged. A body/camera change during capture is rejected before export.

Rendered checks produced and reopened both HRA 1440 × 1085 exports and a compact
1100 × 898 isolated-femur export with both panels hidden. All retained their camera,
anatomy, labels and undo state. Pixel checks confirmed footer text was actually drawn,
and invalid image/format inputs left existing files unchanged. The
[HRA export](prototype/export-female.png) and [study export](prototype/export-bone-study.png)
were inspected. The developer rendered-bundle check passed the same composer/writer
for all three references without opening the OS picker. Human native-picker operation
remains separate work.

The packages from source commit `ab566b7` passed exported Linux and Mac embedded
content/workflow checks. Their archive CRCs, source snapshots, hashes and screenshot
instructions matched. The actual Windows release executable passed all three native
credited PNG exports on AMD graphics, alongside saved-view, keyboard/panel and source
inspection checks, with exit code 0. The study's whole-reference native export was
inspected. [windows-screenshot-qa.json](audit/windows-screenshot-qa.json) records the
tested archive, image sizes and limits. The OS picker and real Mac execution remain
human/device acceptance work.

## Paired spinal source inspection — 2026-10-12

The official repository still resolved to the pinned source commit. Separate v1.2
female/male vertebra and spinal-cord models were found outside the United files,
downloaded and checked against tree sizes/Git blob identities, then pinned by SHA-256.
The four candidates contain 108 source meshes. Their unchanged geometry imported with
matching actual engine mesh/triangle counts and declared world bounds. Source-frame
previews place them against the corresponding original skin without fitting geometry.
Display colours and skin transparency are inspection modifications.

One female node named `VH_F_lumbar_vertebra_6` has missing label/ontology fields.
The preview highlights that actual node, and the audit preserves the gap without
inferring a clinical interpretation or manufacturing an identifier. Candidates remain
outside the app/package catalogue. [Candidate findings](audit/HRA_SPINAL_CANDIDATES.md)
retain verified hashes, metadata, engine evidence, previews and admission work.


## Responsive prepared-reference loading — 2026-10-12

Source hash verification now uses a file-reading worker; prepared scene reads use
Godot's threaded ResourceLoader and selection preparation yields between mesh batches.
The interface shows each loading step while keeping the previous anatomy in view.
Camera/anatomy controls pause until the load resolves. Scene mappings and all declared
meshes are checked before replacing the old body, correcting a late-failure path that
previously cleared the current scene.

Real-source integration and loading regressions passed with 801 female, 788 male and
203 separate bone-study meshes. Tests observed process-frame updates during loads and
verified exact scene/view/history preservation after missing files, changed hashes,
missing anatomy roots and a declared mesh pointing to a non-mesh source node. They
also injected undo, Escape and camera input while loading, rejected concurrent loads
and freed a live source verifier cleanly. Named-view round trips and the offline
bundle check passed with the asynchronous switch. The [rendered loading view](prototype/loading-reference.png)
shows the prior displaced heart while a replacement loads.

Resource background reads do not remove main-thread scene instantiation or final
replacement pauses. The first raw development import remains a preparation step,
and staging a second reference temporarily increases memory. These checks establish
frame processing and failure preservation, not a maximum latency or device-performance
acceptance result.


Packages from source commit `24b300a` passed exported Linux and Mac embedded-content
checks. Both archive CRCs, executable architectures, hashes and shipped source
snapshots matched. The actual Windows release on AMD graphics observed 42, 39 and
10 UI process frames during the respective female, male and bone-study loads.
All three deliberately rejected replacements preserved the same scene/view and
inspection/navigation histories. Native rendering, credited PNGs, named saved views
and keyboard/panel checks also passed, with exit code 0.
[Windows evidence](audit/windows-loading-qa.json) records the exact artifact and
process-memory observations; a [native loading capture](prototype/windows-loading-male.png)
shows the prior male exploration while checking a rejected replacement. No maximum
pause or sustained-performance claim follows from the frame counts.


## Local notes attached to saved views — 2026-10-12

The saved-view library now retains optional multiline personal study notes. It accepts
10,000 characters per view, including Unicode and line breaks. The two-column window
keeps view context and note editing together. Changing selection retains typed drafts;
Save notes explicitly persists them. Closing/restoring or a normal application-close
request protects drafts with save, discard and keep-editing choices. Saving before
continuing writes all drafts in one library update. A failed/stale write leaves the
drafts and decision dialog open. Force-stop/crash recovery of unsaved notes is not
implemented. Personal text stays distinct from anatomy snapshots and authored content.

Storage/UI integration checks cover earlier note-free libraries without opening-time
rewrites, exact multiline Unicode reopening, batch rejection without partial writes,
stale readers, oversized/invalid note records, backup recovery, retained drafts,
normal window-close routing and restoration after a save decision. Existing multi-body
named-view checks still pass. Rendered compact-layout checks exercise actual Save notes
and Restore clicks, text undo without anatomy changes, and unsaved-choice rendering.
[Saved-note window](prototype/saved-view-study-notes.png) and
[draft protection](prototype/unsaved-study-notes.png) are retained inspection captures.


Packages from source commit `8e4f5bb` passed exported Linux and Mac embedded-content
checks, including multiline-note storage/reopening. Both archive CRCs, source
snapshots, architecture checks and study-note startup instructions matched. The
actual Windows release on AMD graphics passed note-editor insertion, Save notes,
reopening and unchanged-view checks for all three references. The three retained
native note windows were inspected. Loading/failure preservation, keyboard/panels,
offline geometry and credited screenshot checks also passed with exit code 0.
[Windows study-note evidence](audit/windows-study-notes-qa.json) records the exact
archive, captures and whole-process memory observations. Human note input/OS-close
acceptance and real Mac execution remain open.


## Search and trace supplied source records — 2026-10-12

The HRA catalogues contain 378 female and 382 male display labels beyond the first
occurrence of each label. Those records now remain distinct in two-line search rows
with original source names. Exact labels/identifiers rank ahead of prefix and other
multiword matches; ordering is stable. Search checks the active reference's supplied
names, source names and ontology/catalogue IDs, with identifier separator normalization.
A separate summary reports the complete match count when the displayed list caps at
100. Details now show original source names and IDs; Copy source record offers a
reference fingerprint, coverage notice and draft/review status without study notes.

Real-data checks passed on both HRA bodies and the separate bone study: canonical
mitral selection, ontology/filename lookup for Right femur, repeated-label/ontology
records, word-order/whitespace variations, stable limits, explicit empty states,
clearing to the hierarchy, isolation/history preservation and retained search after
a failed replacement. Rendered checks typed identifiers, pressed Enter, clicked a
repeated-label row and checked a compact 1100 × 720 layout. Filtering preserved
anatomy edits; result selection used the existing source-geometry navigation.
[Valve lookup](prototype/search-ontology-valve.png),
[distinct source names](prototype/search-duplicate-source-names.png) and
[compact bone lookup](prototype/search-source-bone-compact.png) are retained previews.
Clipboard access is user-triggered; the developer checks validate its text without
reading or changing the tester's clipboard. Human clipboard/device acceptance remains open.


Packages from source commit `c9019ca` passed exported Linux and Mac embedded-content
checks, including source-ID selection and preserved inspection state. Both archive
CRCs, hashes, executable architectures, source snapshots and search instructions
matched. The actual Windows release passed source-search rendering for both HRA
mitral valves and the separate source femur on AMD graphics. All three native search
captures were inspected. Notes, loading/failure preservation, keyboard/panels, offline
geometry and credited exports also passed with exit code 0.
[Exact-artifact Windows evidence](audit/windows-source-search-qa.json) retains source
fingerprints, captured images and whole-process memory observations.

`tools/verify_windows.py` now makes this check reproducible from the repository on
Windows or through explicit WSL interop. It validates the artifact before running,
creates isolated native test data, requires every reference's workflow markers and
pinned engine, retains logs/captures, then removes successful native staging. Both
rendered and headless WSL-to-Windows runs passed. Sixteen Python tests cover ingestion,
packaging and verification, including incomplete/failed native evidence, changed
archives and literal PowerShell path handling. The direct Windows Python caller and
human device acceptance remain separate work. App sources remain the tested `c9019ca`
snapshot; this QA tool is excluded from application exports.


## Configurable sustained measurements — 2026-10-12

Developer profiling now accepts explicit sample/warmup durations, repetitions and
window dimensions. Each repetition reconstructs the eight existing workloads after
loading the three source references. Reports retain all rendered intervals, counts
above 33.33/100 ms, actual window/viewport sizes, focus, MSAA and VSync. Load reports
retain process-frame intervals across the entire reference switch, stage timestamps
and the next post-draw delay. Partial start/end intervals are identified in the
method; neither these stage times nor post-draw callbacks measure GPU execution or
presentation latency.

The independent validator requires complete planned scenes, loads and repetitions;
it recomputes durations, cadence, nearest-rank percentiles and stall counts from raw
intervals. Historical short profiles remain readable. Twenty-two Python checks and
the headless configuration test pass, including invalid/duplicate options, modified
statistics, omitted workloads and source/configuration mismatches. A rendered Linux
development run passed raw validation for two repetitions (16 scenes and six loads),
using one-second samples at 1100 × 720. Its renderer was Mesa llvmpipe software;
these checks demonstrate the measurement workflow, not native hardware performance.

`tools/profile_windows.py` binds a new native measurement to its exact archive,
source revision and engine, isolates test data, records host/driver/power identity,
observes only its own process and retains raw evidence. The sustained native result
will be recorded after rebuilding this source snapshot. Commands, workload scope and
interpretation are in [the protocol](PERFORMANCE_PROTOCOL.md) and
[native build guide](NATIVE_BUILDS.md).

An intermediate package audit found generated `dist` QA captures included by Godot's
all-resources export. All three presets now explicitly exclude `dist` and `build`.
Exported-runtime verification and profiling check that generated output, tests, tools,
docs and editor addons contain no bundled files. Native evidence must include this
boundary check. The traversal test distinguishes empty/absent directories from nested
developer files; the native validator additionally requires the exact eight current
workloads rather than accepting any eight internally consistent scene records.
The intermediate packages were superseded before recording the sustained baseline.

The first native sustained attempt from `92a1673` completed all 24 samples and nine
reference loads but failed the fixed-window check. The reported window changed from
1920 × 1080 to 1920 × 1111 during the first bone inspection; 17 later samples differed
from the request. Only two samples retained focus throughout. One unfocused male
whole-body sample included a 106,786.646 ms post-draw gap; its cause is unknown. Raw
arithmetic/workload completeness passed an explicitly diagnostic check, with all
intervals and actual dimensions retained. This is rejected trial evidence, not a
fixed-resolution acceptance result. The 3D buffers were 832 × 657 or 832 × 611; a
larger window did not establish a 1080p 3D render buffer. Process peak working set
was 1,765,928,960 bytes; maximum sampled private memory was 1,930,596,352 bytes.
[Rejected-run evidence](audit/windows-sustained-rejected-qa.json) and
[raw measurements](audit/windows-render-profile-rejected.json) retain the outlier.
On 2026-10-13, the operator answered “Not sure” when asked about resizing or
minimizing the window or locking/suspending the computer. The cause remains unknown;
the reply does not change the rejection or the raw measurements.

Profiling now fixes its own window bounds and checks dimensions throughout sampling.
An interruption saves partial evidence and stops before further workloads. The runner
persists startup archive/source/tool/host binding before launching and retains failed
raw data. Rendered fault injection resized an actual source-femur sample: it rejected
the scene, retained intervals and preserved anatomy. Twenty-nine Python checks pass,
including diagnostic variation without skipping arithmetic and rejected-profile
handling. The corrected native sustained trial remains to be recorded.

Both `92a1673` archives passed the reusable CRC, architecture, committed-notice and
source-snapshot audit. Its Mac core pack separately passed the absolute-path resource
checker on the Linux development engine. This verifies the pack boundary, not Mac
device execution. Future builds run that independent checker and explicitly require
the boundary in embedded-pack verification: engine-consumed flags are excluded from
[`OS.get_cmdline_args`](https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-get-cmdline-args).

The guarded `640cf57` Windows release then completed three repetitions of all eight
60-second scenes at a fixed 1920 × 1080 window. Independent raw validation passed
24 samples, 83,190 rendered intervals over 1,440.20 measured seconds, and all nine
reference loads. Observed per-sample average cadence ranged from 48.5 to 59.9 FPS.
The highest scene p95 was 37.69 ms in the male chest workload; 489 rendered intervals
exceeded 33.33 ms and none exceeded 100 ms. Process peak working set was
1,766,273,024 bytes; maximum sampled private memory was 1,933,799,424 bytes.

This remains a scoped observation: actual 3D buffers were 832 × 611/657, only one
sample retained focus throughout, and background/power/thermal conditions were
uncontrolled. It does not establish foreground 1080p 3D or minimum-hardware acceptance.
HRA switch wall times were approximately 2.73–3.00 seconds; largest process gaps were
2.01–2.22 seconds during `Loading anatomy`. Source-bone loads took 0.54–0.60 seconds,
with 0.28–0.31-second gaps. Stage timestamps include scheduling and cannot identify
the exact engine operation responsible. Loading pauses remain a concrete optimization
target. [Readable report](audit/WINDOWS_SUSTAINED_PROFILE.md),
[native binding](audit/windows-sustained-profile-qa.json) and
[unmodified raw intervals](audit/windows-sustained-profile.json) are retained.

Both corrected archives passed CRC, architecture, committed-notice and source-snapshot
checks against `640cf57`. Exported Linux checks and Mac embedded-content/boundary checks
passed. The same actual Windows release passed normal source-search, note-editor,
loading/failure preservation, keyboard, offline geometry and credited screenshot
workflows after profiling. All fifteen native captures were inspected and retained
with [their exact-artifact evidence](audit/windows-guarded-viewer-qa.json).
The QA scripts were exercised through WSL into native Windows; direct Windows Python,
Mac hardware, human input/picker/clipboard, representative performance and anatomy
review acceptance remain separate work.

## Loading optimization with exact picking geometry

Call-level instrumentation in `a2ee90f` reproduced the roughly two-second HRA
process gap while showing fast resource request/status/collection calls and
millisecond-scale scene instantiation/indexing. The gap occurred between those calls;
the measurements do not identify a precise CPU, physics or GPU operation.

The `d8771b1` experiment removed picking colliders from compiled geometry and rebuilt
them in runtime batches. Gaps shrank, but HRA loads took 5.668–6.269 seconds and process
peak working set reached 3,049,803,776 bytes. The final `e85e638` implementation instead
prepares the exact triangle shapes offline and loads bounded groups separately from
geometry: 48 female, 52 male and eight bone-study groups. No anatomy is simplified.

A matched Windows diagnostic retained three repetitions, nine loads and all 24 short
navigation samples for each implementation. Final HRA switches took 2.837–2.897
seconds, with female maximum process gaps of 233.495–253.818 ms and male gaps of
110.022–113.198 ms. Median peak gaps fell by 88.7% and 94.4%, respectively, against
the instrumented baseline. Bone-study gaps fell to 79.687–86.390 ms. Final peak working
set was 1,746,427,904 bytes; sampled private maximum was 1,904,308,224 bytes. This
preserves the responsiveness gain with memory near the baseline and slightly longer
total loads. [Full comparison and retained trial evidence](audit/LOADING_OPTIMIZATION.md).

Engine checks compare all 1,792 meshes, exact surface arrays, transforms, hierarchy,
material settings and picking faces with the previous caches. Seven separate bad
picking-cache cases preserve the current real anatomy and inspection state. The
existing asynchronous loading tests and 31 Python checks pass. Both current packages
match `e85e638` and pass archive/source audits, exported Linux checks and Mac embedded
content/boundary checks. Normal rendered Windows search, notes, inspection, loading,
keyboard and credited exports also passed; all fifteen retained captures were
inspected. [Native workflow evidence](audit/windows-grouped-selection-viewer-qa.json).

The new profile measured 59.4–59.9 average frame-cadence FPS, but used only two-second
samples and 832 × 611/657 3D buffers. All 24 held focus; background/power/thermal
conditions remain uncontrolled. It neither replaces the earlier sustained result
nor establishes intended 1080p 3D, representative hardware or actual Mac execution.
Large individual picking shapes and final replacement still cause shorter pauses.
