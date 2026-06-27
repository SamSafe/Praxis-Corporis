# Feature Catalog

Features are tagged by priority:
- **[v1]** — part of the first wedge (see [SCOPE.md](SCOPE.md))
- **[v2]** — next, after the wedge is good
- **[later]** — North Star; aspirational

## 1. Navigation & viewing

- **[v1]** Rotate, pan, zoom the model (orbit camera).
- **[v1]** Isolate / hide structures and systems (skeletal, muscular, nervous, vascular…).
- **[v1]** Opacity / X-ray to see through layers.
- **[v1]** Cross-section / clipping plane (slice the model along an axis).
- **[v2]** Preset views & camera bookmarks (e.g. "anterior brachial plexus").
- **[v2]** Layer peeling (skin → fascia → muscle → bone).
- **[later]** Free-form dissection; explode view; physiology animation (heartbeat, peristalsis).

## 2. Labeling & annotation

- **[v1]** Toggle structure labels on/off.
- **[v1]** Click a structure to select & highlight it.
- **[v1]** Structure info panel (name, function, key relationships).
- **[v2]** User pins/notes attached to coordinates or structures.
- **[v2]** Drawing/markup on a saved view; export image.
- **[later]** Shareable annotated views/scenes.

## 3. Knowledge layer (structure → function)

- **[v1]** Per-structure data: name(s) incl. Latin/eponyms, function, relationships
  (e.g. muscle: origin/insertion/innervation/action/blood supply).
- **[v2]** Cross-links between structures ("innervated by", "drains to").
- **[v2]** Search/jump to any structure by name.
- **[later]** Full knowledge graph traversal across systems.

## 4. Pathology & disease

- **[v1]** Normal ↔ diseased toggle for 3–5 conditions in the wedge region.
- **[v1]** Condition info: what it is, cause, effect on the structure, presentation.
- **[v2]** Multiple severities/stages of a condition.
- **[v2]** Link condition → affected structures → expected symptoms.
- **[later]** **Systemic disease tracing** — pick a systemic condition (diabetes,
  hypertension, sickle cell) and see its impact across every affected organ system.
- **[later]** Lesion placement ("cut this nerve here, what's the deficit?").

## 5. Testing & study (the differentiator)

- **[v1]** Identify-the-structure quiz (click the highlighted part / name it).
- **[v1]** Spaced-repetition scheduler over the region's items (SM-2 or FSRS).
- **[v1]** Track per-item mastery; due-today queue.
- **[v2]** Question types: condition→effect, effect→condition, clinical vignette → 3D answer.
- **[v2]** Custom study sets / "exam mode" (timed, scored).
- **[later]** Import/export decks (Anki interop); shared community decks.

## 6. Content authoring (for you, the maintainer)

- **[v1]** Content lives in version-controlled files (see [DATA_MODEL.md](DATA_MODEL.md)),
  editable without touching app code.
- **[v2]** Authoring/validation tooling (schema checks, broken-link detection).
- **[later]** In-app or web authoring UI; contributor review workflow.

## 7. Platform & accounts

- **[v1]** Local-first: progress & notes stored on device, no login required.
- **[v2]** Optional account + cloud sync.
- **[later]** Educator features (classes, assignments, analytics), mobile, VR, API.
