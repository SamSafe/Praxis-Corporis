# Save all study notes

Runtime source `98fb26e69d6ce632f813b35662042f6184af7783` adds **Save all notes** and **Ctrl/Cmd+S** inside the
Saved views window. It saves every pending note and keeps the library open.
The existing **Save notes** action still saves only the selected view. Checked
on 2026-10-16.

The note status now counts drafts on other views. All notes use the existing
single atomic batch write, file-fingerprint guard and backup. If one note is
invalid or writing fails, every draft stays available. This includes notes hidden
by search. Selection and cursor stay in place when their view still matches.

Saving or discarding notes before import/export or another pending action now
refreshes the results. Previously, a view could remain listed solely because its
discarded draft or replaced saved note had matched the search. Discard resets the
editor before refreshing, so the discarded note cannot reappear as a new draft.
Saving either one note or all notes also preserves an unfinished view name;
refreshing the current row no longer replaces that text or its cursor/selection.
Explicitly selecting a view still fills its name.

## Development evidence

The extended [filter check](../../tests/saved_views_filter_smoke.gd) passes both
Control and Command shortcuts, shared saves, unchanged file bytes on an empty save,
selection/cursor preservation, invalid-note rejection, real file-open failure,
retry, and updated search results after save/discard. The study-notes and deletion
undo checks also pass. A typed name, its cursor and selected text survive the
shared save; the single-note save also retains the name. [Check index](all-notes-development-qa.json).

The actual bundled note-editor routine passes against the development reference
in headless mode. It creates two drafts, blocks the temporary write with a
directory, confirms that both drafts and the file remain intact, removes its own
fixture and saves both through Ctrl+S. [Probe](all-notes-bundle-check.gd.txt),
[log](all-notes-bundle.log.txt).

The existing real-mouse capture check now saves two notes with **Save all notes**
at the minimum 720 × 500 library size, with the main window at 1100 × 720 and text
at 130%. The button is reachable within the scrollable content; the result stays
visible. Anatomy/camera and inspection/navigation histories remain equal to their
initial values. [Capture check](../../tests/capture_saved_views_undo.gd),
[log](all-notes-captures.log.txt),
[inspected result](../prototype/saved-notes-save-all-minimum.png).

All 60 Python checks pass. [Log](all-notes-python.log.txt).

## Private packages

Exported Linux-runtime and Mac embedded-content checks pass all seven references.
Both run the actual note-editor workflow, including unfinished-name preservation, two pending drafts, write
failure, retained file/drafts, retry through Ctrl+S, cursor/selection preservation
and reopened notes. All recorded runtime hashes remain unchanged at build
completion. Mac content uses the Linux development engine.
[Build report](all-notes-build-report.json), [log](all-notes-build.log.txt).

The exact Windows archive passes native AMD OpenGL workflows for all seven
references, including the two-note failure/retry and unfinished-name checks.
The [native note-editor capture](../prototype/saved-notes-save-all-native.png)
was inspected: two saved notes remain in the open library, and the unfinished view
name keeps its text, cursor and focus. [Native report](all-notes-windows-qa.json),
[runtime log](all-notes-windows-runtime.log.txt).

The report retains 94 capture identities. Four normal launches pass source/title
identity, fresh startup-reference writes, unavailable-reference fallback and
1300 × 800/maximized window restoration. The successful generated session was
removed after copying evidence and independently checked absent.
[Launch observations](all-notes-normal-lifecycle.json),
[evidence hashes and per-reference checks](all-notes-evidence.json).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](all-notes-artifact-audit.json).

Current private archives are under `dist/all-notes-final/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328129705 | `c40374d2e59ad12783dd78e64252a3286958fd18ac1a77bf5ca952653a4a110a` |
| PraxisCorporis-macOS-universal-private.zip | 350575653 | `693470f2d928a7742718359ecd7e80a1c9a27bc950c494d44816ba55951f4b51` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Scripted checks and the software-rendered desktop inspection do not establish
human usability or actual Mac acceptance. Anatomy, source identities, saved-view
schema and medical explanations are unchanged. Learning content remains draft,
with human source and expert review pending.
