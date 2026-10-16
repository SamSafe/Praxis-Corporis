# Draft learning content and valve-reference verification

Private runtime source `82120935bacc41a182a7d0b48c83bfceff4d6b8d`, following
feature checkpoint `ea0f47d`, checked on 2026-10-15.

## Review-stage correction

Earlier packages labelled assistant-cross-checked text `source_checked`, although
[the review model](../DATA_MODEL.md#review-evidence) requires a recorded human
check for that stage. That overstated the evidence. The old engineering reports
are annotated accordingly; their archived runtime identities and captures remain
unchanged.

All 15 cards, the circulation route and both condition records now use `draft`,
with human source review and expert review pending. Preliminary assistant checks
are recorded separately, including actor, date, scope and source references.
They are not reviewer evidence. The loader rejects unsupported review promotions.
The card/route text, source window, screenshot credits and package instructions
retain the distinction.

## Condition-reference studies

Two initial examples, aortic stenosis and mitral regurgitation, have short draft
summaries and explicit anatomical associations. The sources are
[NHLBI valve-disease types](https://www.nhlbi.nih.gov/health/heart-valve-diseases/types)
and [heart blood flow](https://www.nhlbi.nih.gov/health/heart/blood-flow).
No source media or substantial text passages are reused.

Reading/closing a card preserves exploration. **Inspect reference anatomy** reveals
the supplied valve and records the previous view. Return to context and Back recover
the appropriate body or earlier isolated context. Anatomy edits remain intact.
The text explicitly identifies reference geometry: no pathological mesh, narrowing,
leakage, leaflet motion or blood-flow simulation is supplied. Separate bone/spinal
studies have no inferred condition locations.

## Evidence

| Check | Retained result |
|---|---|
| Python | 47 checks pass, including draft-review invariants, real catalogue associations and conditional native requirements. [Log](draft-learning-python.log.txt). |
| Affected engine checks | 13 scripts pass: condition interactions, malformed content/review promotions, inspection/actions, view/note transfer, chest/route restoration, information windows, keyboard movement and export boundary. [Indexed logs/hashes](draft-learning-development-qa.json). |
| Exported offline content | Linux QA and Mac embedded content pass all seven references, including both valve inspections/returns. [Build log](draft-learning-build.log.txt), [build report](draft-learning-build-report.json). Mac content uses the development engine. |
| Actual Windows | The exact archive passes native AMD OpenGL workflows for all seven references, including both condition studies, inspection return, supported drafts, information windows and the existing workflows. [Native report](draft-learning-windows-qa.json), [raw log](draft-learning-windows-runtime.log.txt). |
| Rendered review | Both valve-study dialogs, the female compact route and Sources were inspected individually at 1100 × 720 with 130% text. Draft/human-review and reference-geometry limits are visible. All 94 capture identities are retained in the native report. [Selected-image hashes](draft-learning-selected-captures.json). |
| Archives | CRCs, executable architectures, committed source/notices and Mac content/seal checks pass. [Audit](draft-learning-artifact-audit.json). |

Screens: [female condition](../prototype/draft-learning-condition-female.png),
[male condition](../prototype/draft-learning-condition-male.png),
[route review status](../prototype/draft-learning-route-compact-female.png), and
[source provenance](../prototype/draft-learning-sources.png).

## Private artifacts

Under `dist/draft-study-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328107248 | `0772f5f5e9f782465abf46a33e52dbe7a6d2933988b651f970a57593d82be47f` |
| PraxisCorporis-macOS-universal-private.zip | 350553168 | `b142d20be49f3bc5f02472df9d7088e1b09c80fd999ccf1bae06c15751ada735` |

Anatomy-pack bytes/hash, source-reference identities and saved-view formats remain
unchanged. Human source review, qualified medical review, human usability/accessibility,
actual Mac execution and public distribution gates remain open. Engineering pass
results do not establish medical accuracy or a new sustained-performance result.
