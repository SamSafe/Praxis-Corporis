# Accuracy pass, 2026-11-21

An assistant check of every study card, condition summary and route step against
the sources each one cites. **This is not a medical review.** It checks that each
statement says what its cited source says; it cannot establish that the source,
or the choice of what to include, is clinically right. Qualified human review is
still required ([review packet](../CONTENT_REVIEW_PACKET.md)).

## Method

1. Re-downloaded all 162 cited sources on 2026-11-21. Web pages were reduced to
   text; NCI dictionary entries were read through the NCI glossary API. Every page
   returned HTTP 200.
2. Split every card overview and function, condition summary and location, and
   route step into sentences (about 470).
3. Automatically flagged each sentence whose content words or numbers were not
   found in its own cited sources (92 flagged), and paired every unflagged
   sentence with its closest source sentence to catch changed meaning, such as a
   dropped "not", "only" or "most" (158 pairs with weak overlap).
4. Read every flagged sentence and every weak pair against the source text by
   hand.

## Corrections made

| Record | Problem | Now says (source) |
|---|---|---|
| Heart | "between the lungs" | "in the center of the chest, near the lungs", four chambers surrounded by muscle (NHLBI) |
| Bladder card; bladder infection | "hollow organ" | in the pelvic cavity, behind the pubic symphysis; a temporary storage reservoir for urine (SEER) |
| Uterus card; fibroids; uterine cancer; endometriosis | "in the pelvis" | a muscular organ in which a fetus develops; pear-sized before a first pregnancy (SEER) |
| Ovarian cancer | "each next to a Fallopian tube" | one on each side of the uterus, in the side walls of the pelvic cavity (SEER) |
| Prostate cancer | "surrounds the urethra at the neck of the bladder", uncited | surrounds the part of the urethra just below the bladder; new source: NCI dictionary, prostate |
| Trachea | "windpipe" and "carries air to and from the lungs", uncited | the airway from the larynx to the bronchi, also called the windpipe; new source: NCI dictionary, trachea |
| Pancreas | "closely associated with the small intestine" | a solid digestive organ whose juice reaches the small intestine through ducts (NIDDK) |
| Pancreatitis, diabetes, pancreatic cancer | "releases enzymes into the small intestine" not in cited pages | NIDDK digestive-system page added as a source |
| Pineal gland | "the hormone melatonin" | "produces melatonin" (NCI) |
| Aortic stenosis | "can obstruct forward blood flow" | the valve opening is too small or narrow; valve problems make the heart work harder (NHLBI) |
| Atrial fibrillation | "upper chambers" not in cited pages | NHLBI heart-anatomy page added as a source |
| Lungs | "paired organs connected to the airways" | the main respiratory organs, one on each side of the heart (NHLBI) |
| Left lung | "shares chest space with the heart" | two lobes; slightly smaller because the heart takes up space on the left (NHLBI) |
| ACL injury | "often caused by a sudden twist" | a hard hit to the side of the knee, over-extension, or stopping and changing direction quickly; often with MCL and meniscus tears (MedlinePlus) |
| Osteoporosis | "can affect any bone" | "fractures can occur in any bone" (MedlinePlus) |
| Sources | `nci-def-tendon` cited by nothing | removed |

Earlier on 2026-11-21, a rendered check also found that the male right knee card
listed the left MCL first; the male MCL mappings now list the right side first.

## Checked and kept

- Sentences describing the supplied models (for example "supplied here for the
  pubis, ilium and ischium") are statements about the geometry, not medical
  claims, and are kept.
- Faithful paraphrases, such as "upper right abdomen" for the right hypochondriac
  region, and "the left kidney is usually slightly higher" for "the right kidney
  is usually slightly lower", are kept.

## Limits

- **One source cannot be re-checked automatically.** `pulmonary-branches` (NCBI
  Bookshelf) now shows a CAPTCHA to automated downloads, and it was not bypassed.
  The only text citing it, the route step "Follow a pulmonary arterial branch
  toward either lung", is also supported by its other source (NHLBI blood flow).
- Word-overlap checks can miss a sentence that reuses a source's words with a
  different meaning. The manual reading covered every flagged sentence and every
  weak pairing, but not every sentence the checks found well matched.
- Sources can change after this date. The review packet freezes the text that
  ships in each build.
