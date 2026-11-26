# Body study content (draft)

Added 2026-11-20 as study-content revision `body-study-1-draft`. It extends the
chest material (15 cards, two valve conditions, the heart ↔ lungs route) with
**26 organ cards and 12 conditions** across the circulatory, respiratory,
digestive, lymphatic, urinary and reproductive systems. That makes 41 cards and
14 conditions in total. [Revision 2](#revision-2-brain-eyes-and-knees) adds
the brain, eyes and knees, for 63 cards and 25 conditions.
[Revisions 3 and 4](#revisions-3-and-4-vessels-organ-interiors-airways-skin-and-bone)
bring the totals to 112 cards and 54 conditions. Later revisions, from
[revision 5](#revision-5-dictionary-terms-brain-fluid-spaces-and-more-cancers)
to [revision 16](#revision-16-audit-additions),
bring them to 247 cards and 157 conditions.

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

## Revisions 3 and 4: vessels, organ interiors, airways, skin and bone

Added 2026-11-20 as revisions `body-study-3-draft` and `body-study-4-draft`:
**49 cards and 29 conditions**, for **112 cards and 54 conditions** in total. The
female body offers 52 conditions and the male body 50.

- **Heart and great vessels:** pulmonary trunk and arteries, coronary sinus,
  cardiac veins, the three portions of the aorta, the aortic-arch branches, the
  celiac trunk, both mesenteric arteries, and the renal arteries and veins.
- **Airways and lungs:** larynx cartilages, epiglottis, tracheal cartilage, the
  lobes of each lung and the lung hilum.
- **Kidney interior:** capsule, cortex, medulla, pyramids, papillae, minor and
  major calyces, renal pelvis and hilum.
- **Intestines and liver:** duodenum, jejunum, ileum, ileocecal valve, cecum,
  sigmoid colon, rectum, liver lobes and cystic duct.
- **Female tract (female body only):** Fallopian tubes, infundibulum and
  fimbriae, cervix and vagina.
- **Other:** a sample lymph node, the quadriceps tendon, the skin, the pupil,
  ciliary body, choroid and vitreous, and compact and spongy pelvic bone.
- **Conditions:** heart attack, heart failure, atrial fibrillation, pneumonia,
  lung cancer, chronic kidney disease, bladder infection, bladder cancer,
  diverticular disease, Crohn's disease, ulcerative colitis, celiac disease,
  fatty liver disease, viral hepatitis, diabetes, hemorrhoids, colorectal
  cancer, uterine fibroids, PCOS, cervical cancer, prostate cancer, retinal
  detachment, psoriasis, atopic dermatitis, skin cancer, uveitis, pink eye,
  floaters and osteoporosis.

The full text of every card and condition is in the
[content-review packet](CONTENT_REVIEW_PACKET.md) and its frozen JSON.

### Revision 3 and 4 limits

- **Sources.** NIDDK, NHLBI, NICHD, NEI, NIAMS, NCI (cancer.gov and SEER
  Training) and MedlinePlus pages, each fetched on 2026-11-20. Statements were
  cut back where a page did not support them. For example, the cardiac veins are
  not described as running over the heart's surface, and the cortex is not
  described as filtering blood.
- **Left out for lack of a fetched source:** patella, fibula, sclera,
  conjunctiva, extraocular muscles, hip bones as a whole, the pancreas's parts,
  liver segments, bronchopulmonary segments and most named colon vessels.
- **Condition locations.** Some conditions point at a whole organ rather than
  the affected tissue. Osteoporosis uses the supplied pelvic bone tissue only as
  an example location.
- **Validator limit.** The list of sources the assistant cross-checked now has 86
  entries. Its cap was raised from 64 to 256; the 64-item cap on each record's
  own citations is unchanged.

## Revision 5: dictionary terms, brain fluid spaces and more cancers

Added 2026-11-20 as `body-study-5-draft`: **13 cards and 12 conditions**, for
**125 cards and 66 conditions** in total. The female body offers 64 conditions
and the male body 60.

- **Cards:** sclera, conjunctiva, optic chiasm, olfactory bulbs, pineal gland,
  brain ventricles, dura mater, tracheal carina, pancreatic ducts, hepatic
  arteries, the pelvis, and (female body only) the broad ligament and the fundus
  of the uterus.
- **Conditions:** pancreatic, liver, kidney, ovarian and uterine cancer, brain
  tumors, pulmonary hypertension, polycystic kidney disease, lactose
  intolerance, hydrocephalus, meningitis and traumatic brain injury. Pink eye
  is now also listed on the conjunctiva.
- **New source type:** most new cards cite single entries from the NCI
  Dictionary of Cancer Terms, an NIH glossary written for patients. Each entry is
  its own source ID (`nci-def-…`) so a reviewer can check it separately.

### Revision 5 limits

- **NCBI Bookshelf (StatPearls) was not used.** NCBI shows a CAPTCHA to
  automated downloads, and fetching past it was declined. The hippocampus,
  substantia nigra, basal ganglia, amygdala, cerebral lobes and gyri, patella,
  fibula and extraocular muscles still have no cards for that reason.
- **Dura mater.** The models supply dura mater only with the nerves of each eye,
  not around the brain, and the card says so. Meningitis therefore points at the
  whole brain.
- **IBS was left out.** NIDDK describes it as a functional disorder with no
  single location, so pointing at one organ would mislead.

## Revision 6: heart and gut vessels, eye muscles, voice box and pelvic organs

Added 2026-11-21 as `body-study-6-draft`: **28 cards and 16 conditions**, for
**153 cards and 82 conditions** in total. The female body offers 76 conditions
and the male body 73 (67 shared).

- **Cards:**
  - heart: the left anterior descending artery, the circumflex artery, and the
    right coronary artery's branches;
  - eye: the six eye-moving muscles, the eyelid-raising muscle, the ophthalmic
    vessels, and the central retinal artery and vein;
  - voice box and neck (male model only): the larynx muscles, the vocal-fold
    muscles and the hyoid bone; bronchial cartilage on both bodies;
  - male reproductive and urinary: vas deferens, seminal vesicles, ejaculatory
    ducts and urethra;
  - female reproductive: the uterine ligaments, the ovarian ligaments and the
    uterine vessels;
  - liver and gut: hepatic ducts, hepatic veins, splenic, mesenteric, colic,
    rectal and cystic vessels;
  - veins: iliac veins (both bodies) and brachiocephalic veins (male model);
  - knee: the patellar ligament.
- **Existing cards extended** with parts that one body was missing: the female
  ureters, the portal vein's branches, the male right MCL and the hepatic
  arteries' segmental branches.
- **Conditions:** strabismus, ptosis, retinal artery occlusion, voice
  disorders, laryngitis, deep vein thrombosis, multiple sclerosis, migraine,
  pelvic support problems, bile duct cancer, ectopic pregnancy, ovarian cysts,
  swollen or ruptured spleen, male infertility, urethral disorders and
  prostatitis. Coronary heart disease and heart attack now also show on the new
  coronary branches.
- **New source type:** anatomy without a fetchable government page cites
  [TeachMeAnatomy](https://teachmeanatomy.info/), a non-government anatomy
  teaching reference. The user approved non-government sources on
  2026-11-21. Every condition still cites at least one government page
  (MedlinePlus, NIDDK or NCI), and the Python tests enforce both rules.

### Revision 6 limits

- **Left out for lack of a fetchable source:** the anterolateral ligament of the
  knee and the uterovesical pouch. Cleveland Clinic, Johns Hopkins and
  Radiopaedia refuse automated downloads and were not used.
- **No stomach, esophagus or testes** in the supplied models, so GERD, ulcers,
  stomach cancer and testicular cancer have nowhere to point.
- **Hemorrhoids are not linked to the rectal veins.** TeachMeAnatomy states that
  hemorrhoids are enlarged vascular cushions of the anal canal, not rectal
  varices.
- **DVT** usually occurs in the leg, which the models do not include. The
  condition points at the iliac veins and says so.
- **Migraine and MS** point at the whole brain; neither source places them in
  one region.

### Accuracy pass

On 2026-11-21 every card, condition and route step was re-checked sentence by
sentence against freshly downloaded copies of its sources, and 16 records were
corrected. See the [accuracy pass report](audit/ACCURACY_PASS_2026-11-21.md). It is
an assistant check, not a medical review.

## Revision 7: the complete male body

Added 2026-11-21 as `body-study-7-draft`, together with a new reference: the
**complete male body** built from every BodyParts3D v4.0 source mesh
([tools/build_full_body.py](../tools/build_full_body.py)). It supplies anatomy the HRA
bodies lack: stomach, esophagus, diaphragm, spinal cord, pituitary and adrenal
glands, tongue, teeth, salivary glands, testes, epididymis, penis, the whole
skeleton and most muscles, and the neck and limb vessels.

- **New cards (43):** stomach, esophagus, diaphragm, spinal cord, pituitary,
  tongue, skull, vertebral column, adrenal glands, testes, epididymis, penis,
  sternum, ribs, collarbones, shoulder blades, humerus, forearm bones, hand and
  foot bones, sacrum, mandible, maxillae, teeth, soft palate, pharynx muscles,
  salivary glands, nasal bones, carotid, subclavian and external iliac arteries,
  intercostal muscles, pectoralis major, deltoids, biceps, triceps, trapezius,
  gluteus maximus, quadriceps, hamstrings, calf muscles, tibialis anterior and the
  intervertebral disks.
- **New conditions (25):** GERD, peptic ulcer, stomach cancer, esophageal cancer,
  hiatal hernia, hiccups, spinal cord injury, pituitary tumors, adrenal
  insufficiency, Cushing's syndrome, testicular cancer, erectile dysfunction,
  scoliosis, herniated disk, back pain, carpal tunnel syndrome, gout, rheumatoid
  arthritis, peripheral artery disease, carotid artery disease, rotator cuff
  injuries, lip and oral cavity cancer, tooth decay, salivary gland disorders and
  muscle strain. They appear on the complete body only, because their anatomy is
  not in the HRA bodies.
- **Existing cards on the complete body:** 99 of the 153 earlier cards now also
  resolve on it, by card-named organs or by mappings matched on source names
  (142 of 196 cards in total). On this body the aortic-arch-branches card keeps
  the brachiocephalic artery; the carotid and subclavian arteries have their own
  cards.
- **Sources:** NCI dictionary entries and NCI SEER Training pages for anatomy,
  NIDDK, NIAMS, NHLBI, NCI and MedlinePlus for conditions, and TeachMeAnatomy for
  the radius and ulna. Each new sentence was checked against its source text.

### Revision 7 limits

- **Male only.** BodyParts3D models one adult male. Female-specific conditions
  stay on the HRA female body, and the complete body is not aligned to either HRA
  body.
- **Not in the source at all:** thyroid gland, tonsils, parotid glands, breasts,
  scrotum, the meninges, kidney interiors and the knee ligaments and menisci.
  Thyroid conditions therefore have nowhere to point.
- **Reduced geometry.** The archive is the source's 99% polygon-reduced version;
  small structures look coarse. Unclassified parts keep a softened source colour.
- **Mapping by name.** Existing cards were matched to complete-body parts by
  source names; the [mapping test](../tests/test_study_content.py) checks every
  mapping against the catalogue, but anatomical equivalence is unreviewed.

## Revision 8: breasts, tonsils, thyroid and parathyroid glands, and the HRA spine

Added 2026-11-21 as `body-study-8-draft`, with new geometry in three bodies:

- **HRA bodies.** [tools/build_hra_supplements.py](../tools/build_hra_supplements.py)
  appends later HRA organs to each United v1.1 body: the female mammary glands
  (HRA v1.3), the palatine tonsils of both bodies (v1.4), and the spinal cord and
  vertebrae of both bodies (v1.2). They share the United coordinate frame (the
  v1.4 larynx matches the United thyroid cartilage's width exactly, and the v1.2
  heart encloses the United left ventricle with the same outer edge), and existing node indices and catalogue IDs are unchanged
  ([audit](audit/HRA_SUPPLEMENTS.md)).
- **Complete male body.** The thyroid gland, four parathyroid glands and the
  sublingual glands come from BodyParts3D / Anatomography 4.3, which shares the
  4.0 frame (five shared meshes have identical bounds).
- **New cards (4):** breasts (female), palatine tonsils (both HRA bodies), thyroid
  and parathyroid glands (complete body). The spinal cord and vertebral column
  cards now also resolve on both HRA bodies, and the salivary-glands card
  includes the sublingual glands.
- **New conditions (10):** breast cancer, benign breast changes, tonsillitis,
  hypothyroidism, hyperthyroidism, Hashimoto's disease, Graves' disease, thyroid
  nodules, thyroid cancer and primary hyperparathyroidism. Spinal cord injury,
  scoliosis and back pain now also appear on the HRA bodies.

### Revision 8 limits

- **Still absent from every open source found:** the parotid glands, the scrotum,
  the female external genitalia (vulva) and the pharyngeal and lingual tonsils.
  No openly licensed model was found in the HRA library (to its latest
  release) or BodyParts3D 4.0 and 4.3.
- **No complete female body.** The female body has every HRA female organ, but
  no open source supplies a full female skeleton or muscle set; those exist only
  in the male BodyParts3D body, which is not aligned to the female body.
- **Licence.** The BodyParts3D 4.3 meshes are CC BY-SA 2.1 Japan, from a public
  mirror pinned by commit and checked by SHA-256 and file headers.

## Revision 9: structures no open source models

Added 2026-11-22 as `body-study-9-draft`. Five structures have no openly licensed
model (see [the second search](audit/HRA_SUPPLEMENTS.md)), so they get text-only
cards rather than invented geometry:

- **New unmodelled cards (5):** parotid glands, scrotum, vulva, adenoids
  (pharyngeal tonsils) and lingual tonsils. Each card has a `not_modelled` record
  with a title, a note and the nearby supplied structures to locate, and it never
  carries geometry.
- **How they appear:** search finds them by name, marked "No 3D model". Their card
  lists sources and conditions. "Locate nearby anatomy" selects the first nearby
  structure the current body supplies; for example, the vulva locates the vagina,
  and on the complete body the parotid glands locate the submandibular and
  sublingual glands. Where a body supplies none, the card says so and offers no
  location. A supplied neighbour's panel links the unmodelled card and lists its
  conditions.
- **New conditions (9):** mumps, salivary gland cancer, hydrocele, varicocele,
  vulvar cancer, vulvodynia, Bartholin cyst or abscess and enlarged adenoids, all
  about unmodelled anatomy and so readable on every body; plus testicular torsion,
  located on the testes where a body supplies them. CDC joins the government
  sources.

### Revision 9 limits

- Conditions about unmodelled anatomy say "NO 3D MODEL" instead of the
  reference-anatomy notice, and their location action, where offered, shows a
  neighbouring structure, not the structure itself.

## Revision 10: parotid glands on the female and male bodies

Added 2026-11-22 as `body-study-10-draft`. The parotid glands were traced from the
Visible Human CT scans of the donors behind the female and male bodies and fitted to
each body's eyes and neck vertebrae ([audit](audit/VHP_PAROTID.md)). The parotid card
now maps to them on those bodies. An unmodelled card is now judged per body: on the
complete male body the parotid card stays text-only with "Locate nearby anatomy",
and mumps and salivary gland cancer locate the real glands wherever they exist.

## Revision 11: organs, bones and muscles traced from the Visible Human CT

Added 2026-11-23. The female and male bodies gain a stomach, oesophagus, thyroid,
adrenal glands, ribs and costal cartilages, sternum, gluteal muscles (no gluteus
maximus on the male), iliopsoas and deep back muscles, traced from the same donors'
CT scans ([audit](audit/VHP_CT_PARTS.md)). The stomach, oesophagus, thyroid,
adrenal-glands, ribs, sternum and gluteus maximus cards now map to them, so GERD,
peptic ulcer, stomach and oesophageal cancer, adrenal insufficiency, Cushing's
syndrome and the six thyroid conditions are offered on both bodies. The skull,
shoulder bones and upper-arm bones were traced but left out after review.

`body-study-11-draft` also adds four cards, on all three bodies: gluteus medius,
gluteus minimus, iliopsoas and the deep back muscles (cited to NCI SEER Training and
TeachMeAnatomy; the SEER line that the gluteal group "adducts" the thigh was not used,
since the gluteal muscles abduct and extend it). Paired and member parts now open their
organ's card: either parotid gland, tonsil, adrenal gland or breast, and every rib and
the costal cartilages on the female and male bodies.

## Revision 12: head, neck and trunk muscles, diaphragm and shoulders

Added 2026-11-24 as `body-study-12-draft`. A second CT tracing round
([audit](audit/VHP_CT_PARTS.md#second-round-head-neck-and-trunk-muscles-jaw-diaphragm-and-shoulders))
gives both bodies a tongue, mandible, jaw muscles, scalenes, inferior pharyngeal
constrictor, serratus anterior, latissimus dorsi, abdominal wall muscles, quadratus
lumborum, diaphragm, scapulae and clavicles. The female body also gains the
submandibular glands, hyoid bone and humeri, and the male body the pectoralis major
and temporalis; the audit lists the parts left out on each body and why.

Seven cards are new, on the female, male and (where the source has the muscle) complete
bodies: muscles of mastication, scalenes, serratus anterior, latissimus dorsi, rectus
abdominis, abdominal obliques and quadratus lumborum, cited to TeachMeAnatomy and NCI
SEER Training. Their text was drafted with the tracing work; the assistant's
2026-11-21 source cross-check predates them, so their source check is pending. The
complete male body maps the scalene, serratus anterior and external oblique cards to its
BodyParts3D muscles. Existing tongue, mandible, hyoid, salivary-gland, pharynx-muscle,
pectoralis, diaphragm, scapula, clavicle and humerus cards now open on the traced parts.

Hiatal hernia, hiccups and oral cancer are now offered on both bodies, and rotator-cuff
and salivary-gland disorders on the female body (107 conditions female, 100 male).

## Revision 13: neck muscles re-traced at 0.75 mm

Added 2026-11-24 as `body-study-13-draft`. The scalenes and pharyngeal constrictors
were re-traced on a 0.75 mm head-and-neck volume
([audit](audit/VHP_CT_PARTS.md#neck-muscles-re-traced-at-075-mm)). The pharynx-muscle
card now also shows the male superior and middle pharyngeal constrictors; on the female
body it still shows the inferior constrictor only. No card or condition text changed,
and the offered conditions are unchanged. The male catalogue IDs of the CT parts after
the constrictors moved by two, and the card mappings follow them.

## Revision 14: third tracing round (neck muscles, teeth and neck vessels)

Added 2026-11-25 as `body-study-14-draft`, with the third tracing round
([audit](audit/VHP_CT_PARTS.md#third-round-skin-refits-the-whole-trapezius-and-more-neck-structures)).

- **New cards (6):** sternocleidomastoid (male body), levator scapulae, infrahyoid
  muscles (the body shows the sternothyroid and thyrohyoid), prevertebral muscles,
  digastric (female body) and internal jugular veins. Each is cited to
  TeachMeAnatomy; the sternocleidomastoid's attachments and actions come from its
  accessory-nerve page, which describes the muscles that nerve supplies.
- **Existing cards on new parts:** trapezius (both bodies), pectoralis major and
  the muscles of mastication (female temporalis), soft palate, teeth (female lower
  teeth only), and the carotid and subclavian arteries (female right common carotid
  and right subclavian). The carotid and subclavian cards now also say that the right
  arteries arise from the brachiocephalic trunk. On the HRA bodies the left arteries
  stay with the aortic-arch-branches card, whose text names them.
- **Conditions:** tooth decay is now offered on both HRA bodies, and carotid artery
  disease on the female (109 conditions female, 101 male). No condition text changed.
- **IDs:** both bodies' catalogue IDs of the CT parts after the first changed group
  moved; card mappings and coverage roots follow them.

## Revision 15: intervertebral discs

Added 2026-11-25 as `body-study-15-draft`, with the fourth tracing round
([audit](audit/VHP_CT_PARTS.md#fourth-round-intervertebral-discs)).

- **Existing card on new parts:** the intervertebral-disks card now shows the traced
  discs on both HRA bodies (24 female, C2-C3 to L6-S1; 23 male, C2-C3 to L5-S1), one
  disc per level, named by the body's vertebrae above and below it. Its text is
  unchanged.
- **Conditions:** herniated disk is now offered on both HRA bodies (110 conditions
  female, 102 male). No condition text changed.
- **IDs:** the discs were added after every other group, so no catalogue ID moved.

## Revision 16: audit additions

Added 2026-11-25 as `body-study-16-draft`, after a card-by-card and condition-by-condition
audit of revision 15 and a check of what the two bodies supply but no card explained.
Every new claim was read on its cited page that day (preliminary assistant check, not
human review). Sources are limited to the government sites the tests accept and
TeachMeAnatomy. NINDS, NIA and NIDCR pages were first cited through MedlinePlus or
TeachMeAnatomy instead, then added to the accepted list with the user's approval.

- **New cards for supplied parts (20).** Cerebral hemispheres, motor cortex (precentral
  gyrus), sensory cortex (postcentral gyrus), auditory cortex (superior and transverse
  temporal gyri), basal ganglia (caudate, putamen, globus pallidus, nucleus accumbens,
  subthalamic nucleus), substantia nigra, kneecap (patella), fibula, coccyx, cervical,
  thoracic and lumbar vertebrae, fovea, optic disc, aqueous humor, the eye's drainage
  tissue (trabecular meshwork and Schlemm's canal), prostate zones, bladder trigone,
  colon segments and papillary muscles. All map to existing source meshes on both HRA
  bodies (prostate zones on the male only); the complete male body also shows its basal
  ganglia, patellae, fibulae, vertebral regions and papillary muscles.
- **Venae cavae (1).** A card for the vena cava group the heart-lung route starts on,
  which showed no explanation before.
- **New text-only cards (2). The ears and the sinuses, which no open source models,
  so hearing loss, ear infections and sinusitis can be read on every body.
- **New mappings on existing cards.** The HRA sacra (sacrum card), rectus femoris
  (quadriceps card) and cerebral aqueduct (brain-ventricles card).
- **New conditions (31).** High blood pressure, atherosclerosis, cardiomyopathy,
  congenital heart defects, sleep apnea, collapsed lung, cystic fibrosis, tuberculosis,
  idiopathic pulmonary fibrosis, kidney infection, bladder control problems, irritable
  bowel syndrome, inguinal hernia, gastritis, Huntington's disease, ALS, spinal
  stenosis, sciatica, hip fracture, kneecap dislocation, Osgood-Schlatter disease, TMD,
  refractive errors, lymphoma, leukemia, laryngeal cancer, pelvic inflammatory disease,
  ankylosing spondylitis, hearing loss, ear infections and sinusitis. The female body now
  offers 141 conditions and the male 132.
- **Corrections.** The knee card said four ligaments connect the thigh bone and shin bone;
  the lateral collateral ligament runs to the fibula, so the knee, ACL and LCL cards now
  say which ligament goes where. The pineal card placed the gland "in the cerebrum"; it
  now gives its midline position at the back of the third ventricle and its circadian
  role. The choroid card now describes the choroid as the layer of connective tissue and
  blood vessels between the retina and sclera. The vertebral-column card notes that the
  female body has six lumbar vertebrae.
- **Links.** Glaucoma, BPH, AMD, herniated disk, diverticular disease, colorectal cancer,
  osteoporosis and mitral regurgitation now also appear on the matching new cards.
- **NINDS, NIA and NIDCR accepted (second part).** These NIH pages were first left out
  because the tests' list of government sources did not include them; the user approved
  adding them the same day. With them: hippocampus and amygdala cards; the substantia
  nigra card now says its cells make dopamine and that Parkinson's symptoms follow their
  loss, and Parkinson's disease is shown on it and on the basal ganglia; Alzheimer's
  disease is shown on the hippocampus; the cerebral-hemispheres card notes that each
  hemisphere mainly controls the opposite side of the body. NCBI Bookshelf asked for a
  CAPTCHA, which was not attempted. Prostate cancer's "most common cancer among men"
  matches its NCI page and was kept.
- **Totals:** 247 cards, 157 conditions, one route, 325 sources. No catalogue ID moved.

## Deliberate limits

- **Sources (revision 1).** Claims come only from NIH pages: NHLBI, NIDDK, NICHD and NCI SEER
  Training. Each page returned HTTP 200 on 2026-11-20. Some well-known details
  were left out because no cited page states them:
  - left anterior descending artery: no card was added for it (revision 6 adds one);
  - which regions each vena cava drains: both venae cavae share wording;
  - where the pancreas sits relative to the stomach.
- **No new geometry.** No disease geometry, cutaways or flow are added. The
  catalogue IDs are unchanged.
- **Organs not covered.** The stomach and esophagus are not in the supplied HRA
  samples, so they have no cards. (An earlier version of this note also listed
  the brain; the samples do include it, and revision 2 adds brain cards.)
- **Review packet.** The [content-review packet](CONTENT_REVIEW_PACKET.md) now
  covers build `0344141` (revision `body-study-16-draft`, all 247 cards and 157
  conditions, with each card's parts listed for the female, male and complete
  bodies). Regenerate it with `tools/build_review_packet.py` after any later
  content change.

## Sources

Revision 16 adds:

- `ninds-brain-basics`: [NINDS: Brain basics: know your brain](https://www.ninds.nih.gov/health-information/public-education/brain-basics/brain-basics-know-your-brain)
- `ninds-sleep`: [NINDS: Brain basics: understanding sleep](https://www.ninds.nih.gov/health-information/public-education/brain-basics/brain-basics-understanding-sleep)
- `nia-alzheimers-brain`: [NIA: What happens to the brain in Alzheimer's disease?](https://www.nia.nih.gov/health/alzheimers-causes-and-risk-factors/what-happens-brain-alzheimers-disease)
- `ninds-parkinsons`: [NINDS: Parkinson's disease](https://www.ninds.nih.gov/health-information/disorders/parkinsons-disease)
- `nidcr-tmd`: [NIDCR: Temporomandibular disorders (TMD)](https://www.nidcr.nih.gov/health-info/tmd)
- `tm-basal-ganglia`: [TeachMeAnatomy: The basal ganglia](https://teachmeanatomy.info/neuroanatomy/structures/basal-ganglia/)
- `tm-cerebrum`: [TeachMeAnatomy: The cerebrum](https://teachmeanatomy.info/neuroanatomy/structures/cerebrum/)
- `tm-pineal`: [TeachMeAnatomy: The pineal gland](https://teachmeanatomy.info/neuroanatomy/structures/pineal-gland/)
- `tm-ventricles`: [TeachMeAnatomy: The ventricles of the brain](https://teachmeanatomy.info/neuroanatomy/vessels/ventricles/)
- `tm-fibula`: [TeachMeAnatomy: The fibula](https://teachmeanatomy.info/lower-limb/bones/the-fibula/)
- `tm-vertebral-column`: [TeachMeAnatomy: The vertebral column](https://teachmeanatomy.info/back/bones/vertebral-column/)
- `tm-heart-valves`: [TeachMeAnatomy: The heart valves](https://teachmeanatomy.info/thorax/organs/heart/heart-valves/)
- `tm-prostate`: [TeachMeAnatomy: The prostate gland](https://teachmeanatomy.info/pelvis/the-male-reproductive-system/prostate-gland/)
- `tm-bladder`: [TeachMeAnatomy: The urinary bladder](https://teachmeanatomy.info/pelvis/viscera/bladder/)
- `tm-colon`: [TeachMeAnatomy: The colon](https://teachmeanatomy.info/abdomen/gi-tract/colon/)
- `nci-def-coccyx`: [NCI Dictionary: coccyx](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/coccyx)
- `nci-def-bone-marrow`: [NCI Dictionary: bone marrow](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/bone-marrow)
- `nhlbi-high-blood-pressure`: [NHLBI: High blood pressure](https://www.nhlbi.nih.gov/health/high-blood-pressure)
- `nhlbi-atherosclerosis`: [NHLBI: Atherosclerosis](https://www.nhlbi.nih.gov/health/atherosclerosis)
- `nhlbi-cardiomyopathy`: [NHLBI: Cardiomyopathy](https://www.nhlbi.nih.gov/health/cardiomyopathy)
- `nhlbi-congenital-heart-defects`: [NHLBI: Congenital heart defects](https://www.nhlbi.nih.gov/health/congenital-heart-defects)
- `nhlbi-sleep-apnea`: [NHLBI: Sleep apnea](https://www.nhlbi.nih.gov/health/sleep-apnea)
- `nhlbi-cystic-fibrosis`: [NHLBI: Cystic fibrosis](https://www.nhlbi.nih.gov/health/cystic-fibrosis)
- `nhlbi-ipf`: [NHLBI: Idiopathic pulmonary fibrosis](https://www.nhlbi.nih.gov/health/idiopathic-pulmonary-fibrosis)
- `mlp-collapsed-lung`: [MedlinePlus: Collapsed lung (pneumothorax)](https://medlineplus.gov/ency/article/000087.htm)
- `cdc-tb`: [CDC: About tuberculosis](https://www.cdc.gov/tb/about/index.html)
- `niddk-kidney-infection`: [NIDDK: Kidney infection (pyelonephritis)](https://www.niddk.nih.gov/health-information/urologic-diseases/kidney-infection-pyelonephritis)
- `niddk-bladder-control`: [NIDDK: Bladder control problems (urinary incontinence)](https://www.niddk.nih.gov/health-information/urologic-diseases/bladder-control-problems)
- `niddk-ibs`: [NIDDK: Definition & facts for irritable bowel syndrome](https://www.niddk.nih.gov/health-information/digestive-diseases/irritable-bowel-syndrome/definition-facts)
- `niddk-inguinal-hernia`: [NIDDK: Inguinal hernia](https://www.niddk.nih.gov/health-information/digestive-diseases/inguinal-hernia)
- `niddk-gastritis`: [NIDDK: Gastritis & gastropathy](https://www.niddk.nih.gov/health-information/digestive-diseases/gastritis-gastropathy)
- `niams-spinal-stenosis`: [NIAMS: Spinal stenosis](https://www.niams.nih.gov/health-topics/spinal-stenosis)
- `niams-ankylosing-spondylitis`: [NIAMS: Ankylosing spondylitis](https://www.niams.nih.gov/health-topics/ankylosing-spondylitis)
- `mlp-sciatica`: [MedlinePlus: Sciatica](https://medlineplus.gov/ency/article/000686.htm)
- `mlp-hip`: [MedlinePlus: Hip injuries and disorders](https://medlineplus.gov/hipinjuriesanddisorders.html)
- `mlp-osgood-schlatter`: [MedlinePlus: Osgood-Schlatter disease](https://medlineplus.gov/ency/article/001258.htm)
- `mlp-kneecap-dislocation`: [MedlinePlus: Kneecap dislocation - aftercare](https://medlineplus.gov/ency/patientinstructions/000585.htm)
- `mlp-hearing`: [MedlinePlus: Hearing disorders and deafness](https://medlineplus.gov/hearingdisordersanddeafness.html)
- `mlp-ear-infections`: [MedlinePlus: Ear infections](https://medlineplus.gov/earinfections.html)
- `mlp-sinusitis`: [MedlinePlus: Sinusitis](https://medlineplus.gov/sinusitis.html)
- `mlp-tmd`: [MedlinePlus: Temporomandibular disorders](https://medlineplus.gov/temporomandibulardisorders.html)
- `mlp-huntingtons`: [MedlinePlus: Huntington's disease](https://medlineplus.gov/huntingtonsdisease.html)
- `mlp-als`: [MedlinePlus: Amyotrophic lateral sclerosis (ALS)](https://medlineplus.gov/amyotrophiclateralsclerosis.html)
- `tm-descending-tracts`: [TeachMeAnatomy: The descending tracts](https://teachmeanatomy.info/neuroanatomy/pathways/descending-tracts-motor/)
- `tm-ascending-tracts`: [TeachMeAnatomy: The ascending tracts](https://teachmeanatomy.info/neuroanatomy/pathways/ascending-tracts-sensory/)
- `tm-midbrain`: [TeachMeAnatomy: The midbrain](https://teachmeanatomy.info/neuroanatomy/brainstem/midbrain/)
- `nei-refractive-errors`: [NEI: Refractive errors](https://www.nei.nih.gov/eye-health-information/eye-conditions-and-diseases/refractive-errors)
- `nci-lymphoma`: [NCI: Lymphoma—patient version](https://www.cancer.gov/types/lymphoma)
- `nci-leukemia`: [NCI: Leukemia—patient version](https://www.cancer.gov/types/leukemia)
- `nci-laryngeal-cancer`: [NCI: Laryngeal cancer treatment (PDQ)—patient version](https://www.cancer.gov/types/head-and-neck/patient/adult/laryngeal-treatment-pdq)
- `cdc-pid`: [CDC: About pelvic inflammatory disease (PID)](https://www.cdc.gov/pid/about/index.html)

Revision 14 adds:

- `tma-accessory-nerve`: [TeachMeAnatomy: The accessory nerve (CN XI)](https://teachmeanatomy.info/head/cranial-nerves/accessory/)
- `tma-anterior-triangle`: [TeachMeAnatomy: The anterior triangle of the neck](https://teachmeanatomy.info/neck/areas/anterior-triangle/)
- `tma-posterior-triangle`: [TeachMeAnatomy: The posterior triangle of the neck](https://teachmeanatomy.info/neck/areas/posterior-triangle/)
- `tma-infrahyoid`: [TeachMeAnatomy: The infrahyoid muscles](https://teachmeanatomy.info/neck/muscles/infrahyoid/)
- `tma-suprahyoid`: [TeachMeAnatomy: The suprahyoid muscles](https://teachmeanatomy.info/neck/muscles/suprahyoid-muscles/)
- `tma-prevertebral`: [TeachMeAnatomy: The prevertebral muscles of the neck](https://teachmeanatomy.info/neck/muscles/prevertebral/)
- `tma-neck-veins`: [TeachMeAnatomy: Venous drainage of the head and neck](https://teachmeanatomy.info/neck/vessels/venous-drainage/)
- `tma-neck-arteries`: [TeachMeAnatomy: Arterial supply of the head and neck](https://teachmeanatomy.info/neck/vessels/arterial-supply/)
- `tma-upper-limb-arteries`: [TeachMeAnatomy: Arterial supply to the upper limb](https://teachmeanatomy.info/upper-limb/vessels/arteries/)

Earlier revisions:

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
- `gas-exchange`: [NHLBI: Breathing and gas exchange](https://www.nhlbi.nih.gov/health/lungs/breathing-benefits)
- `heart-anatomy`: [NHLBI: Heart anatomy](https://www.nhlbi.nih.gov/health/heart/anatomy)
- `lungs`: [NHLBI: The respiratory system](https://www.nhlbi.nih.gov/health/lungs/respiratory-system)
- `nci-bladder-cancer`: [NCI: What is bladder cancer?](https://www.cancer.gov/types/bladder)
- `nci-cervical-cancer`: [NCI: What is cervical cancer?](https://www.cancer.gov/types/cervical)
- `nci-colorectal-cancer`: [NCI: Colorectal cancer — patient version](https://www.cancer.gov/types/colorectal)
- `nci-lung-cancer`: [NCI: Lung cancer — patient version](https://www.cancer.gov/types/lung)
- `nci-prostate-cancer`: [NCI: Prostate cancer — patient version](https://www.cancer.gov/types/prostate)
- `nci-skin-cancer`: [NCI: Skin cancer (including melanoma) — patient version](https://www.cancer.gov/types/skin)
- `nei-floaters`: [NEI: Floaters](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/floaters)
- `nei-pink-eye`: [NEI: Pink eye](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/pink-eye)
- `nei-retinal-detachment`: [NEI: Retinal detachment](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/retinal-detachment)
- `nei-uveitis`: [NEI: Uveitis](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/uveitis)
- `nhlbi-afib`: [NHLBI: Atrial fibrillation](https://www.nhlbi.nih.gov/health/atrial-fibrillation)
- `nhlbi-heart-attack`: [NHLBI: Heart attack](https://www.nhlbi.nih.gov/health/heart-attack)
- `nhlbi-heart-failure`: [NHLBI: Heart failure](https://www.nhlbi.nih.gov/health/heart-failure)
- `nhlbi-pneumonia`: [NHLBI: Pneumonia](https://www.nhlbi.nih.gov/health/pneumonia)
- `niams-atopic-dermatitis`: [NIAMS: Atopic dermatitis (eczema)](https://www.niams.nih.gov/health-topics/atopic-dermatitis)
- `niams-osteoporosis`: [NIAMS: Osteoporosis](https://www.niams.nih.gov/health-topics/osteoporosis)
- `niams-psoriasis`: [NIAMS: Psoriasis](https://www.niams.nih.gov/health-topics/psoriasis)
- `nichd-fibroids`: [NICHD: Uterine fibroids](https://www.nichd.nih.gov/health/topics/uterine)
- `nichd-pcos`: [NICHD: Polycystic ovary syndrome (PCOS)](https://www.nichd.nih.gov/health/topics/pcos)
- `niddk-bladder-infection`: [NIDDK: Definition & facts of bladder infection in adults](https://www.niddk.nih.gov/health-information/urologic-diseases/bladder-infection-uti-in-adults/definition-facts)
- `niddk-celiac`: [NIDDK: Definition & facts for celiac disease](https://www.niddk.nih.gov/health-information/digestive-diseases/celiac-disease/definition-facts)
- `niddk-ckd`: [NIDDK: Chronic kidney disease](https://www.niddk.nih.gov/health-information/kidney-disease/chronic-kidney-disease-ckd)
- `niddk-crohns`: [NIDDK: Definition & facts for Crohn's disease](https://www.niddk.nih.gov/health-information/digestive-diseases/crohns-disease/definition-facts)
- `niddk-diabetes`: [NIDDK: What is diabetes?](https://www.niddk.nih.gov/health-information/diabetes/overview/what-is-diabetes)
- `niddk-diverticular`: [NIDDK: Definition & facts for diverticular disease](https://www.niddk.nih.gov/health-information/digestive-diseases/diverticulosis-diverticulitis/definition-facts)
- `niddk-hemorrhoids`: [NIDDK: Definition & facts of hemorrhoids](https://www.niddk.nih.gov/health-information/digestive-diseases/hemorrhoids/definition-facts)
- `niddk-nafld`: [NIDDK: Definition & facts of NAFLD & NASH](https://www.niddk.nih.gov/health-information/liver-disease/nafld-nash/definition-facts)
- `niddk-ulcerative-colitis`: [NIDDK: Definition & facts for ulcerative colitis](https://www.niddk.nih.gov/health-information/digestive-diseases/ulcerative-colitis/definition-facts)
- `niddk-viral-hepatitis`: [NIDDK: What is viral hepatitis?](https://www.niddk.nih.gov/health-information/liver-disease/viral-hepatitis/what-is-viral-hepatitis)
- `pulmonary-branches`: [NCBI Bookshelf: Pulmonary arteries](https://www.ncbi.nlm.nih.gov/books/NBK534812/)
- `seer-bone-tissue`: [NCI SEER Training: Structure of bone tissue](https://training.seer.cancer.gov/anatomy/skeletal/tissue.html)
- `seer-larynx`: [NCI SEER Training: Larynx and trachea](https://training.seer.cancer.gov/anatomy/respiratory/passages/larynx.html)
- `seer-lower-muscles`: [NCI SEER Training: Muscles of the lower extremity](https://training.seer.cancer.gov/anatomy/muscular/groups/lower.html)
- `seer-lymph-nodes`: [NCI SEER Training: Lymph nodes](https://training.seer.cancer.gov/anatomy/lymphatic/components/nodes.html)
- `seer-pathways`: [NCI SEER Training: Circulatory pathways](https://training.seer.cancer.gov/anatomy/cardiovascular/blood/pathways.html)
- `seer-skin`: [NCI SEER Training: Anatomy of the skin](https://training.seer.cancer.gov/melanoma/anatomy/)
- `valve-disease-types`: [NHLBI: Types of heart valve disease](https://www.nhlbi.nih.gov/health/heart-valve-diseases/types)
- `mlp-hydrocephalus`: [MedlinePlus: Hydrocephalus](https://medlineplus.gov/hydrocephalus.html)
- `mlp-meningitis`: [MedlinePlus: Meningitis](https://medlineplus.gov/meningitis.html)
- `mlp-tbi`: [MedlinePlus: Traumatic brain injury](https://medlineplus.gov/traumaticbraininjury.html)
- `nci-brain-tumors`: [NCI: Brain tumors — patient version](https://www.cancer.gov/types/brain)
- `nci-def-broad-ligament`: [NCI Dictionary of Cancer Terms: broad ligament](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/broad-ligament)
- `nci-def-carina-of-trachea`: [NCI Dictionary of Cancer Terms: carina of trachea](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/carina-of-trachea)
- `nci-def-cerebrospinal-fluid`: [NCI Dictionary of Cancer Terms: cerebrospinal fluid](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/cerebrospinal-fluid)
- `nci-def-conjunctiva`: [NCI Dictionary of Cancer Terms: conjunctiva](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/conjunctiva)
- `nci-def-dura-mater`: [NCI Dictionary of Cancer Terms: dura mater](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/dura-mater)
- `nci-def-fundus`: [NCI Dictionary of Cancer Terms: fundus](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/fundus)
- `nci-def-hepatic-artery`: [NCI Dictionary of Cancer Terms: hepatic artery](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/hepatic-artery)
- `nci-def-meninges`: [NCI Dictionary of Cancer Terms: meninges](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/meninges)
- `nci-def-olfactory-bulb`: [NCI Dictionary of Cancer Terms: olfactory bulb](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/olfactory-bulb)
- `nci-def-optic-chiasm`: [NCI Dictionary of Cancer Terms: optic chiasm](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/optic-chiasm)
- `nci-def-pancreatic-duct`: [NCI Dictionary of Cancer Terms: pancreatic duct](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/pancreatic-duct)
- `nci-def-pelvis`: [NCI Dictionary of Cancer Terms: pelvis](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/pelvis)
- `nci-def-pineal-gland`: [NCI Dictionary of Cancer Terms: pineal gland](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/pineal-gland)
- `nci-def-sclera`: [NCI Dictionary of Cancer Terms: sclera](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/sclera)
- `nci-def-ventricle`: [NCI Dictionary of Cancer Terms: ventricle](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/ventricle)
- `nci-kidney-cancer`: [NCI: Kidney (renal cell) cancer — patient version](https://www.cancer.gov/types/kidney)
- `nci-liver-cancer`: [NCI: Liver and bile duct cancer](https://www.cancer.gov/types/liver)
- `nci-ovarian-cancer`: [NCI: Ovarian, fallopian tube, and primary peritoneal cancer — patient version](https://www.cancer.gov/types/ovarian)
- `nci-pancreatic-cancer`: [NCI: Pancreatic cancer](https://www.cancer.gov/types/pancreatic)
- `nci-uterine-cancer`: [NCI: Uterine cancer](https://www.cancer.gov/types/uterine)
- `nhlbi-pulmonary-hypertension`: [NHLBI: Pulmonary hypertension](https://www.nhlbi.nih.gov/health/pulmonary-hypertension)
- `niddk-lactose-intolerance`: [NIDDK: Definition & facts for lactose intolerance](https://www.niddk.nih.gov/health-information/digestive-diseases/lactose-intolerance/definition-facts)
- `niddk-pkd`: [NIDDK: What is polycystic kidney disease?](https://www.niddk.nih.gov/health-information/kidney-disease/polycystic-kidney-disease/what-is-pkd)
- `mlp-dvt`: [MedlinePlus: Deep vein thrombosis](https://medlineplus.gov/deepveinthrombosis.html)
- `mlp-ectopic-pregnancy`: [MedlinePlus: Ectopic pregnancy](https://medlineplus.gov/ectopicpregnancy.html)
- `mlp-eyelid-disorders`: [MedlinePlus: Eyelid disorders](https://medlineplus.gov/eyeliddisorders.html)
- `mlp-laryngitis`: [MedlinePlus Medical Encyclopedia: Laryngitis](https://medlineplus.gov/ency/article/001385.htm)
- `mlp-male-infertility`: [MedlinePlus: Male infertility](https://medlineplus.gov/maleinfertility.html)
- `mlp-migraine`: [MedlinePlus: Migraine](https://medlineplus.gov/migraine.html)
- `mlp-ms`: [MedlinePlus: Multiple sclerosis](https://medlineplus.gov/multiplesclerosis.html)
- `mlp-ovarian-cysts`: [MedlinePlus: Ovarian cysts](https://medlineplus.gov/ovariancysts.html)
- `mlp-pelvic-support`: [MedlinePlus: Pelvic support problems](https://medlineplus.gov/pelvicsupportproblems.html)
- `mlp-retinal-artery-occlusion`: [MedlinePlus Medical Encyclopedia: Retinal artery occlusion](https://medlineplus.gov/ency/article/001028.htm)
- `mlp-spleen-diseases`: [MedlinePlus: Spleen diseases](https://medlineplus.gov/spleendiseases.html)
- `mlp-strabismus`: [MedlinePlus Medical Encyclopedia: Strabismus](https://medlineplus.gov/ency/article/001004.htm)
- `mlp-urethral-disorders`: [MedlinePlus: Urethral disorders](https://medlineplus.gov/urethraldisorders.html)
- `mlp-voice-disorders`: [MedlinePlus: Voice disorders](https://medlineplus.gov/voicedisorders.html)
- `nci-bile-duct-cancer`: [NCI: What is bile duct cancer (cholangiocarcinoma)?](https://www.cancer.gov/types/liver/bile-duct-cancer)
- `nci-def-bile-duct`: [NCI Dictionary of Cancer Terms: bile duct](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/bile-duct)
- `nci-def-coronary-artery-disease`: [NCI Dictionary of Cancer Terms: coronary artery disease](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/coronary-artery-disease)
- `nci-def-inferior-vena-cava`: [NCI Dictionary of Cancer Terms: inferior vena cava](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/inferior-vena-cava)
- `nci-def-seminal-vesicle`: [NCI Dictionary of Cancer Terms: seminal vesicle](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/seminal-vesicle)
- `nci-def-ureter`: [NCI Dictionary of Cancer Terms: ureter](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/ureter)
- `nci-def-urethra`: [NCI Dictionary of Cancer Terms: urethra](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/urethra)
- `nci-def-vas-deferens`: [NCI Dictionary of Cancer Terms: vas deferens](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/vas-deferens)
- `nci-def-vocal-cord`: [NCI Dictionary of Cancer Terms: vocal cord](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/vocal-cord)
- `niddk-prostatitis`: [NIDDK: Prostatitis: inflammation of the prostate](https://www.niddk.nih.gov/health-information/urologic-diseases/prostate-problems/prostatitis-inflammation-prostate)
- `tm-abdominal-veins`: [TeachMeAnatomy: Venous drainage of the abdomen](https://teachmeanatomy.info/abdomen/vasculature/venous-drainage/)
- `tm-coeliac-trunk`: [TeachMeAnatomy: The coeliac trunk](https://teachmeanatomy.info/abdomen/vasculature/arteries/coeliac-trunk/)
- `tm-coronary`: [TeachMeAnatomy: Coronary arteries and veins](https://teachmeanatomy.info/thorax/organs/heart/heart-vasculature/)
- `tm-extraocular`: [TeachMeAnatomy: The extraocular muscles](https://teachmeanatomy.info/head/organs/eye/extraocular-muscles/)
- `tm-eyeball`: [TeachMeAnatomy: The eyeball - structure - vasculature](https://teachmeanatomy.info/head/organs/eye/eyeball/)
- `tm-gallbladder`: [TeachMeAnatomy: The gallbladder - biliary tree](https://teachmeanatomy.info/abdomen/viscera/gallbladder/)
- `tm-hyoid`: [TeachMeAnatomy: The hyoid bone](https://teachmeanatomy.info/neck/bones/hyoid-bone/)
- `tm-ima`: [TeachMeAnatomy: The inferior mesenteric artery](https://teachmeanatomy.info/abdomen/vasculature/arteries/inferior-mesenteric/)
- `tm-knee`: [TeachMeAnatomy: The knee joint](https://teachmeanatomy.info/lower-limb/joints/knee-joint/)
- `tm-larynx-folds`: [TeachMeAnatomy: Laryngeal ligaments and folds](https://teachmeanatomy.info/neck/viscera/larynx/ligaments-folds/)
- `tm-larynx-muscles`: [TeachMeAnatomy: Muscles of the larynx](https://teachmeanatomy.info/neck/viscera/larynx/muscles/)
- `tm-liver`: [TeachMeAnatomy: The liver](https://teachmeanatomy.info/abdomen/viscera/liver/)
- `tm-ovaries`: [TeachMeAnatomy: The ovaries](https://teachmeanatomy.info/pelvis/female-reproductive-tract/ovaries/)
- `tm-patella`: [TeachMeAnatomy: The patella](https://teachmeanatomy.info/lower-limb/bones/patella/)
- `tm-pelvic-veins`: [TeachMeAnatomy: The pelvic veins](https://teachmeanatomy.info/pelvis/vasculature/venous-drainage/)
- `tm-rectum`: [TeachMeAnatomy: The rectum](https://teachmeanatomy.info/abdomen/gi-tract/rectum/)
- `tm-seminal-vesicles`: [TeachMeAnatomy: The seminal vesicles](https://teachmeanatomy.info/pelvis/the-male-reproductive-system/seminal-vesicles/)
- `tm-sma`: [TeachMeAnatomy: The superior mesenteric artery](https://teachmeanatomy.info/abdomen/vasculature/arteries/superior-mesenteric/)
- `tm-spermatic-cord`: [TeachMeAnatomy: The spermatic cord](https://teachmeanatomy.info/pelvis/the-male-reproductive-system/spermatic-cord/)
- `tm-spleen`: [TeachMeAnatomy: The spleen](https://teachmeanatomy.info/abdomen/viscera/spleen/)
- `tm-svc`: [TeachMeAnatomy: The superior vena cava](https://teachmeanatomy.info/thorax/vasculature/superior-vena-cava/)
- `tm-tracheobronchial`: [TeachMeAnatomy: The tracheobronchial tree](https://teachmeanatomy.info/thorax/organs/tracheobronchial-tree/)
- `tm-urethra`: [TeachMeAnatomy: The urethra](https://teachmeanatomy.info/pelvis/viscera/urethra/)
- `tm-uterus`: [TeachMeAnatomy: The uterus](https://teachmeanatomy.info/pelvis/female-reproductive-tract/uterus/)
- `nci-def-prostate`: [NCI Dictionary of Cancer Terms: prostate](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/prostate)
- `nci-def-trachea`: [NCI Dictionary of Cancer Terms: trachea](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/trachea)
- `mlp-carotid`: [MedlinePlus: Carotid artery disease](https://medlineplus.gov/carotidarterydisease.html)
- `mlp-carpal-tunnel`: [MedlinePlus: Carpal tunnel syndrome](https://medlineplus.gov/carpaltunnelsyndrome.html)
- `mlp-herniated-disk`: [MedlinePlus: Herniated disk](https://medlineplus.gov/herniateddisk.html)
- `mlp-hiatal-hernia`: [MedlinePlus: Hiatal hernia](https://medlineplus.gov/hiatalhernia.html)
- `mlp-hiccups`: [MedlinePlus Medical Encyclopedia: Hiccups](https://medlineplus.gov/ency/article/003068.htm)
- `mlp-pituitary-tumors`: [MedlinePlus: Pituitary tumors](https://medlineplus.gov/pituitarytumors.html)
- `mlp-rotator-cuff`: [MedlinePlus: Rotator cuff injuries](https://medlineplus.gov/rotatorcuffinjuries.html)
- `mlp-salivary`: [MedlinePlus: Salivary gland disorders](https://medlineplus.gov/salivaryglanddisorders.html)
- `mlp-spinal-cord-injury`: [MedlinePlus: Spinal cord injury](https://medlineplus.gov/spinalcordinjuries.html)
- `mlp-sprains-strains`: [MedlinePlus: Sprains and strains](https://medlineplus.gov/sprainsandstrains.html)
- `mlp-tooth-decay`: [MedlinePlus: Tooth decay](https://medlineplus.gov/toothdecay.html)
- `nci-def-adrenal-gland`: [NCI Dictionary of Cancer Terms: adrenal gland](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/adrenal-gland)
- `nci-def-carotid-artery`: [NCI Dictionary of Cancer Terms: carotid artery](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/carotid-artery)
- `nci-def-clavicle`: [NCI Dictionary of Cancer Terms: clavicle](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/clavicle)
- `nci-def-diaphragm`: [NCI Dictionary of Cancer Terms: diaphragm](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/diaphragm)
- `nci-def-epididymis`: [NCI Dictionary of Cancer Terms: epididymis](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/epididymis)
- `nci-def-esophagus`: [NCI Dictionary of Cancer Terms: esophagus](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/esophagus)
- `nci-def-mandible`: [NCI Dictionary of Cancer Terms: mandible](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/mandible)
- `nci-def-maxilla`: [NCI Dictionary of Cancer Terms: maxilla](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/maxilla)
- `nci-def-penis`: [NCI Dictionary of Cancer Terms: penis](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/penis)
- `nci-def-pharynx`: [NCI Dictionary of Cancer Terms: pharynx](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/pharynx)
- `nci-def-pituitary-gland`: [NCI Dictionary of Cancer Terms: pituitary gland](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/pituitary-gland)
- `nci-def-sacrum`: [NCI Dictionary of Cancer Terms: sacrum](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/sacrum)
- `nci-def-scapula`: [NCI Dictionary of Cancer Terms: scapula](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/scapula)
- `nci-def-skull`: [NCI Dictionary of Cancer Terms: skull](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/skull)
- `nci-def-soft-palate`: [NCI Dictionary of Cancer Terms: soft palate](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/soft-palate)
- `nci-def-spinal-cord`: [NCI Dictionary of Cancer Terms: spinal cord](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/spinal-cord)
- `nci-def-spine`: [NCI Dictionary of Cancer Terms: spine](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/spine)
- `nci-def-sternum`: [NCI Dictionary of Cancer Terms: sternum](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/sternum)
- `nci-def-stomach`: [NCI Dictionary of Cancer Terms: stomach](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/stomach)
- `nci-def-testicle`: [NCI Dictionary of Cancer Terms: testicle](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/testicle)
- `nci-esophageal-cancer`: [NCI: Esophageal cancer](https://www.cancer.gov/types/esophageal)
- `nci-oral-cancer`: [NCI: Lip and oral cavity cancer treatment (PDQ) - patient version](https://www.cancer.gov/types/head-and-neck/patient/adult/lip-mouth-treatment-pdq)
- `nci-stomach-cancer`: [NCI: What is stomach cancer?](https://www.cancer.gov/types/stomach)
- `nci-testicular-cancer`: [NCI: Testicular cancer](https://www.cancer.gov/types/testicular)
- `nhlbi-pad`: [NHLBI: Peripheral artery disease](https://www.nhlbi.nih.gov/health/peripheral-artery-disease)
- `niams-back-pain`: [NIAMS: Back pain](https://www.niams.nih.gov/health-topics/back-pain)
- `niams-gout`: [NIAMS: Gout](https://www.niams.nih.gov/health-topics/gout)
- `niams-ra`: [NIAMS: Rheumatoid arthritis](https://www.niams.nih.gov/health-topics/rheumatoid-arthritis)
- `niams-scoliosis`: [NIAMS: Scoliosis](https://www.niams.nih.gov/health-topics/scoliosis)
- `niddk-adrenal-insufficiency`: [NIDDK: Adrenal insufficiency and Addison's disease](https://www.niddk.nih.gov/health-information/endocrine-diseases/adrenal-insufficiency-addisons-disease)
- `niddk-cushings`: [NIDDK: Cushing's syndrome](https://www.niddk.nih.gov/health-information/endocrine-diseases/cushings-syndrome)
- `niddk-ed`: [NIDDK: Definition and facts for erectile dysfunction](https://www.niddk.nih.gov/health-information/urologic-diseases/erectile-dysfunction/definition-facts)
- `niddk-gerd`: [NIDDK: Definition and facts for GER and GERD](https://www.niddk.nih.gov/health-information/digestive-diseases/acid-reflux-ger-gerd-adults/definition-facts)
- `niddk-peptic-ulcer`: [NIDDK: Definition and facts for peptic ulcers](https://www.niddk.nih.gov/health-information/digestive-diseases/peptic-ulcers-stomach-ulcers/definition-facts)
- `seer-adrenal`: [NCI SEER Training: Adrenal gland](https://training.seer.cancer.gov/anatomy/endocrine/glands/adrenal.html)
- `seer-appendicular`: [NCI SEER Training: Appendicular skeleton](https://training.seer.cancer.gov/anatomy/skeletal/divisions/appendicular.html)
- `seer-axial`: [NCI SEER Training: Axial skeleton](https://training.seer.cancer.gov/anatomy/skeletal/divisions/axial.html)
- `seer-male-duct`: [NCI SEER Training: Male duct system](https://training.seer.cancer.gov/anatomy/reproductive/male/duct.html)
- `seer-mechanics`: [NCI SEER Training: Mechanics of ventilation](https://training.seer.cancer.gov/anatomy/respiratory/mechanics.html)
- `seer-mouth`: [NCI SEER Training: Mouth](https://training.seer.cancer.gov/anatomy/digestive/regions/mouth.html)
- `seer-muscles-head-neck`: [NCI SEER Training: Muscles of the head and neck](https://training.seer.cancer.gov/anatomy/muscular/groups/head_neck.html)
- `seer-muscles-trunk`: [NCI SEER Training: Muscles of the trunk](https://training.seer.cancer.gov/anatomy/muscular/groups/trunk.html)
- `seer-muscles-upper`: [NCI SEER Training: Muscles of the upper extremity](https://training.seer.cancer.gov/anatomy/muscular/groups/upper.html)
- `seer-nose`: [NCI SEER Training: Nose, nasal cavities and paranasal sinuses](https://training.seer.cancer.gov/anatomy/respiratory/passages/nose.html)
- `seer-penis`: [NCI SEER Training: Penis](https://training.seer.cancer.gov/anatomy/reproductive/male/penis.html)
- `seer-pharynx`: [NCI SEER Training: Pharynx and esophagus](https://training.seer.cancer.gov/anatomy/digestive/regions/pharynx.html)
- `seer-pituitary`: [NCI SEER Training: Pituitary and pineal glands](https://training.seer.cancer.gov/anatomy/endocrine/glands/pituitary.html)
- `seer-stomach`: [NCI SEER Training: Stomach](https://training.seer.cancer.gov/anatomy/digestive/regions/stomach.html)
- `seer-testes`: [NCI SEER Training: Testes](https://training.seer.cancer.gov/anatomy/reproductive/male/testes.html)
- `tm-radius`: [TeachMeAnatomy: The radius](https://teachmeanatomy.info/upper-limb/bones/radius/)
- `tm-ulna`: [TeachMeAnatomy: The ulna](https://teachmeanatomy.info/upper-limb/bones/ulna/)
- `mlp-breast-diseases`: [MedlinePlus: Breast diseases](https://medlineplus.gov/breastdiseases.html)
- `mlp-thyroid-nodules`: [MedlinePlus Medical Encyclopedia: Thyroid nodule](https://medlineplus.gov/ency/article/007265.htm)
- `mlp-tonsillitis`: [MedlinePlus: Tonsillitis](https://medlineplus.gov/tonsillitis.html)
- `nci-breast-cancer`: [NCI: Breast cancer](https://www.cancer.gov/types/breast)
- `nci-def-areola`: [NCI Dictionary of Cancer Terms: areola](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/areola)
- `nci-def-breast`: [NCI Dictionary of Cancer Terms: breast](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/breast)
- `nci-def-nipple`: [NCI Dictionary of Cancer Terms: nipple](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/nipple)
- `nci-def-parathyroid-gland`: [NCI Dictionary of Cancer Terms: parathyroid gland](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/parathyroid-gland)
- `nci-def-thyroid`: [NCI Dictionary of Cancer Terms: thyroid](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/thyroid)
- `nci-def-tonsil`: [NCI Dictionary of Cancer Terms: tonsil](https://www.cancer.gov/publications/dictionaries/cancer-terms/def/tonsil)
- `nci-thyroid-cancer`: [NCI: Thyroid cancer - patient version](https://www.cancer.gov/types/thyroid)
- `niddk-graves`: [NIDDK: Graves' disease](https://www.niddk.nih.gov/health-information/endocrine-diseases/graves-disease)
- `niddk-hashimotos`: [NIDDK: Hashimoto's disease](https://www.niddk.nih.gov/health-information/endocrine-diseases/hashimotos-disease)
- `niddk-hyperparathyroidism`: [NIDDK: Primary hyperparathyroidism](https://www.niddk.nih.gov/health-information/endocrine-diseases/primary-hyperparathyroidism)
- `niddk-hyperthyroidism`: [NIDDK: Hyperthyroidism (overactive thyroid)](https://www.niddk.nih.gov/health-information/endocrine-diseases/hyperthyroidism)
- `niddk-hypothyroidism`: [NIDDK: Hypothyroidism (underactive thyroid)](https://www.niddk.nih.gov/health-information/endocrine-diseases/hypothyroidism)
- `seer-thyroid`: [NCI SEER Training: Thyroid and parathyroid glands](https://training.seer.cancer.gov/anatomy/endocrine/glands/thyroid.html)
- `seer-tonsils`: [NCI SEER Training: Tonsils](https://training.seer.cancer.gov/anatomy/lymphatic/components/tonsils.html)
