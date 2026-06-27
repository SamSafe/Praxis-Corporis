# Competitive Landscape

## Short answer: yes, this exists — but no single tool does *all* of it well, and none are free + open.

Your full vision (navigate + label + test + pathology overlays + systemic disease
impact) is essentially the union of several existing products. Each does a slice. The
opportunity is **integration, openness, and a study/testing-first design** — not
inventing a brand-new capability.

## The major players (as of 2025–2026)

| Product | Strength | Pathology / disease | Built-in testing | Notes |
|---|---|---|---|---|
| **Complete Anatomy** (Elsevier / 3D4Medical) | Best-in-class consumer 3D anatomy, gorgeous models, can animate pain points & simulate some injuries/pathologies, 1,500+ videos | Partial — injuries, some conditions | Yes (quizzes) | The gold standard for individual students. Subscription. |
| **BioDigital Human** | 1,000+ interactive models, organized by system/specialty; strong **disease & condition library** (heart disease, cancer, diabetes), browser-based, freemium | Strong — large pathology/treatment library | Some | Closest to your "anatomy + disease in one place" idea. API exists. |
| **Visible Body** | High-detail, realistic models, deep structure info (innervation, blood supply, actions), courseware | Some | Yes (courseware) | Common via university subscriptions. |
| **VOKA 3D Anatomy & Pathology** | Explicitly pairs **normal anatomy + microanatomy + gross pathology**; 19 clinical categories; expert-written articles | Strong — its whole selling point | Yes (quizzes) | The single closest match to "see normal vs diseased." |
| **Anatomage Table** | Photorealistic prosected cadaver scans, normal + pathological tissue; instructor quizzes | Yes | Yes | Hardware (a literal table) + software; institutional. |
| **Virtual Medicine** | VR; converts CT/MRI (DICOM) to 3D; VR test manager | Via real imaging | Yes (VR tests) | VR-first, education + pre-op planning. |
| **Anki + anatomy decks** (e.g. AnKing) | Free, spaced repetition, enormous community | Text/image only | Yes (SRS) | Not 3D, but it's what students *actually* use to get tested. |

Newer entrants are adding **AI-generated 3D anatomy** (e.g. Fundamental XR, 2025),
which lowers the asset-creation cost that historically protected incumbents.

## Where the genuine gaps are (your opening)

1. **No great free + open option.** Everything good is a paid subscription or
   institutional license. An open, student-built tool has a real audience.
2. **Testing is usually bolted on, not central.** Students live in Anki for a reason.
   A 3D tool whose *core loop is spaced-repetition testing* (not just a quiz tab) is
   differentiated.
3. **Systemic disease tracing is rare.** "Pick diabetes, watch it damage the retina,
   kidney, nerves, and vessels across the body" — most tools show one organ at a time.
4. **Integration / connectedness.** Linking structure ↔ function ↔ pathology ↔
   question as one graph you can traverse is underserved.
5. **Openness/extensibility.** None are a platform you can script, self-host, or extend.

## What this means for strategy

- Do **not** try to out-render Complete Anatomy or out-content BioDigital. You will
  lose — they have teams, money, and licensed asset libraries.
- **Win on a wedge + a wedge of differentiation**: pick one region, make the
  *test-driven learning loop* and the *normal↔disease toggle* genuinely better than the
  incumbents for that region, and be free/open.
- Consider building **on top of** an existing engine/library rather than from scratch
  (e.g. BioDigital's API, or open anatomical model sets) to skip the asset problem —
  see [CONTENT_PIPELINE.md](CONTENT_PIPELINE.md).

## Sources

- [Complete Anatomy (3D4Medical / Elsevier)](https://3d4medical.com/student)
- [BioDigital Human](https://www.biodigital.com/) · [Human library](https://human.biodigital.com/)
- [Visible Body](https://www.visiblebody.com/blog/how-does-visible-body-courseware-compare-with-the-biodigital-human)
- [VOKA 3D Anatomy & Pathology](https://voka.io/product/) · [vs BioDigital](https://voka.io/voka-3d-anatomy-and-pathology-vs-biodigital/)
- [Anatomage Table](https://anatomage.com/table/)
- [Virtual Medicine](https://www.medicinevirtual.com/)
- [Fundamental XR AI 3D anatomy (2025)](https://med-techinsights.com/2025/10/22/fundamental-xr-launches-ai-powered-3d-anatomy-generation/)
- [Faculty/student evaluation of 3D anatomy tools (NIH PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11102696/)
