# Production-readiness checkpoint

Checked 2026-10-19. **The project is a tested private candidate, not yet production
ready against the agreed release requirements.** The current archive/source
identities are in [native builds](NATIVE_BUILDS.md) and the
[build-identity/package verification](audit/BUILD_IDENTITY_VERIFICATION.md).

The user's stopping rule is to finish material improvements and stop when further
work offers noticeably less benefit. Apply that rule to verified failures, missing
release requirements and usability findings. Defer speculative features and further
minor polish while the blockers below remain. Passing automated checks alone does
not close the human, content or distribution requirements.

The target remains [the agreed scope](SCOPE.md): Windows/macOS, both adult reference
bodies and continuous exploration. This checkpoint does not replace that scope with
a smaller product or promote private draft content to reviewed content.

On 2026-10-19 the user deferred Mac acceptance until a future Git checkout on their
Mac. That trial is not a prerequisite for continued private development. Mac support
remains in scope; actual Mac execution is unverified and remains a release
requirement. Use the [Mac source setup](PROTOTYPE.md#mac-source-checkout) for that
later checkout rather than assuming the local packaged archive is included in Git.

## Current engineering evidence

Runtime source `c86cfba1e544b20917b66c14ea405f0b74abfd47` has fresh private Windows
and universal Mac archives. The 79-file source audit and all 94 Python checks pass.
The exact Windows archive passes seven-reference workflows, 784 placement
comparisons, 543 redraw comparisons, four normal launches and two early closes.
The embedded private build ID, declared version, source inputs, engine and
content identity match the build record. Native accessibility names, 3D focus,
query updates and page/filter actions also pass in an isolated copy. The marked
verification sessions are removed. The embedded Mac resource pack passes the development-engine workflow; this does not execute the Mac binary.

The older `9e864a0` and current `c86cfba` Windows archives also pass a native
upgrade/rollback/reopen cycle: 10 normal launches, 28 saved views and 21 complete
scene comparisons across seven references. Notes/identities, preferences and window
state are preserved. The batch's 98 Python checks pass; seven altered real-data
controls are rejected. [Exact pair, evidence and limits](audit/PRIVATE_UPGRADE_VERIFICATION.md).

Current-build rendering measurements cover all sixteen workloads at actual 1080p:
48 one-minute samples retain 169,448 intervals. Only 18/48 samples held focus
throughout, so controlled foreground acceptance remains open. The formatter exposes
each workload's focus count and retains all samples/outliers. All 100 Python checks
pass. [Current evidence and limits](audit/CURRENT_PERFORMANCE_VERIFICATION.md).

The [fresh-source setup](audit/SOURCE_CHECKOUT_VERIFICATION.md) also passes from
the committed tree without prior engine/geometry caches on the development host.
All seven references prepare, the bone study reproduces its pinned geometry, and
source interaction/study/persistence checks pass without altering tracked files.
This supports the future checkout handoff; Mac execution remains deferred.

[Build/source audit](audit/build-identity-artifact-audit.json),
[native Windows report](audit/build-identity-windows-qa.json),
[Python checks](audit/build-identity-python.log.txt).

## Personal-prototype requirements

These rows map every numbered requirement in
[Acceptance criteria](RELEASE_CRITERIA.md#personal-prototype).

| Requirement | Current evidence | Remaining acceptance |
| --- | --- | --- |
| 1. Open and identify a whole-body reference | Both HRA references and explicit Coverage/gap descriptions pass native workflows. | Human understanding; coverage remains partial. |
| 2. Orbit, pan, zoom, select, focus and return | Camera, pointer interruption, keyboard navigation and history checks pass. | Actual Mac and physical mouse/trackpad trials. |
| 3. Reveal deeper anatomy and undo visibility | Supplied-group hide/fade/show, Undo/Redo and isolation/return checks pass. | Human task completion and interpretation. |
| 4. Select small/overlapping anatomy through lists | Source search, complete paged records, hierarchy, part lists and tiny spinal picking checks pass. | Physical-device usability and ambiguous-target expectations. |
| 5. Explicit Move and exact restoration | Mode/gesture boundaries, keyboard steps, Undo and restoration pass. | Human mode awareness and trackpad use. |
| 6. Labels/panels retain navigation | Expanded/workspace controls, label placement, text scales and return focus pass. | Actual assistive-technology and human layout trials. |
| 7. Save/reopen and recover when content is absent | Named views, notes/drafts, transfer, conflicts, damaged input and reference fallback are checked. The recorded Windows private pair passes upgrade/rollback/reopen. | Native picker/clipboard use, actual Mac and future changed-content/schema acceptance. |
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
| Distinguish conditions/highlights/comparisons | 126 draft condition summaries (chest, abdomen, pelvis, head and neck, brain, eyes, knees, skin and bone) can inspect reference locations; see [body study content](BODY_STUDY_CONTENT.md). Disease geometry and authored comparisons are unavailable. |
| Follow the lung route and handle branches/gaps | The draft conceptual route has both lung branches, explicit gaps and reversible navigation. Qualified review is pending. |
| Retain orientation, visibility and return | Scripted orientation/history/return checks pass; human understanding remains pending. |
| Restore guided/manual separation | Exact starting-state/history and movement restoration checks pass. |
| Distinguish movement from disease state | The UI identifies teaching displacement and absent pathology. No authored disease state exists to accept. |

## Release requirements still open

| Requirement | Evidence and next acceptance |
| --- | --- |
| Declared scope and coverage in both bodies | [Coverage inventory](../content/coverage_notes.json) and [scope](SCOPE.md) explicitly retain missing skeleton/muscle/nerve coverage, unregistered studies, unavailable cutaways/comparisons and injury scenarios. Final release inventory and required content remain unresolved. |
| Qualified review of published content | [Study content](../content/study_content.json) retains 216 cards, 126 conditions and one route as drafts, with human source and expert reviews pending. The [version-specific review packet](CONTENT_REVIEW_PACKET.md) covers build `c5b7866` with reviewer-readable text, frozen JSON, exact build identities and a 343-row results template. Geometry/labels also remain unreviewed. Obtain actual human evidence; preparation and automated checks cannot supply it. |
| Private pilot | Complete and retain actual task observations on representative Windows and Mac devices, including keyboard and trackpad use. No completed acceptance record is supplied by the automated runtime reports. |
| Performance | [Current 48-sample measurements](audit/CURRENT_PERFORMANCE_VERIFICATION.md) cover `c86cfba`, sixteen workloads and actual 1080p on one Windows host; 18/48 samples retained focus. Controlled foreground, representative Windows/Mac, additional-density/overlay/transition and agreed load/memory-budget evidence remain required by the [protocol](PERFORMANCE_PROTOCOL.md). Historical all-focused measurements remain tied to `ae600197`. |
| Accessibility | Keyboard, focus, scalable text and text alternatives are implemented and checked. Native names, 3D focus, query updates and page/filter actions pass. Native assistive scrolling/row activation, actual screen-reader trials and conformance evidence remain open. |
| Persistence and upgrades | Current-version save/reopen/recovery and the [exact Windows private pair](audit/PRIVATE_UPGRADE_VERIFICATION.md) pass. The [update/rollback guide](PRIVATE_UPDATE_TRIAL.md) covers backups and preserving later notes. Actual Mac, future schema/content changes and the public update process remain open. |
| Offline behavior and downloads | Starter content is bundled; local behavior is implemented. Confirm the actual device experience and document any eventual update/download flow. |
| Content and application rights | [Attributions](../ATTRIBUTIONS.md) retain pinned notices. Public rights review and an application-code license decision remain open; source access does not close these gates. |
| Distribution | Windows remains unsigned; Mac is ad-hoc signed and not notarized. Actual Mac execution and the intended public signing/distribution process require acceptance. Linux is outside the target and its separate release-template issue remains open. |
| Corrections, versions and updates | Trial/issue templates exist. Private exports now expose a unique build ID and source fingerprint in Sources and START_HERE, checked against their build record. A public correction route, release policy and tested update/recovery process remain open. No reporting service or publication is implied. |

## Next work and stopping point

1. Use the recorded Windows compatibility pair and backup procedure for private
   trials. Address material failures from actual-device and assistive-technology
   trials; public release policy and future migrations remain open.
2. Complete physical-device/performance acceptance and arrange qualified content
   review and release decisions before a production-ready claim.
3. Mac acceptance is deferred at the user's request (reconfirmed 2026-11-20, when
   Vision Pro / visionOS work was also deferred). When their future Mac checkout
   is available, record its actual revision and observations using the
   [acceptance guide](MAC_ACCEPTANCE.md); fix material issues it reveals then.

Stop optional feature growth at this checkpoint. The engineering candidate is ready
for those acceptance steps; the production goal remains open until its material
requirements are satisfied or the user explicitly changes them.
