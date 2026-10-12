# Planning Status

Updated: 2026-10-12, using the America/Edmonton client date.

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
Both current archives match the committed `640cf57` application snapshot. Native
Windows source search, saved notes, loading/failure preservation, keyboard workspace
and credited exports passed again; all fifteen retained captures were inspected.
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
| Baseline hardware | One Windows AMD host has validated repeated one-minute observations; low-resolution 3D buffers, mostly unfocused and no acceptance matrix. | Repeat foreground trials at the intended 3D resolution and test a representative Mac. |
| Pathway content | Grouping is not verified connectivity. | Source/author and review explicit routes. |
| Medical review | No access. | Arrange review before the planned public content release. |
| Application licence | Undecided; private prototype code now exists. | Decide before implementation distribution. |
| Name | Existing working name: Praxis Corporis. | Confirm later. |
| Distribution | Private Windows x64 and Mac Universal ZIPs generated locally. | Test on target devices and arrange public signing/notarization and distribution. |

## Planning completion

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
