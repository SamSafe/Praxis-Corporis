# Saved-view recovery safeguards

Runtime source `6ca4acf5072391b152d9a7dbd9e86a276d92b1fd` follows recovery checkpoint `3e428e1` and usage-guide
checkpoint `1e7d533`. Checked on 2026-10-16.

Recovery records a fingerprint of the bytes that failed validation. It checks the
current main file before preserving it and again before writing the replacement.
A stale offer reports that Saved views must be reopened. A healthy loaded library
cannot be rolled back through this action. Missing-file recovery also refuses a
replacement created after the offer.

Recovery preserves a damaged original as `.damaged`. If that filename already
exists, it creates `.damaged-<unique ID>` and leaves the earlier copy intact. The
result names the preserved file. It retains the valid `.bak` and restores that
backup's snapshots and notes. Malformed JSON in libraries, imports and backups
produces the app's readable error without an engine JSON parser error. UTF-8 BOM
input remains readable without a rewrite merely from opening it.

The library's feedback now stays outside scrolling content, beside its persistent
action buttons. This keeps save, delete and recovery messages visible at the
minimum dialog size. Keyboard focus still brings search and note controls into view.

## Evidence

| Check | Retained result |
|---|---|
| Initial regression | The initial storage trial reproduced stale recovery, replacement of an earlier damaged copy and engine errors for malformed JSON. Seven assertions failed. [Log](saved-view-recovery-initial-regression.log.txt). |
| Initial affected checks | Six scripts pass after the storage correction: recovery/UI state, search/drafts, portable views, study notes, named libraries and export boundary. [Index and hashes](saved-view-recovery-development-qa.json). |
| Final affected checks | Recovery/feedback, search and note-draft checks pass after the persistent feedback change. Includes rejected stale UI offers, successful recovery and the named copy's exact bytes. [Final index](saved-view-recovery-final-qa.json). |
| Python | 58 checks pass, including changed/deleted input files and newly added runtime scripts. [Log](saved-view-recovery-final-python.log.txt). |
| Actual Linux desktop | Real save/restore, note editing and text undo pass at 1100 × 720 with 130% text. Feedback and actions are checked within the minimum 720 × 500 dialog; Ctrl+F returns to search. [Log](saved-view-recovery-rendered.log.txt), [inspected screen](../prototype/library-feedback-minimum.png). Software rendering provides no performance result. |

The feedback check initially failed because the result label was below the visible
content area. [Regression log](saved-view-recovery-feedback-regression.log.txt).
Moving that label beside the action row resolves the failure.

## Build inputs

The builder compares recorded runtime hashes and the script set again before
recording success. Changed or removed recorded inputs, and newly added runtime
scripts, invalidate that report.
An intermediate export preceded the feedback correction and is marked unverified;
the new check rejects its recorded inputs against the changed working tree.
[Observed rejection](saved-view-recovery-intermediate-rejected.log.txt).
The final build uses a stable runtime snapshot. Archive auditing separately checks
that recorded runtime hashes and notices match the source commit. This guard checks
input equality at completion; it is not a substitute for keeping source stable
throughout export.

## Private packages

Linux exported-runtime and Mac embedded-content checks pass all seven references,
including the disposable recovery protocol. The Mac content check uses the
development engine. The build records `runtime_sources_unchanged: true` after its
completion check. [Build report](saved-view-recovery-build-report.json),
[build log](saved-view-recovery-build.log.txt).

The exact Windows archive passes native AMD OpenGL checks for all seven references,
including recovery with a real source snapshot, retained Unicode notes, rejected
stale offers and an earlier damaged copy. The native recovery marker is present
once, and the process exits without engine errors. The report retains 94 capture
identities and the existing study, search, inspection and note-editor workflows.
[Native report](saved-view-recovery-windows-qa.json),
[runtime log](saved-view-recovery-windows-runtime.log.txt).

Three normal launches also pass the 1300 × 800 and maximized-state lifecycle.
[Observations](saved-view-recovery-window-lifecycle.json). The generated successful
session was removed after evidence copying and independently checked absent.
[Evidence hashes](saved-view-recovery-evidence.json).

Archive CRCs, executable architectures, notices, committed runtime hashes and Mac
content/seal checks pass. [Audit](saved-view-recovery-artifact-audit.json).

Current private archives are under `dist/recovery-final/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328117731 | `f8574888758a2eeb2e50dc9840c79b0aa965c58cc0ce51a67fdb7dc86648c76b` |
| PraxisCorporis-macOS-universal-private.zip | 350563646 | `c8492bb5ee9cc7896ecd2848b817a3f1018cc0f62d5677d347aab318ec761eee` |

## Limits

Saved-view schema, anatomy identities and source geometry are unchanged. Authored
learning content remains draft with human source and expert review pending. Human
usability/accessibility, native Mac execution and public release gates remain open.
The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
These checks provide no new sustained-performance result.
