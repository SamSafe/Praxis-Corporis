# Preserve notes when a saved-view file has damaged text

Source `e3efc07f3efda936ae0d9e974881b8306dda6335` checks saved-view library, import and backup bytes before
text decoding. Malformed UTF-8 or a raw NUL produces a readable error and retains
the input bytes and last known library. Checked on 2026-10-17 (America/Edmonton).

The [probe](text-encoding-before.gd.txt), [before](text-encoding-before.log.txt)
and [after](text-encoding-after.log.txt) show the earlier loader accepting a note
containing byte FF after the decoder replaced it with U+FFFD. A rename then rewrote
the altered note. The new loader rejects that file before decoding. The main-file
fingerprint still covers the original raw bytes, so the existing explicit recovery
can preserve the damaged original and restore a valid backup.

The encoding checks follow the UTF-8 byte boundaries in
[RFC 3629](https://www.rfc-editor.org/info/rfc3629/). Raw NUL is separately rejected
because it is not valid unescaped JSON text and can stop the decoder before the end
([JSON grammar and strings](https://www.rfc-editor.org/rfc/rfc8259.html)).
The check runs before the engine decoder can substitute text or stop at NUL
([Godot 4.7.2 decoder](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/core/string/ustring.cpp)).
No schema or valid-text normalization changes are introduced. Existing JSON and
entry validation still applies after the encoding check.

## Development checks

The [file check](../../tests/saved_views_utf8_smoke.gd) covers 22 malformed payloads:
invalid leaders/continuations, truncation, overlong forms, surrogate/out-of-range
encodings, obsolete lengths, and raw NUL within a note or after a complete JSON
library. It checks rejected imports without library changes, retained in-memory
entries, blocked rename/note/export writes, raw-byte recovery fingerprints, valid
backup recovery and exact damaged-copy bytes. Invalid backups are unavailable and
stale recovery cannot replace a newly healthy main file. Valid Unicode, combining
marks, emoji, a literal replacement character and BOM files retain their text
through load, rename, export and import.
[Development log](text-encoding-development.log.txt).

An independent generator uses Python's strict UTF-8 decoder, excluding raw NUL for
the JSON input layer. The Godot check agrees on **73,996** inputs: every single byte,
every two-byte combination, scalar boundaries, mixed Unicode and deterministic
random longer sequences. This tests encoding, rather than declaring these inputs
valid JSON documents. [Generator](text-encoding-oracle-generator.py.txt),
[Godot check](text-encoding-oracle-check.gd.txt),
[generated identities](text-encoding-oracle-generated.json),
[result](text-encoding-oracle-result.json), [log](text-encoding-oracle.log.txt).
The vector file is reproducible under ignored `build/qa/` using the retained
generator; its SHA-256 binds the result.
Reproduce from the repository root with the pinned Godot engine available as `godot`:

```sh
python3 docs/audit/text-encoding-oracle-generator.py.txt
cp docs/audit/text-encoding-oracle-check.gd.txt build/qa/check_utf8_oracle.gd
godot --headless --path . --script build/qa/check_utf8_oracle.gd
```


Existing recovery, portable-view/preferences and named-library checks pass. All
80 Python checks pass, including rejection of missing reference encoding evidence
and decoder-replacement diagnostics without an ERROR prefix.
[Recovery](text-encoding-recovery.log.txt), [portable](text-encoding-portable.log.txt),
[named library](text-encoding-library.log.txt), [Python](text-encoding-python.log.txt),
[check identities](text-encoding-development-qa.json).

The [scan-only probe](text-encoding-scan-profile.gd.txt) records approximately
6.4 ms for 100,000 ASCII bytes, 128 ms for 2,000,000, and 2.14 seconds at the existing
32-MiB input limit on this development host. It excludes disk and JSON parsing;
this is no end-to-end or representative-laptop responsiveness claim.
[Scan log](text-encoding-scan-development.log.txt).

Medical text/review stages, sources, geometry/identities, saved-view format,
200-view/32-MiB/10,000-character limits and inspection history are unchanged.
All fixtures are disposable; no browser/network request or clipboard access occurs.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, all seven reference workflows, checks for encoding, recovery and Unicode round trips using their actual snapshots, and two loading-shutdown cases on the
development engine. This does not establish actual Mac execution.
[Build report](text-encoding-build-report.json), [build log](text-encoding-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, including 22 malformed payloads per reference (154 trials), protected
imports/edits, exact copies of damaged bytes, recovery guards, and valid Unicode/
BOM import/export using each reference's actual snapshot. The independent oracle with 73,996 inputs above is development-engine evidence; the native check exercises
the file workflows. The full workflow retains 106 capture identities. Four normal
launches pass reference/window restoration and unavailable-reference fallback.
Two early-close processes pass resource cleanup while preserving user-file bytes,
modification times and identities. No runtime error, diagnostic about decoder replacements
or ObjectDB leak is reported. The successful isolated session was removed and
independently checked absent.
[Native report](text-encoding-windows-qa.json),
[runtime log](text-encoding-windows-runtime.log.txt),
[normal launches](text-encoding-normal-lifecycle.json),
[initial close](text-encoding-native-initial-anatomy.log.txt),
[replacement close](text-encoding-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](text-encoding-artifact-audit.json).
[Evidence identities](text-encoding-evidence.json) bind the retained results.

Private archives are under `dist/text-encoding-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328185757 | `f68b319473930d5d6a55787bc71ea74628cd5fea4e722bf1adfb2e01d435368b` |
| PraxisCorporis-macOS-universal-private.zip | 350631610 | `60ec3650d494bdf8e2523154717911eb2f5d9163d8fb9d6961c5cfe4359ef4f2` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Human file-picker/device and accessibility acceptance, representative laptops and
actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human source and expert medical review remain pending.
