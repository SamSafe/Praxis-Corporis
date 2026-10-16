# Dark-theme readability and keyboard focus

Runtime source `11741bd4e1014b03be9e4c6973d5b9b71eb0de52` follows interface checkpoint
`745d259`. Checked on 2026-10-16.

Unavailable buttons and links now have explicit muted text colors; they remain
readable against the dark panels. Notes and other text fields share a dark palette,
visible carets and teal selection highlights. Text fields, lists and selectable
information have teal focus borders. Small internal padding keeps Help text clear
of its focus border. The saved-view counter uses singular “view” for a one-view
library.

Focusing the anatomy hierarchy, parts list or search results reuses the existing
deferred scroll-to-selection action. It resolves the current item after layout;
it does not change selection or camera. The observed large-text case had a selected
heart row below the viewport even though keyboard navigation still followed the
correct structure. Focus now brings that row into view.

## Evidence

| Check | Retained result |
|---|---|
| Existing engine checks | Six affected checks pass: information windows, keyboard workspace, saved-view filtering/drafts, study notes, scene layout and export boundary. [Index and hashes](interface-readability-development-qa.json). |
| Counter wording | The filter check is rerun after the final singular-count correction. [Log](interface-readability-counter.log.txt). The exact Windows capture below also shows “1 of 1 view”. |
| Python | 60 checks pass. [Log](interface-readability-python.log.txt). |
| Desktop inspection | At 1100 × 720 with 130% text, Help, selected notes, search and the hierarchy have visible focus cues. [Capture log](interface-readability-captures.log.txt), [reproduction script](interface-readability-capture.gd.txt). |
| Keyboard context | Focus preserves the complete view, and Down selects the expected next visible source record. [Observation log](interface-readability-tree-navigation.log.txt). |
| Loading input | Existing real-mouse cancellation checks still pass in both layouts with the new disabled styles. [Log](interface-readability-loading-mouse.log.txt). |

Inspected screens: [unavailable actions](../prototype/interface-disabled-actions.png),
[Help focus](../prototype/interface-help-focus.png),
[note selection](../prototype/interface-notes-selection.png),
[search focus](../prototype/interface-search-focus.png), and
[selected anatomy row](../prototype/interface-tree-focus.png).
The desktop captures use software rendering and establish no performance result.

## Private packages

Linux exported-runtime and Mac embedded-content checks pass all seven references,
including existing study, cancellation, recovery and saved-note workflows. Mac
content uses the development engine. Recorded runtime inputs remain unchanged
at completion. [Build report](interface-readability-build-report.json),
[build log](interface-readability-build.log.txt).

The exact Windows archive passes native AMD OpenGL checks for all seven references,
retaining 94 capture identities. The actual [loading screen](../prototype/interface-native-loading.png),
[scrolled Help window](../prototype/interface-native-help.png) and
[note editor](../prototype/interface-native-notes.png) were inspected for the changed
text, field and focus styling. [Native report](interface-readability-windows-qa.json),
[runtime log](interface-readability-windows-runtime.log.txt).

Four normal launches pass source/title identity, fresh startup-reference writes,
unavailable-choice fallback and the 1300 × 800/maximized window lifecycle.
[Observations](interface-readability-normal-lifecycle.json). The successful generated
session was removed after copying evidence and independently checked absent.
[Evidence hashes](interface-readability-evidence.json).

Archive CRCs, architectures, notices, committed runtime hashes and Mac content/seal
checks pass. [Audit](interface-readability-artifact-audit.json).

Current private archives are under `dist/interface-readability-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328125132 | `2c6be743b38cb7cddb9a9ced557a833f1c4fe19b8bec7a4c489afed7ad8a4889` |
| PraxisCorporis-macOS-universal-private.zip | 350570846 | `7adb4e76be4e94e82d450502595254f250dec3a09876bb73bab0fd149da3a268` |

## Limits

These are rendered/scripted checks, not a human accessibility acceptance or formal
contrast certification. Anatomy, source identity, medical text and saved-view
formats are unchanged. Learning content remains draft with human source and expert
review pending. Actual Mac execution and public-release gates remain open.
The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.
