# Roadmap

Progress by demonstrated quality, not a fixed deadline. The team is the user and
assistant. Planning precedes implementation.

## Stage 0 — Settle the design

- Review the product, scope, interaction journey, architecture proposal, and data model.
- Confirm established decisions and proposed defaults.
- Record source candidates and their unverified coverage.
- Understand medical-review and distribution dependencies.
- Keep application licence and working name explicitly open.

Deliverable: coherent reviewable documentation. **Current stage.**
Documentation completion does not authorise coding automatically.

## Stage 1 — Feasibility and asset audit, after implementation is authorised

- Inspect selected free-source model files and record actual licences/versions.
- Audit both adult reference bodies and their coverage gaps.
- Verify exterior/layer removal, organ subparts, interiors, and spatial registration.
- Trial Godot import, picking, focus, labels, transparency, cutaways, and local restoration.
- Export and test minimal native viewers on Windows and macOS.
- Establish representative baseline laptops and benchmark render/load behaviour.
- Evaluate keyboard/trackpad access and native accessibility support.

Gate: a supported content path for both bodies and a viable measured engine.
If either fails, revise assets, engine, or public scope before deep implementation.
An isolated male-only proof can test import, but does not satisfy this gate.

## Stage 2 — Personal whole-body explorer

- Whole-body overview for both references, with explicit incomplete coverage.
- Continuous camera navigation, selection, system/region browsing, and search.
- Reversible hide/fade/reveal controls, local labels, orientation, and history.
- Explicit Move mode, original-position context, restoration, and undo.
- Proposed local saved views and offline starter content.

Gate: the user can explore, reveal anatomy, select a structure, and return without
getting lost or accidentally moving parts.

## Stage 3 — Detailed chest journey

- Heart and surrounding chest anatomy remain in the body scene.
- Supported internal components and prepared cutaways.
- Guided separated views with exact restoration.
- Reviewed/sourced connection records and route guidance toward the lungs.
- Local-part labels, composition, and expandable explanations.

Gate: the complete reference journey works in both bodies with declared supported
detail and no invented connections or hidden missing content.

## Stage 4 — Conditions and injury exploration

- Related-condition lists and affected-structure highlights.
- An initial authored condition set, selected comparisons, and a supported injury scenario.
- Clear normal/condition state, sources, review evidence, and reset.
- Content-version handling, correction process, and scenario capability validation.

Gate: the user understands what a visual represents and can restore normal anatomy.
Unreviewed medical material stays in private drafts.

## Stage 5 — Private pilot

- Test with people the user knows; no messages or recruitment actions are implied.
- Observe task completion, orientation, menu/label clarity, trackpad usability,
  performance, and whether explanations support the exploration.
- Include both reference bodies and representative Windows/Mac devices.
- Resolve material problems before broader release.
- Seek qualified medical review separately.

Gate: [Private pilot criteria](RELEASE_CRITERIA.md) met; usability feedback is not
a substitute for accuracy review.

## Stage 6 — Public release

- Freeze and publish the actual anatomy/condition/capability inventory.
- Obtain qualified review of the content being published.
- Resolve licences/credits and application code licensing.
- Complete performance, save recovery, accessibility, and platform packaging checks.
- Distribute tested builds with a correction/contact mechanism and supported-system list.

Gate: [Public criteria](RELEASE_CRITERIA.md) met. If review or complete required body
coverage remains unresolved, retain the private pilot or revise release scope with
the user. Do not declare a launch complete because time or effort has been spent.

## Later expansion

Extend detail across systems, conditions, comparisons, and authored injuries.
Then consider animation, microscopic content, additional variants, simpler mobile
access, VR, and optional study tools. Retain portable content and review/version evidence.
