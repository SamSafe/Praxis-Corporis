# ADR 0004 — Stable Anatomical Identity

- Date: 2026-10-11
- Status: proposed.
- Deciders: assistant technical recommendation.

## Context and proposal

One anatomical concept may have several meshes and representations across bodies,
detail levels, and conditions. Vendor node names cannot be the sole identity.

Use stable namespaced anatomical IDs plus explicit mappings to representation
nodes. Preserve source IDs and ontology links. Groups and unmodelled concepts are
valid when their coverage is explicit.

## Consequences

Selection, labels, connections, conditions, and saved views use canonical identity.
Validate all declared geometry mappings and capabilities. Deprecations preserve
aliases and migration paths. See [Data model](../DATA_MODEL.md).
