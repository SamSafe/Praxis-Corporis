# Native accessibility and complete record browsing

Checked 2026-10-18. Runtime source `9e864a0` adds meaningful names/descriptions to
anatomy search, the 3D view, hierarchy/parts, label density, saved-view fields and
coverage groups. It also adds a native paged List view alongside the hierarchy.
This is a private candidate; it does not establish accessibility conformance.

## Verified failures and changes

A native Windows UI Automation probe against source `6a878b7` found unnamed core
controls ([baseline tree](accessibility-before-tree.json)). Setting the anatomy query through the native Value pattern changed its
text but left the hierarchy visible and did not refresh results
([search snapshot](accessibility-before-search-tree.json)). A small native
fixture reproduced this behavior. The pinned engine's
[LineEdit setter](https://github.com/godotengine/godot/blob/ed1daf0bf001b61586d9930840f2f1394092c079/scene/gui/line_edit.cpp#L1202)
calls `set_text()` without the normal `text_changed` signal.

The app's small `ValueInput` subclass registers an accessibility value action that
applies the native text limit and emits the normal handler once when text changes.
Read-only fields and non-string actions are ignored. Anatomy search, the saved-view
filter and saved-view name use it. Ordinary keyboard input retains native behavior.
A native fixture confirms the new callback refreshes its observed text:
[before](accessibility-input-fixture-before.json),
[after](accessibility-input-fixture-after.json).

The same fixture exposes two ItemList rows through UI Automation and zero Tree
rows. The pinned engine's
[Tree accessibility code](https://github.com/godotengine/godot/blob/ed1daf0bf001b61586d9930840f2f1394092c079/scene/gui/tree.cpp#L4907)
marks rows hidden using the opposite parent-visibility condition to its ordinary
visibility test. The app retains its hierarchy and offers List view as a native
alternative. It does not patch the engine.

List view includes every real catalogue record in deterministic alphabetical pages
of 100. Original source names/IDs remain attached. Search keeps normal ranking;
clearing it returns to the chosen browsing mode. Paging does not select anatomy,
change the camera, edit structures or create history. A new reference starts at the
first page. The mode remains separate from saved anatomy state and preferences.

## Development checks

- All 90 Python checks pass.
- Accessible input checks cover native length limits, Unicode, no-op actions,
  read-only state and single signal delivery.
- Search and saved-view filter integration checks pass using the accessibility
  value callback rather than manually emitting their ordinary signals.
- Every record is reached exactly once across all seven references: 970 female,
  961 male, 205 bone-study, and 30/26/31/25 spinal-study records. Counts include
  source grouping records as well as mesh-bearing anatomy.
- Paging preserves camera, selection, model edits, Undo/Redo and Back/Forward.
  Exact source-ID search/selection and hierarchy return pass for each reference.
- Search, mode, records and paging controls fit the 1100 × 720 workspace at both
  100% and 130% text size.

The 3D surface also needs a semantic panel role: setting the name alone left
TextureRect absent from the native tree. A small native fixture confirms the role
exposes its name and accepts native keyboard focus.

Windows UI Automation exposes visible native list rows. The fixture does not
support the list Scroll pattern; its scrollbar range is read-only through that
API. Added range metadata did not resolve this and was removed. Native scrolling,
row activation and real screen-reader operation remain open acceptance work. No
engine fork or custom row-accessibility implementation is included.

## Exact native candidate

The final build/source audit passes 77 version-2 inputs, ZIP CRCs, executable
architectures, pinned notices and anatomy identity. The Mac embedded pack passes
all seven development-engine workflows and both early-close cases.
[Build report](accessibility-build-report.json), [build log](accessibility-build.log.txt),
[archive/source audit](accessibility-artifact-audit.json).

The exact Windows archive passes the native accessibility verifier: meaningful
core names, 3D keyboard focus, source search through the Value pattern, three page
comparisons, hierarchy return and saved-view filtering from two fake records to
one. Its process exits normally with code 0, logs no runtime error or object leak,
and leaves the isolated library byte-for-byte unchanged. The marked session is
removed and independently checked absent. The checker reads only its own root
window and never accesses clipboard contents, file pickers or user libraries.
[Native accessibility report](accessibility-windows-uia.json),
[runtime](accessibility-windows-uia-runtime.log.txt).

[Python checks](accessibility-python.log.txt),
[all-reference list/compact layout](accessibility-list-development.log.txt),
[display/picking regression](accessibility-display-development.log.txt),
[input](accessibility-input-development.log.txt),
[search](accessibility-search-development.log.txt),
[library integration](accessibility-library-development.log.txt).
[Retained evidence identities](accessibility-evidence.json).

The exact Windows archive also passes the full rendered workflow across seven
references: 107 captures, 784 placement comparisons, 543 redraw comparisons, four
normal launches and two early-close cases. Runtime logs contain no engine error,
Unicode replacement diagnostic or ObjectDB leak. The marked session is removed
and independently checked absent. The native search capture was visually inspected
for the new mode control, search row, anatomy and surrounding actions.
[Native workflow report](accessibility-windows-qa.json),
[runtime](accessibility-windows-runtime.log.txt),
[normal launches](accessibility-normal-lifecycle.json),
[initial close](accessibility-native-initial-anatomy.log.txt),
[replacement close](accessibility-native-replacement-selection.log.txt).
Detailed comparison/capture files remain under `dist/accessible-surface-windows-qa/`
with their identities in that native report.

Private archives under `dist/accessible-surface-improvements/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328221352 | `33fc0c1e06fd4515dc55f764408839b51ea6f49265b0fa58f34bdbf985614310` |
| PraxisCorporis-macOS-universal-private.zip | 350666985 | `6d682ca8db50ae0ef9bee50e720716a08f673ed6bac0fe7fa693524a82fb45e0` |

The anatomy package remains 624,166,432 bytes with SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
Geometry, medical text, source mappings and review stages remain unchanged.
Actual Mac execution, VoiceOver/Windows screen-reader use, physical-device input,
representative performance, medical review and public release gates remain open.
The [Mac acceptance packet](../MAC_ACCEPTANCE.md) identifies this candidate;
its earlier version's template remains available for observations already begun.
