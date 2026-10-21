# 03 — Anatomy Sources: Geometry and Identifiers

Two separate problems that are easy to conflate:

- **Identifiers** — what to call things, and how to name them so other systems agree.
  Cheap to adopt, and adopting them late is expensive. Do this from record one.
- **Geometry** — actual 3D meshes of anatomy. Expensive, licence-encumbered, and
  deliberately deferred per the recorded decision in
  [06-decisions.md](06-decisions.md).

**Verify every licence below against its current source before shipping anything.**
Licensing details change and the summaries here are a starting point for that check,
not a substitute for it.

---

## Identifiers — adopt now

Populate `xref` on every structure record from the beginning. Nothing consumes it on
day one; everything wants it by month six, and backfilling thousands of records by
hand is the kind of task that stalls a project permanently.

### FMA — Foundational Model of Anatomy
The reference ontology of human gross anatomy (University of Washington), ~100k
classes with rich part-of and connectivity relations. The natural primary key for
gross anatomy here, and notably the identifier system that the main open mesh sources
below already key against — which is what makes it the practical choice, not just the
principled one.

### UBERON
Cross-species anatomy ontology, well maintained, cross-references FMA and much else.
Useful as a secondary xref because it is the best-connected hub in the biomedical
ontology space — a good bridge if the project ever wants to pull in related data.

### Terminologia Anatomica
The international standard for anatomical *terminology* (the authority behind correct
Latin names). Not an open machine-readable dataset in the way the ontologies above
are — treat it as the reference for `latin` and `label` correctness rather than as
something to import.

### ICD-11 (conditions)
WHO's classification, and the sensible xref for Condition records. WHO publishes it
online with an API. Prefer it over ICD-10 for new work.

### SNOMED CT (conditions, clinical detail)
Far richer clinically than ICD, but **licensing is the catch**: free use is tied to
membership/affiliate status, which varies by country. Do not build a dependency on it
without checking the terms that apply where the project will be used. ICD-11 is the
safer default.

### Reactome (biochemical pathways)
Open, well-curated pathway database, generally the friendliest licence in this space.
The natural source if Process records extend into biochemistry.

> Note on **KEGG**: widely referenced in teaching material, but its licensing is
> restrictive for redistribution and commercial use. Check carefully before depending
> on it; Reactome is usually the better choice for an open project.

---

## Geometry — deferred, but plan for it

### Phase 1 (agreed): procedural placeholders

Generated primitives, anatomically arranged. Crude but sufficient to build and prove
every subsystem: layers, picking, cutaways, pathology overlays, process animation.
The reasoning is in [06-decisions.md](06-decisions.md#d2); the short version is that
asset plumbing done first eats the entire first phase and produces nothing runnable.

A workable generator set: long bone (shaft + epiphyses), flat/irregular bone hull,
fusiform and pennate muscle bellies between attachment points, tubular vessel/nerve
along a spline, ellipsoid and lobed organs, capsule joints.

The one thing worth spending real care on even here is **placement** — plausible
positions and proportions in a shared body coordinate frame. Placement is the part
that survives the swap to real meshes; the geometry itself is disposable.

### Phase 2: real anatomical meshes

Candidate sources, best to worst fit:

**BodyParts3D** (DBCLS, Japan) — the most viable open option. Thousands of individual
segmented structures derived from a real body, **keyed to FMA identifiers**, which
means the `xref` discipline above pays off directly: meshes map onto existing records
almost mechanically. Distributed under a Creative Commons licence including a
share-alike condition — verify the current terms, and note that share-alike propagates
to derivative geometry and constrains how the project can be distributed.

**Z-Anatomy** — an open anatomy atlas built on BodyParts3D geometry, cleaned up and
organized in Blender, with terminology applied. Often a better *starting point* than
raw BodyParts3D because the tidying work is already done. Also share-alike; same
propagation caveat.

**Commercial libraries** (BioDigital, Zygote, and similar) — highest quality, and
licensed on terms that generally do not permit redistributing the meshes inside your
own application. Realistic only if the project stays private or a licence is bought.

**Segmenting open imaging data yourself** (Visible Human Project, or open CT/MRI
datasets) — total control and no share-alike inheritance, but segmentation is a
serious specialist undertaking. Not a reasonable path for a solo project unless
segmentation is itself something you want to learn.

### The pipeline Phase 2 needs

Source meshes are far too heavy for real-time, especially in XR. Expect to build:

```
source meshes  →  decimate to a per-structure triangle budget
               →  fix normals / orientation / winding
               →  normalize to the project's body coordinate frame + scale
               →  generate LODs
               →  compress + pack to an interchange format
               →  emit a manifest: FMA id → asset path + node
```

That manifest is the entire integration point. If `xref.fma` is populated, Phase 2
reduces to running the pipeline and rewriting the `mesh` field on each record from
`{"kind": "procedural", …}` to `{"kind": "asset", …}` — a scripted transformation,
not a rewrite. **That is the payoff for the discipline asked for in Phase 1**, and the
reason the deferral is safe rather than merely convenient.

---

## Content accuracy

Geometry is the visible part; the medical content is the part that can actually
mislead. Some discipline worth adopting early:

- **Cite sources on Condition records.** The `sources` field exists for this. A claim
  without a source is a claim you cannot re-check in a year.
- **Prefer standard references** over aggregated web content for anything asserted
  as fact.
- **Mark confidence.** Some records will be written quickly while studying and
  deserve a `"draft"` flag so they can be revisited rather than silently trusted.
- **Represent variation eventually.** Textbook anatomy is a convenient fiction;
  coronary dominance, renal arteries, and the brachial plexus all vary meaningfully
  between people. Not a day-one concern, but the schema should not make it
  impossible — a variant is naturally expressed as an alternative Structure record
  plus a prevalence note.
- **State the boundary in the UI.** The educational-use, not-for-clinical-decisions
  scope from [00-vision-and-scope.md](00-vision-and-scope.md) should be visible in
  the product, not just in a design document.
