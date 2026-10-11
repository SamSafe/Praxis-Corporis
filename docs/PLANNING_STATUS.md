# Planning Status

Updated: 2026-10-11, using the America/Edmonton client date.

This is a documentation draft. No application, asset import, medical review,
performance measurement, or platform build has been completed. Research consists
of source-document inspection, not downloaded-model evaluation.

## Established by the user

| Decision | Direction |
|---|---|
| Audience | Aspiring doctors and medical students across learning stages. |
| Main experience | Explore anatomy and related conditions. |
| Manipulation | Both manual and guided separation. |
| Context | Remain inside one body scene and follow connections. |
| Appearance | Clean, detailed, leaning realistic. |
| Disease priorities | Locate/highlight first; comparison useful; animation later. |
| Scenarios | Supported injury/change options with causes and effects. |
| Platform | Native Windows and macOS application. Linux unnecessary now. |
| Reference anatomy | Both male and female adult bodies in the first-release plan. |
| Assets | Free, progressively expanded. |
| Business | Free initially, potentially paid later. |
| Team/timing | User and assistant; quality over a deadline. |
| Testing | User, small private group, public. |
| Review access | No qualified medical reviewer available. |

The user delegated routine design decisions. That supports draft recommendations;
implementation remains deferred until the plan is settled.

## Proposed defaults

- Godot viewer, Blender preparation, portable GLB geometry, JSON metadata.
- Ordinary student laptops; mouse/keyboard and trackpad controls.
- Offline exploration and local sessions without mandatory accounts.
- Whole-body overview with the chest as the first detailed milestone.
- Search, history, bookmarks, notes, and screenshot export.
- Source-backed explanations with recorded review evidence.
- Qualified review of published medical content as a public-release gate.
- Commercial-compatible assets, excluding noncommercial material from the core.

## Evidence and decisions still needed

| Item | Current state | How to resolve |
|---|---|---|
| Male/female coverage | Sources identified; geometry uninspected. | Audit separate structures, registration, interiors, layers, and gaps. |
| Exterior and deeper layers | Completeness unknown. | Audit the reveal-to-heart journey for both bodies. |
| Engine suitability | Godot proposed, not benchmarked. | Later asset, label, clipping, picking, export, and performance trial. |
| Baseline hardware | No measured test matrix. | Test representative Windows and Mac laptops. |
| Pathway content | Grouping is not verified connectivity. | Source/author and review explicit routes. |
| Medical review | No access. | Arrange review before the planned public content release. |
| Application licence | Undecided; no code exists. | Decide before implementation distribution. |
| Name | Existing working name: Praxis Corporis. | Confirm later. |
| Distribution | Direct downloads proposed. | Arrange packaging, signing, notarization, and platform testing. |

## Planning completion

Settle scope, interaction, content method, architecture, quality gates, release stages,
and remaining dependencies before implementation. Later feasibility trials are
acceptance work, not completed evidence at the planning stage.

The earlier browser/quiz-centred proposal is superseded by this draft.

## Current design artifacts

[Interface specification](INTERFACE_SPEC.md) adds whole-body, heart-selection, and
pathway wireframes. They contain schematic placeholders, not evaluated anatomy.
[Asset audit](ASSET_AUDIT.md) defines the evidence and per-body inventory needed
before a complete anatomy source can be selected. Neither artifact is implementation.
