# Enlarged information windows verification

Private runtime source `d11bb9f7537c3c22a26a1d5c6daabc4b823e1c04`, following
feature checkpoint `ea8a112`, built and checked on 2026-10-15. The earlier
[circulation package](CIRCULATION_ROUTE_VERIFICATION.md) keeps its own identities.

Keyboard help and Sources now use bounded, scrollable, selectable plain text.
Page Up/Down scrolls focused text, and Escape closes the window even when the
text control has focus. Close remains inside the compact window at 130% text.
Sources works before the first anatomy reference loads and includes the authored
study-text sources. Route citations now have visible spacing.

## Checks

| Check | Retained result |
|---|---|
| Python tools | 44 checks pass. [Log](information-python.log.txt). The native verifier requires the information-window marker/captures only for committed packages containing the new module. |
| Affected engine checks | Seven scripts pass: information windows across all seven references, content validation, circulation, study workspace, keyboard movement/camera and export boundary. [Indexed logs/hashes](information-development-qa.json). The previous complete 21-script batch is retained in the circulation report. |
| Offline exports | All seven references pass in the Linux QA runtime and the Mac embedded content, including the new information-window check. [Build log](information-build.log.txt), [build report](information-build-report.json). Mac content uses the development engine. |
| Native Windows | The exact archive passes AMD OpenGL workflows across all seven references, including enlarged information text, real Page Down input, Escape and subsequent route/movement workflows. [Native report](information-windows-qa.json), [raw log](information-windows-runtime.log.txt). |
| Rendered inspection | The help window, source window and both compact route screens were inspected individually at 1100 × 720 with 130% text. All 92 runtime capture identities are retained in the native report. [Selected-image hashes](information-selected-captures.json). |
| Archives | CRCs, executable architectures, committed source/notices and Mac content/seal checks pass. [Audit](information-artifact-audit.json). |

Screens: [help](../prototype/information-help.png),
[sources](../prototype/information-sources.png),
[female route](../prototype/information-route-compact-female.png), and
[male route](../prototype/information-route-compact-male.png).

## Private artifacts

Under `dist/usability-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328090991 | `9cc994820801dd6d591c852698a05ff561b9a01296214f352c6b4750a483923d` |
| PraxisCorporis-macOS-universal-private.zip | 350536303 | `bbe246baa073d669156674346b85533f8c5fdebc7eaf352838d279348b4f4fad` |

Anatomy geometry and saved-view identities are unchanged. Actual Mac execution,
human accessibility/input/comprehension and qualified medical review remain open.
These checks make no new sustained-performance or public-release claim.
