# Read a study card while keeping anatomy in view

Source `e5147328076c50582e06cfc19a3aeebbfaf6fbb7` adds **Read study card** to the workspace details and
expanded **Explore** menu, and gives related-anatomy links a stable keyboard
reading action. Checked on 2026-10-17 (America/Edmonton).

The [probe](study-reader-before.gd.txt), [before](study-reader-before.log.txt)
and [after](study-reader-after.log.txt) show the related link to the left atrium
changing from no keyboard focus after selection to a focused reading action.
The previous study text was an unselectable sidebar label, hidden in expanded
anatomy. That sidebar remains; the new action opens a larger selectable reader.

The window includes the reference, selected structure, exact existing card text,
draft/review status, and source titles/addresses. It follows text size, bounds and
scrolling from the shared information window. Close/Escape returns to its opening
control. Related-anatomy activation focuses the new card's reading action, so Enter
opens the selected text. Anatomy without an authored card offers no inferred text.

## Development checks

The [reader check](../../tests/study_reader_smoke.gd) passes all 15 cards in both
HRA bodies, both layouts and 100%/130% text size: 120 reading contexts. It checks
exact card/source text, reference identity, selectable plain text, text size,
window bounds, Page Down at a shorter height, Select All, and alternating Close
and Escape. It checks restored focus, anatomy/camera state, histories and layout.
All 36 related links in each body retain the reading action after Enter (72
transitions). Four active-guide/route reads preserve their step and route history.
Missing cards in both HRA roots and the five separate source studies stay unavailable.
[Development log](study-reader-development.log.txt).

Workspace activation uses Enter on the actual button. Expanded activation dispatches
the connected Explore menu-item signal; this is not OS menu-key injection. Godot's
menu acceptance passes through its window-input handler before item activation
([Godot 4.7.2 source](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/scene/gui/popup_menu.cpp)).
Human native-menu acceptance remains separate.

Existing source-link and study-navigation checks pass sequentially. The geometry
integration check passes both original HRA bodies. All 77 Python checks pass,
including rejection of missing reference/reader-capture evidence.
[Source links](study-reader-sources.log.txt), [navigation](study-reader-navigation.log.txt),
[geometry](study-reader-geometry.log.txt), [Python](study-reader-python.log.txt),
[check identities](study-reader-development-qa.json).

The reader makes no browser/network request and performs no automatic clipboard
access. Select All selects text only. Medical text/review stages, source URLs,
geometry/identities, saved-view formats and inspection-history limits are unchanged.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, all seven reference workflows, the 120 reader contexts and related-link/
active-study checks in both HRA bodies, unavailable-card checks, and two loading-
shutdown cases on the development engine. This does not establish actual Mac execution.
[Build report](study-reader-build-report.json), [build log](study-reader-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, including the 120 card-reading contexts, 72 related-link transitions,
active-study preservation and unavailable-card checks. The workflow retains 106
capture identities. The [workspace](../prototype/study-reader-workspace-windows.png)
and [expanded](../prototype/study-reader-expanded-windows.png) readers at 130% text
size were visually inspected: text and sources remain readable and selectable,
with scrolling for the longer heart card and a visible Close button. Raw PNG
checks confirm matching reference, Function, draft/geometry-limit and Sources text
regions in both originals; repeated-image tool previews can omit unchanged glyphs.
[Pixel check](study-reader-pixel-inspection.py.txt),
[results](study-reader-pixel-inspection.json).

Four normal launches pass reference/window restoration and unavailable-reference
fallback. Two early-close processes pass resource cleanup while preserving
user-file bytes, modification times and identities. No runtime error or ObjectDB
leak is reported. The successful isolated session was removed and independently
checked absent. [Native report](study-reader-windows-qa.json),
[runtime log](study-reader-windows-runtime.log.txt),
[normal launches](study-reader-normal-lifecycle.json),
[initial close](study-reader-native-initial-anatomy.log.txt),
[replacement close](study-reader-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](study-reader-artifact-audit.json).
[Evidence identities](study-reader-evidence.json) bind the retained results.

Private archives are under `dist/study-reader-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328177968 | `3d8eba4aad75afddd530929c22761395c9d58063e28fa500db32c8d708517185` |
| PraxisCorporis-macOS-universal-private.zip | 350623866 | `00942c6073ad3aa07ce5d43eb7cf59d63d9faec9dd3c8908b2534d505c90d84e` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks use scripted input and menu dispatch. Human keyboard/device and
accessibility acceptance, representative laptops and actual Mac execution remain
pending. The independent [Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md)
remains open; Linux is not a release target. Human source and expert medical review
remain pending.
