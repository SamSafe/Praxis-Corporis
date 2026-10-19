# Content Pipeline

Status: two pinned HRA samples imported and technically inventoried; broader source
coverage and medical review remain open. The original planning-phase source shortlist
below remains the basis for supplemental audits.

Use [ASSET_AUDIT.md](ASSET_AUDIT.md) for the per-source, per-body, and primary-journey
evidence checklist. Preparing that checklist does not establish asset coverage.

## Candidate anatomy sources

| Source | Verified from source documentation | Still to inspect |
|---|---|---|
| BodyParts3D | Free adult male reference anatomy, downloadable geometry and anatomical grouping data. Current official archive lists CC BY 4.0. | Actual source version, structure coverage, surface/layer detail, interiors, geometry quality, and export preparation. |
| Human Reference Atlas (HRA) | Male/female 3D reference organs; source repository lists CC BY 4.0. | Both whole-body assemblies, missing regions, small structures, registration, and suitability for disassembly. |
| Z-Anatomy | Blender atlas derived partly from BodyParts3D; credits list multiple source licences. | Each contributing asset's rights, alterations, coverage, and quality. Do not assume a blanket licence clears every asset. |
| Visible Human Project | Public-domain male/female cryosection, CT, and MRI reference images. | Reconstruction/segmentation work; images are not ready-made selectable meshes. |

Sources inspected 2026-10-11:

- [BodyParts3D description](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html),
  [downloads](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html),
  [current archive licence](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html).
- [HRA publication](https://www.nature.com/articles/s41592-024-02563-5) and
  [source model library](https://github.com/hubmapconsortium/ccf-3d-reference-object-library).
- [Z-Anatomy model repository and credits](https://github.com/Z-Anatomy/Models-of-human-anatomy).
- [Visible Human Project](https://www.nlm.nih.gov/research/visible/visible_human.html).

BodyParts3D is a candidate starting collection for male anatomy. HRA is a candidate
for female and additional regional coverage. These are hypotheses about integration,
not evidence that the complete two-body requirement is already satisfied.
The subsequent [BodyParts3D technical audit](audit/BODYPARTS3D_FINDINGS.md) verifies
the official archive and a separate 203-mesh bone study. The current licence page
states CC BY 4.0 while original mesh comments retain legacy BY-SA 2.1 Japan text;
both records are preserved. This is a separate private study, not HRA registration
or an accepted complete female/male atlas.

Do not silently turn a male model into a female reference by changing the exterior
or attaching unrelated structures. Every reused or aligned region needs appropriate
spatial support and documented review.

## Commercial-compatible sourcing

Prefer public-domain/CC0 or CC BY content. CC BY-SA remains an option with its
attribution and adaptation obligations assessed. Exclude noncommercial assets from
the core collection unless separate permission is obtained.

CC BY and CC BY-SA allow commercial uses subject to their terms; CC BY-NC restricts
commercial uses. [CC BY](https://creativecommons.org/licenses/by/4.0/),
[CC BY-SA](https://creativecommons.org/licenses/by-sa/4.0/),
[CC BY-NC](https://creativecommons.org/licenses/by-nc/4.0/).

Record actual licences from the selected source/version. A derivative atlas may
carry obligations different from the newly licensed original dataset. Keeping
files separate does not by itself resolve licence obligations.

## Coverage inventory

For each body, region, and structure track:

- Source, geometry, selectable parts, baseline placement, and quality.
- Exterior/interior availability; cutaway/cross-section support.
- Composition and explanation coverage.
- Connections/pathways and their supporting evidence.
- Conditions, highlights, comparisons, and scenario choices.
- Technical validation, source checking, and medical review separately.
- Missing pieces, known simplifications, and the next enrichment task.

Prioritize the whole-body foundation and the heart-to-lungs journey. Do not declare
a region complete using only its exterior or mesh count.

## Geometry preparation after planning

1. Record source/version/licence and keep an unmodified source reference.
2. Inventory true meshes, concepts, groups, and markers.
3. Establish body, scale, units, coordinate axes, and anatomical landmarks.
4. Map anatomical IDs to source nodes without destructive identity assumptions.
5. Clean unsupported geometry and prepare consistent materials and detail levels.
6. Preserve selectable small structures and important internal surfaces.
7. Register supplemental assets against supported landmarks; record uncertainty.
8. Prepare labels, cutaways, separation presets, and pick geometry.
9. Validate technical integrity and check anatomy with appropriate review.
10. Package approved assets with versions, mappings, capability flags, and credits.

Blender is the proposed preparation tool. The planning phase did not download or
alter models. The subsequently authorised prototype uses pinned HRA GLBs and locally
compiled Godot scenes, as recorded in [the sample audit](audit/HRA_SAMPLE_FINDINGS.md).

## Medical explanations

Write original summaries grounded in authoritative, accessible references. Record
which source supports each substantive statement. Sources may include established
anatomy references, institutional educational material, and primary research.

Reading a copyrighted source does not grant rights to copy its text or media.
Reuse content only under applicable permission; separately cite facts used in
original explanations. Do not treat imported atlas descriptions as already reviewed.

Use the review stages in [DATA_MODEL.md](DATA_MODEL.md). Source checking is distinct
from qualified medical review, and neither is an automatic product of AI drafting.

## Conditions and authored scenarios

Start with linked explanations and reviewed structure/region highlights. Add
normal/condition comparisons only when suitable representations exist. Add damage
options only for prepared and reviewed choices.

A model swap, overlay, or parameter is an authored educational representation.
It does not become a physiological prediction because it is interactive.

Public medical content requires the review evidence specified in
[RELEASE_CRITERIA.md](RELEASE_CRITERIA.md). Review access is currently unresolved;
private drafts remain useful for development but cannot be silently promoted.

The [current private-candidate review packet](CONTENT_REVIEW_PACKET.md) supplies a
frozen copy of the authored study JSON, exact archive/source identities, an item
inventory and a results template. It prepares scoped human review; all current
source/expert review outcomes remain pending.

## Ongoing corrections

Track versions and changed claims. Invalidate affected reviews on substantive
changes. Keep a correction log, preserve saved-view recovery, and distribute content
updates independently from unnecessary UI changes where feasible.
