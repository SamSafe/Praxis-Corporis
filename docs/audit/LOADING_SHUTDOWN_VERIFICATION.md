# Closing during reference loading

Runtime source `8fe8d58cfeca204100329931123a2d42710e5c1f` collects an owned threaded
resource request before releasing its anatomy model. Checked on 2026-10-16.

Closing during a prepared-scene or picking-shape read previously left one
RefCounted ObjectDB instance reported at process exit. The model now tracks each
successful threaded request, clears ownership after normal collection, and collects
any remaining request on return or exit. The existing source-file reader is still
joined, and staged geometry is freed afterward.

Godot documents that [collecting an unfinished threaded request waits for it to finish](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html#class-resourceloader-method-load-threaded-get).
This cleanup can therefore wait for the current read; no close-time performance
claim is made. Normal reference loading remains asynchronous.

## Reproduction and source evidence

The initial-scene reproduction exits with one reported RefCounted leak before
the fix. A normal close after loading reports none. The replacement picking-shape
case also reproduced the leak. [Initial read, verbose](loading-shutdown-before-initial.log.txt),
[replacement read](loading-shutdown-before-replacement.log.txt),
[ready control](loading-shutdown-ready-control.log.txt),
[reproduction script](loading-shutdown-reproduction.gd.txt).
These before-fix warnings are retained evidence, not current-runtime results.

The repeatable source check passes eight fresh-process cases: initial female opening
and female-to-male replacement at source verification, prepared anatomy, picking-shape reading and
mesh preparation. Each case proves that it closed with the expected owned worker,
resource request or staged scene; cleanup completed; the remembered reference
stayed intact; and the process reported no ObjectDB leak. Recorded inputs match
the committed revision and remain unchanged through the checks.
[Source report and logs](loading-shutdown-source/report.json).

```sh
python3 tools/check_loading_shutdown.py --godot /path/to/godot --output dist/shutdown-source-qa
```

Normal responsive loading, failed replacements and cancellation checks pass.
Cancellation now also asserts an empty pending-request field. A separate probe
returns from expanded anatomy during a live replacement picking-shape request;
the scene stays attached and the male reference completes with 788 meshes.
[Loading](loading-shutdown-loading.log.txt), [cancellation](loading-shutdown-cancel.log.txt),
[layout probe](loading-shutdown-layout.log.txt), [layout script](loading-shutdown-layout.gd.txt).

All 63 Python checks pass, including rejection of missing, mismatched or duplicate
shutdown markers, reported errors and late ObjectDB leaks.
[Python log](loading-shutdown-python.log.txt).

## Private packages

Exported Linux-runtime and Mac embedded-content checks pass all seven references
and two separate early-close processes: initial anatomy and replacement picking
shapes. Each early-close command must emit its exact cleanup marker and report no
error or ObjectDB leak, including warnings after the marker. Recorded runtime
inputs remain unchanged at build completion. Mac content uses the Linux
development engine. [Build report](loading-shutdown-build-report.json),
[log](loading-shutdown-build.log.txt).

Later qualification: the older Linux bundle runner did not reject every engine
error. A single-menu Linux-template reproduction now reports focus-connection
errors, so this report's Linux workflow markers do not establish an error-free
runtime. The two shutdown checks already rejected errors and leaks. Mac content
and native Windows have separate evidence. [Reproduction and stricter checks](POPUP_TEMPLATE_VERIFICATION.md).

The exact Windows archive passes both early-close processes using native AMD
OpenGL. Each closes with an owned request, reports completed cleanup and exits
without an ObjectDB leak. The replacement case also proves staged-scene release.
Saved views and preference/reference/window files keep their bytes, modification
times and file identities. [Initial close](loading-shutdown-native-initial-anatomy.log.txt),
[replacement close](loading-shutdown-native-replacement-selection.log.txt),
[native report](loading-shutdown-windows-qa.json).

Standard native workflows pass all seven references and retain 94 capture
identities. Four normal launches pass source/title identity, fresh startup-reference
writes, unavailable-reference fallback and 1300 × 800/maximized window restoration.
The successful generated session was removed after retaining evidence and
independently checked absent. [Runtime log](loading-shutdown-windows-runtime.log.txt),
[launch observations](loading-shutdown-normal-lifecycle.json),
[evidence hashes](loading-shutdown-evidence.json).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](loading-shutdown-artifact-audit.json).

Current private archives are under `dist/loading-shutdown-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328135211 | `5ced04c9c77c41fa5a438f2a7846dc872a2e9bea4c8ea9f98f5f0bbe88475d60` |
| PraxisCorporis-macOS-universal-private.zip | 350581114 | `8e11e645837bc3ac88741560f33b11273ef9abaf0edd0a9ba9050d7d587027ef` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These are scripted checks of the recorded shutdown boundaries, not a general
memory-leak certification or human platform acceptance. Actual Mac execution
remains pending. Anatomy, source identities, saved-view formats and medical text
are unchanged. Learning content remains draft, with human source and expert review
pending.
