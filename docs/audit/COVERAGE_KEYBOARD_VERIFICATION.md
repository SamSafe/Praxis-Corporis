# Reading Coverage with the keyboard

Source `07d23cedb30bd31c7a9aad8eddf692f46a8631f0` makes Coverage's inventory
reachable with the keyboard. Checked on 2026-10-16 (America/Edmonton).

Previously, Tab from the group list skipped the inventory and focused a button;
Page Down then left its scrollbar at zero. The text was not selectable.
The retained [baseline probe](coverage-access-before.gd.txt) and
[log](coverage-access-before.log.txt) record that behavior against the preceding
source. They do not establish that the former control had a zero focus-mode value.

Coverage now opens with its group list focused. Arrows choose a group, Tab reaches
the inventory, Page Up/Down scroll and Ctrl/Cmd+A selects its text. Further Tab
presses reach Explore and Close. Escape closes even when text is selected. The
heading wraps, the notice inherits the chosen text size, and truncated group
labels have full tooltips. Closing preserves the current anatomy, camera, layout
and histories; Explore deliberately selects a supplied group in the active reference.

The respiratory gap note also had an outdated statement that no heart–lung route
had been authored. It now identifies the existing separate route as an unreviewed
conceptual guide and retains the lack of pathological geometry. This is a product
availability correction. The inventory's source commit, audit date, mesh counts,
roots and technical status are unchanged. Learning cards, route graph, geometry,
anatomy IDs, saved-view formats and pending human source/expert review are unchanged.

## Development checks

The [keyboard check](../../tests/coverage_keyboard_smoke.gd) exercises all seven
real references in workspace and expanded layouts, at both 100% and 130% text.
It uses the 760 × 520 minimum dialog in an 1100 × 720 window, checks list/text/action
focus, group selection, scrolling, text selection, action bounds and Escape, and
compares anatomy/camera/history/preferences before and after. Keyboard Explore is
checked separately for every reference without changing anatomy edits.
[Workspace log](coverage-access-workspace.log.txt).

The existing Coverage count/gap/Explore check passes for both HRA bodies.
The rendered source check exercises female respiratory coverage and a separate
female cord study at 130% text, including selection and restoration. It waits for
the rich text to finish layout before capture. All 69 Python checks pass,
including rejection of native logs missing keyboard or rendered Coverage evidence
for any reference. [Existing check](coverage-access-legacy.log.txt),
[rendered log](coverage-access-capture.log.txt), [Python](coverage-access-python.log.txt),
[check identities](coverage-access-development-qa.json).

Selection is exercised using Ctrl/Cmd+A. Automated clipboard reading and copying
are not part of these checks. Human copy/paste, input-device and accessibility
acceptance remain private trial tasks.

## Packaging timeout

The first Mac export exceeded the builder's 120-second limit while creating the
bundle. A separate export with a 300-second bound completed successfully. The
packaging-only follow-up gives this Mac export step five minutes; runtime checks
retain their existing limits. [Initial timeout](coverage-access-build-timeout.log.txt),
[completed export probe](coverage-access-mac-export-probe.log.txt).

## Private packages

The completed build uses source `8586934deca135b0fab6d6baff711408c4eb80da`,
which adds only the packaging timeout adjustment after the Coverage commit.
The runtime inputs remain unchanged throughout the build. The embedded Mac
resource boundary, workflows for all seven references and two loading-shutdown
cases pass on the development engine. This is not execution on a Mac device.
[Build report](coverage-access-build-report.json), [build log](coverage-access-build.log.txt).

The exact Windows archive passes the keyboard checks on all seven references and
retains 101 capture identities, including a Coverage reader for each reference.
The reader captures use the minimum dialog at 130% text. The full native workflow
also passes four normal launches and two early-close processes; user-file bytes,
modification times and identities remain unchanged in the early-close checks.
No runtime error or ObjectDB leak is reported. The successful isolated session
was removed and independently checked absent.
[Native report](coverage-access-windows-qa.json),
[runtime log](coverage-access-windows-runtime.log.txt),
[normal launches](coverage-access-normal-lifecycle.json),
[initial close](coverage-access-native-initial-anatomy.log.txt),
[replacement close](coverage-access-native-replacement-selection.log.txt).

All seven original Coverage PNGs were inspected. The heading, inventory, scroll
area and persistent actions remain within the dialog. Representative captures:
[female respiratory](../prototype/coverage-keyboard-female.png),
[bone study](../prototype/coverage-keyboard-bodyparts-male-bones-study.png),
[female cord](../prototype/coverage-keyboard-hra-v1-2-female-cord-study.png).
An apparent text omission in the image preview was checked against the PNG pixels:
all seven heading prefixes are identical, and the cord's HRA text is present.
Early, delayed and explicit-redraw source captures also have identical dialog
pixels. This investigation did not identify an app rendering defect.
[Pixel check](coverage-access-pixel-inspection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](coverage-access-artifact-audit.json).
[Evidence identities](coverage-access-evidence.json) bind the retained results and captures.

Private archives are under `dist/coverage-keyboard-final/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328150644 | `7a2fc90c3088e3340aa57b79a43fd48c428f752eec1bf5c8e8d0392b09e73316` |
| PraxisCorporis-macOS-universal-private.zip | 350596568 | `d9fd0abf72f41c9b7a4865e6cd1615f08cbbde25bdc1d7226a54af4c704ecdc5` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These are scripted actions. Actual Mac execution, human accessibility/device
acceptance and representative laptop trials remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target.
No clinical review or anatomical completeness is established by these checks.
