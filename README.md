# Praxis Corporis — 3D Medicine Viewer

Praxis Corporis is the existing working name; final naming is open.

A desktop anatomy explorer for aspiring doctors and medical students. Reveal body
layers, select and label structures, move parts aside, inspect internal anatomy,
follow connections, and explore related diseases within one continuous body scene.

**Status: private Godot feasibility prototype, 2026-10-15.**
The user authorised work after the planning/documentation stage. Both reference
samples are imported; coverage is partial and anatomical review is pending.
[Prototype guide](docs/PROTOTYPE.md) explains setup, controls, checks and limitations.
[Private desktop builds](docs/NATIVE_BUILDS.md) describes the Windows/Mac archives.
[Planning status](docs/PLANNING_STATUS.md) separates decisions from unverified evidence.

## Agreed direction

- Native Windows and macOS application.
- Both male and female adult reference anatomy in the first-release plan.
- Exploration first, with a clean, detailed appearance leaning realistic.
- Free manipulation and guided separated views, with anatomical restoration.
- Disease location/highlighting first; selected comparisons and authored injury
  scenarios; animation later.
- Free assets and progressive detail, with potential paid features after a free launch.
- User and assistant build together; quality over a deadline.
- Testing sequence: user, small private group, then public.

Reference journey: open the body, reveal deeper anatomy, focus on the heart, label
its parts, explore conditions, orbit it, and follow connections toward the lungs
without opening a disconnected organ scene.

## Read the plan

1. [Planning status](docs/PLANNING_STATUS.md) — decisions and unresolved evidence.
2. [Vision](docs/VISION.md) and [Scope](docs/SCOPE.md) — product and release boundaries.
3. [Interaction design](docs/INTERACTION_DESIGN.md) and
   [Interface specification](docs/INTERFACE_SPEC.md) — controls and three desktop wireframes.
4. [Features](docs/FEATURES.md) — priorities and observable behaviour.
5. [Architecture](docs/ARCHITECTURE.md) — proposed native design.
6. [Data model](docs/DATA_MODEL.md) — anatomy, geometry, connections, conditions.
7. [Content pipeline](docs/CONTENT_PIPELINE.md) and [Asset audit](docs/ASSET_AUDIT.md)
   — sources, coverage evidence, preparation, and review.
8. [Release requirements](docs/COMPLIANCE.md) — accuracy, licensing, accessibility, distribution.
9. [Roadmap](docs/ROADMAP.md) and [Acceptance criteria](docs/RELEASE_CRITERIA.md).
10. [Decisions](docs/decisions/), [Glossary](docs/GLOSSARY.md), and
    [Research notes](docs/COMPETITIVE_LANDSCAPE.md).

## Licensing and implementation

Application code licensing is undecided. A free launch does not establish an
open-source licence. Third-party content retains its applicable licences.
[ATTRIBUTIONS.md](ATTRIBUTIONS.md) lists the pinned prototype assets and notices.

Open [project.godot](project.godot) with Godot 4.7.2 after the setup in the
[prototype guide](docs/PROTOTYPE.md). The app has selection, search, camera focus,
hide/fade controls, inspection movement with original-position overlays, restoration,
undo/redo and local saved views with personal study notes.
The saved-view library searches names, notes and selected anatomy IDs, with a This reference filter and preserved drafts.
Ctrl/Cmd+F opens anatomy search from the workspace or expanded view; Escape clears search and then returns focus to 3D.
Undo delete recovers the last deleted view and its unfinished notes while the library stays open.
Save all notes, or Ctrl/Cmd+S in the library, retains every pending note without closing it.
Export safeguards recognize alternate paths to the active library and protect newer notes.
Switching away during a drag stops it; completed movement remains available to Undo.
Zoom honors fine wheel amounts and reverses equal wheel/key steps without accumulating drift away from the limits.
A selected part has an Actions menu beside its surface, with a corner fallback
for hidden or off-screen anatomy. Shift+F10 opens it from the focused 3D view.
[Menu verification](docs/audit/PART_ACTIONS_VERIFICATION.md) records the private
packages, native Windows workflows and inspected captures.
Local part labels have clickable surface leaders and controlled density;
Back/Forward restores selection and camera views while preserving inspection changes.
Camera views provides six source-backed orientations around the current focus,
with a persistent direction cue and body-side labels.
Inspect alone temporarily reveals supplied components; Return to context restores
the prior body view while preserving inspection edits.
Coverage compares supplied source groups across both references and states their gaps.
Its group list, scrollable inventory and Explore action can be used with the keyboard.
An optional BodyParts3D male bone study adds separately selectable source bones in
its own unregistered reference. [Source audit and preparation](docs/audit/BODYPARTS3D_FINDINGS.md).
Fifteen draft heart/lung study cards now include related-structure
links and primary sources. A six-step Guided chest view includes reversible chamber
separation. A sourced Heart ↔ lungs route offers either lung branch, explicit
coverage gaps and exact starting-view restoration. Saved views and notes can be exported/imported with a compatibility
preview. Text size, panel layout, rendering quality and label preferences are retained.
Normal launches also remember window size and maximized state, with size bounds
for the current display.
They reopen the last successfully loaded reference after a normal close; saved
anatomy setups and notes remain in named views.
Cancel opening preserves the current view and study progress when replacing a reference.
Closing during opening also collects pending reads before releasing staged geometry.
Two draft valve-condition summaries link to inspection of their
reference anatomy, with explicit depiction limits; human source and medical review are pending.
Precise keyboard movement supports 5 mm and 1 mm inspection steps with undo/redo.
Four separate HRA v1.2 spinal-cord/vertebra studies add 108 source meshes across both
sexes, without registering them to the original bodies. [Study workspace guide](docs/STUDY_WORKSPACE.md),
[verification and private packages](docs/audit/COVERAGE_KEYBOARD_VERIFICATION.md).
Pathological geometry, validated cutaways and physiological simulation are future work.
Private Windows/macOS ZIPs are generated locally under dist/. Target-device testing,
public signing/notarization, and baseline-laptop performance remain open.
The [full-resolution Windows measurement report](docs/audit/WINDOWS_FULLHD_PROFILE.md)
records 24 focused one-minute samples at an actual 1920 × 1080 3D buffer,
with 59.5–59.9 average frame-cadence FPS. Representative hardware and Mac trials
remain open; the report retains loading pauses, memory and single-host limits.
