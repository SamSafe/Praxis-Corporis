# Native source snapshots include scenes and resource identities

Source `6a878b7` closes a build-verification gap: the previous guard recorded
scripts and selected configuration/content, but omitted the startup scene. A
startup-scene edit could therefore pass the guard. Checked on 2026-10-18
(America/Edmonton).

The [probe](source-snapshot-probe.py.txt) copies inputs to a disposable fixture
and changes `anchor_right` in `scenes/main.tscn` from 1.0 to 0.5.
[Before](source-snapshot-before.json), the guard accepts that change.
[After](source-snapshot-after.json), a complete snapshot records the scene and
rejects the same edit. The real project scene is untouched.

## Expanded input contract

Snapshot version 2 covers project/export settings, every file under `scripts/`,
`scenes/`, `content/` and `addons/private_native_export/`, plus the native builder,
anatomy packer and shared input collector. This includes resource UID files,
plugin configuration and nested resources. The real build records **75 inputs**,
compared with the previous 41. The builder checks every recorded hash and the
complete file set before recording success. Changed/deleted inputs or new resources
cause rejection. Documentation and QA outputs remain outside those input directories.

The auditor derives the required resource paths from the recorded Git tree, using
the same scope. A revision containing the new collector requires version 2;
omitting the version or downgrading it cannot bypass the scene/UID requirement.
Historical revisions keep the original version 1 checks, explicitly labeled with
their narrower scope. The prior real archives still pass their
[legacy audit](source-snapshot-legacy-audit.json), which reports that the startup
scene and UIDs were not recorded.

All **90 Python checks pass**. Added checks reject scene, UID, plugin and packer
changes/deletions; added nested scripts/scenes/content/UIDs; incomplete committed
resource lists; and a missing/downgraded snapshot version. An independent documentation
edit remains permissible. [Python log](source-snapshot-python.log.txt).
Six [altered real-report controls](source-snapshot-negative-audits.json) are also
rejected: missing scene, missing UID, wrong scene hash, version downgrade, absent
version and an extra uncommitted scene.

## Fresh packages

The fresh build passes embedded Mac-content boundary/workflow checks for all seven
references and both early-close cases on the development engine. The archive audit
passes all ZIP-entry CRCs, architectures, committed source hashes and notices,
Windows anatomy identity and Mac executable modes/resource-seal presence.
[Build](source-snapshot-build.log.txt), [build report](source-snapshot-build-report.json),
[audit](source-snapshot-artifact-audit.json).

All prior 41 runtime-input hashes remain unchanged. A full
[package-member comparison](source-snapshot-package-comparison.json) finds changed
Windows executable and Mac executable/resource/seal bytes. Accordingly, native
Windows verification is repeated against the fresh archive; prior execution evidence
is not transferred based on source equality.

The exact fresh Windows archive passes all seven workflows on the native AMD
OpenGL renderer, including 784 label-placement and 543 scene-image comparisons,
107 capture identities, four normal launches and two early-close cases. The run
reports no runtime error, Unicode replacement diagnostic or ObjectDB leak. The marked
session was removed and independently checked absent.
[Native report](source-snapshot-windows-qa.json),
[runtime](source-snapshot-windows-runtime.log.txt),
[normal launches](source-snapshot-normal-lifecycle.json),
[initial close](source-snapshot-native-initial-anatomy.log.txt),
[replacement close](source-snapshot-native-replacement-selection.log.txt).
Detailed per-case JSON remains in `dist/source-snapshot-windows-qa/`, with its
identities in the native report. [Retained evidence identities](source-snapshot-evidence.json).

Private archives under `dist/source-snapshot-improvements/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328218038 | `1fc5546f0a89f2f41eb0921072590e1082cb89d966d55c99a673a6bed6ce34d6` |
| PraxisCorporis-macOS-universal-private.zip | 350662703 | `f507220195e6928d8257d29cbb25b3baac1bf8a45a4235b55cb275c1eb179fa4` |

The anatomy package remains 624,166,432 bytes with SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
This batch changes export verification and documentation. Medical text, geometry,
source mappings and review stages remain unchanged.
Actual Mac, human input/accessibility and representative-device acceptance remain
pending, as do public licensing/signing/release gates. The separate Linux
release-template popup qualification remains open.
