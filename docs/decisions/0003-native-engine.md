# ADR 0003 — Godot as Initial Engine Candidate

- Date: 2026-10-11
- Status: adopted for private prototype; full acceptance remains conditional.
- Deciders: assistant recommendation under delegated design decisions.

## Context and proposal

Native Windows/macOS exploration, free assets, potential paid features, and future
VR favour an engine with native exports, accessible source tooling, and suitable
licensing. Propose Godot/GDScript, portable GLB assets, and independent JSON content.

## Consequences

Test real atlas import, small-part picking, labels, transparency, prepared cutaways,
restoration, accessible controls, performance, and both platform exports before
committing. Keep source data independent of engine nodes.

The user authorised a feasibility prototype on 2026-10-11. It uses Godot 4.7.2,
GDScript, the Compatibility renderer and source-derived local scene caches.
See [Architecture](../ARCHITECTURE.md) for the target design and
[prototype guide](../PROTOTYPE.md) for actual capabilities and remaining evidence.
