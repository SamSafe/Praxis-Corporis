# Keep cursors and typing groups within the selected note

Source `c6830a05cfce1a6e54a344c4f4d73388dab900be` prevents extra cursors from
carrying into another saved note with equal text. The browser reuses one editor;
previously, two cursors in note A remained after keyboard list navigation selected
an identical note B. Typing one character then inserted it at both old positions.
Checked on 2026-10-17 (America/Edmonton).

Selecting a new note now ends the previous typing action, removes extra cursors,
clears selection and moves the remaining cursor to the beginning before clearing
Undo history. Ending the typing action also prevents an unfinished group from
leaving an invalid Undo chain in the next note. The pinned engine's
[typing/history implementation](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/scene/gui/text_edit.cpp)
maintains this action state separately from the history list.

The [probe](note-carets-probe.gd.txt) sets up two real editor cursors, then uses
the actual list Down key and an ordinary character-key event.
[Before](note-carets-before.log.txt), note B has two cursors and the character
appears twice. [After](note-carets-after.log.txt), B has one cursor at the beginning
and the character appears once. No clipboard operation is used.

## Development checks

The [cursor check](../../tests/note_carets_smoke.gd) passes all seven references
with workspace/expanded anatomy and 100%/130% text (28 contexts). Multiline,
Unicode, emoji and combining-character notes are included. Cursor setup uses the
editor API; list navigation, character entry, selection and Undo use keyboard
events through the actual browser window.

The check verifies that filtering, renaming and saving the same note retain its
two cursor positions and editor history. It then switches to an equal-text note
using list navigation: one cursor starts at line/column zero, one key inserts once,
and Undo removes only that note's new edit. The original draft and main/backup
file bytes remain intact. A different-text switch while typing also starts a clean
Undo chain.

With editor focus retained, refreshing/saving the same note preserves its text
selection. An identity change clears that selection without depending on focus
loss. Normal focus changes still use the editor's usual deselection behavior.
Anatomy, camera and inspection/navigation histories remain intact.
[Development log](note-carets-development.log.txt).

Existing note-history, study-note protection and unfinished-note export checks pass.
All 85 Python checks pass, including rejection of missing per-reference cursor
evidence. [History](note-carets-history.log.txt), [notes](note-carets-notes.log.txt),
[export](note-carets-export.log.txt), [Python](note-carets-python.log.txt),
[check identities](note-carets-development-qa.json).

## Private packages

The exact Windows archive passes all 28 cursor contexts across seven references,
including list-key navigation, character entry, selection and Undo. Existing
note-history checks pass as well. The run retains 107 capture identities and passes
543 cached/continuous scene pixel comparisons. Four normal launches pass window
and reference restoration/fallback. Two early closes collect owned resources while
preserving user-file bytes, times and identities. No runtime error, Unicode
replacement diagnostic or ObjectDB leak is reported. The marked QA session was
removed and independently checked absent.
[Native report](note-carets-windows-qa.json), [runtime](note-carets-windows-runtime.log.txt),
[normal launches](note-carets-normal-lifecycle.json),
[initial close](note-carets-native-initial-anatomy.log.txt),
[replacement close](note-carets-native-replacement-selection.log.txt).

The build checks unchanged runtime inputs, the embedded Mac resource boundary,
all seven workflows and both shutdown cases on the development engine. The
independent archive audit passes committed source hashes, ZIP-entry CRCs, notices,
architectures, the unchanged anatomy fingerprint and Mac resource-seal presence.
[Build report](note-carets-build-report.json), [build log](note-carets-build.log.txt),
[audit](note-carets-artifact-audit.json), [evidence identities](note-carets-evidence.json).

Private archives are under `dist/note-caret-improvements/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328203588 | `4ab3cc70404e64f9594742366f6dbb4efc9eff338526a93b77ab71e34d234f18` |
| PraxisCorporis-macOS-universal-private.zip | 350649495 | `bcbad6ee62f101b40b4007eea7d5492240bb4e307112a30962b0abdb6c18c64b` |

Switching notes starts fresh editor history/cursor state; each note's unfinished
text remains attached to its saved-view identity. Source geometry, medical text,
review stages, note limits and saved-view format are unchanged. Actual Mac
execution, human OS-input/accessibility acceptance and public-release gates remain
open. The embedded Mac-resource check uses the development engine. The separate
Linux release-template popup qualification remains open.
