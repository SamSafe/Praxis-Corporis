# Body study content (draft)

Added 2026-11-20 as study-content revision `body-study-1-draft`. It extends the
chest material (15 cards, two valve conditions, the heart ↔ lungs route) with
**26 organ cards and 12 conditions** across the circulatory, respiratory,
digestive, lymphatic, urinary and reproductive systems. That makes 41 cards and
14 conditions in total. [Revision 2](#revision-2-brain-eyes-and-knees) adds
the brain, eyes and knees, for 63 cards and 25 conditions.

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

## Revision 2: brain, eyes and knees

Added 2026-11-20 as revision `body-study-2-draft`: **22 cards and 11 conditions**, for 63 cards and 25 conditions in total. Each body now offers 24 conditions.

Paired and split parts (both eyes, both knees, the separate source pieces of the cerebellum or thalamus) share one card. A card's per-body `geometry` may therefore be a list of mappings; any listed structure shows the card, and the first one present is where its conditions focus. Each mapped structure still belongs to only one card, and a stale mapping is ignored rather than re-attached.

### Brain

| Card | Source parts (female / male) | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.brain` | 1 / 1 | Divided into the cerebrum, diencephalon, brain stem and cerebellum. With the spinal cord it forms the central nervous system. | The body's control center. It controls thoughts, memory, speech and movement, and regulates the function of many organs. | seer-cns, mlp-brain |
| `anatomy.cerebellum` | 6 / 6 | The second largest part of the brain, below the occipital lobes of the cerebrum. The supplied cerebellum is split into several source parts. | Processes input from other areas of the brain, the spinal cord and sensory receptors to time coordinated, smooth movements. | seer-cns, mlp-cerebellum |
| `anatomy.brainstem` | 10 / 10 | The region between the diencephalon and the spinal cord, made of three parts: the midbrain, pons and medulla oblongata. | Links the brain and spinal cord. All the sensory and motor nerve fibers connecting them pass through the medulla. | seer-cns |
| `anatomy.thalamus` | 22 / 22 | Two oval masses of gray matter making up about 80 percent of the diencephalon, which the cerebral hemispheres nearly surround. | Relays sensory impulses, except for smell, to the cerebral cortex. | seer-cns |
| `anatomy.hypothalamus` | 10 / 10 | A small region of the diencephalon below the thalamus. | Plays a key role in maintaining homeostasis because it regulates many visceral activities. | seer-cns |
| `anatomy.corpus-callosum` | 2 / 2 | An arching band of white fibers joining the two cerebral hemispheres. | Provides a communication pathway between the two halves of the cerebrum. | seer-cns |

### Eyes

| Card | Source parts (female / male) | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.eyes` | 3 / 3 | Light passes through the cornea, enters through the pupil, then passes through the lens to the retina at the back of the eye. | The parts of the eye work together so you can see: they focus light and turn it into signals the brain makes into images. | nei-how-eyes-work |
| `anatomy.cornea` | 2 / 2 | The clear, dome-shaped front layer of the eye. | Bends light to help the eye focus. | nei-how-eyes-work |
| `anatomy.iris` | 2 / 2 | The colored part of the eye, around an opening called the pupil. | Controls how much light the pupil lets in. | nei-how-eyes-work |
| `anatomy.lens` | 2 / 2 | A clear inner part of the eye. Light passes through it after entering through the pupil. | Works together with the cornea to focus light correctly on the retina. | nei-how-eyes-work, nei-cataracts |
| `anatomy.retina` | 2 / 2 | A light-sensitive layer of tissue at the back of the eye. | Special cells called photoreceptors turn light into electrical signals, which travel through the optic nerve to the brain. | nei-how-eyes-work |
| `anatomy.macula` | 2 / 2 | Part of the retina, the light-sensitive tissue at the back of the eye. | Controls sharp, straight-ahead vision. | nei-amd |
| `anatomy.optic-nerves` | 2 / 2 | Each optic nerve leaves the back of an eye. | Carries electrical signals from the retina to the brain. | nei-how-eyes-work, nei-glaucoma |

### Knees

| Card | Source parts (female / male) | Overview | Function | Sources |
| --- | --- | --- | --- | --- |
| `anatomy.knee` | 2 / 2 | The joint where the end of the thigh bone (femur) meets the top of the shin bone (tibia). It is made up of bone, cartilage, ligaments and fluid. | Four main ligaments connect the thigh bone and shin bone; muscles and tendons help the joint move. | mlp-knee, mlp-acl |
| `anatomy.femur` | 2 / 2 | The thigh bone. Its lower end meets the top of the shin bone at the knee joint. | Forms the upper part of the knee joint. | mlp-acl |
| `anatomy.tibia` | 2 / 2 | The shin bone. Its top meets the end of the thigh bone at the knee joint. | Forms the lower part of the knee joint. The cruciate ligaments keep it from sliding forward or backward against the thigh bone. | mlp-acl |
| `anatomy.knee-cartilage` | 2 / 2 | Articular cartilage covers the ends of the bones where they meet in a freely movable joint. The supplied cartilage covers the lower end of the femur. | Covers the bone ends inside the joint. In osteoarthritis this cartilage breaks down. | seer-articulations, niams-osteoarthritis |
| `anatomy.meniscus` | 2 / 2 | A C-shaped piece of tough but flexible cartilage in the knee joint. Each knee has two. | Cushions the bones of the knee like a shock absorber, helps distribute weight to the cartilage and helps stabilize the joint. | mlp-meniscus |
| `anatomy.acl` | 2 / 2 | The anterior cruciate ligament, in the middle of the knee. One of the four main ligaments connecting the thigh bone and shin bone. | Prevents the shin bone from sliding out in front of the thigh bone. | mlp-acl, mlp-knee |
| `anatomy.pcl` | 2 / 2 | The posterior cruciate ligament, one of the four main knee ligaments. It works opposite to the ACL. | Prevents the shin bone from sliding backward under the thigh bone. | mlp-acl |
| `anatomy.mcl` | 2 / 1 | The medial collateral ligament, which runs along the inside of the knee. | Prevents the knee from bending inward. | mlp-acl |
| `anatomy.lcl` | 2 / 2 | The lateral collateral ligament, which runs along the outside of the knee. | Prevents the knee from bending outward. | mlp-acl |

### Conditions

| Condition | Focus | Summary | Not depicted | Sources |
| --- | --- | --- | --- | --- |
| Stroke | `anatomy.brain` | Blood flow to part of the brain is lost, so brain cells cannot get the oxygen and nutrients they need and start to die within minutes. Most strokes are ischemic, caused by a clot blocking a blood vessel in the brain; hemorrhagic strokes are caused by a vessel that breaks and bleeds into the brain. A stroke needs emergency help right away. | Blocked or bleeding blood vessels, blood flow and damaged brain tissue are not depicted. | mlp-stroke, mlp-cerebellum, seer-cns |
| Alzheimer's disease | `anatomy.brain` | The most common form of dementia among older people. It begins slowly over many years, first involving the parts of the brain that control thought, memory and language, and its symptoms get worse over time. It is not a normal part of aging. | Brain changes caused by the disease are not depicted. | mlp-alzheimers, seer-cns |
| Parkinson's disease | `anatomy.brain` | A movement disorder in which the brain cells that make the chemical dopamine slowly die. Without enough dopamine, movement becomes hard to control; symptoms include trembling, stiffness, slowness and poor balance, often starting on one side of the body. | The affected brain cells and dopamine signaling are not depicted. | mlp-parkinsons, mlp-parkinson-disease, seer-cns |
| Epilepsy | `anatomy.brain` | A brain disorder that causes recurring seizures, which happen when clusters of nerve cells in the brain send out the wrong signals. Medicines can control seizures for most people. | Nerve-cell signaling and seizure activity are not depicted. | mlp-epilepsy, seer-cns |
| Cataracts | `anatomy.lens` | A cloudy area in the lens of the eye. Cataracts are very common with age and can make vision blurry, hazy or less colorful. Surgery can remove them. | Clouding of the lens is not depicted. | nei-cataracts, nei-how-eyes-work |
| Glaucoma | `anatomy.optic-nerves` | A group of eye diseases that can cause vision loss and blindness by damaging the optic nerve at the back of the eye. It often has no symptoms at first; early treatment can often stop the damage. | Optic nerve damage and vision loss are not depicted. | nei-glaucoma, nei-how-eyes-work |
| Age-related macular degeneration (AMD) | `anatomy.macula` | Aging damages the macula, the part of the retina that controls sharp, straight-ahead vision, blurring central vision. Most people have dry AMD, in which the macula gets thinner with age. | Thinning or other damage to the macula is not depicted. | nei-amd |
| Diabetic retinopathy | `anatomy.retina` | An eye condition that can cause vision loss and blindness in people with diabetes. It affects blood vessels in the retina and may have no symptoms at first. | Retinal blood vessels and their damage are not depicted. | nei-diabetic-retinopathy, nei-how-eyes-work |
| Anterior cruciate ligament (ACL) injury | `anatomy.acl` | Over-stretching or tearing, partial or complete, of the ACL in the knee. It is often caused by a sudden twist or by stopping and changing direction quickly, and often occurs with other knee injuries such as a meniscus tear. | The torn ligament and knee motion are not depicted. | mlp-acl, mlp-knee |
| Meniscus tear | `anatomy.meniscus` | A tear in the shock-absorbing cartilage of the knee. It can happen when the knee is twisted or over-flexed, and the meniscus becomes more brittle and easier to tear with age. | The tear and knee motion are not depicted. | mlp-meniscus |
| Osteoarthritis of the knee | `anatomy.knee-cartilage` | A degenerative joint disease in which tissues of the joint break down over time. It is the most common disease affecting the knee: the cartilage gradually wears away, causing pain and swelling. | Cartilage loss, bone spurs and joint changes are not depicted. | niams-osteoarthritis, mlp-knee, seer-articulations |

Stroke is also listed on the cerebellum and brainstem; glaucoma on the retina; AMD on the retina and eyes; knee osteoarthritis on the meniscus.

### Revision 2 limits

- **Sources.** NEI, NIAMS, NCI SEER Training and MedlinePlus (National Library of Medicine) pages, each fetched on 2026-11-20. NINDS and NIA pages refuse automated retrieval, so their text could not be checked. For that reason there are no hippocampus or substantia nigra cards, and the four brain conditions point to the whole brain instead of a specific region.
- **Brain regions.** The thalamus, hypothalamus, cerebellum and brainstem cards group several Allen atlas source parts. The brainstem card omits the central canal. Many atlas gyri and nuclei remain without cards.
- **Knee coverage.** The male source has no right tibial collateral ligament, so the MCL card has one part in that body. There is no patella card because no fetched source describes the patella.
- **Source labels.** 207 source structures per body carried a literal "-" label. The pack builder now derives a readable name from the source node name instead (for example "Thalamus, left"). IDs, source names and ontology are unchanged, so saved views and mappings are unaffected.

## Deliberate limits

- **Sources (revision 1).** Claims come only from NIH pages: NHLBI, NIDDK, NICHD and NCI SEER
  Training. Each page returned HTTP 200 on 2026-11-20. Some well-known details
  were left out because no cited page states them:
  - left anterior descending artery: no card was added for it;
  - which regions each vena cava drains: both venae cavae share wording;
  - where the pancreas sits relative to the stomach.
- **No new geometry.** No disease geometry, cutaways or flow are added. The
  catalogue IDs are unchanged.
- **Organs not covered.** The stomach and esophagus are not in the supplied HRA
  samples, so they have no cards. (An earlier version of this note also listed
  the brain; the samples do include it, and revision 2 adds brain cards.)
- **Review packet.** The [content-review packet](CONTENT_REVIEW_PACKET.md) still
  describes the `c86cfba` build and its 15 cards, not revisions 1 or 2. Prepare a new packet with the
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
- `mlp-acl`: [MedlinePlus Medical Encyclopedia: Anterior cruciate ligament (ACL) injury](https://medlineplus.gov/ency/article/001074.htm)
- `mlp-alzheimers`: [MedlinePlus: Alzheimer's disease](https://medlineplus.gov/alzheimersdisease.html)
- `mlp-brain`: [MedlinePlus: Brain diseases](https://medlineplus.gov/braindiseases.html)
- `mlp-cerebellum`: [MedlinePlus: Cerebellum - function](https://medlineplus.gov/ency/imagepages/18008.htm)
- `mlp-epilepsy`: [MedlinePlus: Epilepsy](https://medlineplus.gov/epilepsy.html)
- `mlp-knee`: [MedlinePlus: Knee injuries and disorders](https://medlineplus.gov/kneeinjuriesanddisorders.html)
- `mlp-meniscus`: [MedlinePlus Medical Encyclopedia: Meniscus tears - aftercare](https://medlineplus.gov/ency/patientinstructions/000684.htm)
- `mlp-parkinson-disease`: [MedlinePlus Medical Encyclopedia: Parkinson disease](https://medlineplus.gov/ency/article/000755.htm)
- `mlp-parkinsons`: [MedlinePlus: Parkinson's disease](https://medlineplus.gov/parkinsonsdisease.html)
- `mlp-stroke`: [MedlinePlus: Stroke](https://medlineplus.gov/stroke.html)
- `nei-amd`: [NEI: Age-related macular degeneration](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/age-related-macular-degeneration)
- `nei-cataracts`: [NEI: Cataracts](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/cataracts)
- `nei-diabetic-retinopathy`: [NEI: Diabetic retinopathy](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/diabetic-retinopathy)
- `nei-glaucoma`: [NEI: Glaucoma](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/glaucoma)
- `nei-how-eyes-work`: [NEI: How the eyes work](https://www.nei.nih.gov/learn-about-eye-health/healthy-vision/how-eyes-work)
- `niams-osteoarthritis`: [NIAMS: Osteoarthritis](https://www.niams.nih.gov/health-topics/osteoarthritis)
- `seer-articulations`: [NCI SEER Training: Articulations](https://training.seer.cancer.gov/anatomy/skeletal/articulations.html)
- `seer-cns`: [NCI SEER Training: Central nervous system](https://training.seer.cancer.gov/anatomy/nervous/organization/cns.html)
