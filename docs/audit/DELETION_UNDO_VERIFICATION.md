# Undo saved-view deletion

Runtime source `75d13945c7e8f3bcfc32c84c030df273d016861f` adds one-step **Undo delete** to the open Saved views
window. Checked on 2026-10-16. It restores the deleted entry's identity, date,
snapshot, saved notes and prior list position where possible. A deleted unsaved
note returns as a draft, with the existing save/discard/keep-editing protection.
Undo never restores the anatomy or camera.

The undo record stays in memory for this window only. A later confirmed deletion
replaces it; successful undo clears it. Failed deletion preserves an earlier undo.
Failed undo retains its record and reports the error. Writes reuse the library's
atomic replacement, backup, file-fingerprint and size checks. Existing identities
and names cannot be overwritten. No storage schema or anatomy IDs change.

## Development evidence

Seven affected engine checks pass: deletion undo, named-view storage, notes,
filtering, recovery, portable transfer and export boundary. The undo check covers
real write failures, external file changes, name and identifier conflicts, invalid
entries, library capacity, original order and snapshots, pending drafts, retry and
window lifetime. [Check index](deletion-undo-development-qa.json).

All 60 Python checks pass. [Log](deletion-undo-python.log.txt).

Real mouse clicks pass at 1100 × 720 with 130% text and the library's minimum
720 × 500 logical size. The feedback and Undo button remain visible outside the
scrolling content. Recovered notes can be saved, and reopening retains the restored
view. Camera, anatomy edits, undo/redo and navigation histories remain equal to
their initial values. [Capture check](../../tests/capture_saved_views_undo.gd),
[log](deletion-undo-captures.log.txt),
[Undo offer](../prototype/saved-view-delete-undo.png),
[recovered draft](../prototype/saved-view-delete-restored.png).
The software-rendered capture session uses the engine's dummy-audio fallback after
the host audio driver fails; the app has no audio workflow.

## Private packages

Exported Linux-runtime and Mac embedded-content checks pass all seven references,
including deletion undo with each reference's actual snapshot. Runtime hashes
remain unchanged at build completion. Mac content is exercised by the Linux
development engine. [Build report](deletion-undo-build-report.json),
[log](deletion-undo-build.log.txt).

The exact Windows archive passes native AMD OpenGL workflows for all seven
references. Both storage undo and rendered-library undo pass with every reference;
the restored saved entry equals its original and its unfinished note remains a
draft. The [native restored-note capture](../prototype/saved-view-delete-native-restored.png)
was inspected. [Native report](deletion-undo-windows-qa.json),
[runtime log](deletion-undo-windows-runtime.log.txt).

The report retains 94 capture identities. Four normal launches pass source/title
identity, fresh startup-reference writes, unavailable-reference fallback and
1300 × 800/maximized window restoration. The successful generated session was
removed after copying evidence and independently checked absent.
[Launch observations](deletion-undo-normal-lifecycle.json),
[evidence hashes and undo observations](deletion-undo-evidence.json).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](deletion-undo-artifact-audit.json).

Current private archives are under `dist/deletion-undo-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328127114 | `dc3e3e0ae2ac87ff98a873a11c3fb749ce3608137cb1d5575ecdd3164eeba1cc` |
| PraxisCorporis-macOS-universal-private.zip | 350573016 | `bfc38bf842a7e48ea02c787eb7e25eb3c86ce3773a9bc6de1c69cf772c76363f` |

## Limits

Scripted verification does not establish human usability or Mac device acceptance.
Anatomy and medical explanations are unchanged; learning content remains draft,
with human source and expert review pending. The anatomy pack remains 624166432
bytes, SHA-256 `5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
