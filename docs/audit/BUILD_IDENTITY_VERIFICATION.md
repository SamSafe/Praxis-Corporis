# Identify private builds from the app

Runtime source `c86cfba` adds a private build identity to Sources and to
`START_HERE.txt`. The previous candidate's Sources dialog identified anatomy,
licences and draft status but could not identify the tested application build.
Checked 2026-10-18.

The builder creates one random build ID for each invocation. Its Windows and Mac
archives share that ID; the runtime platform and recorded archive SHA-256 distinguish
the artifacts. The stamp also records the declared application version, full Git
revision, source-input fingerprint, engine and content-pack ID. Sources includes
the actual runtime engine/platform. These fields help attach observations to an
exact private candidate. They do not establish medical review, signing, authenticity
or release acceptance.

## Recorded export contract

The export plugin adds `res://content/build_identity.json` to the core resource
pack before final packaging/signing. It does not create or alter a source-tree
content file. The version comes from the existing Windows/Mac export presets;
their four version settings must agree. The source fingerprint is SHA-256 over
UTF-8 JSON of the recorded source-hash dictionary, with sorted keys and compact
separators. The committed input collector, generator, plugin and runtime reader
are included in the source snapshot.

The private builder requires a valid resource-insertion marker. Mac-content workflow
checks compare the actual embedded identity with the build report. The Windows
verifier likewise requires exactly one matching runtime identity marker. Missing,
duplicate or mismatched identities cannot be accepted by a completion marker.
The source audit validates the record against committed inputs and version settings,
and checks the identity lines in both packages' startup instructions. Runtime
checks establish that the core payload carries that same record; the static audit
alone does not execute it.

A source checkout says **Development checkout · build identity unavailable**.
A direct export without a builder stamp says **Unrecorded export**. Corrupt,
oversized, incomplete or wrong-pack metadata also becomes unavailable. Those
exports can open normally, but they cannot pass the private bundle verification
without their recorded identity. No Git command runs inside the app. The stamp
contains no user library, notes, machine name, personal path or telemetry.

## Checks

- All 94 Python checks pass. Added cases reject mismatched platform versions,
  source/version/engine/content records, wrong startup identities and missing,
  duplicate or changed runtime identity markers.
- The runtime reader retains every generated value, rejects corrupt/oversized
  data and mismatched content, and distinguishes a development checkout.
- Reading Sources preserves the anatomy snapshot.
- Sources remains available before the first reference loads; all seven reference
  dialogs preserve URLs/review status and fit at 1100 × 720 with 130% text.
- The previous `9e864a0` source snapshot still passes its historical audit. Earlier
  packages are not relabeled with a new identity or new execution evidence.

## Exact candidate

- Build ID: `f962ce195f324c89a400cf07d8767c9d`
- Declared application version: `0.1.0` (private)
- Source revision: `c86cfba1e544b20917b66c14ea405f0b74abfd47`
- Source inputs SHA-256: `72347b3bb7ef35baf9eae06dd7cb5bb10f3fa8ca6e7064e63eb3353e10af4bb0`
- Complete committed source snapshot: 79 inputs, version 2.

[Build report](build-identity-build-report.json),
[build/resource workflow](build-identity-build.log.txt),
[archive/source/startup-identity audit](build-identity-artifact-audit.json),
[Python checks](build-identity-python.log.txt),
[runtime reader and development Sources](build-identity-development.log.txt),
[all-reference information dialogs](build-identity-information-development.log.txt).

The exact Windows archive passes native rendered verification with a runtime
identity equal to its build record. All seven references pass, including 107
captures, 784 label-placement comparisons, 543 redraw comparisons, four normal
launches and two early-close cases. Runtime logs contain no engine error,
Unicode replacement diagnostic or ObjectDB leak. The marked session was removed
and independently checked absent. The captured compact Sources dialog was visually
inspected for readable text, scrolling and its Close action. The built-in check
also confirms the build ID, source revision and fingerprint are present in that
same rendered message.
[Native report](build-identity-windows-qa.json),
[runtime](build-identity-windows-runtime.log.txt),
[normal launches](build-identity-normal-lifecycle.json),
[initial close](build-identity-native-initial-anatomy.log.txt),
[replacement close](build-identity-native-replacement-selection.log.txt).

Native UI Automation names/focus/search/page/filter checks also pass on the new
archive. Its fake library remains byte-for-byte unchanged, its process closes with
code 0 and its marked data is removed and independently checked absent.
[API report](build-identity-windows-uia.json),
[runtime](build-identity-windows-uia-runtime.log.txt).
The API scope excludes assistive scrolling/row activation and screen-reader trials.

Six [altered real-report/runtime controls](build-identity-negative-controls.json)
are rejected: wrong revision, fingerprint, declared version, engine, content pack
and a different build ID supplied against the actual successful native log.
Detailed comparisons, captures and API trees remain under
`dist/build-identity-windows-qa/` and `dist/build-identity-windows-uia/` with their
identities in the reports. [Retained evidence identities](build-identity-evidence.json).

Private archives under `dist/build-identity-improvements/`:

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| PraxisCorporis-Windows-x64-private.zip | 328224510 | `7518559369a6b55f20fbcf37363b47edb5013e666136b675469426e35b649ec4` |
| PraxisCorporis-macOS-universal-private.zip | 350671781 | `7d900e32b30ffd4a46639bfc6f5b082799260c3b3d0de4994dec3fea98f57bd4` |

The anatomy package remains 624,166,432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
Medical text, geometry, mappings, portable saved-state schemas and review status
remain unchanged. The [Mac packet](../MAC_ACCEPTANCE.md) identifies this candidate
and preserves earlier templates for observations already begun. Upgrade/rollback
trials for the exact Windows private pair now pass in the
[separate compatibility record](PRIVATE_UPGRADE_VERIFICATION.md). Actual Mac
execution, assistive technology, qualified content review and public release
decisions remain open.
