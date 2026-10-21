# Anatomy Visualizer — Design Documentation

> **Archived 2026-10-20.** This is the earlier, headset-first design (July 2026), merged
> here from the former `vision_pro_medicine_visualizer` folder. It is kept unchanged as
> input for a future VR/visionOS port. Praxis Corporis has since superseded its open
> questions: the engine is Godot ([ADR 0003](../../decisions/0003-native-engine.md)) and
> the first target is native desktop ([ADR 0005](../../decisions/0005-exploration-platform.md)).
> Its headset interaction notes are in [04-interaction-model.md](docs/04-interaction-model.md).

An interactive 3D visualizer of the human body, designed from the start to grow into
a platform for layering **structure** (bones, muscles, organs, vessels, nerves),
**process** (physiological and biochemical pathways), and **pathology** (diseases and
their anatomical footprint) on top of a shared anatomical substrate.

## Status

**Design phase.** No implementation yet. No stack chosen yet.

These documents are deliberately technology-agnostic: they describe *what the system
must be able to represent and do*, not which engine, language, or framework does it.
The stack decision comes later and should be made against the requirements in
[docs/02-architecture.md](docs/02-architecture.md), not the other way around.

## Documents

| Doc | What it covers |
| --- | --- |
| [00-vision-and-scope.md](docs/00-vision-and-scope.md) | What this is for, who it serves, what it explicitly is not |
| [01-data-model.md](docs/01-data-model.md) | The core of the design: how anatomy, conditions, and pathways are represented |
| [02-architecture.md](docs/02-architecture.md) | Subsystems, boundaries, and the requirements any stack must satisfy |
| [03-anatomy-sources.md](docs/03-anatomy-sources.md) | Where real geometry and real identifiers come from, and their licenses |
| [04-interaction-model.md](docs/04-interaction-model.md) | How a user navigates a body — on a screen and in an immersive headset |
| [05-roadmap.md](docs/05-roadmap.md) | Phased build order, with the reasoning for the sequence |
| [06-decisions.md](docs/06-decisions.md) | Decision log — what has been settled, and why |
| [07-open-questions.md](docs/07-open-questions.md) | What still needs a call before building |

## The one idea everything else follows from

> **Geometry is an asset. Anatomy is data. Knowledge is a separate layer that references
> anatomy by stable identifier and never touches geometry.**

A disease does not own a mesh. A disease is a record that says *"this process affects
these structures, in this way, with these consequences."* The renderer's job is to turn
that statement into something you can see. Every extensibility goal in this project —
adding muscles, adding diseases, adding pathways, adding a whole new body system —
reduces to *adding records*, not writing rendering code.

If a future change requires editing the renderer to add a disease, the architecture
has failed. That is the test to hold every design decision against.
