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
Short native rendering profiles on the Windows Ryzen 5 PRO 6650U / AMD Radeon host
observed about 60 frame-cadence FPS across eight scenes. Raw intervals and hardware
identity are retained; repeated sustained 1080p trials and a representative Mac are
still required by [the measurement protocol](PERFORMANCE_PROTOCOL.md).
The workspace now has a focused keyboard camera route and independently collapsible
side panels. Camera keys preserve inspection data; search and tree arrows retain their
own behaviour. Teal focus rendering, compact layout and source picking after collapse
were checked. Complete keyboard manipulation/assistive-technology acceptance remains open.

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
| Baseline hardware | One actual Windows AMD host has short rendering/memory observations; no acceptance matrix. | Run repeated sustained 1080p trials and test a representative Mac. |
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
