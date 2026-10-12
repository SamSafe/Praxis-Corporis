# Praxis Corporis — 3D Medicine Viewer

Praxis Corporis is the existing working name; final naming is open.

A desktop anatomy explorer for aspiring doctors and medical students. Reveal body
layers, select and label structures, move parts aside, inspect internal anatomy,
follow connections, and explore related diseases within one continuous body scene.

**Status: private Godot feasibility prototype, 2026-10-12.**
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
undo/redo and local saved views.
Local part labels have clickable surface leaders and controlled density;
Back/Forward restores selection and camera views while preserving inspection changes.
Inspect alone temporarily reveals supplied components; Return to context restores
the prior body view while preserving inspection edits.
Disease content, validated cutaways and guided pathways are future work.
Private Windows/macOS ZIPs are generated locally under dist/. Target-device testing,
public signing/notarization, and baseline-laptop performance remain open.
