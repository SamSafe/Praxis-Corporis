# Current private candidate: content-review packet

Prepared 2026-11-27. Review is pending. This packet identifies the exact draft
study material in one private build and supplies a
[results template](reviews/09970EE_TEMPLATE.md) for a human source checker or
qualified medical reviewer. A completed review applies only to its recorded items,
reference mappings and exact versions. The broader release scope in
[SCOPE.md](SCOPE.md) still includes unresolved content and capabilities.

The previous packet, for build `c86cfba` and its 15 chest cards, is kept at
[reviews/C86CFBA_PACKET.md](reviews/C86CFBA_PACKET.md).

## Exact material

- Application source: `09970ee9f85d7f24dd72acf4828cad9a1d55c8ae`.
- Private build ID: `eadd09d8c1e540209bff322b15b8560b`.
- Application version: `0.1.0`.
- Source snapshot SHA-256: `07c1d14ede6ce7ef70c2b74cf0f099f97c73bcad4578371b606553350f577de1`.
- Engine: `4.7.2.stable.official.ed1daf0bf`.
- Study-content revision: `body-study-17-draft`.
- Frozen study JSON SHA-256: `52142c9242d7fac33ec63057deb2649686432bfe1c88ffaa6f30d93f9a715bb3`.

| Artifact | SHA-256 |
| --- | --- |
| PraxisCorporis-Windows-x64-private.zip | `83ceabdfc25cb13fe90125b2a286cbab18a1fad516be4c21e1263e88df4ad807` |

The app's Sources dialog and START_HERE file show the build ID; check that it
matches before reviewing. Use [native setup](NATIVE_BUILDS.md) and the
[backup procedure](PRIVATE_UPDATE_TRIAL.md) for an isolated private trial.

## What to review

- **[Reviewer text](reviews/09970ee-reviewer-text.md):** every item in readable
  form, grouped by body system, with the 3D part names shown in each body and
  every source link. Start here.
- **[Frozen JSON](reviews/09970ee-study-content.json):** the authoritative copy of
  the same material.
- **[Results template](reviews/09970EE_TEMPLATE.md):** one row per item.

The build contains **247 cards, 173 condition summaries and
1 route**, all marked draft with human source review
and expert review pending. The female body offers 156 conditions
and the male body 147; the rest need anatomy only one body has.

For each card, check every statement against its cited source, the related-anatomy
links, and that the named 3D parts are the structures the card describes. For each
condition, check the summary, the reference-location text, the focus part, the
parts it is listed on, and that the "not depicted" statement is accurate: the app
locates healthy reference anatomy only and shows no disease geometry. For the
route, check every node, transition, branch and stated gap.

Paired or split parts (both eyes, both knees, separate atlas pieces of one brain
region) share one card; any listed part shows it. Some source parts had no name
in the model files, and the app derives one from the source node name (for
example "Thalamus, left"); those names are part of the label review below.

## Reference, label and mapping review

Approving authored text does not establish that imported labels, grouping,
geometry or placement are anatomically correct. Record the exact reference and
catalogue IDs inspected, any omitted regions and unresolved source metadata.
Counts include grouping records and do not establish completeness.

| Reference ID | Catalogue records | Geometry source SHA-256 |
| --- | ---: | --- |
| `female` | 1197 | `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5` |
| `male` | 1158 | `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863` |
| `bodyparts-male-bones-study` | 205 | `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27` |
| `bodyparts-male-complete` | 3476 | `9e3b751a4f34cc018cc01c127a7e6187d29bf29c5b9ef9b222eb22353c6eac9c` |
| `hra-v1-2-female-cord-study` | 30 | `d9bfc840783a415068e34b8a1a9343fff40ad03d0025fafabf74f9d8664887f8` |
| `hra-v1-2-female-vertebrae-study` | 26 | `bdbea49a40e9e64cac1c8f0d67b6483686a3cc9617f7cae645e58159e4b02984` |
| `hra-v1-2-male-cord-study` | 31 | `a7858d88c2237aa7d559c4c1d638923d213d2a9f46c575dea03d6ba67a9975c0` |
| `hra-v1-2-male-vertebrae-study` | 25 | `981041904438bd74c14d671af8f87b3f407b675294bbf297af673c8df7144451` |

Review the HRA bodies separately. The bone and spinal studies keep separate
coordinates and pending registration/metadata questions. Catalogue paths are
`content/sample_pack.json`, `content/bodyparts3d_bone_study.json` and
`content/spinal_studies.json`. Obtain the exact file with, for example:

```sh
git show 09970ee9f85d7f24dd72acf4828cad9a1d55c8ae:content/sample_pack.json
```

## Record findings and review boundaries

Copy the results template to a dated review record. Enter the reviewer's identity,
relevant qualifications or role, date, the actual archive inspected, reviewed IDs
and supporting evidence. A user usability trial and an assistant cross-check are
separate from human source checking and qualified medical review, as specified in
[the data model](DATA_MODEL.md#review-evidence).

List unreviewed material explicitly. Give findings with exact wording or catalogue
IDs, reproduction steps, source addresses and the required correction. Any later
change to a claim, mapping or geometry invalidates the affected approval and needs
another version-specific review. Repository content stays draft until applicable
human evidence is recorded and the change is reviewed.

Asset/application rights, device usability, accessibility and release distribution
have separate gates in [the production checkpoint](PRODUCTION_READINESS.md).
