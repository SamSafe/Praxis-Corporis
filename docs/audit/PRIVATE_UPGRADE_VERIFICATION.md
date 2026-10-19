# Private Windows upgrade and rollback

The recorded Windows pair passes a native old → current → old → current cycle.
Checked 2026-10-18 local time (2026-10-19 UTC in the report). The app archives and
anatomy are unchanged; this batch adds compatibility verification and a
[backup/update procedure](../PRIVATE_UPDATE_TRIAL.md).
Verifier/tests are checkpointed at `985ca23`; the packaged application remains
source `c86cfba`. [Native verifier](../../tools/upgrade_windows.py).

| Role | Runtime source | Windows archive SHA-256 |
| --- | --- | --- |
| Older private build | `9e864a0df24a973ce1245b7db420fb2a4354bb1f` | `33fc0c1e06fd4515dc55f764408839b51ea6f49265b0fa58f34bdbf985614310` |
| Current private build | `c86cfba1e544b20917b66c14ea405f0b74abfd47` | `7518559369a6b55f20fbcf37363b47edb5013e666136b675469426e35b649ec4` |

The current build ID is `f962ce195f324c89a400cf07d8767c9d`. The older archive predates
embedded build identification. Both declare application version `0.1.0`; these
results identify the exact private archives rather than a general version range.
Both use the same seven reference geometries and schema-1 local library/settings.

## Native cycle

The verifier validates both archives and committed source snapshots, extracts fresh
marked copies, and starts their actual Windows executables. Normal launch arguments
keep persistence enabled. Generated APPDATA/LOCALAPPDATA directories isolate all
fictional notes and settings from the user's library.

1. Seven older-build launches create one view per reference through native controls:
   select a supplied mesh, fade it, inspect alone and move it by a keyboard step.
   Save a named view and multiline `Café λ 🫀` notes, including hyphenated reference IDs.
2. The current build restores all seven older views and saves seven new views/notes.
3. The older build restores all seven current views and saves seven rollback views.
4. The current build restores all seven rollback views and saves seven reopened views.

All **10 launches close normally**, with exit code 0 and no forced termination.
All **28 views** remain, with the existing IDs, names, timestamps and notes preserved
at each step. The **21 complete scene comparisons** retain reference/source identity,
selection, camera, isolation/Return to context, label settings, movement and
hidden/faded visibility. Scene numbers allow absolute/relative `1e-12` tolerance for
JSON decimal reserialization; keys, strings and booleans retain exact comparisons.
The original-entry metadata and note comparisons remain exact.

Device preferences remain byte-for-byte unchanged: 115% text, 75% 3D resolution,
both panels shown, selection labels off, local labels on and density 5. Every launch
restores the 1300 × 800 client size. Baseline launches seed each chosen reference;
the three version-switch launches read the reference remembered by the previous
normal close. Runtime logs contain no engine error, Unicode parsing diagnostic or
ObjectDB leak. The marked session is removed and independently checked absent.

[Native report](private-upgrade-windows-report.json),
[controller completion log](private-upgrade-controller.log.txt),
[retained evidence identities](private-upgrade-evidence.json).
The report records each runtime-log hash, process exit, initial reference/window,
completed cases, tool identities and detailed evidence hashes. All ten runtime logs
are retained beside it. Full per-launch profiles remain under `dist/upgrade-candidate-pair/`.

The phase libraries are retained for inspection:
[older baseline](private-upgrade-baseline-library.json),
[upgrade](private-upgrade-forward-library.json),
[rollback](private-upgrade-rollback-library.json),
[reopen](private-upgrade-reopen-library.json).
All names and notes in these files are fictional QA fixtures.

## Verification controls

All **98 Python tests** pass. Seven alterations to the real successful profiles or
runtime log are rejected: a missing original view, changed original notes, lost
Unicode in new notes, changed camera, lost movement, changed inspection return and
an engine error appended to an otherwise successful log.
[Python checks](private-upgrade-python.log.txt),
[altered real-data results](private-upgrade-negative-controls.json),
[control procedure](private-upgrade-negative-controls.py.txt).

Native interaction uses UI Automation plus messages addressed to the generated
process's own window. The test brings that window forward when focusing fields,
scrolls its details panel to expose clipped actions, pairs punctuation key/character
events and uses unique fixture-name tokens to avoid ambiguous broad search results.
It never uses global keyboard injection or the clipboard. Earlier diagnostic
sessions closed normally and were removed; they are not passing compatibility runs.

## Limits

This verifies seven representative saved scenes for this exact Windows pair with
unchanged geometry and schemas. It does not qualify Mac, arbitrary older versions,
changed content/schemas, legacy quick-save migration, installers, an automatic
updater, human input-device usability or assistive-technology conformance.
Actual Mac, content review and distribution acceptance remain open in the
[production checkpoint](../PRODUCTION_READINESS.md).
