# Remaining implementation work

The working viewer is a partial feasibility prototype. External trials and medical
review do not exhaust the work that can continue locally. Prioritize complete
exploration journeys and source coverage alongside engineering checks.

| Next work | Concrete outcome | Dependencies and acceptance |
|---|---|---|
| Source orientation and camera views | Implemented: persistent direction cue and six camera presets around the current focus. | Source/geometry and native Windows checks pass; [verification](audit/ORIENTATION_VERIFICATION.md). Human understanding and actual Mac trials remain open. |
| Part-level action menu | Implemented: supported inspection, label, visibility, Move, restoration and history actions beside a selected part in either workspace mode. | Real GUI and native Windows checks pass; [verification](audit/PART_ACTIONS_VERIFICATION.md). Human usability/text scaling remain open. |
| Portable saved views | Implemented: JSON export/import of named views and saved notes, with compatibility preview, duplicate handling and atomic merge. | Source/engine and exported-runtime checks; [usage and limits](STUDY_WORKSPACE.md). Human picker acceptance remains open. |
| Progressive anatomy coverage | Four separate private HRA v1.2 spinal studies now add 108 source meshes. Continue continuous-body coverage and missing systems. | Pinned geometry, exact picking and independent coverage records are checked. Studies remain unregistered; missing female metadata remains explicit. [Details](STUDY_WORKSPACE.md). |
| Guided separation | Implemented first chest guide and separated chamber teaching layout in both HRA bodies. Extend supported groups after review. | Exact starting-state/history restoration is checked; teaching displacement remains separate from disease/deformation. [Details](STUDY_WORKSPACE.md). |
| Content framework | Implemented 15 versioned draft heart/lung explanations with primary sources and explicit related-structure mappings. Related conditions remain future work. | Source-checked status is recorded separately from pending qualified review and mesh completeness. [Details](STUDY_WORKSPACE.md). |
| Heart-to-lung routes | Implemented: sourced circulation graph with both lung branches, previous/return navigation, explicit coverage gaps and reversible workspace. | Exact female/male source mappings are checked; graph relationships remain draft content pending qualified review. No continuity is inferred from proximity. [Usage](STUDY_WORKSPACE.md). |
| Interior viewing | Supported supplied interiors and prepared cutaway/section demonstrations. | Audit actual surfaces/caps; clipping cannot manufacture missing interior anatomy. |
| Preferences and accessibility | Implemented remembered preferences, 100/115/130% text and precise keyboard movement in all seven references. Continue assistive-technology work. | Invalid preferences recover to defaults; compact layout, movement increments and undo/redo are checked. Human accessibility acceptance remains open. |
| Distribution readiness | Human-tested Windows/Mac packages and a reliable update/recovery process. | Actual Mac execution, representative hardware, application licensing and public signing/notarization remain separate gates. |

Human mouse/trackpad, clipboard, picker and comprehension observations use
[the private trial guide](PRIVATE_TRIAL_GUIDE.md). The backlog does not imply that
those checks, medical review, complete coverage or public-release eligibility pass.

Keep implementation and evidence at reviewable Git checkpoints. Native package
validation remains tied to the actual runtime snapshot, and previous performance
reports retain their original source/artifact identities.
