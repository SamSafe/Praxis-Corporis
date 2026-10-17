# Reach study links by keyboard and recover a browser-launch failure

Source `bfa26916bab8d22bacee450b414313254c39c74e` makes study, related-anatomy/condition and route-source
links reachable with ordinary Tab navigation. A failed system browser launch
leaves a selectable source address in the app. Checked on 2026-10-17
(America/Edmonton).

The [prior wiring](source-link-prior-wiring.json) records both callbacks at
`c9e4316af955a4fb2e8baedcab5f4fd8c9139cf0`: they discarded the system launch
result and used the engine's default LinkButton focus mode. An
[intermediate development check](source-link-initial-focus-check.log.txt)
reported that these links could receive focus only with a screen reader active.
That log precedes the explicit focus correction; it is not a baseline package run.

Study links now accept ordinary keyboard focus. Source links share a launcher
handler. When the OS reports failure, a bounded window explains the failure and
shows the exact plain-text address, with selection and the chosen text size.
Escape or Close returns focus to the originating link. Reading or closing the
address preserves the study step, anatomy and camera. A successful launch opens
no fallback window.

## Development checks

The [source-link check](../../tests/source_fallback_smoke.gd) passes both HRA
references at 100%/130% text size, in workspace cards, workspace routes and expanded
routes: 12 reading contexts. It uses real Tab and Enter events for the actual
source links, checks the exact URL for each exercised citation, and simulates both
successful and failed launcher results. It checks related-anatomy/condition Tab
access too. It verifies selectable plain text, font size, window bounds, Escape,
restored link focus and preserved exploration/route history.
[Development log](source-link-development.log.txt).

Existing study-navigation and information-window checks pass sequentially. All
76 Python checks pass, including rejection of missing reference/capture evidence
for the fallback. [Navigation](source-link-navigation.log.txt),
[information windows](source-link-information.log.txt),
[Python](source-link-python.log.txt), [check identities](source-link-development-qa.json).

The checks replace only the system launcher callback and restore it afterward.
They open no browser, make no network request and read/write no clipboard. Keyboard
Select All selects dialog text. Medical text/review stages, source URLs, geometry,
source identities, saved-view formats and inspection history limits are unchanged.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, all seven reference workflows, source-link success/failure checks in
both HRA bodies, and two loading-shutdown cases on the development engine. This
does not establish actual Mac execution.
[Build report](source-link-build-report.json), [build log](source-link-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references. Both HRA bodies pass the 12 source-link reading contexts, including
Tab/Enter activation, exact URL routing, simulated success/failure, text selection,
Escape and restored link focus. The workflow retains 104 capture identities.
The [fallback at 130% text size](../prototype/source-link-fallback-windows.png)
was visually inspected: the address, selectable reader and Close button are readable
inside the compact expanded-anatomy window. The launcher is simulated here too;
this does not establish real browser handoff.

Four normal launches pass reference/window restoration and unavailable-reference
fallback. Two early-close processes pass resource cleanup while preserving
user-file bytes, modification times and identities. No runtime error or ObjectDB
leak is reported. The successful isolated session was removed and independently
checked absent. [Native report](source-link-windows-qa.json),
[runtime log](source-link-windows-runtime.log.txt),
[normal launches](source-link-normal-lifecycle.json),
[initial close](source-link-native-initial-anatomy.log.txt),
[replacement close](source-link-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](source-link-artifact-audit.json).
[Evidence identities](source-link-evidence.json) bind the retained results.

Private archives are under `dist/source-link-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328173232 | `dc9c8e82658fa94b7496d9958994203834551eee489b1690b722052496db4181` |
| PraxisCorporis-macOS-universal-private.zip | 350618947 | `be5f4065ef7141c604d11b82a13af4dac5978b1a5c197472896ac1b081aa1a17` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

This handles failure reported by the system when launching a browser. It cannot
detect a page that fails to load after a successful launch. Actual browser handoff,
human keyboard/device and accessibility acceptance, representative laptops and
actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human source and expert medical review remain pending.
