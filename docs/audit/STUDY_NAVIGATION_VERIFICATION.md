# Continuous keyboard navigation through a study

Source `b5c8266355410ce8973331430307b854cb006e19` keeps focus on study navigation
actions as the guide or route changes. Checked on 2026-10-16 (America/Edmonton).

Previously, activating Next with Enter moved focus to the 3D view. A second Enter
did not advance. The route's rebuilt action buttons had the same behavior.
The retained [probe](study-navigation-before.gd.txt),
[before log](study-navigation-before.log.txt) and
[after log](study-navigation-after.log.txt) show the actual input/focus transition.

Next now retains focus until the last chest step, which focuses Finish and restore.
Previous retains focus while available; at the first step it focuses the forward
action. A route action focuses the next step's first route button. At the lung
choices, Tab reaches the other branch and Enter follows the focused choice.
Finishing restores the starting exploration and returns focus to the 3D view.
Starting a study still focuses anatomy. Programmatic step changes retain their
existing behavior when a navigation action did not have focus.

These are navigation changes. The six chest steps, 17-node route, citations,
draft/review status, source geometry and identities, and saved-view formats are
unchanged. The route remains conceptual; no physiological flow is inferred.
The scope notes in PROTOTYPE.md now accurately describe the existing draft
condition summaries, conceptual route and temporary chamber teaching layout.

## Development checks

The [study navigation check](../../tests/study_navigation_smoke.gd) passes both HRA
references in workspace and expanded layouts at 100% and 130% text, in an
1100 × 720 window. It sends actual Enter/Tab events, checks continuous advancement,
first/last-step focus, both branch actions and Previous, and completes a route
back to its starting node. It compares the restored camera, selection, anatomy
edits, isolation/return context and both histories, and restores preferences/layout.
It activates Enter only when a Button has focus, preventing a failed focus check
from activating a source link. [Workspace log](study-navigation-workspace.log.txt).

Existing study-workspace and circulation-route checks pass. All 70 Python checks
pass, including rejection of native results missing navigation evidence for either
supported HRA reference. The separate bone/spinal studies continue to have no
inferred chest guide or route. [Guide regression](study-navigation-guide-regression.log.txt),
[route regression](study-navigation-route-regression.log.txt),
[Python](study-navigation-python.log.txt),
[check identities](study-navigation-development-qa.json).

## Private packages

The build keeps all runtime inputs unchanged and passes the embedded Mac resource
boundary, every bundled reference workflow including both supported study-navigation
checks, and two loading-shutdown cases on the development engine. This does not
establish Mac device execution. [Build report](study-navigation-build-report.json),
[build log](study-navigation-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references. Both HRA references pass continuous study navigation in both layouts
and text sizes. The full workflow retains 101 capture identities. Four normal
launches pass reference/window restoration and unavailable-reference fallback;
two early-close processes pass resource cleanup while preserving user-file bytes,
modification times and identities. No runtime error or ObjectDB leak is reported.
The successful isolated session was removed and independently checked absent.
[Native report](study-navigation-windows-qa.json),
[runtime log](study-navigation-windows-runtime.log.txt),
[normal launches](study-navigation-normal-lifecycle.json),
[initial close](study-navigation-native-initial-anatomy.log.txt),
[replacement close](study-navigation-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](study-navigation-artifact-audit.json).
[Evidence identities](study-navigation-evidence.json) bind the retained results.

Private archives are under `dist/study-navigation-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328153679 | `57d8be2b43aa4c3fdfd039d05c27be92a4e017758d1e0372ee66a51d1cd711f7` |
| PraxisCorporis-macOS-universal-private.zip | 350599510 | `e52c3a7fab42f70177b699c8657dc546e194901c3f425e8d2d056b8e6bd5f36d` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks inject input events. Human keyboard/device and accessibility
acceptance, representative laptop trials and actual Mac execution remain pending.
The independent [Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md)
remains open; Linux is not a release target. Medical source and expert review
remain pending.
