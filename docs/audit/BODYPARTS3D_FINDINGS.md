# BodyParts3D v4.0 technical audit

Date: 2026-10-12. Private study geometry, without HRA registration or medical review.

The official LSDB archive provides an adult male reference, OBJ geometry, FMA names
and element/compound mappings. [Source description](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html),
[downloads](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html).
The selected v4.0 archive is labelled 99% polygon reduction by the source; that label
is not an anatomical fidelity/completeness score.

## Measured inventory

| Item | Observed result |
|---|---:|
| Official archive | 142,903,898 bytes |
| OBJ members, CRC-checked | 2,234 |
| Selected meshes inventoried | 552 |
| Bone-organ group FMA5018 | 203 declared/present mesh files |
| Bone-group triangles | 505,532 |
| Source rib group | 24 declared/present elements |
| Source vertebra group | 24 declared/present elements |
| Source nerve group | 26 declared/present elements |
| Source muscle-organ group | 323 declared/present elements |

These are file/group counts, not reviewed-structure counts. The bone group provides
skull, rib, spinal and upper-limb shapes absent from the current HRA assemblies.
Presence does not establish regional completeness, interiors or clinical suitability.

The raw bone group spans approximately 648 × 254 × 1,707 mm in source X/Y/Z.
OBJ headers explicitly label Bounds(mm). The study uses [x,z,-y] × 0.001 to convert
millimetres to metres and source Z-up to Y-up, retaining source normals. It applies
no HRA fitting, female conversion or bone deformation. Laterality/orientation and
small structures still need qualified review.

## Licence records

The [current official page](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html)
and [README](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/README_e.html)
state CC BY 4.0 after the 2025 update. Original OBJ comments still carry legacy
CC BY-SA 2.1 Japan text. Both are retained; original notices are not rewritten.
Required current attribution:

> BodyParts3D, © The Database Center for Life Science licensed under CC Attribution 4.0 International

Local evidence: [current page](../../third_party/BodyParts3D-CURRENT-LICENSE.html),
[README](../../third_party/BodyParts3D-README.html),
[original mesh notice](../../third_party/BodyParts3D-LEGACY-OBJ-NOTICE.txt).
The private study uses the current grant, retains legacy notices and identifies its
coordinate/display changes. App code licensing remains independent and undecided.
Public-release rights and medical review remain separate gates.

## Reproduce the study

[Source manifest](../../content/bodyparts3d_source_manifest.json) pins URLs, sizes and
SHA-256 hashes. Downloads, derived GLBs and prepared scenes are excluded from Git.
After ordinary HRA setup:

```sh
python3 tools/fetch_assets.py --manifest content/bodyparts3d_source_manifest.json
python3 tools/audit_bodyparts.py assets/bodyparts3d/raw --output docs/audit/bodyparts3d-v4-inventory.json
python3 tools/build_bone_study.py assets/bodyparts3d/raw
godot --headless --path . --script tools/prepare_assets.gd
godot --path .
```

Male bones / BodyParts3D study appears when its prepared source is available. It
remains separate from both HRA references and has its own coverage record. Saves
are tied to the derived geometry hash. Skin/chest actions are unavailable for it.

The generated GLB is 12,895,068 bytes with 203 selectable source meshes.
[Catalogue](../../content/bodyparts3d_bone_study.json),
[measured inventory](bodyparts3d-v4-inventory.json),
[standalone rendered preview](../prototype/bodyparts-male-bone-study.png).
The converter requires pinned inputs, source normals, declared millimetres and
triangular faces; it rejects malformed/unsupported data instead of creating surfaces.
The first development import parsed in 0.19 s and prepared in roughly 1.6 s, an
uncontrolled observation rather than a hardware claim.

## Admission scope

Admit an explicitly separate, private male bone study. This does not fill the female
skeleton gap or establish an integrated HRA skeleton. Preserve both HRA references,
source identities, coordinates and notices. Review orientation/detail and support
alignment with appropriate landmarks before body integration. The comprehensive
two-body and public-release gates remain open.
