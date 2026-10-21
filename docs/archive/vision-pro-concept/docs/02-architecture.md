# 02 — Architecture

Stack-agnostic. This describes subsystems, the boundaries between them, and the
requirements any candidate technology must satisfy. It should be readable as a
checklist when the stack decision is finally made.

---

## Layered structure

```
┌─────────────────────────────────────────────────────────┐
│  Presentation      layer tree · search · info panel ·   │
│                    timeline scrubber · condition picker │
├─────────────────────────────────────────────────────────┤
│  Interaction       selection · picking · camera ·       │
│                    cutaway planes · XR input            │
├─────────────────────────────────────────────────────────┤
│  Scene             visibility · materials · overlays ·  │
│                    deformation · animation              │
├─────────────────────────────────────────────────────────┤
│  Resolver   ◄── the load-bearing boundary ──►           │
│                    ids → scene objects; effects →       │
│                    visual treatments                    │
├─────────────────────────────────────────────────────────┤
│  Content           structures · relations · processes · │
│                    conditions   (pure data, no engine)  │
├─────────────────────────────────────────────────────────┤
│  Assets            geometry: generated now, real later  │
└─────────────────────────────────────────────────────────┘
```

**Content knows nothing about rendering. Rendering knows nothing about medicine.**
The Resolver is the only place the two meet, and it is the only layer that should
need rewriting if the stack is ever changed.

---

## Subsystems

### Content store
Loads and indexes the four record types. Builds the lookup structures everything else
depends on: id → structure, system → structures, region → structures, and the relation
graph in both directions (a reverse index matters — "what supplies the stomach?" is
asked as often as "what does the coeliac trunk supply?").

Pure data. No engine types. Should be testable, and meaningfully usable, with no
renderer present at all — that is the cleanest signal the boundary is intact.

### Geometry provider
Turns a `mesh` descriptor into renderable geometry, hiding *how*.

Given the recorded decision to start with procedural placeholders, this begins as a
small library of anatomically-arranged generators — a fusiform muscle belly between
two attachment points, a tubular vessel along a path, an ellipsoid organ, a long bone
with epiphyses. Crude, but sufficient to exercise every other subsystem end to end.

The contract it must hold, so the later swap to real meshes is a data edit and not a
rewrite:

- Same interface for generated and loaded geometry.
- Lazy and cancellable — a full body will not fit in memory at full detail.
- Level-of-detail aware; XR at 90fps per eye is a hard budget (see below).
- Deterministic mapping from `structure.id` → scene object, so selection and overlays
  work identically regardless of geometry origin.

### Resolver
The translation layer, and the piece most worth designing carefully:

- `structure.id` → scene object(s), including laterality instancing.
- `effect` + `magnitude` → concrete visual treatment (colour, opacity, deformation,
  outline, particle overlay).
- Process `steps[]` → an animation track along resolved anatomical positions.
- Layer/visibility queries → sets of scene objects.

Everything medical stops here. Above this line, the system is manipulating scene
objects and materials; below it, it is manipulating records.

### Scene
Visibility state, material assignment, overlay compositing, cutaway planes, animation
playback. Must handle several visual channels at once without them fighting:
base material, system tint, selection highlight, pathology effect, process animation.
Decide the compositing order once, centrally, or it becomes an unfixable mess of
special cases.

### Interaction
Picking (screen ray and XR ray), camera or user locomotion, plane-based cutaways,
layer toggling. Kept separate from Presentation so the same interaction core serves
both a flat screen and a headset — see [04-interaction-model.md](04-interaction-model.md).

### Presentation
Layer tree, search, info panel, relation browser, condition picker, process timeline.
The one subsystem expected to be substantially different between a 2D screen and an
immersive headset, which is precisely why it sits at the top with nothing depending
on it.

---

## Requirements for any candidate stack

Use this as the scoring rubric for the deferred stack decision.

**Must have**

1. Real-time 3D with per-object material control and transparency ordering that can
   be reasoned about (semi-transparent skin over opaque organs is a *core* view, not
   an edge case — this breaks naively in many engines).
2. Efficient picking against hundreds of objects.
3. Clipping/cutaway planes, or a viable path to them.
4. Instancing or equivalent, for paired structures and repeated elements (ribs,
   vertebrae, phalanges).
5. Runtime-editable materials — pathology overlays are applied per-object at runtime,
   not baked.
6. Loads a standard interchange geometry format, for when real meshes arrive.

**Strongly desirable**

7. An immersive-display path, given the original Vision Pro motivation. Worth noting
   plainly: a **WebXR-capable web stack reaches Vision Pro, Quest, phone AR, and an
   ordinary desktop browser from one codebase**, and can be built and run on this
   Linux machine today. A native visionOS stack gives the best possible headset
   experience but requires macOS and Xcode to build at all, and reaches nothing else.
   This is a real trade-off, not a foregone conclusion — it depends on whether the
   headset experience or the breadth is the actual goal.
8. Text-based, diffable content files — the content is the long-lived asset.
9. Fast iteration loop. Thousands of small content edits are coming.

**Performance budget to design against**

An immersive headset is the binding constraint: ~90fps, rendered twice. That implies
roughly 1–2ms of application logic per frame and aggressive draw-call discipline.
Practical consequences: batch by material; never rebuild scene graphs per frame;
precompute the relation graph indices at load; keep per-frame work proportional to
what changed, not to how much anatomy exists.

---

## Boundaries worth defending

These are the ones that erode quietly under deadline pressure:

- **No medical vocabulary below the Resolver.** If a material or shader mentions
  "inflammation", the boundary has leaked. It should mention *red emissive tint*.
- **No engine types above the Resolver.** If a condition record imports a vector or
  colour class from the rendering library, the content is no longer portable.
- **Content is loaded, never compiled in.** New anatomy should not require a rebuild.
  This is what eventually allows content to be authored by someone who does not code —
  including a future version of the author who does not want to.
- **One place decides visual compositing.** Not per-feature.

## Testability

The reason the boundary is drawn where it is: the content layer, the relation graph,
the validator, and most of the Resolver's mapping logic can be tested with no
renderer, no window, and no GPU. That is the majority of the project's actual
complexity, kept in the part that is cheap to verify.
