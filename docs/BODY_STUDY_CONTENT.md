# Body study content (draft)

Added 2026-11-20 as study-content revision `body-study-1-draft`. It extends the
chest material (15 cards, two valve conditions, the heart ↔ lungs route) with
**26 organ cards and 12 conditions** across the circulatory, respiratory,
digestive, lymphatic, urinary and reproductive systems. That makes 41 cards and
14 conditions in total.

**Everything here is a private draft.** Every record keeps `review_status: draft`
with human source review and expert review pending, and the app labels it that
way. An assistant compared each statement with its cited page on 2026-11-20 and
kept only claims the page supports. That is a preliminary check, not reviewer
evidence.

## How the cards reach the geometry

The chest cards use shared IDs (for example `anatomy.heart`) that both bodies'
catalogues define. The new organs have no shared IDs: each body names its own
source node. Rather than rename those nodes, which would break saved views, each
new card carries an explicit `geometry` mapping per body, giving the source
structure ID, source name and ontology. The mapping is the same pattern the
heart ↔ lungs route already uses. The app uses a mapping only while the loaded
structure still has that source name and ontology. If the catalogue changes, the
card disappears rather than attaching to the wrong mesh.

A card with a mapping for one body only stays in that body. Two such cases exist
beyond the sex-specific organs: the female catalogue has no ureter mesh, so the
ureter card is male only, and the bone study has no organ meshes at all.

## Cards

### Heart and great vessels

| Card | Bodies | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.aorta` | female and male | The main artery of the body, leaving the left ventricle through the aortic valve. | Carries oxygen-rich blood from the heart to the rest of the body. | heart-flow, nhlbi-aortic-aneurysm |
| `anatomy.coronary.left` | female and male | One of the two coronary arteries that branch from the aorta and run over the surface of the heart. | Supplies oxygen-rich blood to the heart muscle. | seer-heart, heart-flow, nhlbi-chd |
| `anatomy.coronary.right` | female and male | One of the two coronary arteries that branch from the aorta and run over the surface of the heart. | Supplies oxygen-rich blood to the heart muscle. | seer-heart, heart-flow, nhlbi-chd |
| `anatomy.vena-cava.superior` | female and male | One of the two venae cavae, the large veins through which blood returns to the heart. | Returns oxygen-poor blood from the body to the right atrium. | heart-flow |
| `anatomy.vena-cava.inferior` | female and male | One of the two venae cavae, the large veins through which blood returns to the heart. | Returns oxygen-poor blood from the body to the right atrium. | heart-flow |
| `anatomy.pulmonary-veins` | female and male | Veins running from the lungs back to the heart. | Return oxygen-rich blood from the lungs to the left atrium. | heart-flow |

### Airways

| Card | Bodies | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.trachea` | female and male | The windpipe. In the chest it divides into the right and left primary bronchi. | An airway that carries air to and from the lungs. | seer-bronchi, nhlbi-asthma |
| `anatomy.bronchi` | female and male | The right and left primary bronchi branch from the trachea into smaller and smaller airways inside the lungs. | Conduct air between the trachea and the tiny air sacs of the lungs. | seer-bronchi, nhlbi-asthma |

### Digestive

| Card | Bodies | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.liver` | female and male | The largest gland in the body, lying mainly in the upper right abdomen just beneath the diaphragm. | Makes bile and processes the nutrient-rich blood that arrives from the digestive tract through the hepatic portal vein. | seer-accessory, niddk-digestive |
| `anatomy.gallbladder` | female and male | A pear-shaped sac attached to the underside of the liver. | Stores bile between meals and squeezes it through the bile ducts into the small intestine when you eat. | seer-accessory, niddk-digestive |
| `anatomy.bile-duct.common` | female and male | Part of the duct system that carries bile toward the small intestine. | Delivers bile, which helps digest fats. | niddk-digestive |
| `anatomy.pancreas` | female and male | A gland of the digestive system closely associated with the small intestine. | Releases digestive enzymes into the small intestine and the hormones insulin and glucagon into the blood. | seer-accessory, niddk-digestive |
| `anatomy.portal-vein` | female and male | The hepatic portal vein leads to the liver. | Carries nutrient-rich blood from the digestive tract to the liver. | seer-accessory |
| `anatomy.small-intestine` | female and male | A long tube divided into three parts: the duodenum, jejunum and ileum. | Finishes digesting food and absorbs its nutrients. | seer-intestine, niddk-digestive |
| `anatomy.colon` | female and male | The main part of the large intestine, which also includes the rectum and anal canal. | Absorbs water and electrolytes and moves waste toward the rectum for elimination. | seer-intestine, niddk-digestive |
| `anatomy.appendix` | female and male | A finger-shaped pouch attached to the cecum, the first part of the large intestine. | Part of the large intestine. Inflammation of the appendix is called appendicitis. | niddk-digestive, niddk-appendicitis |

### Lymphatic

| Card | Bodies | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.spleen` | female and male | The largest lymphatic organ, in the upper left abdomen just beneath the diaphragm and behind the stomach. | Filters blood. Its lymphocytes react to pathogens carried in the blood. | seer-spleen |
| `anatomy.thymus` | female and male | A lymphatic organ behind the sternum. It is relatively large in children and shrinks after puberty. | Processes and matures special lymphocytes called T cells. | seer-thymus |

### Urinary

| Card | Bodies | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.kidneys` | female and male | Two bean-shaped organs, each about the size of a fist, just below the rib cage on each side of the spine. | Filter wastes and extra water from the blood to make urine, and make hormones that help control blood pressure. | niddk-kidneys, seer-kidney |
| `anatomy.kidney.left` | female and male | Lies against the back wall of the abdomen, usually slightly higher than the right kidney. | Filters blood to make urine. | seer-kidney, niddk-kidneys |
| `anatomy.kidney.right` | female and male | Usually sits slightly lower than the left kidney because the liver displaces it downward. | Filters blood to make urine. | seer-kidney, niddk-kidneys |
| `anatomy.bladder` | female and male | A hollow organ in the pelvic cavity. Its size and shape change with the amount of urine it holds. | A temporary storage reservoir for urine. | seer-bladder, niddk-urinary |
| `anatomy.ureters` | male only | Two small tubes, each about 25 cm long, that descend along the back wall of the abdomen. | Carry urine from the kidneys to the bladder. | seer-ureters, niddk-urinary |

### Reproductive

| Card | Bodies | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.uterus` | female only | A muscular organ in the pelvis. | Receives a fertilized egg and provides the environment for a developing fetus. | seer-female-tract |
| `anatomy.ovaries` | female only | Two almond-sized organs, one on each side of the uterus in the side walls of the pelvic cavity. | Develop egg cells and secrete hormones such as estrogen. | seer-ovaries |
| `anatomy.prostate` | male only | A gland that sits below the bladder and surrounds the urethra at the bladder's neck. | An accessory gland whose secretions enter the urethra and form part of semen. | seer-male-glands, niddk-bph |

## Conditions

All use `reference_location_only`: Inspect reference anatomy isolates the
normal supplied structure, and the text says what is not depicted.

| Condition | Focus | Summary | Not depicted | Sources |
| --- | --- | --- | --- | --- |
| Coronary heart disease | `anatomy.coronary.left` | Plaque made of cholesterol and other substances builds up in the coronary arteries, narrowing them and reducing blood flow to the heart muscle. | Plaque, arterial narrowing and blood flow are not depicted. | nhlbi-chd, seer-heart |
| Aortic aneurysm | `anatomy.aorta` | A balloon-like bulge in the wall of the aorta. A large aneurysm can burst or tear the artery wall, which can be life-threatening. | The bulge, any tear and blood flow are not depicted. | nhlbi-aortic-aneurysm, heart-flow |
| Pulmonary embolism | `anatomy.lungs` | A blood clot, usually from a deep vein in the leg, breaks loose and travels through the bloodstream to the lungs. | Clots, blocked vessels and blood flow are not depicted. | nhlbi-pulmonary-embolism, heart-flow |
| Chronic obstructive pulmonary disease (COPD) | `anatomy.lungs` | A long-term lung disease that blocks airflow and makes it hard to breathe. It mainly includes emphysema, damage to the walls between air sacs, and chronic bronchitis, in which thick mucus forms in the airways. | Damaged air sacs, mucus and airflow are not depicted. | nhlbi-copd, seer-bronchi |
| Asthma | `anatomy.bronchi` | A long-term condition in which the airways in the lungs can become inflamed and narrowed, making it harder for air to flow out. | Airway inflammation, narrowing and airflow are not depicted. | nhlbi-asthma, seer-bronchi |
| Gallstones | `anatomy.gallbladder` | Hard, pebble-like pieces of material, usually made of cholesterol or bilirubin, that develop in the gallbladder. Stones that block the bile ducts can cause sudden pain that needs prompt medical attention. | Stones, blocked ducts and bile flow are not depicted. | niddk-gallstones, niddk-digestive |
| Cirrhosis | `anatomy.liver` | Scar tissue replaces healthy liver tissue, permanently damaging the liver and preventing it from working normally. | Scarring and changes in liver shape or texture are not depicted. | niddk-cirrhosis, seer-accessory |
| Pancreatitis | `anatomy.pancreas` | Inflammation of the pancreas. Acute pancreatitis is short term; chronic pancreatitis can get worse over time. Causes include gallstones and heavy alcohol use. | Inflammation and tissue damage are not depicted. | niddk-pancreatitis, seer-accessory |
| Appendicitis | `anatomy.appendix` | Inflammation of the appendix, and the most common cause of sudden abdominal pain that needs surgery. Quick treatment prevents most complications. | Inflammation and swelling are not depicted. | niddk-appendicitis, niddk-digestive |
| Kidney stones | `anatomy.kidneys` | A solid, pebble-like piece of material that can form in one or both kidneys when urine has high levels of certain minerals. A stone passing through the urinary tract can cause sharp pain in the back, side, lower abdomen or groin. | Stones and urine flow are not depicted. | niddk-kidney-stones, niddk-urinary, seer-ureters |
| Enlarged prostate (benign prostatic hyperplasia) | `anatomy.prostate` | The prostate grows larger than normal, but not because of cancer. As it grows it can squeeze the urethra and make emptying the bladder harder. | Prostate enlargement and urine flow are not depicted. | niddk-bph, seer-male-glands |
| Endometriosis | `anatomy.uterus` | Tissue similar to the lining of the uterus grows outside the uterus. It can cause pain, infertility and other symptoms. | Tissue growing outside the uterus is not depicted. | nichd-endometriosis, seer-female-tract, seer-ovaries |

Coronary heart disease is also listed on the heart, next to the two valve
conditions. Gallstones are also listed on the liver and common bile duct, and
kidney stones on each kidney, the ureters and the bladder.

Enlarged prostate appears only in the male reference, and endometriosis only in
the female one. Each body therefore offers 13 conditions.

## Deliberate limits

- **Sources.** Claims come only from NIH pages: NHLBI, NIDDK, NICHD and NCI SEER
  Training. Each page returned HTTP 200 on 2026-11-20. Some well-known details
  were left out because no cited page states them:
  - left anterior descending artery: no card was added for it;
  - which regions each vena cava drains: both venae cavae share wording;
  - where the pancreas sits relative to the stomach.
- **No new geometry.** No disease geometry, cutaways or flow are added. The
  catalogue IDs are unchanged.
- **Organs not covered.** The stomach, esophagus and brain are not in the
  supplied HRA samples, so they have no cards.
- **Review packet.** The [content-review packet](CONTENT_REVIEW_PACKET.md) still
  describes the `c86cfba` build and its 15 cards. Prepare a new packet with the
  next private build before asking a reviewer to check this material.

## Sources

- `heart-flow`: [NHLBI: Blood flow through the heart](https://www.nhlbi.nih.gov/health/heart/blood-flow)
- `nhlbi-aortic-aneurysm`: [NHLBI: Aortic aneurysm](https://www.nhlbi.nih.gov/health/aortic-aneurysm)
- `nhlbi-asthma`: [NHLBI: Asthma](https://www.nhlbi.nih.gov/health/asthma)
- `nhlbi-chd`: [NHLBI: Coronary heart disease](https://www.nhlbi.nih.gov/health/coronary-heart-disease)
- `nhlbi-copd`: [NHLBI: COPD](https://www.nhlbi.nih.gov/health/copd)
- `nhlbi-pulmonary-embolism`: [NHLBI: Pulmonary embolism](https://www.nhlbi.nih.gov/health/pulmonary-embolism)
- `nichd-endometriosis`: [NICHD: Endometriosis](https://www.nichd.nih.gov/health/topics/endometriosis)
- `niddk-appendicitis`: [NIDDK: Appendicitis](https://www.niddk.nih.gov/health-information/digestive-diseases/appendicitis)
- `niddk-bph`: [NIDDK: Enlarged prostate (benign prostatic hyperplasia)](https://www.niddk.nih.gov/health-information/urologic-diseases/prostate-problems/prostate-enlargement-benign-prostatic-hyperplasia)
- `niddk-cirrhosis`: [NIDDK: Cirrhosis](https://www.niddk.nih.gov/health-information/liver-disease/cirrhosis)
- `niddk-digestive`: [NIDDK: Your digestive system and how it works](https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works)
- `niddk-gallstones`: [NIDDK: Gallstones](https://www.niddk.nih.gov/health-information/digestive-diseases/gallstones)
- `niddk-kidney-stones`: [NIDDK: Kidney stones](https://www.niddk.nih.gov/health-information/urologic-diseases/kidney-stones)
- `niddk-kidneys`: [NIDDK: Your kidneys and how they work](https://www.niddk.nih.gov/health-information/kidney-disease/kidneys-how-they-work)
- `niddk-pancreatitis`: [NIDDK: Pancreatitis](https://www.niddk.nih.gov/health-information/digestive-diseases/pancreatitis)
- `niddk-urinary`: [NIDDK: The urinary tract and how it works](https://www.niddk.nih.gov/health-information/urologic-diseases/urinary-tract-how-it-works)
- `seer-accessory`: [NCI SEER Training: Accessory digestive organs](https://training.seer.cancer.gov/anatomy/digestive/regions/accessory.html)
- `seer-bladder`: [NCI SEER Training: Urinary bladder](https://training.seer.cancer.gov/anatomy/urinary/components/bladder.html)
- `seer-bronchi`: [NCI SEER Training: Bronchi, bronchial tree and lungs](https://training.seer.cancer.gov/anatomy/respiratory/passages/bronchi.html)
- `seer-female-tract`: [NCI SEER Training: Female genital tract](https://training.seer.cancer.gov/anatomy/reproductive/female/tract.html)
- `seer-heart`: [NCI SEER Training: Structure of the heart](https://training.seer.cancer.gov/anatomy/cardiovascular/heart/structure.html)
- `seer-intestine`: [NCI SEER Training: Small and large intestine](https://training.seer.cancer.gov/anatomy/digestive/regions/intestine.html)
- `seer-kidney`: [NCI SEER Training: Kidneys](https://training.seer.cancer.gov/anatomy/urinary/components/kidney.html)
- `seer-male-glands`: [NCI SEER Training: Male accessory glands](https://training.seer.cancer.gov/anatomy/reproductive/male/glands.html)
- `seer-ovaries`: [NCI SEER Training: Ovaries](https://training.seer.cancer.gov/anatomy/reproductive/female/ovaries.html)
- `seer-spleen`: [NCI SEER Training: Spleen](https://training.seer.cancer.gov/anatomy/lymphatic/components/spleen.html)
- `seer-thymus`: [NCI SEER Training: Thymus](https://training.seer.cancer.gov/anatomy/lymphatic/components/thymus.html)
- `seer-ureters`: [NCI SEER Training: Ureters](https://training.seer.cancer.gov/anatomy/urinary/components/ureters.html)
