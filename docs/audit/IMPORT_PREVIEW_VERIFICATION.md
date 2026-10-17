# Reading an import preview with the keyboard

Source `d73ba5fed84d867c4233c13b5941194d78ea3c2d` makes saved-view import previews
keyboard-readable. Checked on 2026-10-16 (America/Edmonton).

Previously, a 32-row preview opened with a Button focused. Its content exceeded
the scroll area, but Page Down left the scroll position at zero. The
[baseline probe](import-preview-before.gd.txt) and
[log](import-preview-before.log.txt) retain that behavior.

The preview now opens with selectable plain text focused and uses the chosen
text size. Page Up/Down scroll and Ctrl/Cmd+A selects its text. Enter or Space
while reading leaves the library unchanged; Tab reaches Import and Cancel.
Escape cancels even with a text selection and returns to the saved-view window.
Names containing bracket markup remain literal text. The existing compatibility,
duplicate, collision, atomic-write and stale-preview rules are unchanged.

## Development checks

The [import-preview check](../../tests/import_preview_smoke.gd) passes all seven
real references in workspace and expanded layouts at 100% and 130% text, in an
1100 × 720 window: 28 reference/layout/text combinations. Each case starts with
two existing views and previews 33 incoming rows: one identical view, 31 new
compatible views and one incompatible reference version. A name collision is
renamed while retaining both views; preview names keep literal brackets and notes
remain attached to the imported views.

The checks exercise focus, scrolling, selection, Enter/Space while reading,
Escape after selection, Tab to the import action and confirmation. Reading and
canceling preserve the library's SHA-256. Confirmation adds only the compatible
views and preserves the existing entries and notes. Repeating the import skips
all 33 rows and disables Import while keeping the preview readable. Anatomy,
camera, isolation/return context, both histories and preferences are preserved.
[Workspace log](import-preview-workspace.log.txt).

Existing portable-view and study-workspace checks pass. All 71 Python checks
pass, including rejection of native results missing import-preview evidence for
any reference or the rendered preview check.
[Portable regression](import-preview-portable.log.txt),
[study regression](import-preview-study-regression.log.txt),
[Python](import-preview-python.log.txt),
[check identities](import-preview-development-qa.json).

Automated text selection uses Ctrl/Cmd+A. Clipboard reading/copying and native
file-picker acceptance remain human trial tasks. Medical content, review stages,
source geometry and identities, and saved-view formats are unchanged.

## Private packages

The build keeps runtime inputs unchanged and passes the embedded Mac resource
boundary, every bundled reference workflow including the import preview in both
layouts/text sizes, and two loading-shutdown cases on the development engine.
This does not establish Mac device execution.
[Build report](import-preview-build-report.json), [build log](import-preview-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, including import-preview checks in both layouts and text sizes.
The workflow retains 103 capture identities. The inspected
[long preview](../prototype/import-preview-long.png) and
[duplicate-only preview](../prototype/import-preview-duplicates.png) show 130% text
with the reader and both actions within the window; Import is disabled when no
new views can be added.

Four normal launches pass reference/window restoration and unavailable-reference
fallback. Two early-close processes pass resource cleanup while preserving user-file
bytes, modification times and identities. No runtime error or ObjectDB leak is
reported. The successful isolated session was removed and independently checked
absent. [Native report](import-preview-windows-qa.json),
[runtime log](import-preview-windows-runtime.log.txt),
[normal launches](import-preview-normal-lifecycle.json),
[initial close](import-preview-native-initial-anatomy.log.txt),
[replacement close](import-preview-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](import-preview-artifact-audit.json).
[Evidence identities](import-preview-evidence.json) bind the retained results and captures.

Private archives are under `dist/import-preview-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328159906 | `d29b16722742c94302416245d71e68a97114f5e31976e722a290db23056327bb` |
| PraxisCorporis-macOS-universal-private.zip | 350605646 | `1187b03fd2ce6d20dfe9de0b3b5d38ab176394f1954c44bf702d84f1084b5707` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These are scripted input events. Human keyboard/device and accessibility acceptance,
representative laptop trials and actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human medical source and expert review remain pending.
