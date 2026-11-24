# Organs, bones and muscles traced from the Visible Human CT

Date: 2026-11-23. Assistant technical check, not anatomical review.

## What was added

The female and male HRA bodies lacked a stomach, oesophagus, thyroid, adrenal glands,
rib cage and trunk muscles. They were made from the Visible Human donors, whose CT
scans the U.S. National Library of Medicine publishes, so these parts were traced from
the same donors' scans with the method used for [the parotid glands](VHP_PAROTID.md).

| Part | Female | Male |
|---|---|---|
| Stomach, oesophagus, thyroid gland | added | added |
| Left and right adrenal glands | added | added |
| 24 ribs and the costal cartilages | added | added |
| Sternum | added | added |
| Gluteus medius and minimus, both sides | added | added |
| Gluteus maximus, both sides | added | left out (cut off, see below) |
| Iliopsoas, both sides | added | added |
| Deep back muscles (erector spinae and transversospinalis), both sides | added | added |

These parts unlock 12 existing conditions on both bodies: GERD, peptic ulcer, stomach
cancer, oesophageal cancer, adrenal insufficiency, Cushing's syndrome and the six
thyroid conditions. Hiatal hernia still needs the diaphragm, which was not traced.

## Method

Scripts in [tools/vhp_parotid](../../tools/vhp_parotid); work files in
`build/parotid-work/` (not committed).

1. **Scans.** Every "normal" CT slice was downloaded (male 522 listed, one,
   `c_vm1557`, absent on the server; female 1,734). Each series is a head-to-thigh
   pass followed by leg passes whose table coordinates restart, so only the first
   continuous pass is used: about 984 mm from the top of the head for the female and
   955 mm for the male. Female slices are 1 mm; male torso slices are 3-6 mm.
2. **Sections.** `build_region.py` stacks overlapping depth ranges (female 0-330,
   230-630, 480-860 and 700-984 mm; male the same with 680-955) at 1.5 mm, placing
   each slice by its header corner coordinates.
3. **Tracing.** TotalSegmentator 2.18.0, `total` task (free, Apache 2.0) on CPU, for
   the target parts and for anchor structures. Usage statistics were switched off.
   `merge.py` joins the sections; where they overlap, a voxel traced in either is kept.
4. **Fitting.** `build_body_parts.py` fits each region separately with a similarity
   transform from shared structures, refined by surface ICP. Vertebrae are paired by
   position after an initial fit, which handles the female's sixth lumbar vertebra.

   | Region | Anchors | Parts |
   |---|---|---|
   | Thorax | C6-T12, five lung lobes, heart, trachea | thyroid, oesophagus, ribs, cartilages, sternum |
   | Abdomen | T10-L3 (where paired), liver, spleen, kidneys, pancreas | stomach, adrenal glands |
   | Spine | every paired vertebra | deep back muscles |
   | Pelvis | lowest lumbar vertebrae, sacrum, both hip bones | gluteal muscles, iliopsoas |

   The femurs are not anchors: the first pass ends mid-thigh, so the traced femurs are
   partial and biased the scale.
5. **Meshing.** `mesh.py`: specks under 5% of the largest piece removed, holes closed,
   Gaussian smoothing, marching cubes, Taubin smoothing over the edge graph (trimesh's
   own filters threw vertices far away at non-manifold edges), gentle simplification
   with a needle-triangle guard, outward winding.

## Fit results

| Body, region | Scale | Median surface distance |
|---|---|---|
| Female thorax | 1.011 | 1.0-2.0 mm on vertebrae; 2.3-6.6 mm on lungs, heart, trachea |
| Female abdomen | 1.005 | 0.9-3.2 mm |
| Female spine | 0.996 | 0.7-1.5 mm |
| Female pelvis | 1.040 | 0.8-2.1 mm |
| Male thorax | 0.979 | 1.0-2.4 mm on vertebrae; up to 4.3 mm on lungs |
| Male abdomen | 0.971 | 1.4-2.6 mm |
| Male spine | 0.978 | 0.7-2.5 mm |
| Male pelvis | 1.018 | 1.7-2.0 mm |

Scales near 1 are expected because each scan and body come from the same donor. The
male lower thoracic and lumbar vertebrae (T10-L4) did not pair within 15 mm, probably
because of the 3-6 mm male torso slices; the male abdomen fit therefore uses organs only.

## Checks

`check.py` samples 400 vertices per part and reports the share outside the body's skin
and inside existing organs (signed by the nearest face normal).

- **Outside the skin:** 0% for every organ, rib and the sternum; 1-7% for the deep back
  and gluteal muscles at their thin edges.
- **Inside existing organs:** mostly 5-14% at contact surfaces (stomach against liver
  and spleen, gluteus minimus against the hip bone).
- **Ribs and lungs:** ribs overlap the body's lungs by up to 65% (female) and 41%
  (male). Renders show the ribs correctly placed and the lungs bulging between them:
  the body's lungs, from frozen sections, are fuller than in the CT taken before
  freezing. Left as is.
- **Male right adrenal gland:** 26% inside the liver; it is a 4 cm³ gland pressed
  against the liver, and renders show it on top of the right kidney.

Renders: [female front](vhp-ct/female-front.png), [female back](vhp-ct/female-back.png),
[male front](vhp-ct/male-front.png), [male back](vhp-ct/male-back.png).

## Left out after review

- **Shoulder blades, collarbones and upper-arm bones:** 20-42% of each fell outside the
  body's skin. The shoulders are posed differently in the scans, and the body has no
  shoulder or arm bones to anchor them.
- **Skull:** the fit was correct (the eyes sit in the orbits), but the scans' field of
  view cuts the front of the face, so the upper jaw is missing and the thin facial
  bones are rough. The complete male body keeps its BodyParts3D skull.
- **Male gluteus maximus:** cut off where the male first pass ends.

## Second round: head, neck and trunk muscles, jaw, diaphragm and shoulders

Date: 2026-11-24. Assistant technical check, not anatomical review. Segmentation was
started on the Linux host and finished on Windows with the same TotalSegmentator
2.18.0 (CPU); the round-1 files above were kept byte for byte.

| Part | Female | Male |
|---|---|---|
| Submandibular glands | added | left out (26-43% outside the skin) |
| Tongue, mandible | added | added |
| Masseter, medial and lateral pterygoids | added | added |
| Temporalis | left out (12/22% outside the skin) | added |
| Anterior, middle and posterior scalenes | added | added |
| Sternocleidomastoid | left out (26/62% outside) | left out (16/32% outside) |
| Inferior pharyngeal constrictor | added | added |
| Superior and middle pharyngeal constrictors | left out (fragments) | left out (fragments) |
| Hyoid bone | added | not traced: the body has its own |
| Serratus anterior, latissimus dorsi | added | added |
| Pectoralis major | left out (24/17% outside; misfit) | added |
| Trapezius | left out (fragments) | left out (traced beside the spine only) |
| Rectus abdominis, external and internal obliques | added | added |
| Quadratus lumborum | added | added |
| Diaphragm | added | added |
| Scapulae and clavicles | added | added |
| Humeri | added | left out (cut off by the field of view) |

The new cards (muscles of mastication, scalenes, serratus anterior, latissimus dorsi,
rectus abdominis, abdominal obliques, quadratus lumborum) and the existing tongue,
mandible, hyoid, salivary-gland, pharynx-muscle, pectoralis, diaphragm, scapula,
clavicle and humerus cards map to these parts. Hiatal hernia, hiccups and oral cancer
are now offered on both bodies, and rotator-cuff and salivary disorders on the female.

### Method additions

- **Tasks.** Free TotalSegmentator tasks beyond `total`: `head_muscles` and
  `craniofacial_structures` on the 0.75 mm head volume; `headneck_muscles` and
  `headneck_bones_vessels` on the 0-330 mm section; `abdominal_muscles` and
  `trunk_cavities` on the three upper 1.5 mm sections, merged as before. Each
  supplement record names its group's task.
- **Diaphragm.** No free task traces it. `diaphragm.py` takes the sheet where the
  traced thoracic and abdominal cavities meet (voxels within 4 mm of both): female
  180 cm3, male 309 cm3. Its openings and crura are therefore not shown.
- **Shoulders.** `shoulder_fit.py` refines the thorax fit per side and per bone group
  by a rigid ICP of the scan's skin near the bones onto the body's skin. Median skin
  distance fell from 16-26 mm to 4.6-7.4 mm, with rotations of 9-24 degrees. Round 1
  had left these bones out at 20-42% outside the skin; after the fit they are 0-7%.
- **Review rule.** As in round 1, a part with 20% or more of its sampled vertices
  outside the skin is left out, with both sides of a pair left out together; renders
  decided the fragmentary or cut-off parts.

### Checks

- **Outside the skin**, after the exclusions: 0% for most parts; female masseter 1/12%,
  tongue 10%, submandibular glands 6/14%, external and internal obliques up to 18%
  and 9% on the left; male mandible and right pectoralis major 4%. Superficial muscles
  sit just under the skin, so a few millimetres of fit error shows here first.
- **Inside existing organs:** female clavicles 31-49% inside the body's lungs and the
  diaphragm 14% inside lungs and liver; male diaphragm 34% inside the lungs. As with
  the ribs, the body's frozen-section lungs are fuller than in the CT. The male right
  latissimus dorsi and obliques are 12-14% inside the right kidney, at its contact with
  the body wall.
- **Small parts:** the posterior scalenes are about 1 cm3 (thin slips at 1.5 mm);
  the female hyoid 1.2 cm3. The female right humerus kept its unsimplified mesh
  (33,000 faces) because simplification left needle triangles.

Renders: [female front](vhp-ct/female-round2-front.png),
[female back](vhp-ct/female-round2-back.png), [male front](vhp-ct/male-round2-front.png),
[male back](vhp-ct/male-round2-back.png).

### Possible follow-up

The neck muscles were re-traced at 0.75 mm afterwards (next section). The
sternocleidomastoid and trapezius might still trace better with a neck-specific fit;
the skull remains left out.

## Neck muscles re-traced at 0.75 mm

Date: 2026-11-24. Assistant technical check, not anatomical review.

`headneck_muscles` resamples its input to 0.75 x 0.75 x 1.0 mm and crops it to the
clavicles and vertebrae C1-T4. Round 2 gave it the 1.5 mm 0-330 mm section, and the
260 mm parotid head volumes stop 45 mm (female) and 70 mm (male) above the lowest
neck muscles. `build_volume.py` therefore built a taller volume from the same slices:
400 mm from the top of the scan, 360 mm wide, 0.75 mm voxels (female z -38 to -439 mm,
male 390 to -12 mm). The female slices are 1 mm apart throughout; the male slices are
1 mm apart down to about z 220 mm and 3 mm apart below, so the male lower neck is
interpolated vertically as before. The masks use the same scanner coordinates, so the
skull fit is unchanged.

**Result.** The traced muscles are essentially the same as in round 2: each volume is
within 5% of its 1.5 mm trace, with the same extent. The model already worked at
0.75 mm internally; the gain is the 0.75 mm output grid, which the meshes now follow.
A few specks at the bottom edge of the crop are dropped by the 5% rule in `mesh.py`.

| Part | Female | Male |
|---|---|---|
| Anterior, middle and posterior scalenes | re-meshed; 0% outside the skin | re-meshed; 0% outside the skin |
| Inferior pharyngeal constrictor | re-meshed (3.3 cm3); 0% outside | re-meshed (4.9 cm3); 0% outside |
| Superior and middle pharyngeal constrictors | still left out: 0.1 and 0.6 cm3 in separate pieces | added: 0.7 and 2.9 cm3, single pieces continuous with the inferior constrictor, 0% outside the skin |
| Sternocleidomastoid | still left out (28/55% outside the skin) | still left out (20/35% outside) |

The sternocleidomastoid barely changed (round 2: 26/62% and 16/32%), so its misfit
comes from the fit or neck pose rather than resolution; a neck-specific fit is the next
thing to try. The female anterior scalenes remain 11-12% inside the lung apices, and
the posterior scalenes about 1-1.5 cm3. Other muscles this task traces (levator
scapulae, sternothyroid, thyrohyoid, platysma, prevertebral muscles) are not added;
the trapezius comes from `abdominal_muscles` and reaches beyond this volume.

The two new male nodes move the male catalogue IDs of the CT parts after the
constrictors by two; card mappings and coverage roots follow them. Both supplemented
bodies changed, so views saved against earlier builds are refused as a different
reference geometry version. Renders (side views, body vertebrae, hyoid, thyroid
cartilage and trachea in grey): [female](vhp-ct/female-neck-0.75mm-side.png),
[male](vhp-ct/male-neck-0.75mm-side.png).

## Licence

As for the parotid glands: NLM Terms and Conditions ("Courtesy of the U.S. National
Library of Medicine"; no endorsement implied; derived data may not reflect NLM's most
current data). TotalSegmentator is Apache 2.0.
