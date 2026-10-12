# Contributing

The present team is the user and assistant. Planning established the product
direction; the user authorised the first private feasibility prototype on 2026-10-11.

## Version control

Keep progress in small local Git commits grouped by purpose. Inspect the diff,
validate the changed artifacts, and stage explicit files. Commit documentation
separately from later application changes. Preserve existing history and user edits.
Repository initialization is already complete; reinitialization is unnecessary.
Remote creation, pushing, public publication, and contacting others require their
own user instruction rather than being implied by local version control.

## Planning changes

Keep user-established scope distinct from proposed technical defaults and unverified
evidence. Record significant choices in [docs/decisions/](docs/decisions/).
Do not reinstate a browser/quiz-first scope without a new product decision.

## Content work

- Keep medical content separate from viewer/UI code.
- Record asset provenance, exact licences, versions, modifications, and credits.
- Write sourced original explanations; do not assume source access grants media reuse.
- Use draft, source_checked, and expert_reviewed evidence stages from
  [DATA_MODEL.md](docs/DATA_MODEL.md).
- AI may assist drafting and validation but cannot be an expert reviewer.
- Human usability review and source checking do not establish clinical verification.
- Keep anatomical ID-to-geometry mappings explicit and preserve saved-view compatibility.
- Validate capabilities and references before activating or publishing content.
- Invalidate affected review evidence when medical claims or geometry materially change.

## Code work

The current feasibility prototype uses Godot 4.7.2/GDScript and Python content tools.
Keep native viewer modules separate from portable anatomy data. Small, reviewable
changes should include validation appropriate to their behaviour.

Use the checks and setup in [docs/PROTOTYPE.md](docs/PROTOTYPE.md). Downloaded GLBs,
prepared scenes and engine caches are reproducible local artifacts, excluded from
Git. Preserve the pinned source manifest and draft-review status when regenerating
the sample catalogue. Keep documentation about actual capabilities current.

Application code licensing remains open. A public source repository or free app does
not automatically grant reuse rights. Resolve licensing before distributing code.

## Review and release

The user tests first, then a private group, then public. Public medical content requires
the proposed accuracy gate in [RELEASE_CRITERIA.md](docs/RELEASE_CRITERIA.md).
Neither this document nor the roadmap authorises sending messages to testers/reviewers.
