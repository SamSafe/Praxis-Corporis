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

## Licence

As for the parotid glands: NLM Terms and Conditions ("Courtesy of the U.S. National
Library of Medicine"; no endorsement implied; derived data may not reflect NLM's most
current data). TotalSegmentator is Apache 2.0.
