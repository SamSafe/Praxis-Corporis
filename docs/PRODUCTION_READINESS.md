# Production-readiness checkpoint

Checked 2026-10-18. **The project is a tested private candidate, not yet production
ready against the agreed release requirements.** The current archive/source
identities are in [native builds](NATIVE_BUILDS.md) and the
[source-snapshot verification](audit/SOURCE_SNAPSHOT_VERIFICATION.md).

The user's stopping rule is to finish material improvements and stop when further
work offers noticeably less benefit. Apply that rule to verified failures, missing
release requirements and usability findings. Defer speculative features and further
minor polish while the blockers below remain. Passing automated checks alone does
not close the human, content or distribution requirements.

The target remains [the agreed scope](SCOPE.md): Windows/macOS, both adult reference
bodies and continuous exploration. This checkpoint does not replace that scope with
a smaller product or promote private draft content to reviewed content.

## Current engineering evidence

Runtime source `6a878b7e5c0d65f7b5525ffbc84da7af43608205` has fresh private Windows
and universal Mac archives. The 75-file source audit and all 90 Python checks pass.
The exact Windows archive passes seven-reference workflows, 784 placement
comparisons, 543 redraw comparisons, four normal launches and two early closes.
Its marked verification session is removed. The embedded Mac resource pack passes
the development-engine workflow; this does not execute the Mac binary.

[Build/source audit](audit/source-snapshot-artifact-audit.json),
[native Windows report](audit/source-snapshot-windows-qa.json),
[Python checks](audit/source-snapshot-python.log.txt).

## Personal-prototype requirements

These rows map every numbered requirement in
[Acceptance criteria](RELEASE_CRITERIA.md#personal-prototype).

| Requirement | Current evidence | Remaining acceptance |
| --- | --- | --- |
| 1. Open and identify a whole-body reference | Both HRA references and explicit Coverage/gap descriptions pass native workflows. | Human understanding; coverage remains partial. |
| 2. Orbit, pan, zoom, select, focus and return | Camera, pointer interruption, keyboard navigation and history checks pass. | Actual Mac and physical mouse/trackpad trials. |
| 3. Reveal deeper anatomy and undo visibility | Supplied-group hide/fade/show, Undo/Redo and isolation/return checks pass. | Human task completion and interpretation. |
| 4. Select small/overlapping anatomy through lists | Source search, hierarchy, part lists and tiny spinal picking checks pass. | Physical-device usability and ambiguous-target expectations. |
| 5. Explicit Move and exact restoration | Mode/gesture boundaries, keyboard steps, Undo and restoration pass. | Human mode awareness and trackpad use. |
| 6. Labels/panels retain navigation | Expanded/workspace controls, label placement, text scales and return focus pass. | Actual assistive-technology and human layout trials. |
| 7. Save/reopen and recover when content is absent | Named views, notes/drafts, transfer, conflicts, damaged input and reference fallback are checked. | Native picker/clipboard use and release-to-release upgrade acceptance. |
| 8. Installed starter content works offline | Bundled resources, source identities, export boundaries and local persistence pass. | Actual Mac launch and offline trial. |

The [private trial guide](PRIVATE_TRIAL_GUIDE.md) describes the physical-device
tasks. Its presence is a plan, not a completed trial record.

## Detailed chest journey

| Acceptance requirement | Current state |
| --- | --- |
| Run the full journey on both bodies | Scripted private workflows pass; human acceptance is pending. |
| Focus the heart in its surroundings | Implemented and checked in both HRA references. |
| Identify supplied parts using labels/lists | Implemented; source labels and anatomical interpretation remain unreviewed. |
| Inspect supplied interiors or validated cutaways | Supplied components can be isolated; validated cutaways/interior completeness are not established. |
| Distinguish conditions/highlights/comparisons | Two draft valve summaries can inspect reference locations. Disease geometry and authored comparisons are unavailable. |
| Follow the lung route and handle branches/gaps | The draft conceptual route has both lung branches, explicit gaps and reversible navigation. Qualified review is pending. |
| Retain orientation, visibility and return | Scripted orientation/history/return checks pass; human understanding remains pending. |
| Restore guided/manual separation | Exact starting-state/history and movement restoration checks pass. |
| Distinguish movement from disease state | The UI identifies teaching displacement and absent pathology. No authored disease state exists to accept. |

## Release requirements still open

| Requirement | Evidence and next acceptance |
| --- | --- |
| Declared scope and coverage in both bodies | [Coverage inventory](../content/coverage_notes.json) and [scope](SCOPE.md) explicitly retain missing skeleton/muscle/nerve coverage, unregistered studies, unavailable cutaways/comparisons and injury scenarios. Final release inventory and required content remain unresolved. |
| Qualified review of published content | [Study content](../content/study_content.json) retains 15 cards, two conditions and one route as drafts, with human source and expert reviews pending. Geometry/labels also remain unreviewed. Obtain version-specific review; automated checks cannot supply it. |
| Private pilot | Complete and retain actual task observations on representative Windows and Mac devices, including keyboard and trackpad use. No completed acceptance record is supplied by the automated runtime reports. |
| Performance | [Historical full-HD measurements](audit/WINDOWS_FULLHD_PROFILE.md) cover source `ae600197`, one Windows host and eight workloads. They do not qualify the current archives, Mac, every label density or all release workloads. Follow the [performance protocol](PERFORMANCE_PROTOCOL.md), including agreed load/memory budgets and device evidence. |
| Accessibility | Keyboard, focus, scalable text and text alternatives are implemented and checked. Actual assistive-technology trials and conformance evidence remain open. |
| Persistence and upgrades | Current-version save/reopen/recovery is tested. A defined release-to-release upgrade/rollback trial remains required. |
| Offline behavior and downloads | Starter content is bundled; local behavior is implemented. Confirm the actual device experience and document any eventual update/download flow. |
| Content and application rights | [Attributions](../ATTRIBUTIONS.md) retain pinned notices. Public rights review and an application-code license decision remain open; source access does not close these gates. |
| Distribution | Windows remains unsigned; Mac is ad-hoc signed and not notarized. Actual Mac execution and the intended public signing/distribution process require acceptance. Linux is outside the target and its separate release-template issue remains open. |
| Corrections, versions and updates | Trial/issue templates exist. A public correction route, release identity and tested update/recovery process are not yet established. No reporting service or publication is implied. |

## Next work and stopping point

1. Complete the [Mac acceptance run](MAC_ACCEPTANCE.md) against the exact current
   archive; record failures and fix material issues it reveals. The user has a Mac
   available for this run.
2. Examine native accessibility and release-identification/update gaps that can be
   addressed locally. Retain actual evidence and keep the public requirements open.
3. Complete physical-device/performance acceptance and arrange qualified content
   review and release decisions before a production-ready claim.

Stop optional feature growth at this checkpoint. The engineering candidate is ready
for those acceptance steps; the production goal remains open until its material
requirements are satisfied or the user explicitly changes them.
