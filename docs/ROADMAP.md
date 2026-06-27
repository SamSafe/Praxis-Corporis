# Roadmap

Phased so that **something works end-to-end early** and each phase produces a usable
artifact. Pick the wedge first ([SCOPE.md](SCOPE.md)).

## Phase 0 — Foundations & decisions (no app yet)
**Goal:** remove ambiguity so building is mechanical.
- [ ] Choose the **wedge region** (heart vs upper limb vs kidney).
- [ ] Choose **3D sourcing approach** (open asset set vs hosted API) — record as ADR.
- [ ] Choose **code license** — record as ADR.
- [ ] Confirm stack ([ARCHITECTURE.md](ARCHITECTURE.md)) — record as ADR.
- [ ] Lock the **shared-id naming convention** ([DATA_MODEL.md](DATA_MODEL.md)).
- **Deliverable:** filled-in docs + 3 ADRs. (This step is half-done already.)

## Phase 1 — Viewer skeleton ("hello, body")
**Goal:** load and navigate one model in the browser.
- [ ] Scaffold app (Vite + React + react-three-fiber + TypeScript).
- [ ] Load the wedge's glTF; orbit camera; light/material setup.
- [ ] Click a node → log its id (proves the selection mechanism).
- [ ] Content-validation script (every model node has a structure & vice versa).
- **Deliverable:** deployed static page where you can rotate the region and click parts.

## Phase 2 — Knowledge layer
**Goal:** click → learn.
- [ ] Author structure content files for the region (`draft` status).
- [ ] Info panel renders name/function/relationships from content by id.
- [ ] Label toggle; isolate/hide; opacity; one clipping plane.
- [ ] Search/jump to structure by name.
- **Deliverable:** a genuinely useful labeled, clickable atlas of one region.

## Phase 3 — Pathology layer
**Goal:** normal ↔ disease.
- [ ] Author 3–5 pathologies with `visual.type` overlays.
- [ ] Toggle disease on/off; render overlay; show condition info + presentation.
- **Deliverable:** "show me an MI on this heart and tell me what happens."

## Phase 4 — Testing loop (the differentiator)
**Goal:** the tool examines you.
- [ ] Quiz items from structures/pathologies; identify-structure mode.
- [ ] FSRS scheduler; per-item mastery; due-today queue.
- [ ] Progress persisted in IndexedDB.
- **Deliverable:** a daily spaced-repetition study session over the region.

## Phase 5 — Polish & validate the wedge
**Goal:** beat the incumbents *for this region*.
- [ ] UX pass, performance, accessibility basics, disclaimer banner.
- [ ] Put it in front of 3–5 real students; collect feedback.
- **Gate:** do people prefer it for this region? If no, iterate here — **do not expand.**

## Phase 6+ — Expand
- [ ] Add the next region using the now-proven pipeline.
- [ ] More question types; exam mode; user notes/markup.
- [ ] Begin medical review process (`draft` → `reviewed` → `verified`).
- [ ] Then consider: accounts/sync, mobile, educator features, systemic disease tracing,
      AI tutor — each justified by real demand, each its own mini-roadmap.

## Suggested first three concrete steps
1. Decide the wedge (write it into [SCOPE.md](SCOPE.md)).
2. Find one CC-licensed model of that region and confirm its license.
3. Do Phase 1 — get it on screen and clickable. Momentum comes from seeing it move.
