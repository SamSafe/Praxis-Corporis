# Remembered desktop layout verification

Private runtime source `0000d07265d32a207040443c322b65fac1e19030`, following
feature checkpoint `d276d5c`; lifecycle harness correction `f4d999f`. Checked on
2026-10-15 America/Edmonton (native report timestamp 2026-10-16 UTC).

Normal desktop launches save the windowed client size and maximized state on an
accepted close. Reopening bounds the saved size to the current display's usable
area, subject to the app minimum, and centers the window. Minimized state is not
restored. A canceled unsaved-note close does not save window settings or exit.
Scripted QA and headless execution leave the desktop settings file alone.
Malformed settings fall back without emitting a JSON parser error or overwriting
the invalid file during loading.

## Evidence

| Check | Retained result |
|---|---|
| Python | 56 checks pass, including lifecycle observation validation. [Log](desktop-layout-python.log.txt). |
| Affected engine checks | Ten scripts pass, covering storage, invalid preferences, protected shutdown, portable views, notes and affected anatomy interactions. [Indexed logs and hashes](desktop-layout-development-qa.json). |
| Linux desktop | Actual rendered resize, maximize and reopen smoke passes with software rendering. [Log](desktop-layout-linux-rendered.log.txt). No performance claim. |
| Offline export | Linux QA and Mac embedded content pass all seven references; the latter uses the development engine rather than a Mac device. [Build log](desktop-layout-build.log.txt), [build report](desktop-layout-build-report.json). |
| Actual Windows | The exact archive passes all seven references under native AMD OpenGL, retaining 94 capture identities. A seeded desktop-settings fixture is unchanged by scripted QA. [Report](desktop-layout-windows-qa.json), [runtime log](desktop-layout-windows-runtime.log.txt). |
| Normal Windows launches | Three separate app processes, without QA user arguments, pass the size/maximize/restore lifecycle below. [Observations](desktop-layout-window-lifecycle.json), [protocol output](desktop-layout-window-lifecycle-runtime.log.txt). |
| Archives | CRCs, architectures, source/notices and Mac content/seal checks pass. [Audit](desktop-layout-artifact-audit.json). |

The normal-launch protocol resizes the first window to a 1300 × 800 client area,
closes it through its own window handle and checks the saved record. The second
launch restores that size, is maximized and closes with the original windowed
size retained. The third launch opens maximized; unmaximizing restores 1300 × 800.
It closes with `maximized: false`. Native client-size and maximized observations
agree with the three saved records: [first](desktop-layout-window-first-state.json),
[second](desktop-layout-window-second-state.json), [third](desktop-layout-window-third-state.json).
All three processes exit successfully without engine errors. These short lifecycle
launches check desktop state, not completion of anatomy loading; the separate
seven-reference run checks that workflow.

The first lifecycle trial timed out because its harness waited for a buffered
engine-log line while the app was running. [Failure log](desktop-layout-first-trial-failure.log.txt).
The corrected protocol observes GUI readiness and actual window size/mode instead.
It passed against the same app archive. The failed session was retained; the
successful generated session was removed after evidence copying and independently
checked absent. The [evidence manifest](desktop-layout-evidence.json) records hashes,
including all three normal-launch logs and their saved records.

## Private artifacts

Under `dist/window-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328111220 | `d2853e94dd053d75839f05ec6f5b632188368027703e3093146558a8b0db61fb` |
| PraxisCorporis-macOS-universal-private.zip | 350557299 | `6203d832b1bc0d80e6b4bb5a536892552f4053abcd1b479c591f40af02be3151` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
Anatomy identity and saved-view formats are unchanged. Learning content remains
draft, with human source and expert review pending; see the
[review-stage correction](DRAFT_CONTENT_VERIFICATION.md).
Actual Mac execution, human keyboard/accessibility trials and different-display
hardware trials remain open. Scripted bounds checks do not establish behavior on
every desktop configuration. These packages remain private and are not a public
release or a new sustained-performance result.
