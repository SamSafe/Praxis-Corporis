# Current private candidate: content-review packet

Prepared 2026-10-19. Review is pending. This packet identifies the current draft
material and supplies a [results template](reviews/C86CFBA_TEMPLATE.md) for a human
source checker or qualified medical reviewer. A completed review applies only to
its recorded items, reference mappings and exact versions. The broader release
scope in [SCOPE.md](SCOPE.md) still includes unresolved content and capabilities.

## Exact material

- Application source: `c86cfba1e544b20917b66c14ea405f0b74abfd47`.
- Private build ID: `f962ce195f324c89a400cf07d8767c9d`.
- Application version: `0.1.0`.
- Source-input fingerprint: `72347b3bb7ef35baf9eae06dd7cb5bb10f3fa8ca6e7064e63eb3353e10af4bb0`.
- Study-content revision: `chest-study-3-draft`.
- Frozen study JSON SHA-256: `ca76692360de3b1328e0bc049e6173fc7162e9bacbfa4e9d93c1607a2a1f6d8c`.

Use the [frozen study JSON](reviews/c86cfba-study-content.json) for the exact text,
linked anatomy, condition locations and route graph. It contains 15 cards, two
condition summaries and one 17-node route, all retaining draft/pending metadata.
The app displays that material with its supplied visuals; inspect both together.

| Artifact | SHA-256 |
| --- | --- |
| PraxisCorporis-Windows-x64-private.zip | `7518559369a6b55f20fbcf37363b47edb5013e666136b675469426e35b649ec4` |
| PraxisCorporis-macOS-universal-private.zip | `7d900e32b30ffd4a46639bfc6f5b082799260c3b3d0de4994dec3fea98f57bd4` |

The [build record](audit/build-identity-build-report.json) binds all 79 committed
inputs, including catalogues, source manifests, coordinate frames and coverage
notes. Sources and START_HERE identify the build. Use [native setup](NATIVE_BUILDS.md)
and the [backup procedure](PRIVATE_UPDATE_TRIAL.md) for an isolated private trial.

## Authored material

Each item needs its own source-check and expert-review outcome. Check the meaning
and sufficiency of the cited sources, every substantive statement, related-anatomy
links and the applicable visual/label mapping. Record corrections precisely.

| Type | Stable item ID | Source IDs in the frozen JSON |
| --- | --- | --- |
| Card | `anatomy.heart` | `heart-anatomy`, `heart-flow` |
| Card | `anatomy.heart.chambers` | `heart-anatomy` |
| Card | `anatomy.heart.septum` | `heart-anatomy` |
| Card | `anatomy.heart.atrium.right` | `heart-anatomy`, `heart-flow` |
| Card | `anatomy.heart.atrium.left` | `heart-anatomy`, `heart-flow` |
| Card | `anatomy.heart.ventricle.right` | `heart-anatomy`, `heart-flow` |
| Card | `anatomy.heart.ventricle.left` | `heart-anatomy`, `heart-flow` |
| Card | `anatomy.heart.valves` | `heart-flow` |
| Card | `anatomy.heart.valve.tricuspid` | `heart-flow` |
| Card | `anatomy.heart.valve.pulmonary` | `heart-flow` |
| Card | `anatomy.heart.valve.mitral` | `heart-flow` |
| Card | `anatomy.heart.valve.aortic` | `heart-flow` |
| Card | `anatomy.lungs` | `lungs`, `gas-exchange` |
| Card | `anatomy.lung.left` | `lungs`, `gas-exchange` |
| Card | `anatomy.lung.right` | `lungs`, `gas-exchange` |
| Condition | `condition.aortic-stenosis` | `valve-disease-types`, `heart-flow` |
| Condition | `condition.mitral-regurgitation` | `valve-disease-types`, `heart-flow` |
| Route | `heart-lung` | `heart-flow`, `gas-exchange`, `pulmonary-branches` |

For condition summaries, check the location/focus target and the distinction
between reference-valve inspection and absent disease geometry. For the route,
check all 17 nodes, transitions, both lung branches, stated gaps and the distinction
between conceptual connections and supplied geometry. Missing cutaways, disease
comparisons or injury scenarios require their own prepared content and review.

### Recorded source addresses

- `heart-anatomy`: [NHLBI: Heart anatomy](https://www.nhlbi.nih.gov/health/heart/anatomy).
- `heart-flow`: [NHLBI: Blood flow through the heart](https://www.nhlbi.nih.gov/health/heart/blood-flow).
- `lungs`: [NHLBI: The respiratory system](https://www.nhlbi.nih.gov/health/lungs/respiratory-system).
- `gas-exchange`: [NHLBI: Breathing and gas exchange](https://www.nhlbi.nih.gov/health/lungs/breathing-benefits).
- `pulmonary-branches`: [NCBI Bookshelf: Pulmonary arteries](https://www.ncbi.nlm.nih.gov/books/NBK534812/).
- `valve-disease-types`: [NHLBI: Types of heart valve disease](https://www.nhlbi.nih.gov/health/heart-valve-diseases/types).

## Reference, label and mapping review

Authored-text approval does not establish anatomical correctness of imported
labels, grouping, geometry or placement. Record the exact reference and catalogue
IDs inspected, any omitted regions, and unresolved source metadata. Counts below
include grouping records and do not establish anatomical completeness.

| Reference ID | Catalogue records | Geometry source SHA-256 |
| --- | ---: | --- |
| `female` | 970 | `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5` |
| `male` | 961 | `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863` |
| `bodyparts-male-bones-study` | 205 | `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27` |
| `hra-v1-2-female-cord-study` | 30 | `d9bfc840783a415068e34b8a1a9343fff40ad03d0025fafabf74f9d8664887f8` |
| `hra-v1-2-female-vertebrae-study` | 26 | `bdbea49a40e9e64cac1c8f0d67b6483686a3cc9617f7cae645e58159e4b02984` |
| `hra-v1-2-male-cord-study` | 31 | `a7858d88c2237aa7d559c4c1d638923d213d2a9f46c575dea03d6ba67a9975c0` |
| `hra-v1-2-male-vertebrae-study` | 25 | `981041904438bd74c14d671af8f87b3f407b675294bbf297af673c8df7144451` |

Review the HRA bodies separately. The bone and spinal studies retain separate
coordinates and pending body-registration/metadata questions. Check
[coverage](../content/coverage_notes.json), [reference frames](../content/reference_frames.json)
and the source manifests against the recorded commit. Catalogue paths are
`content/sample_pack.json`, `content/bodyparts3d_bone_study.json` and
`content/spinal_studies.json`. Obtain a historical file with, for example:

```sh
git show c86cfba1e544b20917b66c14ea405f0b74abfd47:content/sample_pack.json
```

## Record findings and review boundaries

Copy the results template to a dated local review record. Enter the reviewer's
identity, relevant qualifications/role, date, actual artifact, reviewed IDs and
supporting evidence. A user usability trial and an assistant cross-check remain
separate from human source checking and qualified medical review, as specified in
[the data model](DATA_MODEL.md#review-evidence).

List unreviewed material explicitly. Attach findings with exact wording or catalogue
IDs, reproduction steps, source addresses and required corrections. Any later
material claim, mapping or geometry change invalidates the affected approval and
needs another version-specific review. Repository content stays draft until
applicable human evidence is recorded and the change is reviewed.

Asset/application rights, device usability, accessibility and release distribution
have separate gates in [the production checkpoint](PRODUCTION_READINESS.md).
