# 01 — Data Model

This is the centre of the design. Get this right and the rendering layer stays small
and the content scales indefinitely. Get it wrong and every new disease becomes a
code change.

Examples below are written as JSON for legibility. The serialization format is not
decided — see [07-open-questions.md](07-open-questions.md). What matters here is the
*shape* of the information, not the syntax.

---

## The four record types

| Type | Answers | Example |
| --- | --- | --- |
| **Structure** | "What is this thing?" | Left ventricle, biceps brachii, sciatic nerve |
| **Relation** | "How do these things connect?" | The sciatic nerve innervates biceps femoris |
| **Process** | "What flows or happens, and where?" | Cardiac conduction, the patellar reflex arc |
| **Condition** | "What goes wrong, and what does it do to the above?" | Aortic stenosis, L4/L5 disc herniation |

Structures and Relations are the substrate. Processes and Conditions are *overlays*
that reference the substrate and never duplicate it.

---

## 1. Structure

A named anatomical entity. One record per entity, regardless of how many meshes it
eventually takes to draw it.

```json
{
  "id": "heart.ventricle.left",
  "label": "Left ventricle",
  "latin": "Ventriculus sinister",
  "synonyms": ["LV"],
  "xref": { "fma": "FMA:7101", "uberon": "UBERON:0002084" },

  "systems": ["cardiovascular"],
  "region": "thorax.mediastinum",
  "parent": "heart",
  "laterality": "none",

  "mesh": { "kind": "procedural", "generator": "chamber.ellipsoidShell", "params": { } },
  "transform": { "position": [0.01, 1.30, 0.02] },

  "appearance": { "material": "myocardium", "defaultOpacity": 1.0 },

  "notes": "Wall ~3x thicker than RV; generates systemic pressure."
}
```

### Field notes

**`id`** — a hierarchical, human-readable, permanently stable string. This is the
single most important decision in the whole schema, because every other record type
points at it. Rules:

- Dotted path, lowercase, describing containment: `limb.upper.arm.muscle.biceps_brachii`.
- **Never renamed.** If a name turns out wrong, add a synonym or an alias record;
  do not rewrite the id, because thousands of references will point at it.
- Laterality is *not* in the id. One record for "biceps brachii", with
  `"laterality": "paired"`, instantiated twice at render time as `…biceps_brachii@left`
  and `@right`. This halves the authoring burden and makes "show all flexors" trivial.
  Where left and right genuinely differ (lungs, kidneys' vascular relations, the
  recurrent laryngeal nerves), write two records — the model must allow both.

**`xref`** — external identifiers. Not decoration; this is what lets the project
eventually pull in real geometry, connect to ontologies, and be checked for accuracy
against a source of truth. Populate it from the beginning even when nothing consumes
it yet — backfilling 2,000 records later is miserable. See
[03-anatomy-sources.md](03-anatomy-sources.md) for which identifier systems to use.

**`systems`** — an *array*, not a single value, because the body does not partition
cleanly. The diaphragm is respiratory and muscular. The pancreas is digestive and
endocrine. Any schema that forces one system per structure will start lying almost
immediately.

**`parent`** — containment, forming a tree used for the layer/visibility UI ("hide
the thorax" hides everything inside it). Keep this **strictly** containment. Every
other kind of connection is a Relation, not a parent link. Resist the temptation to
overload it.

**`mesh`** — a *reference to how geometry is obtained*, never geometry itself. This
indirection is what makes the agreed placeholder-first strategy work: the same record
survives the switch from a generated primitive to a real anatomical mesh by editing
one field.

```json
"mesh": { "kind": "procedural", "generator": "muscle.fusiform", "params": { "origin": [...], "insertion": [...] } }
"mesh": { "kind": "asset", "src": "assets/heart/lv.glb", "node": "LV_wall" }
"mesh": { "kind": "composite", "parts": ["…"] }
"mesh": { "kind": "none" }
```

`"kind": "none"` matters more than it looks — plenty of useful records (a *region*
like "posterior triangle of the neck", an abstract grouping like "muscles of
mastication") have no geometry of their own and exist purely to organize others.

---

## 2. Relation

A typed, directed edge between two structures. Stored separately from structures so
that adding a new *kind* of connection never requires touching structure records.

```json
{ "type": "innervates", "from": "nerve.femoral",   "to": "muscle.quadriceps.rectus_femoris" }
{ "type": "supplies",   "from": "artery.coeliac",  "to": "organ.stomach" }
{ "type": "drains_to",  "from": "vein.splenic",    "to": "vein.portal_hepatic" }
{ "type": "origin",     "from": "muscle.biceps_brachii", "to": "bone.scapula.supraglenoid_tubercle" }
{ "type": "insertion",  "from": "muscle.biceps_brachii", "to": "bone.radius.tuberosity" }
{ "type": "action",     "from": "muscle.biceps_brachii", "to": "joint.elbow", "qualifier": "flexion" }
```

A starting vocabulary of relation types — deliberately closed, extended only
deliberately, because an open vocabulary degrades into synonyms within months:

`part_of` · `supplies` · `drains_to` · `innervates` · `origin` · `insertion` ·
`action` · `articulates_with` · `adjacent_to` · `passes_through` · `secretes` ·
`continuous_with`

This relation graph is quietly the highest-value asset in the project. Once it exists,
questions that are painful in a textbook become one query: *what does the femoral
nerve supply?* *what would ischaemia of the anterior descending artery affect?*
*which muscles cross the elbow?* The UI in
[04-interaction-model.md](04-interaction-model.md) is largely a browser for this graph.

---

## 3. Process

Something that happens *through* anatomy over time. This is what makes physiology
visible rather than described.

```json
{
  "id": "process.cardiac_conduction",
  "label": "Cardiac conduction",
  "kind": "electrical",
  "steps": [
    { "at": "heart.node.sinoatrial",       "t": 0,   "label": "SA node depolarizes" },
    { "at": "heart.atrium.right",          "t": 30,  "label": "Right atrial contraction" },
    { "at": "heart.node.atrioventricular", "t": 80,  "label": "AV delay",  "dwell": 100 },
    { "at": "heart.bundle.his",            "t": 180 },
    { "at": "heart.purkinje",              "t": 220, "label": "Ventricular depolarization" }
  ]
}
```

Three families of process are worth supporting, and they share this shape:

- **Transport** — blood, lymph, air, bile, urine. A path through vessels/ducts, animated.
- **Signal** — conduction, reflex arcs, ascending/descending tracts. A path through
  neural structures, animated, often with a delay or synapse.
- **Biochemical** — metabolic and pharmacological cascades. Here `at` may reference a
  *tissue or cell compartment* rather than a gross structure, so the id space must
  eventually extend below gross anatomy. Design for it; don't build it yet.

Note the deliberate omission: no coordinates. A process is expressed purely as a
sequence of anatomical references. The renderer resolves those to positions along
the geometry. Hardcoding coordinates here would break the moment real meshes replace
the placeholders — the same reason `mesh` is indirect.

---

## 4. Condition

A disease, injury, or lesion. **This is the record type the whole architecture exists
to make cheap**, since the stated goal is to keep adding them indefinitely.

```json
{
  "id": "condition.aortic_stenosis",
  "label": "Aortic stenosis",
  "xref": { "icd11": "BB60.0" },
  "category": "valvular",

  "involves": [
    {
      "structure": "heart.valve.aortic",
      "effect": "narrowing",
      "severity": "primary",
      "visual": { "highlight": "#c94f4f", "deform": "stenosis", "magnitude": 0.6 },
      "note": "Calcific degeneration; reduced leaflet excursion."
    },
    {
      "structure": "heart.ventricle.left",
      "effect": "hypertrophy",
      "severity": "secondary",
      "visual": { "deform": "wallThickening", "magnitude": 0.5 },
      "note": "Concentric hypertrophy from chronic pressure overload."
    }
  ],

  "affects_process": [
    { "process": "process.systemic_circulation", "change": "reduced_flow", "at": "heart.valve.aortic" }
  ],

  "presentation": ["Exertional syncope", "Angina", "Dyspnoea", "Ejection systolic murmur radiating to carotids"],
  "explanation": "Fixed outflow obstruction limits the ability to raise cardiac output on exertion…",
  "sources": ["…"]
}
```

### Why this shape

Everything sits in `involves[]`, an array of *(structure, effect, visual)* triples.
That single decision is what keeps the renderer generic: it does not know what aortic
stenosis is. It knows how to apply an `effect` of `narrowing` with `magnitude 0.6` to
whatever structure it is pointed at. Adding a hundred more conditions adds zero
rendering code.

The `effect` vocabulary must therefore be a **closed, deliberately curated set** —
the actual API between content and renderer. A reasonable starting set:

`inflammation` · `necrosis` · `ischaemia` · `hypertrophy` · `atrophy` · `narrowing` ·
`dilation` · `occlusion` · `mass` · `fracture` · `displacement` · `effusion` ·
`fibrosis` · `demyelination` · `erosion`

Each needs exactly one visual treatment defined once, applied everywhere. Adding a
sixteenth effect is a real (small) piece of work; adding the two-hundredth condition
that reuses the existing fifteen is free. That asymmetry is the entire point.

`severity: primary | secondary | consequence` encodes causal ordering, which lets the
UI do something textbooks are bad at: reveal a disease *in the order it happens*
rather than as a flat list of features.

---

## Integrity rules

Worth enforcing with a validator from the very first record, because broken references
are silent and accumulate:

1. Every `structure` / `from` / `to` / `at` reference resolves to an existing Structure id.
2. Structure `parent` chains are acyclic and terminate at a root.
3. Every `effect` and `relation.type` is in the closed vocabulary.
4. No two Structures share an `id`; no `id` is ever reused after deletion.
5. Every `xref` namespace is one of the recognized set (`fma`, `uberon`, `icd11`, …).
6. Warn on Structures with no relations — usually a sign of a half-written record.

## What to resist

- **Coordinates in Condition or Process records.** They reference structures; the
  renderer resolves position. Anything else breaks when geometry is replaced.
- **Rendering hints leaking into anatomy.** A Structure says what it *is*. How thick
  a highlight outline should be is the renderer's business.
- **One-off fields for one condition.** If a disease needs something the schema can't
  express, that is a signal to extend the closed vocabulary deliberately — not to add
  a bespoke key that only one record uses.
- **Free-text where an id belongs.** `"affects": "the left ventricle"` is unqueryable
  and unlinkable. It will be everywhere within a month if allowed once.
