# Remaining implementation work

The working viewer is a partial feasibility prototype. External trials and medical
review do not exhaust the work that can continue locally. Prioritize complete
exploration journeys and source coverage alongside engineering checks.

| Next work | Concrete outcome | Dependencies and acceptance |
|---|---|---|
| Source orientation and camera views | Implemented: persistent direction cue and six camera presets around the current focus. | Source/geometry and native Windows checks pass; [verification](audit/ORIENTATION_VERIFICATION.md). Human understanding and actual Mac trials remain open. |
| Part-level action menu | Implemented: supported inspection, label, visibility, Move, restoration and history actions beside a selected part in either workspace mode. | Real GUI and native Windows checks pass; [verification](audit/PART_ACTIONS_VERIFICATION.md). Human usability/text scaling remain open. |
| Portable saved views | Export/import named views and optional notes between local installations. | Preview reference/version compatibility, handle duplicates and invalid data, preserve the existing library on failure. No account or upload service required. |
| Progressive anatomy coverage | Admit additional clearly identified source geometry with explicit body/region coverage. | Source hashes, licences, coordinate evidence, exact geometry/picking, provenance and recoverable loading. [Spinal candidates](audit/HRA_SPINAL_CANDIDATES.md) still need admission decisions and unresolved source-identity handling. |
| Guided separation | Authored inspection layouts for supported groups with exact restoration. | Distinguish a teaching layout from disease/deformation; retain body coordinates and undo/return paths. |
| Content framework | Versioned structure explanations and related-condition records with affected-structure mappings. | Recorded primary sources, capability/review status and body-specific gaps. Private drafts can progress; public medical claims need qualified review. |
| Heart-to-lung routes | Explicit source-backed connection records, steps, branches, gaps and a route back. | Source/author the relationships; grouping and proximity cannot establish blood flow or nerve connectivity. |
| Interior viewing | Supported supplied interiors and prepared cutaway/section demonstrations. | Audit actual surfaces/caps; clipping cannot manufacture missing interior anatomy. |
| Preferences and accessibility | Persist useful viewing preferences and improve keyboard/text routes. | Recovery from invalid settings; test focus, contrast, text scaling, reduced motion and actual assistive technology. |
| Distribution readiness | Human-tested Windows/Mac packages and a reliable update/recovery process. | Actual Mac execution, representative hardware, application licensing and public signing/notarization remain separate gates. |

Human mouse/trackpad, clipboard, picker and comprehension observations use
[the private trial guide](PRIVATE_TRIAL_GUIDE.md). The backlog does not imply that
those checks, medical review, complete coverage or public-release eligibility pass.

Keep implementation and evidence at reviewable Git checkpoints. Native package
validation remains tied to the actual runtime snapshot, and previous performance
reports retain their original source/artifact identities.
