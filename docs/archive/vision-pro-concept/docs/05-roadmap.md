# 05 — Roadmap

Phases are ordered by **risk retired per unit of effort**, not by how impressive the
result looks. Each phase should end with something runnable — a phase that ends with
"infrastructure is ready" is a phase that can silently fail.

The recurring failure mode for a project like this is spending months on breadth
(hundreds of structures) before proving depth (one structure that does everything).
The ordering below is designed to make that mistake hard.

---

## Phase 0 — Decide

Settle the open questions in [07-open-questions.md](07-open-questions.md) that block
building: stack, serialization format, coordinate convention.

**Done when:** the decisions are written into [06-decisions.md](06-decisions.md) with
reasoning.

---

## Phase 1 — One structure, end to end

A single structure — say the heart — rendered from a record, selectable, with an info
panel driven by real data.

Deliberately tiny, and the most important phase in the plan. It forces the
Content → Resolver → Scene path to exist and proves the boundaries in
[02-architecture.md](02-architecture.md) actually hold under contact with a renderer.
Every boundary violation the project would otherwise live with for years shows up
here, when it costs an hour to fix.

**Done when:** clicking the heart shows its name from a data file, and no medical
term appears anywhere below the Resolver.

---

## Phase 2 — The vertical slice

One region, done properly. Thorax is a good choice: it contains a rich mix of tissue
types and the two most teachable processes in the body.

- ~30–50 structures: heart with chambers and valves, great vessels, lungs and lobes,
  ribcage, diaphragm.
- Relation graph populated for all of them.
- Layer controls by system and region, with ghosting.
- Search.
- **One process** (cardiac conduction — small, visual, and a genuinely good test of
  the timing model).
- **One condition** (myocardial infarction — hits multiple structures with different
  effects and severities, exercising the staged causal reveal).

This is where you learn whether the schema survives contact with real content. Expect
to change it here, which is exactly why it happens at 40 records and not 400.

**Done when:** you can select a condition and watch it appear across the anatomy in
causal order, and you would voluntarily use the result to study.

---

## Phase 3 — Widen

Only now go broad, and only with the schema stable.

Region by region, driven by whatever you are actually studying — that keeps content
authoring aligned with something you were going to do anyway, which is the only
sustainable model for a solo project. Add cutaway planes here; they become essential
once there is enough anatomy to hide things.

**Done when:** content growth is routine and boring. Boring is the goal.

---

## Phase 4 — Immersive

Add the headset path once there is enough content to be worth putting on a headset for.

Deliberately late, and worth being clear about why given it was the original
motivation: XR multiplies the cost of every UI decision, and the underlying value —
the anatomy, the relation graph, the conditions — is the same in both. Building the
substrate first means the headset version arrives as a new presentation over proven
content rather than as a parallel project.

If the stack chosen in Phase 0 is WebXR-capable, much of this is enabling a mode and
rebuilding the panels for spatial placement rather than starting over.

**Done when:** the same content is navigable in a headset at frame rate.

---

## Phase 5 — Real geometry

Run the mesh pipeline from [03-anatomy-sources.md](03-anatomy-sources.md) and flip
`mesh` descriptors from procedural to asset.

Late by design, and safe to be late *only because* `xref.fma` was populated from the
start. If that discipline slipped, this phase becomes a manual remapping of every
record and gets much worse — which is the reason it is called out in three separate
documents.

**Done when:** the visualizer looks like anatomy instead of like geometry, with no
schema change.

---

## Later, if it earns it

- Cross-sectional view alongside the 3D model, mapped to imaging planes.
- Pharmacology as a Process family — drugs acting at points in existing cascades.
- Quiz mode; the relation graph generates questions almost for free.
- Anatomical variation.
- Sharing — a link that opens a specific view, which is what makes it useful for
  teaching or explaining to a patient.

---

## Signals to watch

**Healthy**
- Adding a condition means writing one file and nothing else.
- The content layer's tests run without a renderer.
- You reach for the tool while studying without deciding to.

**Trouble**
- A new disease requires a code change → the Resolver boundary has leaked.
- The `effect` vocabulary is growing per-condition → it stopped being an API.
- Broad content growth before the schema stabilized → a costly migration is queued up.
- Months of work with nothing runnable → the phase ordering was abandoned.
