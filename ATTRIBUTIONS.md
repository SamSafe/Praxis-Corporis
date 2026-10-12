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
| BodyParts3D v4.0 bone-organ study | Database Center for Life Science, official LSDB archive | Current official CC BY 4.0 grant; legacy OBJ comments retain CC BY-SA 2.1 Japan | Source archive unchanged. Bone-group subset converted from mm/Z-up to metre/Y-up with source normals; generic display colour and temporary inspection effects | Separate private male bone reference, unregistered to HRA/female anatomy | Required attribution, current source/licence links, original legacy notice and modification description retained. |

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
