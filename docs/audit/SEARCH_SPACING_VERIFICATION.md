# Unicode spaces in anatomy and saved-view search

Source `e41d05c` makes Unicode whitespace work consistently in anatomy and
saved-view searches. A shared compiled expression normalizes whitespace for
lookup; stored source records, names, notes and unfinished drafts retain their
original text. Library underscores retain their existing literal behavior;
anatomy identifiers retain their existing separator normalization.
Checked on 2026-10-17 (America/Edmonton).

The [Unicode 17.0 White_Space property](https://www.unicode.org/Public/17.0.0/ucd/PropList.txt)
contains 25 code points, including nonbreaking, narrow nonbreaking, em and
ideographic spaces. The expression covers separator categories plus TAB through
CR and NEXT LINE. Godot's [RegEx API](https://docs.godotengine.org/en/stable/classes/class_regex.html)
supports compiling it once and substituting globally. Format characters such as
zero-width spaces and joiners are retained. A whitespace-only anatomy query shows
the full hierarchy; Enter leaves the current anatomy unchanged.

## Reproduction and checks

The [probe](search-spacing-probe.gd.txt) uses actual female source records.
[Before](search-spacing-before.log.txt), `left atrium` returns two records with an
ordinary space and zero with U+00A0, U+202F, U+2003 or U+3000. The corresponding
saved-view tokens also remain incorrectly joined. [After](search-spacing-after.log.txt),
all five queries return the same two source records and produce two library tokens.
These are scripted strings; no clipboard operation occurs.

The [spacing check](../../tests/search_spacing_smoke.gd) passes all seven references.
It compares ordered anatomy results for all 25 whitespace characters, including
leading, trailing and repeated separators. Disposable saved-view filters cover
names, persisted Unicode notes, unfinished drafts and blank queries. Six format
characters remain unchanged; anatomy/library underscore behavior is preserved.
Four common copied spaces also exercise the visible anatomy list, result IDs and
blank-query hierarchy. Source records, anatomy/camera state, inspection/navigation
histories, saved library bytes and draft text remain unchanged.

The fixture snapshots the library after its normal JSON reload, avoiding a false
failure caused by comparing pre-serialization and loaded numeric representations.
[Development](search-spacing-development.log.txt),
[existing source search](search-spacing-search.log.txt),
[library search](search-spacing-library.log.txt).

All 87 Python checks pass, including rejection of missing per-reference spacing
markers. [Python log](search-spacing-python.log.txt).

## Private packages

The exact Windows archive passes all seven spacing checks on the native AMD OpenGL
renderer. The full run also passes 784 label-placement comparisons and 543 scene-image
comparisons, retains 107 capture identities, and completes four normal launches and
two early-close checks without a runtime error, Unicode replacement diagnostic or
ObjectDB leak. The marked temporary session was removed and independently checked
absent. [Native report](search-spacing-windows-qa.json),
[runtime](search-spacing-windows-runtime.log.txt),
[normal launches](search-spacing-normal-lifecycle.json),
[initial close](search-spacing-native-initial-anatomy.log.txt),
[replacement close](search-spacing-native-replacement-selection.log.txt).

The embedded Mac content passes the seven-reference workflow and both early-close
checks on the development engine. The independent archive audit passes ZIP CRCs,
architectures, committed runtime hashes, notices and resource boundaries.
[Build report](search-spacing-build-report.json), [build log](search-spacing-build.log.txt),
[audit](search-spacing-artifact-audit.json), [evidence identities](search-spacing-evidence.json).
The script UID files generated during export are retained separately in `42dcbfb`;
the tested runtime source remains `e41d05c`.

Private archives are under `dist/search-spacing-improvements/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328216788 | `3470f35929fa5b42cc3edaf99d515b67001470b9308c36e792c8d3c3cda2257e` |
| PraxisCorporis-macOS-universal-private.zip | 350662755 | `1b901e158e511ad465fb3939964785909e4975f509b719a0d0fa5455bb30f6fc` |

The underlying anatomy package remains 624,166,432 bytes with SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
No medical text, geometry, source mapping or review stage changes.
Actual Mac, human keyboard/clipboard/accessibility and representative-device
acceptance remain pending. Existing licensing, signing and public-release gates
remain open. The Linux release-template popup issue remains separate.
