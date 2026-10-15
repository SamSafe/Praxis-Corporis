# Circulation route and keyboard inspection verification

This is the `03cf80c` checkpoint. Subsequent [information-window improvements and
refreshed packages](INFORMATION_DIALOG_VERIFICATION.md) retain separate identities.

Private changes on 2026-10-15. Runtime source:
`03cf80c581f018095e78f5eaa4ea9a2ba7bc5e3d`; feature checkpoint: `adab8f5`.
This extends the earlier study workspace while preserving source-reference and
saved-view identities. [Controls and content limits](../STUDY_WORKSPACE.md).

## Implemented behavior

- An authored heart/lung circulation graph with both lung branches, previous/return
  navigation, explicit gas-exchange/systemic gaps and exact workspace restoration.
- Separate female/male mappings checked against source names and ontology IDs.
  Relationships remain source-checked drafts, with qualified medical review pending.
- Camera-relative keyboard movement at 5 mm or 1 mm per press, with undo/redo,
  focus guards and ignored held-key repeat, across all seven references.
- Content validation rejects malformed records, dangling citations, invalid URLs,
  unreachable route nodes and missing return paths before displaying learning claims.
- Related/route controls can replace themselves safely during selection signals.
  Reference names are left-aligned, with complete labels in tooltips.

The route summarizes [NHLBI blood flow](https://www.nhlbi.nih.gov/health/heart/blood-flow),
[NHLBI gas exchange](https://www.nhlbi.nih.gov/health/lungs/breathing-benefits), and
[Tucker, Weber and Burns on pulmonary arteries](https://www.ncbi.nlm.nih.gov/books/NBK534812/).
Source checking is separate from anatomical mesh completeness and qualified review.
No source media or substantial text passages are reused.

## Retained checks

| Check | Evidence |
|---|---|
| Python tools/content | 43 checks pass. [Log](circulation-python.log.txt). Native verification requires the new runtime markers when the committed source includes the route; historical packages retain their own requirements. |
| Engine source | 21 smoke scripts pass, including actual root keyboard input, all seven references, guide/route switching and exact state/history restoration. [Indexed logs and hashes](circulation-development-qa.json). |
| Content failure handling | Rejected shapes, review stages, source URLs, dangling citations, broken/one-way routes and missing mappings expose no partial cards. A changed source identity disables the route. [Log](circulation-study_content_smoke.log.txt). |
| Exported offline resources | Linux QA and Mac embedded content pass all seven references, including route and movement checks. [Build log](circulation-build.log.txt), [build report](circulation-build-report.json). Mac content is checked using the development engine. |
| Actual Windows | The exact archive passes native AMD OpenGL workflows across all seven references. Both lung branches and route return pass; keyboard movement/undo pass in every reference. [Report](circulation-windows-qa.json), [raw runtime log](circulation-windows-runtime.log.txt). |
| Rendered review | All 90 capture identities are retained. Seven contact sheets were inspected; the compact female route was also inspected individually. The compact route retains usable anatomy space at 1100 × 720 with 130% text. [Selected-image hashes](circulation-selected-captures.json). Closely spaced source links were identified for a subsequent polish pass. |
| Archive identity | ZIP CRCs, executable architectures, committed notices/source hashes and Mac content/seal checks pass. [Audit](circulation-artifact-audit.json). |

Contact sheets: [female](../prototype/circulation-contact-female.png),
[male](../prototype/circulation-contact-male.png),
[bone study](../prototype/circulation-contact-bodyparts-male-bones-study.png),
[female cord](../prototype/circulation-contact-hra-v1-2-female-cord-study.png),
[female vertebrae](../prototype/circulation-contact-hra-v1-2-female-vertebrae-study.png),
[male cord](../prototype/circulation-contact-hra-v1-2-male-cord-study.png), and
[male vertebrae](../prototype/circulation-contact-hra-v1-2-male-vertebrae-study.png).

Full route screens: [female compact](../prototype/circulation-route-compact-female.png),
[male compact](../prototype/circulation-route-compact-male.png),
[female gap](../prototype/circulation-route-female.png), and
[male gap](../prototype/circulation-route-male.png).

## Private artifacts

Generated under `dist/circulation-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328087091 | `2dc9b597e421ea6ec3ce5efa8336aa4ce5306d44ac5ad430c0600a6728da6144` |
| PraxisCorporis-macOS-universal-private.zip | 350533029 | `d6dff83982c1070d1fd27c8941b11817404205bd4e3b97f2d9b5b0754ac6ea07` |

Earlier archives and reports retain their original source identities. Medical review,
human input/comprehension/accessibility, actual Mac execution, public signing and
representative-hardware acceptance remain open. No new sustained-performance claim
is made by this batch.
