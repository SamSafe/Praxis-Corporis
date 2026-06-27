# Data Model

The data model is the heart of the project. Get the **shared-id contract** right and
the 3D view, content, and quizzes stay in sync forever. Get it wrong and everything
drifts.

All content is **version-controlled files** (JSON/YAML/Markdown), validated against
schemas. No database in v1.

## Core entities

### Structure

An anatomical structure (bone, muscle, nerve, vessel, organ, region…).

```yaml
id: heart.left-ventricle        # stable, unique, matches glTF node name
name: Left ventricle
synonyms: [LV]
latin: ventriculus sinister
type: chamber                   # bone | muscle | nerve | vessel | organ | chamber | ...
system: cardiovascular
modelNodes: [heart.left-ventricle]   # node id(s) in the glTF model
function: >
  Pumps oxygenated blood into the aorta and systemic circulation; the
  highest-pressure chamber, hence its thick myocardium.
relationships:
  - kind: receives-from
    target: heart.left-atrium
  - kind: pumps-into
    target: vessel.aorta
references: [ref.gray-anatomy-ch3]    # see CONTENT_PIPELINE.md
reviewStatus: draft             # draft | reviewed | verified
```

### Pathology / Condition

A disease or condition and how it changes a structure.

```yaml
id: path.myocardial-infarction
name: Myocardial infarction (heart attack)
category: cardiovascular
summary: >
  Necrosis of myocardium due to prolonged ischemia, usually from coronary
  artery occlusion.
affects:
  - structure: heart.left-ventricle
    effect: >
      Infarcted region loses contractility; may thin, scar, or rupture.
    visual:
      type: region-overlay        # how the model shows it (overlay | color | swap-mesh | deform)
      overlayNodes: [heart.lv-anterior-wall]
      style: necrosis
presentation: [chest pain, dyspnea, ST elevation, troponin rise]
severityStages: [acute, subacute, chronic-scar]
references: [ref.robbins-path-ch12]
reviewStatus: draft
```

### Quiz item

Generated from or linked to structures/pathologies — never a free-floating fact.

```yaml
id: q.identify.left-ventricle
type: identify-structure        # identify-structure | name-structure | condition-effect | vignette
prompt: Identify the highlighted chamber.
target: heart.left-ventricle    # what's highlighted / the answer
distractors: [heart.right-ventricle, heart.left-atrium, heart.right-atrium]
explanation: >
  Thick-walled chamber on the (anatomical) left, pumping into the aorta.
links: [heart.left-ventricle]
```

### User progress (local, IndexedDB — not in repo)

```jsonc
{
  "schedulerVersion": "fsrs-1",
  "items": {
    "q.identify.left-ventricle": {
      "due": "2026-07-02T00:00:00Z",
      "stability": 4.2, "difficulty": 0.31,
      "reps": 3, "lapses": 0, "lastGrade": "good"
    }
  },
  "notes": { "heart.left-ventricle": "remember: thickest wall" }
}
```

## The shared-id contract (most important rule)

`Structure.id` == glTF node name == the key used by pathologies and quiz items.

```
   glTF model node  ──┐
                      ├──  "heart.left-ventricle"  ── one structure, one truth
   content file id  ──┤
   pathology target ─┤
   quiz target/link ─┘
```

Rules:
- IDs are **lowercase, dotted, namespaced by region/system**, never reused, never
  renamed (add `synonyms`/aliases instead).
- A structure with no matching model node, or a model node with no structure, is a
  **validation error** (build a checker — see [ROADMAP.md](ROADMAP.md) Phase 1).

## File layout (proposed)

```
content/
  heart/                      # one folder per wedge/region
    model.glb                 # 3D asset with named nodes (or pointer to it)
    structures/
      left-ventricle.yaml
      ...
    pathologies/
      myocardial-infarction.yaml
      ...
    quizzes/
      identify.yaml
  _schemas/                   # Zod/JSON schemas for validation
  _references/                # citation registry (see COMPLIANCE/CONTENT)
```

## Why files, not a database

- **Reviewable** — medical accuracy changes go through PR review (a diff a human can read).
- **Versioned** — every content change is tracked; you can see who changed a fact and why.
- **Portable** — no server, trivially hostable, easy to back up.
- Move to a DB only if/when you add multi-user authoring at scale.
