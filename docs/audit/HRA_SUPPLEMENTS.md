# Later HRA organs and BodyParts3D 4.3 glands

Date: 2026-11-21. Assistant technical check, not anatomical review.

## Why

The United v1.1 bodies, and BodyParts3D 4.0, omit organs that later releases
supply. This adds the ones an openly licensed source provides, without moving or
renaming anything that already exists.

| Body | Added | Source | Licence |
|---|---|---|---|
| Female | Left and right mammary glands (lobes, fat, nipple, areola, areolar tubercles) | HRA library `VH_Female/v1.3` | CC BY 4.0 |
| Female, male | Left and right palatine tonsils | HRA library `VH_Female/v1.4`, `VH_Male/v1.4` | CC BY 4.0 |
| Female, male | Spinal cord segments and vertebrae | HRA library `VH_*/v1.2` | CC BY 4.0 |
| Complete male | Thyroid gland (two lobes, isthmus), four parathyroid glands, sublingual glands | BodyParts3D / Anatomography 4.3 via the `olivercase/body_parts_3d_api` mirror, commit `fd527e6` | CC BY-SA 2.1 Japan |

Every file is pinned by URL, size and SHA-256 in
[content/hra_supplements_manifest.json](../../content/hra_supplements_manifest.json) or
[content/bodyparts3d_source_manifest.json](../../content/bodyparts3d_source_manifest.json).
The HRA files come from library commit `f1a3a63`, the same commit as the United
bodies; the library has no later commit.

## Alignment checks

**HRA.** World-space bounds of later files were compared with the same structures
in United v1.1:

| Check | Later file | United v1.1 |
|---|---|---|
| Female heart file (v1.2) vs United left ventricle | whole heart x −0.035–0.108, y 0.389–0.499 | ventricle x 0.010–0.108, y 0.395–0.478 (inside the heart's bounds, same right edge) |
| Female larynx file (v1.4) vs United thyroid cartilage | x −0.033–0.014, y 0.603–0.664 | x −0.033–0.014, y 0.615–0.662 |
| Male heart file (v1.2) vs United left ventricle | whole heart x −0.043–0.081, y 0.423–0.529 | ventricle x 0.005–0.081, y 0.426–0.503 (inside, same right edge) |

Rendered checks then showed the vertebrae and spinal cord running behind the
thoracic and abdominal organs along the curve of the back, the mammary glands on
the front of the chest over the lungs, and the tonsils at the back of the throat
above the larynx. The earlier separate spinal studies were kept unregistered as
a precaution; this check found no offset.

**BodyParts3D 4.3 vs 4.0.** Five meshes present in both releases have identical
millimetre bounds (thyroid cartilage FJ2808, trachea FJ2541, cricoid cartilage
FJ2440, tenth thoracic vertebra FJ3154, pancreas FJ1895), so 4.3 meshes share
the 4.0 frame. The rendered thyroid sits around the trachea between the
carotid arteries.

## How the bodies are built

`tools/build_hra_supplements.py` appends each later file's buffer data,
accessors, meshes, materials and nodes after the United body's own, under the
anatomy root, so every existing node index and catalogue ID is unchanged
(the regenerated catalogue had 0 changed and 0 missing existing records; 78
female and 59 male records were added). `tools/build_sample_pack.py` then reads
the supplemented file. `tools/build_full_body.py` adds the 4.3 meshes to the
complete body, checking each file's hash and `File ID` header.

The supplemented bodies have new file hashes, so the prepared caches, the
orientation records and any saved views tied to the old female or male file
are refreshed or reported as changed.

## Not found in any open source

Parotid glands, scrotum, female external genitalia (vulva), pharyngeal and
lingual tonsils. Searched: HRA library (all releases to v1.4), BodyParts3D 4.0
and 4.3. No complete female skeleton or muscle set exists in these sources.

Second search, 2026-11-22:

- **Z-Anatomy** (Zenodo record 4953712): its 2,649 objects are BodyParts3D
  re-labelled to TA2, under the same CC BY-SA 2.1 Japan terms. It adds no
  parotid gland, scrotum, tonsils or female structures; "parotidomasseteric
  region" is a surface-region label, not a gland.
- **AnatomyTOOL Open3DModel:** built from Z-Anatomy and male only.
- **NIH 3D:** no CC BY parotid, scrotum, adenoid or vulva entry. The female
  pelvis there is the HRA reference organ; its bones are already in the female
  body.
- **Other open models:** the few others found (Maastricht, Dundee) are CC
  BY-NC-SA, and the remaining female sets are commercial.

Hand-built models were considered and rejected. These sources are segmented
from real anatomy, and a hand-made gland would be a guess in shape and position
in a study app, so the gaps stay documented rather than filled.

## Build verification

Build `0eb727b` (build ID `2710ac3f…`) packages the supplemented bodies. A packaging
bug was found and fixed first: the package had carried the original United files
while the app expected the supplemented ones, and the startup check looked for the
old file names. `tools/pack_anatomy.gd` now refuses a body whose file differs from
the catalogue the app loads.

- **Exported Linux run:** all eight references passed every bundled check and the
  run ended with `PASS offline native bundle`. The strict runner still rejects it
  for the known engine popup errors described in
  [the popup-template diagnostic](POPUP_TEMPLATE_VERIFICATION.md).
- **Native Windows, headless:** passed for all eight references, native exit code 0,
  user data isolated ([report](windows-qa-0eb727b/report.json)).
