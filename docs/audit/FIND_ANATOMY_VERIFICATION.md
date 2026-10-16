# Keyboard access to anatomy search

Runtime source `37f951b4140b22039c6c6ff74c2fb26b33ca319b` adds **Ctrl/Cmd+F**, **View → Find anatomy** and
**Explore → Find anatomy**. Checked on 2026-10-16.

Find returns from expanded anatomy when needed, reveals the explorer and selects
the current query. It preserves the details panel's visibility and reuses the
existing panel preference behavior. Menus close before search receives focus,
so immediate typing reaches the field. Search focus does not change anatomy,
camera, edits, histories, Move setting or the active study step.

Escape from the search field or result list clears the query and restores the
hierarchy without resetting the selected source view. A second Escape in the
empty field returns focus to 3D. Enter retains its existing result-selection and
camera-focus behavior. Loading disables Find; search stays read-only before the
first reference index exists. Saved views and exclusive information windows keep
their own input scope. Help, tooltips and packaged instructions describe the route.

## Development evidence

The new [Find check](../../tests/find_anatomy_smoke.gd) passes Control and Command
shortcuts, hidden panels, expanded view, immediate typing, query selection, both
Escape routes, result selection, study preservation, dialog scope and a real
replacement load. Existing source-search, keyboard workspace and information-window
checks also pass. [Check index](find-anatomy-development-qa.json).

The actual bundled search routine passes in the development engine. Its Find and
Escape steps preserve the recorded source view and histories before the existing
source-selection checks. [Probe](find-anatomy-bundle.gd.txt),
[log](find-anatomy-bundle.log.txt).

Mouse menu opening and keyboard item activation pass at 1100 × 720 and 130% text.
The actual popup closure leaves focus on search. The expanded menu fits within
the logical viewport, and Enter/result-list Escape provides a route back to 3D.
The software-rendered captures were inspected. [Capture check](../../tests/capture_find_anatomy.gd),
[log](find-anatomy-captures.log.txt),
[View action](../prototype/find-anatomy-menu-focus.png),
[expanded action](../prototype/find-anatomy-expanded-menu.png),
[compact focus](../prototype/find-anatomy-compact-focus.png).

All 65 Python checks pass, including stricter runtime parsing and required Find
evidence for each native reference. [Log](find-anatomy-python.log.txt).

## Private packages

The final build records committed source
`2923959dcd9f0e75fbe6725a06f7015c23e87586`; the Find runtime matches the feature
checkpoint above. Runtime inputs remain unchanged through packaging. The
`--qa-mac-content` checks pass the resource boundary, all seven references,
Find/Escape workflows and two early-close cases using the development engine.
[Build report](find-anatomy-build-report.json), [log](find-anatomy-build.log.txt).

The exact Windows archive passes native AMD OpenGL verification, including Find
and Escape on every reference, 94 capture identities, four normal launches and
two separate early-close processes. The normal launches check remembered
reference/window state and unavailable-reference fallback. The early closes check
owned-resource cleanup and unchanged user-file bytes, modification times and file
identities. No runtime errors or ObjectDB leaks are reported. The successful
generated session was removed and independently checked absent.
[Native report](find-anatomy-windows-qa.json),
[runtime log](find-anatomy-windows-runtime.log.txt),
[launch observations](find-anatomy-normal-lifecycle.json),
[initial close](find-anatomy-native-initial-anatomy.log.txt),
[replacement close](find-anatomy-native-replacement-selection.log.txt).

The native search captures for the mitral valve and the separate source femur
were inspected: query, matching result, selected source anatomy and inspection
context remain visible.
[Female search](../prototype/find-anatomy-native-female.png),
[bone-study search](../prototype/find-anatomy-native-bones.png).

Archive CRCs, architectures, notices, committed runtime hashes, anatomy identity
and Mac content/seal checks pass. [Audit](find-anatomy-artifact-audit.json),
[evidence identities](find-anatomy-evidence.json).

Current private archives are under `dist/find-anatomy-verified/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328137053 | `e81db297f87e4d9f117f6097869e32d623e2a08b8c940706bbaf103304925968` |
| PraxisCorporis-macOS-universal-private.zip | 350583049 | `47d6eafd687c856f18e7afb9941136d968080c575b269747086b48af4da9b12c` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Scripted checks and software-rendered inspection do not establish human
accessibility or actual Mac acceptance. Anatomy, source identity, saved-view
formats and medical explanations are unchanged. Learning content remains draft,
with human source and expert review pending.

The Linux release template's popup-focus errors reproduce in an independent
single-menu app. The Linux bundle run is not accepted as a clean pass; the strict
runner now rejects it. The final build checks Mac content independently, with
native Windows evidence recorded separately. The preliminary
`dist/find-anatomy-improvements/` build is superseded.
[Reproduction, raw failed evidence and historical qualification](POPUP_TEMPLATE_VERIFICATION.md).
