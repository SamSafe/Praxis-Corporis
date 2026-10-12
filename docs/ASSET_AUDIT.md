# Anatomy Asset Audit Plan

Status: audit method prepared; two pinned HRA v1.1 United GLB samples downloaded
and inventoried. See [sample findings](audit/HRA_SAMPLE_FINDINGS.md) for measured
source counts and gaps. Engine trials are in progress; the complete inventory remains open.

## Purpose

Establish whether free, commercially compatible sources can support the required
male and female whole-body experience. Identify missing detail before making
implementation or completeness promises.

Candidate sources and inspected primary references are in
[CONTENT_PIPELINE.md](CONTENT_PIPELINE.md). No single candidate is currently accepted
as a complete two-body solution.

## Initial system inventory

This table remains the comprehensive-release audit checklist. The narrower sample
findings identify supplied geometry, but do not establish sufficient system coverage.
A source's existence does not mean a system is sufficiently represented.

| System / region | Male geometry | Female geometry | Internal detail | Connections | Planned priority |
|---|---|---|---|---|---|
| Exterior / skin | Pending | Pending | Pending | Pending | Reveal controls and body overview. |
| Skeleton | Pending | Pending | Pending | Pending | Overview, selection, manual separation. |
| Muscles / surrounding soft tissue | Pending | Pending | Pending | Pending | Reveal and spatial context. |
| Heart / chest | Pending | Pending | Pending | Pending | First detailed journey. |
| Lung / respiratory anatomy | Pending | Pending | Pending | Pending | First detailed journey and routes. |
| Circulation | Pending | Pending | Pending | Pending | Supported pathway following. |
| Nervous anatomy | Pending | Pending | Pending | Pending | Progressive detail and routes. |
| Digestive anatomy | Pending | Pending | Pending | Pending | Progressive regional expansion. |
| Urinary anatomy | Pending | Pending | Pending | Pending | Progressive regional expansion. |
| Reproductive / pelvic anatomy | Pending | Pending | Pending | Pending | Appropriate body-specific coverage. |
| Endocrine anatomy | Pending | Pending | Pending | Pending | Progressive expansion. |
| Lymphatic / immune anatomy | Pending | Pending | Pending | Pending | Progressive expansion. |

The first public catalogue is determined from evidence, while the user requirement
for both reference bodies remains in force.

## Audit record per source/version

Record source URL, author, version/release date, access date, selected files, hashes,
actual licence evidence, notices, included contributions, changes, and intended use.

Distinguish original datasets from derivative atlases. Confirm the terms for the
specific files used, rather than reusing an old licence claim from a third-party tool.
Keep any rights questions unresolved until the selected material is cleared.

## Audit record per body/region

| Field | Evidence to capture |
|---|---|
| Reference identity | Body provenance, designation, version, and intended anatomical reference. |
| Geometry | Real mesh count, meaningful anatomical structures, groups, and label-only markers. |
| Selection | Individual selectable components, nested groups, small-structure visibility. |
| Layer reveal | Available exterior/deeper parts and whether the journey can reach the heart. |
| Interiors | Actual supplied components/surfaces; distinguish exterior-only representations. |
| Cutaways | Suitable prepared interior surfaces and caps; supported planes/presets. |
| Materials | Tissue appearance, useful detail, and consistency with neighbouring sources. |
| Placement | Units, axis conventions, scale, landmarks, and documented registrations. |
| Connections | Explicit sourced connectivity, continuity, direction, branch coverage, gaps. |
| Disassembly | Which structures can move independently or as a meaningful group. |
| Detail levels | Geometry cost, preserved small structures, consistent mappings. |
| Medical evidence | Source checking, anatomical review, reviewer scope/version, unresolved issues. |
| Conditions | Linked content and actual available highlight/comparison/scenario assets. |
| Operational cost | Preparation tasks, specialist work, review work, download/package size. |

The geometry inventory and clinical content inventory are related but independent.
Do not infer pathways from overlaps or infer disease capability from normal geometry.

## First detailed journey audit

For both bodies, establish:

1. A useful full-body reference with surrounding chest context.
2. Reversible reveal through actual obstructing anatomy.
3. A separately selectable heart and supported components.
4. Label anchors that name the correct visible structures.
5. Internal geometry or validated cutaways for declared interior inspection.
6. Nearby respiratory anatomy in supported placement.
7. A sourced and reviewed route between the selected structures, with explicit gaps.
8. Supported manual movement and guided separation with exact restoration.
9. A known set of condition highlights, optional comparisons, and authored changes.
10. Remaining work needed before claiming the journey is complete.

This list defines evidence to obtain, not a claim that current sources supply it.

## Candidate decision record

For each candidate or proposed combination, record:

- What can be used as supplied.
- What needs cleanup, relabelling, registration, or supplemental geometry.
- What needs qualified anatomical/medical review.
- What is absent, ambiguous, noncommercial-only, or incompatible.
- Whether the work is realistic for the user/assistant team.
- Whether both bodies can satisfy the release task set.
- Why the candidate is accepted, rejected, or retained provisionally.

Avoid introducing reconstructed imaging as an effortless replacement for missing
models; segmentation and anatomical validation are separate work.

## Authorised feasibility trial

The user authorised the first feasibility prototype on 2026-10-11. The selected
samples contain partial whole-body context and separately grouped organs. Test
actual structure picking, hidden/faded geometry, nested parts, label
anchors, local separation, clipping, restoration, content mapping, and platform exports.

Use models from both bodies and a shared task. Record engine/content versions and
hardware. Report measured performance and failures; never promote a mock-up or
source description into benchmark evidence.

## Audit exit conditions

A documented source path exists for both reference bodies; licences are compatible;
the first journey's required geometry and connection evidence are identified;
known gaps have concrete preparation/enrichment tasks; and remaining specialist
review needs are recorded.

If there is no feasible two-body path, retain the requirement and revise sourcing
or public scope with the user. Do not silently substitute a male-only first release.
