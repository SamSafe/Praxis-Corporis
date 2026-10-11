# Contributing

The present team is the user and assistant. This repository currently contains
planning documentation; implementation waits until the plan is settled.

## Planning changes

Keep user-established scope distinct from proposed technical defaults and unverified
evidence. Record significant choices in [docs/decisions/](docs/decisions/).
Do not reinstate a browser/quiz-first scope without a new product decision.

## Content work, after implementation is authorised

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

## Code work, after implementation is authorised

Godot/GDScript and offline preparation tools are proposed, not committed scaffolding.
Keep native viewer modules separate from portable anatomy data. Small, reviewable
changes should include validation appropriate to their behaviour.

Application code licensing remains open. A public source repository or free app does
not automatically grant reuse rights. Resolve licensing before distributing code.

## Review and release

The user tests first, then a private group, then public. Public medical content requires
the proposed accuracy gate in [RELEASE_CRITERIA.md](docs/RELEASE_CRITERIA.md).
Neither this document nor the roadmap authorises sending messages to testers/reviewers.
