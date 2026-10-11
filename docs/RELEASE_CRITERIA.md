# Acceptance Criteria

These are proposed future checks, not checks already passed.

## Plan review

- User decisions and technical proposals are distinguishable.
- Windows/macOS, both adult bodies, exploration priority, continuous context, free
  assets, potential monetization, and staged testing appear consistently.
- Model coverage, medical review, application licensing, and hardware/distribution
  evidence remain explicit dependencies.
- No implementation or asset-import milestone is described as complete.

## Personal prototype

1. Open a whole-body reference and clearly identify its coverage.
2. Orbit, pan, zoom, select, focus, and return using mouse and a usable trackpad route.
3. Reveal deeper anatomy and undo visibility changes.
4. Select small/overlapping anatomy through the structure list.
5. Move anatomy only in explicit Move mode; restore exact baseline placement.
6. Open/close labels and panels without losing selection or navigation.
7. Save/reopen a view; recover clearly when required content is absent.
8. Explore installed starter content offline.

Draft medical information is identified and private. Prototype acceptance does
not establish public accuracy or full body coverage.

## Detailed chest journey

- Run the full journey in [INTERACTION_DESIGN.md](INTERACTION_DESIGN.md) on both bodies.
- Focus on the heart within its anatomical surroundings.
- Identify supported parts with labels and the list.
- Inspect actual supplied internal anatomy or validated cutaways.
- Open supported conditions and distinguish highlights from detailed comparisons.
- Follow the documented route toward the lungs, including branch/gap handling.
- Retain orientation, useful visibility, and a route back.
- Guided separation and manual movement restore correctly.
- Inspection displacement and authored disease state remain distinct.

## Private pilot

Test task completion and understanding with a small group. Observe rather than
assuming that users understand controls. Record failed tasks, confusing labels,
lost orientation, unsupported expectations, and device/renderer problems.

At least one representative Windows device and one Mac device should run the core
journey. Trackpad and keyboard testing are explicit. Agreement on pilot size and
hardware can happen when testers are available.

## Performance targets

Proposed baseline: 1080p, at least 30 sustained FPS during ordinary navigation,
with 60 FPS as a higher-quality goal. Do not declare these achieved before measuring.

Define the actual hardware, detail preset, scene/content versions, load-time and
memory budgets during feasibility. Measure cold/warm loads, opacity-heavy views,
label density, region changes, disassembly, and condition toggling. Preserve useful
selection and detail when adapting quality.

## Public release

- Both adult bodies meet the declared core tasks and anatomical scope.
- Publish coverage and limitations for each body/region/capability.
- Medical claims, labels, routes, and visuals have appropriate qualified review
  evidence for the actual versions being published.
- All assets have compatible licences, modification records, and complete credits.
- Application licensing is selected; engine/library notices are included.
- Keyboard, trackpad, text alternatives, contrast, reduced motion, and assistive
  technology support are tested; conformance claims match evidence.
- Saves survive restart and upgrades; missing/corrupt packs fail recoverably.
- Tested Windows and Mac builds use the planned distribution/signing process.
- Offline behaviour and intentional downloads are understandable.
- Provide a correction/reporting route and versioned update process.

Ordinary testers do not supply qualified review merely by trying the app. Unresolved
review is a public-release dependency. A disclaimer cannot mark this gate passed.
