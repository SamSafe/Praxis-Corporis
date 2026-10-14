# Planning Status

Updated: 2026-10-14, using the America/Edmonton client date.

Planning established the product direction, and the user authorised the first
private feasibility prototype. Both pinned HRA samples have been downloaded,
inventoried, prepared in Godot and exercised in engine tests. Rendered views were
inspected on the Linux development host. Private Windows/Mac packages are generated;
the exported Linux QA runtime reads both bodies from the offline bundle. Medical
review, comprehensive anatomy coverage, target-device performance and public
Windows/macOS distribution remain open.
See [prototype guide](PROTOTYPE.md) and [measured results](FEASIBILITY_RESULTS.md).
Local part labels and camera/selection history now work in both samples; label
surface ownership, occlusion and saved-view compatibility have been checked.
The supplied-part browser and reversible Inspect alone view now expose covered
meshes while preserving their body coordinates, ordinary visibility and edits.
This is a rendering mask, not authored cutaway or guided-separation content.
An in-app Coverage window now compares supplied system groups and gaps across both
references. A first native Windows headless trial loaded both bodies and passed
offline inspection checks. Native Windows rendering subsequently passed on AMD Radeon
graphics; human input, sustained performance and Mac device trials remain open.
A BodyParts3D v4.0 bone-organ subset is technically audited and available as a
separate private male study. Source notices, coordinate conversion and remaining
alignment/review work are recorded in [its audit](audit/BODYPARTS3D_FINDINGS.md).
Named local views now retain camera/labels and inspection settings across all three
prepared references, including a working return from isolation. Storage checks cover
duplicate names, stale edits, damaged-file recovery and failed writes. The rendered
Save/Restore actions were exercised at the compact desktop size. The older quick-save
slot remains compatible. Native builds also verify write/reopen/restore in temporary
test files without accessing the user's library.
Saved views now include optional local multiline study notes. Drafts survive selection
changes; closing/restoring offers save/discard/keep-editing choices, with a failed write
retaining the draft. Prior note-free libraries remain compatible. Personal notes are
separate from authored/reviewed content and never alter anatomy snapshots. The rebuilt
Windows release passed note-editor save/reopen and unchanged-view checks on AMD
graphics for all three references; scripted native captures were inspected.
Short native rendering profiles on the Windows Ryzen 5 PRO 6650U / AMD Radeon host
observed about 60 frame-cadence FPS across eight scenes. Raw intervals and hardware
identity are retained. Representative Windows/Mac foreground trials at the intended
3D render resolution are still required by [the measurement protocol](PERFORMANCE_PROTOCOL.md).
The profiler now supports explicit durations, repetitions and window sizes, retains
raw loading gaps/stages, and validates complete workloads independently. A first
24-sample sustained Windows attempt was rejected after window-size variation and an
unfocused long frame gap; its unmodified diagnostic evidence is retained. Fixed-window
guards now stop interrupted samples and retain partial data. The rebuilt native
eight-scene short check passed at 1920 × 1080. A guarded run then passed independent
validation of 24 one-minute samples and nine loads on the actual Windows AMD host:
48.5–59.9 average frame-cadence FPS, with 832 × 611/657 3D buffers and only one sample
focused throughout. HRA loads still had 2.0–2.2-second process gaps. These observations
do not pass the intended 1080p 3D/representative-hardware gate; see the retained
[measurement report](audit/WINDOWS_SUSTAINED_PROFILE.md).
Repository tools also audit ZIP CRCs, architectures, committed notices and runtime
source snapshots, then produce a validated Markdown measurement report. Generated QA
output is excluded from exports and checked at runtime; Mac embedded-content checks
now require an independent resource boundary check on the development host.
The earlier guarded archives match the committed `640cf57` application snapshot. Native
Windows source search, saved notes, loading/failure preservation, keyboard workspace
and credited exports passed again; all fifteen retained captures were inspected.
The grouped-loading archives use the `e85e638` application snapshot. Prepared picking shapes now
load in small groups, preserving every source surface and exact picking face. A
matched three-repetition Windows diagnostic reduced median peak HRA loading gaps by
88.7–94.4%, with 2.8–2.9-second wall loads and a 1.75 GB process peak working set.
The runtime-rebuilding experiment that increased time/memory is retained alongside
the baseline and final measurements. Quarter-second pauses and full-resolution/hardware
acceptance remain open; see [the comparison](audit/LOADING_OPTIMIZATION.md).
The final native Windows rendered workflows passed again, and all fifteen captures
were inspected; [workflow evidence](audit/windows-grouped-selection-viewer-qa.json).
The display-density archives use `ae60019` and retain the same anatomy pack. The 3D image now
renders at the displayed pixel density, with Native/75%/50% choices and an expanded
anatomy view that can cover the entire client window. Root GUI picking, labels,
orbit/pan/Move drag and undo have been checked across sizes and rendering fractions.
Display changes preserve the live world and saved exploration setup. Resize anchors
update immediately. Both exports pass offline/content checks; the actual Windows
release passes the new display checks and existing workflows, with all eighteen
captures inspected. [Native display evidence](audit/windows-display-density-viewer-qa.json).
The first sustained expanded/native Windows trial passed independent validation of
24 one-minute samples and nine loads at an actual 1920 × 1080 3D buffer. All samples
held focus; average frame cadence ranged from 59.5 to 59.9 FPS. It meets the proposed
30-FPS baseline for the eight measured workloads on this host. Representative devices,
Mac execution, additional workloads, human input and medical review remain open.
[Full-resolution results](audit/WINDOWS_FULLHD_PROFILE.md).
The expanded-control archives use `33071c1`. Expanded Explore keeps labels, inspection/return,
explicit Move and Undo/Redo, saved views, credited screenshots, keyboard help and
quality controls available. Selection and action feedback remain visible; keyboard
menus and loading guards are checked. Both packages pass offline/content and archive
audits. Native Windows workflows pass for all three references, with all 24 captures
inspected, alongside two compact development captures. The prior sustained profile
remains bound to `ae60019`; human input and actual Mac trials remain open.
[Expanded controls and package evidence](audit/EXPANDED_CONTROLS_VERIFICATION.md).
The `cc705b8` archives add orientation controls. Camera views and a persistent
body-direction cue use fingerprint-matched source frames corroborated by 23 landmark comparisons.
Six presets preserve focus/distance, isolation, anatomy edits and undo; history,
keyboard menus, loading guards, invalid frames and label clearance are checked.
Thirty-six Python checks pass. Both packages pass offline/content and archive audits;
native Windows workflows pass for all three references, with all 27 captures inspected.
Six compact development captures were also inspected. Actual Mac, human input,
medical review and broader content remain open. [Orientation evidence](audit/ORIENTATION_VERIFICATION.md).
The workspace now has a focused keyboard camera route and independently collapsible
side panels. Camera keys preserve inspection data; search and tree arrows retain their
own behaviour. Teal focus rendering, compact layout and source picking after collapse
were checked. Complete keyboard manipulation/assistive-technology acceptance remains open.
Local PNG export now embeds source attribution/licence links, modification notes and
prototype/review status. Rendered output and unchanged-session checks passed for both
HRA references and the compact hidden-panel bone study. Native picker acceptance is
included in the user's [trial guide](PRIVATE_TRIAL_GUIDE.md).
Prepared reference loading now yields interface frames during source verification,
resource reading and batched selection setup. Failed replacements preserve the
previous scene and exploration histories. Scene instantiation/final replacement can
still pause; this does not establish bounded loading latency on target hardware.
The rebuilt native Windows app passed these checks on AMD graphics, alongside the
existing saved-view, keyboard and credited screenshot workflows.
Ranked source-aware search now covers names and original/ontology/catalogue IDs in
all three references. Two-line source rows preserve repeated labels; filtering leaves
inspection/history unchanged. Source details and an explicit copy action retain
reference fingerprints and coverage/review status. Keyboard selection, duplicate-row
clicking and compact rendering passed development checks. The rebuilt Windows
release passed source-search checks on native AMD graphics. Repository verification
now retains exact-artifact logs/captures and isolates test data; its rendered and
headless WSL-to-Windows modes passed. Mac hardware and human clipboard/input
acceptance remain open.
Four separate HRA v1.2 spinal candidates are downloaded/hash-verified and technically
inventoried for both sexes. They are outside the runtime. The female vertebra source
contains one missing label/ontology record that requires interpretation review.
[Candidate findings](audit/HRA_SPINAL_CANDIDATES.md) define source-frame/admission work.
All four also passed actual engine mesh/triangle/bounds checks and were rendered against
their original source-body context. No source fitting or catalogue admission occurred;
the unresolved female node is highlighted in the retained inspection preview.

Current private archives use `b9c23b4`. Selection-bound Actions now expose supported
inspection tools beside anatomy, with hidden/off-screen corner access. Real-input
checks and native Windows workflows pass; 36 captures were reviewed, including
individual inspection of nine new menus. The initial failed QA trial is retained.
[Part-action verification](audit/PART_ACTIONS_VERIFICATION.md). Actual Mac execution
and human acceptance remain open. Portable saved-view import/export is the next
local implementation priority.

## Established by the user

| Decision | Direction |
|---|---|
| Audience | Aspiring doctors and medical students across learning stages. |
| Main experience | Explore anatomy and related conditions. |
| Manipulation | Both manual and guided separation. |
| Context | Remain inside one body scene and follow connections. |
| Appearance | Clean, detailed, leaning realistic. |
| Disease priorities | Locate/highlight first; comparison useful; animation later. |
| Scenarios | Supported injury/change options with causes and effects. |
| Platform | Native Windows and macOS application. Linux unnecessary now. |
| Reference anatomy | Both male and female adult bodies in the first-release plan. |
| Assets | Free, progressively expanded. |
| Business | Free initially, potentially paid later. |
| Team/timing | User and assistant; quality over a deadline. |
| Testing | User, small private group, public. |
| Review access | No qualified medical reviewer available. |

The user delegated routine design decisions and subsequently authorised continued
implementation. Local commits preserve progress; no remote publication is implied.

## Proposed defaults

- Godot viewer, Blender preparation, portable GLB geometry, JSON metadata.
- Ordinary student laptops; mouse/keyboard and trackpad controls.
- Offline exploration and local sessions without mandatory accounts.
- Whole-body overview with the chest as the first detailed milestone.
- Search, history, bookmarks, notes, and screenshot export.
- Source-backed explanations with recorded review evidence.
- Qualified review of published medical content as a public-release gate.
- Commercial-compatible assets, excluding noncommercial material from the core.

## Evidence and decisions still needed

| Item | Current state | How to resolve |
|---|---|---|
| Male/female coverage | Two HRA v1.1 samples inventoried; substantial system gaps remain. | Supplement missing anatomy and validate actual coverage/interiors. |
| Exterior and deeper layers | Skin reveal and chest selection work in the prototype; complete layers absent. | Enrich both bodies and validate the complete journey. |
| Engine suitability | Godot 4.7.2 passes initial import, picking, movement, restore and saved-view trials. | Complete clipping, renderer/device benchmarks, accessibility and platform exports. |
| Baseline hardware | One Windows AMD host passes the proposed 30-FPS baseline for eight measured scenes: 24 focused one-minute samples at an actual 1920 × 1080 3D buffer. No representative-device matrix. | Test representative Windows/Mac devices and remaining workloads; retain single-host and loading-pause limits. |
| Pathway content | Grouping is not verified connectivity. | Source/author and review explicit routes. |
| Medical review | No access. | Arrange review before the planned public content release. |
| Application licence | Undecided; private prototype code now exists. | Decide before implementation distribution. |
| Name | Existing working name: Praxis Corporis. | Confirm later. |
| Distribution | Private Windows x64 and Mac Universal ZIPs generated locally. | Test on target devices and arrange public signing/notarization and distribution. |

## Planning completion

[Implementation backlog](IMPLEMENTATION_BACKLOG.md) records useful work that can
continue locally alongside the outstanding platform, human-input and review trials.

Initial scope, interaction, content method, target architecture, quality gates and
release stages are documented. The project is in Stage 1 feasibility work. Initial
working controls do not close the source-completeness or public-release gates.

The earlier browser/quiz-centred proposal is superseded by this draft.

## Current design artifacts

[Interface specification](INTERFACE_SPEC.md) adds whole-body, heart-selection, and
pathway wireframes. They contain schematic placeholders, not evaluated anatomy.
[Asset audit](ASSET_AUDIT.md) defines the evidence and per-body inventory needed
before a complete anatomy source can be selected. Neither artifact is implementation.

[Rendered prototype captures](FEASIBILITY_RESULTS.md) now complement the schematic
wireframes. The app implements a subset of the interface specification, with future
medical capabilities identified as pending rather than offered as working controls.
