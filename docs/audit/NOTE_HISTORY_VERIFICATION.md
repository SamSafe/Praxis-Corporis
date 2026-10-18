# Keep note Undo/Redo within the selected saved view

Source `00df914362d2fafb24a7ba30a7171adf064c2355` fixes editor history leaking between saved notes with identical
current text. Editing note A from `Review` to `Review!`, then selecting an untouched
note B already containing `Review!`, previously left A's Undo operation attached
to B. Undo changed B to `Review` and created an unintended draft.

The browser reuses one text editor and avoids replacing equal text. It now clears
editor history when the saved-view identity changes, including when the text is
equal. Refreshing the same identity retains its own Undo/Redo. Draft notes remain
attached to their existing saved-view IDs. Checked on 2026-10-17
(America/Edmonton).

[Probe](note-history-probe.gd.txt), [before](note-history-before.log.txt) and
[after](note-history-after.log.txt) show the actual editor behavior. Before the fix,
B reports Undo available and changes to `Review`. After the fix, Undo is unavailable
and B remains `Review!` without an unintended draft. Godot's
[TextEdit API](https://docs.godotengine.org/en/stable/classes/class_textedit.html#class-textedit-method-clear-undo-history)
provides the history-clearing operation.

## Development checks

The [keyboard check](../../tests/note_history_smoke.gd) passes all seven real
references, with workspace/expanded anatomy and 100%/130% text (28 contexts).
Contexts include ordinary, Unicode/combining, multiline and empty note text.

Each case edits one note until it matches another, then selects the other note.
Undo and Redo through the editor's configured keyboard shortcuts leave that note
unchanged and preserve the original draft. A separate case builds a Redo chain,
switches to an equal-text note and verifies that Redo cannot migrate either.
The attempted operations leave main/backup library bytes intact.

Filtering, renaming and saving the same note preserve its editor history. Undo
after Save creates the correct draft; Redo returns to the saved text and clears
that draft. Anatomy, camera and both inspection/navigation histories stay intact.
All fixtures are disposable. No clipboard operation occurs.
[Development log](note-history-development.log.txt).

Existing study-note protection and unfinished-note export checks pass. All 84
Python checks pass, including rejection of packages missing note-history evidence
for a reference. [Notes](note-history-notes.log.txt),
[export](note-history-export.log.txt), [Python](note-history-python.log.txt),
[check identities](note-history-development-qa.json).

## Private packages

The exact Windows archive passes the note-history keyboard cases across all seven
references and all 28 contexts. It also retains 107 capture identities and passes
543 cached/continuous scene pixel comparisons. Four normal launches pass
reference/window restoration and unavailable-reference fallback. Two early-close
processes collect owned resources while preserving user-file bytes, times and
identities. No runtime error, Unicode replacement diagnostic or ObjectDB leak is
reported. The marked QA session was removed and independently checked absent.
[Native report](note-history-windows-qa.json), [runtime](note-history-windows-runtime.log.txt),
[normal launches](note-history-normal-lifecycle.json),
[initial close](note-history-native-initial-anatomy.log.txt),
[replacement close](note-history-native-replacement-selection.log.txt).

The build verifies unchanged runtime inputs, the embedded Mac resource boundary,
all seven workflows including note-history checks, and both shutdown cases using
the development engine. The independent archive audit passes committed source
hashes, every ZIP-entry CRC, notices, architectures, the unchanged anatomy
fingerprint and Mac resource-seal presence.
[Build report](note-history-build-report.json), [build log](note-history-build.log.txt),
[artifact audit](note-history-artifact-audit.json), [evidence identities](note-history-evidence.json).

Private archives are under `dist/note-history-improvements/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328200523 | `9738c4e6c73c9d96f674b269306a687b86ac67ad4d2def2417cf2832e9857860` |
| PraxisCorporis-macOS-universal-private.zip | 350646508 | `4153be15c4503ee7f03c4598a48dcb9a9f674fb6ada51eacb52e84b3d20061bb` |

Medical text, review stages, source geometry/IDs, note limits and saved-view format
are unchanged. Editor history remains local to the currently selected note and
starts fresh when switching saved views; unfinished note text is retained separately.
Actual Mac execution, human OS input/accessibility acceptance and public-release
gates remain open. The separate Linux release-template popup qualification remains
open. The embedded Mac-resource check uses the development engine.
