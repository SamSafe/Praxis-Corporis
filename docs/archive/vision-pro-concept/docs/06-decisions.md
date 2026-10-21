# 06 — Decision Log

Settled decisions and the reasoning behind them. Append; don't rewrite history — if a
decision is reversed, add a new entry that supersedes the old one and say why.

---

### D1 — Documentation before implementation
**Date:** 2026-07-29 · **Status:** active

No code until the design is settled and the stack is chosen deliberately.

**Why:** the schema in [01-data-model.md](01-data-model.md) is the long-lived artifact
here — content written against it will outlive several rewrites of the renderer.
Choosing a stack first tends to let the stack's conventions dictate the data model,
which is backwards for a project whose value is in the content.

---

### D2 — Procedural placeholder geometry first; real meshes later
**Date:** 2026-07-29 · **Status:** active

Phase 1 uses generated primitives arranged anatomically. Real anatomical meshes are
deferred to a later phase.

**Why:** building the asset pipeline first (multi-gigabyte downloads, decimation,
normalization, LOD generation, packing) consumes the entire first phase and produces
nothing runnable. Placeholder geometry exercises every subsystem that actually carries
risk — layers, picking, cutaways, pathology overlays, process animation — immediately.

**What makes the deferral safe:** `mesh` is a *descriptor*, not geometry
([01-data-model.md](01-data-model.md)), and `xref.fma` is populated from the first
record. The main open mesh sources are keyed to FMA identifiers, so the eventual swap
is a scripted field rewrite rather than a manual remapping.

**What would invalidate it:** discovering that placeholder geometry is too crude to
express something structurally important — plausibly the brachial plexus, the coronary
tree, or anything where the *shape itself* is the lesson rather than the arrangement.
If that happens, promote real geometry for that region only, not globally.

---

### D3 — Stack decision deferred
**Date:** 2026-07-29 · **Status:** open

To be made against the rubric in [02-architecture.md](02-architecture.md#requirements-for-any-candidate-stack).

**Context so far:** the original motivation was a Vision Pro app. The practical
tension is that a native visionOS stack gives the best headset experience but cannot
be built without macOS and Xcode — which the current Linux machine does not have —
and reaches only that device. A WebXR-capable web stack reaches Vision Pro, other
headsets, phones, and desktop browsers from one codebase, and can be developed here
today, at the cost of some polish in the headset.

Not resolved. The right answer depends on whether the headset experience is the
point or one delivery target among several — see
[07-open-questions.md](07-open-questions.md#q1).

---

### D4 — Educational scope only
**Date:** 2026-07-29 · **Status:** active

No diagnosis, no clinical decision support, no patient-specific data.

**Why:** partly regulatory — software that suggests what is wrong with a person
acquires a medical-device character and a duty of care that a learning tool should not
carry. Partly focus: the interesting problem here is making structure, process, and
pathology legible together, and that problem is fully available without going anywhere
near clinical use.

**Consequence:** the boundary should be stated in the product UI, not only here.
