# Contributing

> Pre-alpha. These conventions exist now so the project stays coherent as it grows
> (even if "the team" is just you today).

## Two kinds of contribution
1. **Code** — the app (viewer, study engine, UI).
2. **Content** — anatomy/pathology/quiz data ([DATA_MODEL.md](docs/DATA_MODEL.md)).
   Content is held to a higher bar because it teaches medicine.

## Content rules (important)
- Every structure/pathology entry has a `reviewStatus` (`draft`/`reviewed`/`verified`).
- Every non-trivial medical claim cites a source in `content/_references/`.
- **No copied text** from textbooks/atlases; write original summaries. No traced/copied
  copyrighted figures. See [COMPLIANCE.md](docs/COMPLIANCE.md).
- AI may draft, but a cited human-checked source must back every fact before it leaves
  `draft`. Never mark AI output `verified`.
- Every 3D asset added must have its license + attribution recorded in
  `content/_references/` and `ATTRIBUTIONS.md`.

## Code rules
- TypeScript; keep content out of code (data lives in `content/`).
- Respect the **shared-id contract** ([DATA_MODEL.md](docs/DATA_MODEL.md)) — never
  hardcode structure data the content files should own.
- Run content validation before committing (once the validator exists — Phase 1).

## Decisions
Significant choices get an ADR in [docs/decisions/](docs/decisions/) — don't bury them
in commit messages.

## Workflow
- Branch per change; open a PR; PRs are how content gets reviewed for accuracy.
- Keep PRs small and focused (one structure set, one feature, one fix).
