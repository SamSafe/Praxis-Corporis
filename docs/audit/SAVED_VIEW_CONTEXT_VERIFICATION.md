# Finding saved views by reference and anatomy

Source `3887cb342dcedb37f03216d24454562110e0d14a` records saved-view search by name, notes, reference and
selected anatomy names/source IDs, plus **This reference** scope. Checked on
2026-10-16 (America/Edmonton); exact committed source and artifact identities are recorded below.

Matching remains case-insensitive, with every word required across the searchable
fields. Ontology IDs work with and without the colon. The scope compares exact
reference IDs rather than text fragments. It starts off whenever the library
opens. The count stays visible in the heading and includes the whole library total.
Tooltips and selected details share the same reference/anatomy context.

Current labels resolve for the recorded content pack and source geometry, or for
already supported legacy HRA views. Separate
studies still require a fingerprint. Changed or unavailable references retain raw
recorded IDs and disabled Restore where appropriate, while their notes remain
accessible. Searching does not make an incompatible snapshot restorable.

Filtering retains drafts, editor position and unfinished names. Undo delete can
remove reference scope to reveal a restored view, keeping a query that still
matches. Search/scope changes cancel pending deletion and clear its old prompt
without erasing newer feedback. Export all views still includes the entire library.

## Development evidence

The [context check](../../tests/saved_view_context_smoke.gd) passes a mixed-reference
library, name/note/metadata matching, source names, normalized ontology IDs,
current and legacy records, changed source/pack, missing study fingerprint,
unavailable IDs, draft/cursor/name retention, deletion cancellation, cross-reference
undo and protected close. Filtering leaves library bytes, snapshots and current
anatomy unchanged. Existing search and deletion-undo checks pass, including the
full 200-view search. [Context](view-context-development.log.txt),
[search](view-context-filter.log.txt), [undo](view-context-undo.log.txt),
[check identities](view-context-development-qa.json).

The real GUI check clicks This reference in a female-heart/male-bone library and
finds the source femur using `FMA24474`. At 130% text, the search, scope, persistent
count and actions fit both normal and 720 × 500 minimum dialogs. The captures
were inspected. Existing note editing/undo, save and cross-reference restore pass.
[GUI check](../../tests/capture_saved_views.gd), [log](view-context-capture.log.txt),
[context search](../prototype/saved-view-context.png),
[minimum dialog](../prototype/saved-view-context-minimum.png).

All 67 Python checks pass, including rejection of native reports missing a
saved-view anatomy-search marker for any reference.
[Python log](view-context-python.log.txt).

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, all seven reference workflows (including saved-view anatomy search),
and two loading shutdowns using the development engine.
[Build report](view-context-build-report.json), [log](view-context-build.log.txt).

The exact Windows archive passes native AMD OpenGL verification on all seven
references. Each passes anatomy-ID lookup against real saved metadata and exact
reference scoping with a disposable in-memory second-reference row. Filtering
preserves notes, current anatomy and library bytes; the fixture is removed before
the existing deletion-undo and shared-note-save checks. Native dialogs for HRA
and spinal source views were inspected.
[Female dialog](../prototype/saved-view-context-native-female.png),
[cord-study dialog](../prototype/saved-view-context-native-cord.png).

The existing workflows retain 94 capture identities. Four normal launches pass
reference/window restoration and unavailable-reference fallback. Two separate
early-close processes pass owned-resource cleanup and staged-scene release while
preserving user-file bytes, modification times and identities. No runtime error
or ObjectDB leak is reported. The successful generated QA session was removed
and independently checked absent.
[Native report](view-context-windows-qa.json), [runtime log](view-context-windows-runtime.log.txt),
[normal launches](view-context-normal-lifecycle.json),
[initial close](view-context-native-initial-anatomy.log.txt),
[replacement close](view-context-native-replacement-selection.log.txt).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](view-context-artifact-audit.json),
[evidence identities](view-context-evidence.json).

Private archives are under `dist/saved-view-context-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328144519 | `36739fdf40d35ea6dd2e850859cf42e129c8961b9dffcb7201eadd51f7fa0aea` |
| PraxisCorporis-macOS-universal-private.zip | 350590223 | `26aaf99c06c9d0abfa2deb4363f9f0c7897300a986897af924746f9dd153249f` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Scripted events and software-rendered inspection do not establish human
accessibility, clipboard/picker acceptance or actual Mac execution. Medical
content, anatomy/source identities and saved-view formats are unchanged. Human
source and expert review remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target.
