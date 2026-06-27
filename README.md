# Praxis Corporis

*"Practice of the body"* — Latin (*praxis corporis*).

An interactive 3D atlas of the human body that lets you **navigate anatomy from any
perspective, label structures, study and quiz yourself, and overlay diseases and
pathologies to see how they affect the body** — built to stay useful from MCAT prep
through medical school and into clinical practice.

> Status: **Concept / Pre-alpha.** This repo currently contains planning and
> documentation only. No application code yet. See [docs/ROADMAP.md](docs/ROADMAP.md).

## Why this exists

Most study tools are either flat (flashcards, 2D atlases) or expensive walled gardens.
The goal here is a tool that connects **structure → function → pathology → clinical
reasoning** in one navigable 3D space, with a built-in testing/spaced-repetition layer
so the same tool that teaches you also examines you.

See the full motivation and a hard look at whether this should exist in
[docs/VISION.md](docs/VISION.md).

## Read the docs in this order

1. [docs/VISION.md](docs/VISION.md) — what we're building and why; the honest scope reality
2. [docs/COMPETITIVE_LANDSCAPE.md](docs/COMPETITIVE_LANDSCAPE.md) — what already exists and where the gap is
3. [docs/SCOPE.md](docs/SCOPE.md) — picking a wedge so this is finishable
4. [docs/FEATURES.md](docs/FEATURES.md) — feature catalog, prioritized
5. [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — proposed technical design
6. [docs/DATA_MODEL.md](docs/DATA_MODEL.md) — how anatomy/pathology/quiz data is structured
7. [docs/CONTENT_PIPELINE.md](docs/CONTENT_PIPELINE.md) — where 3D models and medical facts come from (the hard part)
8. [docs/COMPLIANCE.md](docs/COMPLIANCE.md) — licensing, medical accuracy, disclaimers, liability
9. [docs/ROADMAP.md](docs/ROADMAP.md) — phased plan, milestones
10. [docs/decisions/](docs/decisions/) — Architecture Decision Records (ADRs)
11. [docs/GLOSSARY.md](docs/GLOSSARY.md) — shared vocabulary

## Quick start

There is no app to run yet. The first buildable milestone is defined in
[docs/ROADMAP.md](docs/ROADMAP.md) (Phase 0 → Phase 1).

## License

TBD — see [docs/COMPLIANCE.md](docs/COMPLIANCE.md). Note that **content licensing**
(3D models, medical text) and **code licensing** are separate decisions, and the
content side is the one most likely to sink the project if ignored.
