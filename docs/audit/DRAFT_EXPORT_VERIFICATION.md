# Export unfinished notes without saving or discarding them

Source `04300ba172d89ff32c404d08892ac53f539c2577` makes **Export all views** include this window's unfinished
note drafts, including drafts hidden by search. The active library, its backup,
loaded entries, drafts and editor state remain unchanged. Checked on 2026-10-17
(America/Edmonton).

The [probe](draft-export-before.gd.txt), [picker spy](draft-export-picker-probe.gd.txt),
[before](draft-export-before.log.txt) and [after](draft-export-after.log.txt) show
Save correctly refusing to replace a newer library. Previously, Export required
a Save/Discard decision, and the saved-only backend copy omitted the unfinished
note. Export now reaches its picker directly and the export handler includes the
draft. The probe's final legacy-labelled line changes from false to true.

The file uses the existing importable saved-view format. Names, identities, dates
and anatomy snapshots remain attached to their notes. Export keeps working when a
newer on-disk library blocks Save, because it writes a separate copy of this
window's views. The picker labels unfinished notes and uses a `views-and-drafts`
default filename. Export success states that drafts remain open. Closing, importing
or restoring still uses the existing note-protection choices.

## Development checks

The [working-draft check](../../tests/draft_export_smoke.gd) passes all seven real
references. Each case has three saved views, two unfinished notes and a filter
showing only one view. Another reader changes a saved note and adds a fourth view.
The stale Save fails; Export through the actual button/Enter path proceeds without
a note decision. The exported three-view copy includes both drafts and retains
all other entry fields. Newer main/backup bytes, loaded entries, draft maps, filter,
selection, the typed name, caret, anatomy/camera and histories stay intact.

The platform picker handoff is spied; the actual `FileDialog` title and filename
are checked without opening it. The export file handler and file writes are real.
Importing that backup into the newer library adds the two changed-note copies,
skips the unchanged entry and retains every newer record. Invalid notes, missing
IDs, protected destinations and a missing output folder leave the output/drafts
intact. [Development log](draft-export-development.log.txt).

The [size-limit check](../../tests/draft_export_limits_smoke.gd) starts with a library payload
under the 32-MiB limit then adds a valid 10,000-character emoji note that pushes the
serialized output over that limit. It rejects the export without replacing an
existing file or changing the saved note. [Log](draft-export-limits.log.txt).

Existing note protection, Unicode integrity, portable-view/preferences and export
path/link safeguards pass. All 81 Python checks pass, including rejection of
missing reference/capture evidence for working-draft export.
[Notes](draft-export-notes.log.txt), [encoding](draft-export-encoding.log.txt),
[portable](draft-export-portable.log.txt), [path safeguards](draft-export-safeguards.log.txt),
[Python](draft-export-python.log.txt), [check identities](draft-export-development-qa.json).

Medical text/review stages, sources, geometry/identities, saved-view format,
200-view/32-MiB/10,000-character limits and inspection history are unchanged.
All fixture files are disposable. No browser/network request or clipboard access occurs.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, all seven reference workflows including unfinished-note backup/import
checks, and two loading-shutdown cases on the development engine. This does not
establish actual Mac execution. [Build report](draft-export-build-report.json),
[build log](draft-export-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, including two drafts (one hidden), a newer four-view library blocking
Save, export through the actual button/Enter path with a spied picker handoff,
protected output failures and explicit compatible import retaining newer records.
The workflow retains 107 capture identities. The
[130% export feedback](../prototype/draft-export-windows.png) was visually inspected:
the filtered one-of-three list, current note, typed name and success message are
readable, and the message states that two unfinished drafts remain open.

Four normal launches pass reference/window restoration and unavailable-reference
fallback. Two early-close processes pass resource cleanup while preserving
user-file bytes, modification times and identities. No runtime error, decoder
replacement diagnostic or ObjectDB leak is reported. The successful isolated
session was removed and independently checked absent.
[Native report](draft-export-windows-qa.json),
[runtime log](draft-export-windows-runtime.log.txt),
[normal launches](draft-export-normal-lifecycle.json),
[initial close](draft-export-native-initial-anatomy.log.txt),
[replacement close](draft-export-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](draft-export-artifact-audit.json).
[Evidence identities](draft-export-evidence.json) bind the retained results.

Private archives are under `dist/draft-export-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328190403 | `e8a1afcc12a4f887cc2ee20584ad953f69763e72cc776508bd2b12948199f3e8` |
| PraxisCorporis-macOS-universal-private.zip | 350635880 | `5f3dbe92aa0fe2fc5245352c49d61cf27e104d16e4c418ae20074a36195e839f` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

The native file picker is not opened by these checks. Human file-picker/device and
accessibility acceptance, representative laptops and actual Mac execution remain
pending. The independent [Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md)
remains open; Linux is not a release target. Human source and expert medical review
remain pending.
