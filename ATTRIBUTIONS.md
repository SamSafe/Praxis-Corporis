# Attributions

The private prototype uses the anatomy samples below. Source files are reproducible
downloads, excluded from Git; their pinned URLs, byte counts and SHA-256 hashes are
in [content/source_manifest.json](content/source_manifest.json). Documentation source
candidates remain separate from imported prototype assets.

## Imported assets

| Asset and version | Creator/source | Licence | Changes | Used for | Required credits |
|---|---|---|---|---|---|
| Female United GLB, v1.1 | HuBMAP / Human Reference Atlas 3D Reference Object Library, including its supplied contributor metadata | CC BY 4.0 | Source GLB unchanged; sampling-site roots excluded, Godot cache conversion, temporary selection colours, fading, inspection movements, original-position overlays, source-label annotations and temporary isolated-part rendering | Female reference in private feasibility viewer | Credit the source library, link source/licence, retain notices and identify changes. |
| Male United GLB, v1.1 | HuBMAP / Human Reference Atlas 3D Reference Object Library, including its supplied contributor metadata | CC BY 4.0 | Same modifications as female sample | Male reference in private feasibility viewer | Same requirements. |
| HRA later organs: mammary glands v1.3, palatine tonsils v1.4, spinal cord and vertebrae v1.2 | HuBMAP / Human Reference Atlas 3D Reference Object Library | CC BY 4.0 | Source GLBs unchanged; nodes appended to a derived copy of each United v1.1 body without altering existing nodes | Extra organs in the female and male references | Same requirements as the United files. |
| Parotid glands traced from Visible Human Project normal CT (male and female head slices) | U.S. National Library of Medicine, Visible Human Project; traced with TotalSegmentator 2.18.0 (Apache 2.0, `head_glands_cavities` task) | NLM Terms and Conditions (no fee; acknowledge NLM; no endorsement implied) | CT slices resampled to 0.75 mm; glands segmented automatically, smoothed, simplified to 6,000 triangles each and fitted to each body's eyes and cervical vertebrae by a similarity transform; appended to the derived female and male bodies ([audit](docs/audit/VHP_PAROTID.md)) | Parotid glands in the female and male references | Include "Courtesy of the U.S. National Library of Medicine"; do not imply NLM endorsement; state that derived data may not reflect NLM's most current data. |
| Stomach, oesophagus, thyroid, adrenal glands, ribs, costal cartilages, sternum, gluteal, iliopsoas and deep back muscles traced from Visible Human Project normal CT (first head-to-thigh pass) | U.S. National Library of Medicine, Visible Human Project; traced with TotalSegmentator 2.18.0 (Apache 2.0, `total` task) | NLM Terms and Conditions | CT sections resampled to 1.5 mm; parts segmented automatically, smoothed and simplified, then fitted region by region to each body's own anatomy; appended to the derived female and male bodies ([audit](docs/audit/VHP_CT_PARTS.md)) | Extra organs, bones and muscles in the female and male references | Same as the parotid glands. |
| Tongue, mandible, muscles of mastication, scalenes, inferior pharyngeal constrictor, chest, back and abdominal wall muscles, quadratus lumborum, diaphragm, scapulae and clavicles; on the female also submandibular glands, hyoid and humeri (second tracing round) | U.S. National Library of Medicine, Visible Human Project; traced with TotalSegmentator 2.18.0 (Apache 2.0; free `head_glands_cavities`, `head_muscles`, `craniofacial_structures`, `headneck_muscles`, `headneck_bones_vessels`, `abdominal_muscles` and `trunk_cavities` tasks) | NLM Terms and Conditions | Same head volume and trunk sections as above; diaphragm taken as the sheet between the traced thoracic and abdominal cavities; shoulder bones refitted per side to the skin around the shoulder; parts more than a fifth outside the skin left out ([audit](docs/audit/VHP_CT_PARTS.md#second-round-head-neck-and-trunk-muscles-jaw-diaphragm-and-shoulders)) | Extra head, neck and trunk muscles, jaw, diaphragm and shoulder bones in the female and male references | Same as the parotid glands. |
| BodyParts3D / Anatomography 4.3: thyroid, parathyroid and sublingual glands | Database Center for Life Science, via the olivercase/body_parts_3d_api mirror (pinned commit) | CC BY-SA 2.1 Japan | Meshes converted from mm/Z-up to metre/Y-up with source normals; display colours and inspection effects | Glands in the complete male body | Credit "BodyParts3D, (c) The Database Center for Life Science licensed under CC Attribution-Share Alike 2.1 Japan"; share-alike applies to redistributed model data. |
| BodyParts3D v4.0 bone-organ study | Database Center for Life Science, official LSDB archive | Current official CC BY 4.0 grant; legacy OBJ comments retain CC BY-SA 2.1 Japan | Source archive unchanged. Bone-group subset converted from mm/Z-up to metre/Y-up with source normals; generic display colour and temporary inspection effects | Separate private male bone reference, unregistered to HRA/female anatomy | Required attribution, current source/licence links, original legacy notice and modification description retained. |
| BodyParts3D v4.0 complete male body | Database Center for Life Science, official LSDB archive (IS-A and PART-OF trees) | Current official CC BY 4.0 grant; legacy OBJ comments retain CC BY-SA 2.1 Japan | Source archives unchanged. Every source mesh included once (13 repeated source meshes kept once), organised by the source PART-OF tree, converted from mm/Z-up to metre/Y-up with source normals; illustrative display colours and temporary inspection effects | Separate private complete male reference, unregistered to HRA/female anatomy | Same requirements as the bone study. |

Attribution: Anatomy models from the HuBMAP / Human Reference Atlas
[3D Reference Object Library](https://github.com/hubmapconsortium/ccf-3d-reference-object-library),
licensed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).
The library's licence includes its disclaimer of warranties and does not imply endorsement.
The supplied [licence text](third_party/HRA-LICENSE.txt) and
[README](third_party/HRA-README.md) are retained locally. Source commit:
`f1a3a63f110e27ff0736047d52d04dba5d3087f9`.

Record original URLs, hashes, relevant licence evidence, and applicability to exported
views/content. Preserve separate obligations for contributions in derivative atlases.

## Software

BodyParts3D attribution: BodyParts3D, © The Database Center for Life Science licensed
under CC Attribution 4.0 International. Its
[current official grant](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html),
[retained current page](third_party/BodyParts3D-CURRENT-LICENSE.html),
[README](third_party/BodyParts3D-README.html) and
[legacy mesh notice](third_party/BodyParts3D-LEGACY-OBJ-NOTICE.txt) accompany the private
study. [Technical findings](docs/audit/BODYPARTS3D_FINDINGS.md) record the limited
admission scope and both licence records.

The prototype uses Godot 4.7.2 and its built-in UI, materials and default font.
Godot is independently licensed under MIT; retain the engine's copyright/licence
and applicable third-party notices when distributing runtime binaries.
[Godot licence and third-party notices](https://godotengine.org/license/).
Engine executables are included in generated private build archives under dist/,
excluded from Git. The exact engine [licence](third_party/Godot-LICENSE.txt) and
[third-party notices](third_party/Godot-COPYRIGHT.txt) are retained and copied into
each archive's NOTICES/ folder. [toolchain_manifest.json](content/toolchain_manifest.json)
pins their source versions/hashes and the official export templates.
Application code licensing remains separate and undecided; no third-party content
licence is applied to app code. No public distribution has been performed.

## Review evidence

Attribution does not establish anatomical or clinical accuracy. Track technical
validation, source checking, and expert review separately.
## Separate HRA spinal source studies

The private viewer also includes four unchanged v1.2 HRA GLBs: female/male
spinal cord and female/male vertebrae, pinned to repository commit
`f1a3a63f110e27ff0736047d52d04dba5d3087f9`. The existing HuBMAP / Human Reference
Atlas CC BY 4.0 credits and retained HRA notices apply. Exact original URLs,
byte counts and SHA-256 hashes are in `content/spinal_source_manifest.json`.

These are independent source studies, with original metre/Y-up coordinates;
no body registration, geometric fitting or silent replacement of United v1.1
references occurs. Cache conversion, selection colours, fading, labels and temporary
inspection displacement/isolation are display modifications. A source record named
`VH_F_lumbar_vertebra_6` has a missing label/ontology; its name and metadata gap are
retained without interpreting it as normal anatomy or a variant.

## Authored study text

The heart/lung study cards, initial valve-condition summaries and circulation route
are original short summaries of the linked NHLBI / NIH health pages, including
[Types of heart valve disease](https://www.nhlbi.nih.gov/health/heart-valve-diseases/types).
The route also cites Tucker WD, Weber C and
Burns B, *Anatomy, Thorax, Heart Pulmonary Arteries*, StatPearls (updated 2023-07-24),
hosted by [NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK534812/), for the
pulmonary arterial branching relationship. Source URLs and the assistant cross-check date are recorded in
`content/study_content.json` and linked in the app. No source images, animations,
video or substantial text passages are reused. These texts remain private drafts.
Human source and qualified medical review are pending. Assistant cross-checks are
preliminary and do not establish review of the text or mesh geometry.
