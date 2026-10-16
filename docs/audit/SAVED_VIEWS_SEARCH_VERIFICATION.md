# Saved-view search verification

Runtime source `14b624083afbde0335a5f3805293b583be952839` includes feature checkpoint `e8855c8` and usage-guide
checkpoint `9ca77d1`. Source checks and
desktop layout trials were run on 2026-10-16. Package verification is recorded below.

The saved-view library searches names, saved notes and unsaved note drafts. Every
query word must match, regardless of word order or letter case. The count covers
all stored views, including the last entry of a 200-view library. Filtering alone
preserves file bytes, snapshots and draft text. A hidden selection is cleared;
the app does not select or restore another view automatically.

Ctrl+F focuses search. Enter selects a matching row without restoring anatomy;
Escape clears a nonempty focused search. Escape from the note editor uses the
existing draft-protection choices. A filtered-out draft still protects close.
Saving or renaming a view reveals it when the active query would otherwise hide
it. Saving notes refreshes matches, and changing the filter cancels pending deletion.

## Source and desktop evidence

| Check | Retained result |
|---|---|
| Python | 56 checks pass. [Log](saved-view-search-python.log.txt). |
| Affected engine checks | Six scripts pass: full-library filtering/drafts, note editor/shutdown, named view storage, keyboard workspace, portable views/preferences and export boundary. [Indexed logs and hashes](saved-view-search-development-qa.json). |
| Cursor correction | Final search and note-editor checks pass. Saving or filtering the same selected note preserves its cursor; the direct multiline observation stays at line 1, column 8. [Final checks](saved-view-search-cursor-qa.json). |
| Actual Linux desktop | At an app size of 1100 × 720 with 130% text, native GUI events save views and notes, preserve text undo, protect unsaved drafts and restore the original reference. Search matches saved notes. [Log](saved-view-search-linux-rendered.log.txt). Software rendering provides no performance result. |
| Minimum dialog | At 720 × 500, action buttons stay inside the dialog. Ctrl+F from the note editor brings search into view through the scroll container. [Inspected screen](../prototype/saved-view-search-minimum.png). |

The first large-text layout trial exposed clipped actions in the previous layout;
[its failure log](saved-view-search-overflow-found.log.txt) is retained. The fixed
dialog keeps the heading and actions outside its scrolling content and uses a
taller initial size bounded by the available window. Keyboard focus brings controls
into view. [Inspected compact screen](../prototype/saved-view-search.png).
These layout captures use `9ca77d1`; the later cursor correction preserves that layout.

The first rebuilt Windows archive passed its then-existing checks, but an additional
note-editing observation found that refreshing search reset the cursor after Save.
The final code avoids replacing unchanged editor text and explicitly checks cursor
preservation in the exported note-editor workflow. The intermediate
[build identity](saved-view-search-initial-build-report.json) and
[Windows report](saved-view-search-initial-windows-qa.json) remain historical evidence.

## Package evidence

The final Linux exported runtime and Mac embedded content pass all seven references,
including missing-content handling. Mac embedded content runs on the development
engine. [Build report](saved-view-search-build-report.json),
[build log](saved-view-search-build.log.txt).

The exact final Windows archive passes native AMD OpenGL checks for all seven
references. The exported note-editor workflow checks search/no-match behavior,
Enter selection, Ctrl+F/Escape, unchanged library bytes, note persistence and cursor
preservation. The report retains 94 capture identities.
[Native report](saved-view-search-windows-qa.json),
[runtime log](saved-view-search-windows-runtime.log.txt),
[inspected final Windows dialog](../prototype/saved-view-search-native-windows.png).

The three normal launches also pass 1300 × 800 size restoration, maximized reopen
and return to the original windowed size. Scripted QA leaves its seeded desktop
settings unchanged. [Lifecycle observations](saved-view-search-window-lifecycle.json).
The generated successful session was removed after evidence copying and independently
checked absent. [Evidence hashes](saved-view-search-evidence.json).

Archive CRCs, executable architectures, notices, committed runtime hashes and Mac
content/seal checks pass. [Archive audit](saved-view-search-artifact-audit.json).

Current private archives are under `dist/saved-view-search-final/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328114868 | `a246e1a537307b3cb946393c00ab3bb4f1b830ec43fcee8f41955e2ee2106c79` |
| PraxisCorporis-macOS-universal-private.zip | 350560849 | `e7b0a96e62a5c5b75d8e1f7dd5be0f8b6f82c6aaa2412d0fa35ae46f1fcc19c8` |

## Limits

Saved-view schema, source geometry and anatomy mappings are unchanged. Search
does not add medical content or infer relationships from personal notes. All
authored learning content remains draft with human source and expert review pending.
Human usability, accessibility and native Mac execution remain separate trials.
The anatomy pack remains 624166432 bytes with SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
No new sustained-performance result or public release is claimed.
