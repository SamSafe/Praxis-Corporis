# Separate HRA spinal source candidates

Technical inspection: 2026-10-12. These files are candidates, outside the runtime and
private packages. This record does not establish medical review, a complete skeleton,
or registration to the bundled v1.1 bodies.

## Source identity

The official repository's main branch still resolved to the same commit as the bundled
samples: `f1a3a63f110e27ff0736047d52d04dba5d3087f9`. The complete Git tree contains separate
female/male v1.2 vertebra and spinal-cord GLBs. The United files remain v1.0/v1.1;
the separate v1.2 files are absent from the current United anatomy inventory.

Primary source folders:
[female v1.2](https://github.com/hubmapconsortium/ccf-3d-reference-object-library/tree/f1a3a63f110e27ff0736047d52d04dba5d3087f9/VH_Female/v1.2),
[male v1.2](https://github.com/hubmapconsortium/ccf-3d-reference-object-library/tree/f1a3a63f110e27ff0736047d52d04dba5d3087f9/VH_Male/v1.2).
The retained [HRA licence](../../third_party/HRA-LICENSE.txt) and
[README](../../third_party/HRA-README.md) correspond to that same commit. The current
prototype attribution/modification rules remain applicable to any eventual derived
use; source admission and qualified review are still required.

Downloads were checked against the official tree's byte counts and Git blob SHA-1,
then pinned with SHA-256 in [the download record](hra-spinal-candidate-downloads.json).
[The generated inventory](hra-spinal-candidates.json) retains every source node name,
label, ontology identifier, spatial-entity tag, declared bounds and metadata gap.
No candidate bytes were committed or added to the app's source manifest.

## Observed inventory

| Candidate | Source meshes | Triangles | Label/ontology gaps |
|---|---:|---:|---:|
| Female spinal cord | 29 | 288,912 | 0 |
| Female vertebrae | 25 | 426,468 | 1 |
| Male spinal cord | 30 | 16,358 | 0 |
| Male vertebrae | 24 | 320,442 | 0 |

Counts describe source meshes, not reviewed anatomical structure counts or completeness.
All four have a single root and no authored node transforms. Their accessor-declared
bounds fit inside the corresponding v1.1 skin's declared axis-aligned bounds. Their
metadata associates them with `#VHFemaleOrgans` or `#VHMaleOrgans`. These observations
support further source-frame inspection; containing boxes/tags cannot establish
correct registration, tissue relationships or medical accuracy.

The female vertebra source has a node named `VH_F_lumbar_vertebra_6`. Its supplied
label, ontology ID and representation URL are `-`. The source geometry/name must be
kept intact. This audit does not infer whether the record represents an anatomical
variant or an authoring/label error, and does not supply a replacement ontology ID.
Qualified review/source clarification is needed before generic teaching claims.
Several male labels use “vertebral bone”/“mammalian cervical vertebra” while node
names identify the numbered cervical parts; retain both forms and their provenance.

## Admission work

1. Render the untouched candidates against their own source coordinates, then inspect
   the corresponding v1.1 context without fitting, warping or relabelling geometry.
2. Verify actual vertex data, transforms, boundaries and picking; check overlap and
   duplicate structures before composing a derived reference.
3. Preserve the missing female label/ontology as an explicit source gap; require review
   for its interpretation. Keep draft imports distinct from normal-anatomy claims.
4. If admitted privately, use a versioned derived/source-study identity, pinned component
   hashes, retained notices and explicit registration/review status. Existing saved
   v1.1 references must remain valid; no silent replacement is planned.
5. Validate labels, isolation/return, restore, saving, source credits and actual device
   behaviour. Keep skull/rib/upper-limb and comprehensive female coverage open.

The candidate audit is reproducible after obtaining the four pinned files under a local
folder named by their original basenames:

```sh
python3 tools/audit_spinal_candidates.py /path/to/candidates \
  --downloads docs/audit/hra-spinal-candidate-downloads.json \
  --output docs/audit/hra-spinal-candidates.json
```

The audit deliberately refuses transformed nodes so source-world bounds cannot be
silently calculated in the wrong coordinate frame. Geometry registration and clinical
interpretation are separate follow-up checks.
