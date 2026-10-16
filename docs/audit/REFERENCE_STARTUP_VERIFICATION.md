# Remembered reference startup

Runtime source `423bdd5b65b9278bdd50cd7e53fc6201247005eb` follows feature checkpoint
`2155ac9`. Checked on 2026-10-16.

A normal desktop close saves the last successfully loaded reference ID and its
source fingerprint in `user://reference-state.json`. Reopening uses that reference's
default anatomy view. Named views retain camera, inspection edits, labels and notes.
The main window title identifies the successfully loaded reference.

Startup compares the saved ID and fingerprint with the installed catalogue. An
invalid, removed or changed choice falls back to the female reference and leaves a
readable status message. If a matched reference's asset cannot load during initial
startup, the app also tries the female reference. A failed later switch preserves
the current exploration and completed reference. Reading/fallback alone does not
rewrite the startup file. An accepted normal close saves the completed load;
canceling an unsaved-note close does not save startup or window state.

## Source evidence

| Check | Retained result |
|---|---|
| Engine | Eight affected scripts pass: every supplied startup identity, real male/study startup, failed-load fallback, protected close, loading transactions, viewer/workspace state, portable preferences and export boundary. [Index and hashes](reference-startup-development-qa.json). |
| Python | 60 checks pass, including validation that normal startup must provide loaded-reference titles, exact saved identities and fresh file writes. [Log](reference-startup-python.log.txt). |
| Protocol syntax | The generated four-launch protocol parses with native Windows PowerShell. [Result](reference-startup-protocol-syntax.log.txt). Runtime execution is separate below. |

The source startup check loads the actual male reference, switches to the independent
female cord study, then starts a fresh viewer with an unavailable remembered male
asset. It verifies the actual female fallback, title, completed-load record and
unchanged startup bytes until an explicit save.

## Package evidence

The final Linux exported runtime and Mac embedded content pass all seven references,
including missing-content handling, source recovery and existing study workflows.
Mac embedded content uses the development engine. Runtime hashes and the script set
remain unchanged at build completion. [Build report](reference-startup-build-report.json),
[build log](reference-startup-build.log.txt).

The exact Windows archive passes native AMD OpenGL workflows for all seven
references, retaining 94 capture identities. Scripted QA leaves both seeded startup
and window settings unchanged. [Native report](reference-startup-windows-qa.json),
[runtime log](reference-startup-windows-runtime.log.txt).

Four separate normal launches pass:

| Launch | Observed reference | Loaded meshes | Saved identity |
|---|---|---:|---|
| First | Male reference (HRA v1.1) | 788 | `male`, exact source hash |
| Reopen | Male reference (HRA v1.1) | 788 | `male`, same source hash |
| Separate study | Female cord · HRA study | 29 | `hra-v1-2-female-cord-study`, exact source hash |
| Unavailable-choice fallback | Female reference (HRA v1.1) | 801 | `female`, exact source hash |

The protocol waits for actual main-window titles set after successful loading,
compares source identities written on shutdown and checks that each owned file's
write time changes. All four fresh-write observations pass. Engine logs independently
show the expected loading identity and prepared mesh count. These launches use no
QA user arguments; APPDATA/LOCALAPPDATA are isolated.
[Observations](reference-startup-normal-lifecycle.json),
[protocol output](reference-startup-normal-runtime.log.txt).

The existing 1300 × 800 reopen, maximized startup and unmaximize lifecycle also
passes. Every normal process exits without engine errors. The successful generated
session was removed after copying evidence and independently checked absent.
[Evidence hashes](reference-startup-evidence.json) include all four engine logs,
saved reference records and window records.

Archive CRCs, architectures, notices, committed runtime hashes and Mac content/seal
checks pass. [Audit](reference-startup-artifact-audit.json).

Current private archives are under `dist/reference-startup-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328120505 | `e38d93f821f2d9fdbf20c718302cf33f5e28da2aac8e18c2da65dcafda8a6c36` |
| PraxisCorporis-macOS-universal-private.zip | 350566295 | `2a8f8615bcee09196a56c9e472b81ac7d806336e655572893e442a8a65b89f8b` |

## Limits

Startup persistence stores no anatomy edits or personal notes. Reference geometry,
source identities and named-view formats are unchanged. Learning content remains
draft, with human source and expert review pending. Native Mac execution, human
usability/accessibility and public release gates remain open. These checks provide
no new sustained-performance result.
The anatomy pack remains 624166432 bytes with SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
