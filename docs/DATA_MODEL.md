# Data Model — Proposed

Content is versioned data, separate from rendering and UI code. Stable anatomical
identity must survive changes in source assets, body reference, level of detail,
engine scene nodes, and disease representation.

## Core records

| Record | Main fields |
|---|---|
| Anatomical structure | Stable ID; names/synonyms; optional Latin name and ontology mappings; type; multiple systems/regions; parent/part relationships; composition; explanation; references; review evidence. |
| Reference body | ID/version; adult reference designation; provenance; available anatomy; coordinate frame; registration evidence; coverage inventory. |
| Representation | Structure/body/scenario IDs; asset/version; node mappings; geometry kind; bounds/label anchors; capability flags; levels of detail; anatomical review. |
| Connection | Source/target structures; typed and possibly directed relationship; body applicability; references; review evidence. |
| Pathway | Ordered/branching connection graph; supported structures; waypoints; source evidence; explicit gaps. |
| Condition | ID; names; original sourced explanation; links to affected structures; optional visuals/scenarios; review evidence. |
| Scenario | Condition/injury ID; supported parameter choices; affected representations; authored changes; causes/effects explanations; reset baseline; review evidence. |
| Asset | Source/author/version; file hash; licence; attribution; modifications; source coordinates; transformations; technical validation. |
| Reference | Author/title; URL or identifier; edition/date; access date; supported claims; reuse terms if media/text is incorporated. |
| Saved view | Schema/content versions; reference body; camera; selection; visibility; labels; inspection displacements; scenario; notes. |

## Identity and geometry mappings

Propose lowercase namespaced IDs that are never reassigned. Vendor IDs and ontology
terms are mappings, not the sole application identity. Deprecation/alias records
handle corrected names without breaking saved views.

One concept can map to multiple meshes; a group can select descendant structures;
the same concept can have different representations for male/female anatomy,
detail levels, and normal/condition state. Anatomy with no geometry can still
exist as a sourced concept, provided the interface identifies the coverage gap.

Multiple systems can reference the same structure without duplicating geometry or
creating contradictory visibility state.

Illustrative mapping, not an actual source asset or medical content record:

    structureId: anatomy.example-structure
    bodyId: reference.example-adult
    representationId: representation.example-normal
    geometryNodes:
      - vendor-node-001
      - vendor-node-002
    capabilities:
      selectable: true
      movable: true
      interiorAvailable: false
      cutawayAvailable: false
    sourceAssetId: asset.example-source
    anatomicalReviewStatus: draft

Do not infer capabilities from filenames or assume all model names are anatomical
structures. Source atlases can contain grouping nodes and nongeometric label markers.

## Relationships

Use explicit types: part-of, adjacent-to, connects-to, supplies, drains-to, innervates,
and affected-by, with meaning, direction, and evidence defined for each.

Containment lists and proximity do not establish flow or anatomical continuity.
Do not automatically predict effects by traversing arbitrary graph edges.
Scenario explanations are authored and reviewed for the supported parameter choices.

## Review evidence

Proposed stages:

- **draft:** authoring or import has not completed source checking.
- **source_checked:** a human has checked the stated claims/mapping against identified
  sources and recorded that evidence.
- **expert_reviewed:** a suitably qualified reviewer has checked the specific content
  version and its applicable visuals.

Record reviewer identity/role, date, scope, referenced versions, and unresolved issues.
AI output is not reviewer evidence. Usability testing is not expert review.
A change to a material claim or geometry invalidates affected review approval.

Geometry validation, licence clearance, factual checking, and expert review are
independent dimensions. Never promote all of them because one check passed.

## Validation rules

- Unique stable IDs; resolvable aliases, references, and relationship endpoints.
- Valid mappings for all declared selectable representations.
- Explicit grouping-only and unmodelled concepts.
- Body identity, coordinate units, and reviewed transforms recorded.
- Supported node/asset references exist for each published capability.
- No selectable missing scenario parameters or pretend comparisons.
- Review evidence applies to the exact published content version.
- Licences, attribution, and modification records exist per imported asset.
- Saved states recover when content is missing, removed, or upgraded.

Target source layout: content/catalogue, content/bodies, content/representations,
content/connections, content/conditions, content/scenarios, content/references, and
content/assets. The initial prototype uses a compact generated sample_pack.json and
source_manifest.json. Most imported source IDs are deliberately body-specific;
explicit shared mappings cover selected systems, skin, heart components and lungs.
This draft catalogue does not replace the full clinical content schema above.
