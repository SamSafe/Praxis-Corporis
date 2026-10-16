# Cancel reference opening and resume study

Runtime source `036ac8faf866aa06fb1fb4b91e35488b6c1f45fe` follows feature checkpoint
`b8d7ea8`. Checked on 2026-10-16.

After one reference is open, **Cancel opening** is available while replacing it in
the workspace or expanded scene. Cancellation retains the exact current anatomy,
camera, labels, isolation, inspection edits, Move mode and edit/navigation histories.
The title, reference selector, source context and remembered startup identity stay
with the completed reference. Keyboard focus returns to anatomy when loading ends.

Guide/route controls pause while a replacement is pending. Canceling or failing
that replacement resumes the same step, route branch/history and original return
context. This also covers a different-reference saved-view restoration. A successful
switch ends the study and restores its original viewing controls before fitting
the new anatomy.

Cancellation is cooperative: a pending file/resource read is allowed to finish and
its result is collected before staging is discarded. A completed source worker is
joined. The old scene is replaced only after the final cancellation check. This
does not promise immediate interruption of scene instantiation or another indivisible
engine operation.

## Evidence

| Check | Retained result |
|---|---|
| Engine | Ten affected scripts pass, including cancellation at seven boundaries, both histories, real scene identity, released staging/workers, guide/route restoration, canceled bookmark restoration and a successful retry. Existing loading, routes, workspace, saved views/notes, startup, picking cache, scene display and export checks pass. [Index and hashes](cancel-opening-development-qa.json). |
| Python | 60 checks pass. [Log](cancel-opening-python.log.txt). |
| Actual desktop input | At 1100 × 720 with 130% text, real mouse clicks cancel in both layouts. The exact view survives, staged work is released, keyboard focus returns and the same source can load afterward. [Log](cancel-opening-desktop.log.txt). |
| Rendered review | Cancel actions fit the compact window; the resumed chest guide leaves anatomy visible. Screens: [workspace](../prototype/cancel-opening-workspace.png), [expanded](../prototype/cancel-opening-expanded.png), [resumed guide](../prototype/cancel-opening-resumed-guide.png). Software rendering establishes no performance result. |

Visual review caught a reshow/layout bug after the first button-input checks: the
expanded guide could retain an excessive height and cover the anatomy.
[Before image](../prototype/cancel-opening-guide-layout-before.png). The guide now
fits its computed content height; the desktop check explicitly requires room for
anatomy below it. Numeric state checks alone did not establish that layout result.

## Private packages

Linux exported-runtime and Mac embedded-content checks pass all seven references,
including the staged-cancellation and guide-restoration probe. Mac content uses
the development engine. Recorded runtime inputs remain unchanged at completion.
[Build report](cancel-opening-build-report.json), [build log](cancel-opening-build.log.txt).

The exact Windows archive passes native AMD OpenGL checks for all seven references.
Its cancellation probe opens a real chest guide, stages the male reference through
selection loading, cancels and verifies released staging plus the exact live guide
and original return state. The marker is present once; the process finishes without
engine errors. The report retains 94 capture identities and the existing workflows.
[Native report](cancel-opening-windows-qa.json),
[runtime log](cancel-opening-windows-runtime.log.txt).

Four normal launches also pass remembered male/study startup, unavailable-choice
fallback, fresh reference writes and the 1300 × 800/maximized window lifecycle.
[Observations](cancel-opening-normal-lifecycle.json). Both scripted-QA preference
fixtures remain unchanged. The successful generated session was removed after
copying evidence and independently checked absent. [Evidence hashes](cancel-opening-evidence.json).

Archive CRCs, architectures, notices, committed runtime hashes and Mac content/seal
checks pass. [Audit](cancel-opening-artifact-audit.json).

Current private archives are under `dist/cancel-opening-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328122439 | `0f370bbe39cdf06e6292cb0d47300530e4c90a44aefb4d8b5d0df4ee3ea41eae` |
| PraxisCorporis-macOS-universal-private.zip | 350568137 | `0c89a8f9977ddaafe01f07a998e4abcd5bd01c569f60397e2d5cc891931a3e87` |

## Limits

Source geometry, anatomy identities and saved-view formats are unchanged. Learning
content remains draft, with human source and expert review pending. Human usability,
accessibility, native Mac execution and public-release gates remain open. No new
sustained-performance or maximum cancellation-latency result is claimed.
The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
