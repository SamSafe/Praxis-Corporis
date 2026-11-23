# Parotid glands from the Visible Human CT

Date: 2026-11-22. Assistant technical check, not anatomical review.

## Why

No openly licensed parotid gland model exists in the HRA library, BodyParts3D,
Z-Anatomy or NIH 3D ([search record](HRA_SUPPLEMENTS.md)). The HRA female and male
bodies were made from the Visible Human Project donors, whose CT scans the U.S.
National Library of Medicine publishes freely. Tracing the glands on those scans gives
the same people's anatomy rather than an invented shape.

## Method

Scripts in [tools/vhp_parotid](../../tools/vhp_parotid); work files in
`build/parotid-work/` (not committed).

1. **Download** the top slices of each "normal" (pre-freezing) CT series from
   `data.lhncbc.nlm.nih.gov/public/Visible-Human/`: 280 male slices (`c_vm1012` on)
   and 300 female slices (`c_vf1001` on).
2. **Build a volume.** Each GE Genesis slice header gives its corner coordinates, so
   series with different fields of view (250-460 mm) are resampled onto one 0.75 mm
   grid covering about 260 mm from the top of the head.
3. **Segment** with TotalSegmentator 2.18.0 on CPU: the `head_glands_cavities` task
   (not a licensed task) for the glands and eyes, and the `total` task limited to
   C1-C7 for the neck vertebrae. Usage statistics were switched off.
4. **Fit** the CT to each body: a similarity transform (rotation, translation, one
   scale) from the centroids of the eyes and seven cervical vertebrae, refined by
   surface ICP on the same structures.
5. **Mesh** each gland: the largest connected piece, small holes closed, Gaussian
   smoothing, marching cubes, Taubin smoothing, simplified to 6,000 triangles.
   Files: `assets/vhp-parotid/{female,male}-parotid-glands.glb`, pinned in
   [the supplement manifest](../../content/hra_supplements_manifest.json) and
   appended to the bodies by `tools/build_hra_supplements.py`.

## Results

| | Male | Female |
|---|---|---|
| Fit scale | 1.009 | 1.057 |
| Eye and C1-C7 centroid residuals | 0.9-2.8 mm | 0.2-4.9 mm |
| Median surface distance after ICP | 0.7-1.0 mm | 0.6-2.5 mm |
| Left / right gland volume in the body | 22.7 / 17.9 cm³ | 23.8 / 22.1 cm³ |

Typical adult parotid volumes are in the same range. A scale near 1 is expected,
since each scan and body come from the same donor; the female body is about 6%
larger than her CT.

**Independent checks (not used in the fit).** On the male body, the Allen brain sits
inside the scanned skull, and the CT head surface lies a median 6 mm from the body's
skin mesh, whose head vertices are about 5 mm apart. The scans were taken before
freezing, so neck posture differs slightly from the body.

**Renders** of the built bodies show each gland lateral to the upper neck, between
the jaw and the spine, from about ear level to the second vertebra:
[male front](vhp-parotid/male-front.png), [male side](vhp-parotid/male-side.png),
[female front](vhp-parotid/female-front.png), [female side](vhp-parotid/female-side.png).

## Limits

- **Approximate.** The glands are automatic segmentations of 1 mm CT, not hand-refined
  models. There is no parotid duct, facial nerve or internal lobe boundary, and the
  surface is smoother than a real gland.
- **The front of the face is cut off** in both scans by the scanner's field of view.
  The parotids, beside the ear, are inside it.
- **The HRA palatine tonsils** sit about 2.5 cm in front of the CT oropharynx airway
  after the fit. That is a property of the HRA tonsil placement or of the cadaver
  airway, not of this fit; it was not changed.
- **Not added to the complete male body.** It is a different, smaller person (60 mm
  between the eyes versus 71 mm), and the best fit there was still 5-9 mm off at the
  surfaces. That body keeps the text-only parotid card with "Locate nearby anatomy".

## Licence

NLM Terms and Conditions: no fee; credit "Courtesy of the U.S. National Library of
Medicine"; do not imply endorsement; redistributed derived data must say it may not
reflect NLM's most current data. TotalSegmentator is Apache 2.0. The app's sources
dialog and exported image captions carry the credit.
