# Saved-view export destination safeguards

Runtime source `0b8e67f8a18ceabb019c063927fe73aec0725fd0` prevents exporting over the active saved-view library
through an alternate filesystem path. Checked on 2026-10-16.

A disposable stale-reader reproduction showed the earlier string comparison
allowing a directory link to overwrite newer saved notes. The new guard compares
filesystem identity, then parent identity and filename for a missing active file.
Case handling follows the destination directory. Independent files with identical
contents remain valid export destinations; the visible library can still be
exported separately without overwriting a newer active file.

The guard uses Godot's [filesystem identity](https://docs.godotengine.org/en/4.7/classes/class_diraccess.html#class-diraccess-method-is-equivalent)
and [case-sensitivity queries](https://docs.godotengine.org/en/4.7/classes/class_diraccess.html#class-diraccess-method-is-case-sensitive).
Paths remain absolute without prematurely collapsing parent segments. A link
followed by parent traversal is rejected before writing; the message asks the
user to choose the folder directly. This avoids the Unix directory helper's
[lexical path simplification](https://github.com/godotengine/godot/blob/4.7-stable/drivers/unix/dir_access_unix.cpp#L52).

## Development evidence

The new [regression check](../../tests/export_safeguards_smoke.gd) covers absolute,
relative and dot-segment spellings; directory, file and backup links; ambiguous
parent traversal; missing active files; case-sensitive filenames; and independent
copies with identical contents. The current code passes. The same regression
against the storage script from `35522f1` fails. Its expected assertion errors are
retained as pre-fix evidence, not current-runtime failures.
[Before](export-guard-before.log.txt), [after](export-guard-development.log.txt).

The exported-runtime safeguard routine also passes in development. It uses each
reference's actual saved snapshot, an intentionally stale reader, newer notes,
letter-case paths, missing-file protection and a separate export. Portable
transfer and backup recovery checks pass. All 60 Python checks pass.
[Check index](export-guard-development-qa.json), [Python log](export-guard-python.log.txt).

## Private packages

Exported Linux-runtime and Mac embedded-content checks pass all seven references,
including the stale-reader export fixture for each reference. They exercise the
case-sensitive branch using the Linux development engine. The runtime hashes
remain unchanged at build completion. [Build report](export-guard-build-report.json),
[log](export-guard-build.log.txt).

The exact Windows archive passes the new fixture on all seven references.
Its actual user-data directory reports case-insensitive filenames; capitalized
aliases to both an existing and a missing active file are rejected, while a
separate copy remains exportable. The newer active notes and stale reader's
memory remain intact. [Native report](export-guard-windows-qa.json),
[runtime log](export-guard-windows-runtime.log.txt).

Standard native AMD OpenGL workflows retain 94 capture identities. Four normal
launches pass source/title identity, fresh startup-reference writes,
unavailable-reference fallback and 1300 × 800/maximized window restoration.
The successful generated session was removed after copying evidence and
independently checked absent. [Launch observations](export-guard-normal-lifecycle.json),
[evidence hashes and per-reference checks](export-guard-evidence.json).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](export-guard-artifact-audit.json).

Current private archives are under `dist/export-guard-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328132805 | `b054d6b54036b1aaa98f9c8c95002b8ccc7eab6c79394b02fef4e25304098a51` |
| PraxisCorporis-macOS-universal-private.zip | 350578546 | `366a720ab1842a5ee85bd4df4b9a8817423c9280e846205eab4cd022d88379b7` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Development link fixtures run on Linux. The Windows run checks letter-case
aliases on its actual filesystem; it does not establish Windows junction or
Mac device acceptance.
Anatomy, source identities, saved-view schema and medical text are unchanged.
Learning content remains draft, with human source and expert review pending.
