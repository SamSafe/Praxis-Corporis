# Part-level anatomy action verification

Recorded on the America/Edmonton client date 2026-10-14. Final private runtime:
`b9c23b479efe6ae73acc1e79a671769ba6906bd2`, Godot `4.7.2.stable.official.ed1daf0bf`.

Selecting anatomy now exposes an Actions button beside its opaque surface label.
Hidden, faded, covered or off-screen selections retain a corner button. Turning
name labels off retains the action anchor. Both workspace and expanded anatomy
use the same focus, inspect/return, label, visibility, explicit Move, restoration,
inspection history and source-copy routes. Visibility and history use submenus.
Visibility is disabled during temporary isolation. Disease, connection and guided
separation content remains pending.

Shift+F10 or the Menu key opens actions from the focused scene. Escape dismisses
submenus and their parent before leaving expanded anatomy. Right-drag still pans.
Actions capture the selection; stale selections and reference loading cannot apply
them to a replacement part. Display/layout changes close the popup. Labels and the
Actions button avoid each other, the orientation cue and expanded toolbars/feedback.
An open popup can temporarily cover other labels or anatomy; human usability and
text-scaling acceptance remain open.

## Evidence

| Check | Result and retained evidence |
|---|---|
| Real GUI and geometry | All three references pass actual root mouse/key events across two workspace modes, 1100 × 720 and 1920 × 1080 windows, and Native/50% rendering: 24 combinations. Hidden/faded/off-screen fallback, focus, visibility, isolation guards, stale selection, loading, explicit Move, restoration, exact Undo/Redo and right-pan checks pass. [Development record](part-actions-development-qa.json), [menu log](part-actions-smoke.log.txt). |
| Existing workflows | Screen-density picking, pan, Move, expanded controls and covered-part inspection pass. [Display regression](part-actions-display-regression.log.txt), [inspection regression](part-actions-inspection-regression.log.txt). These runs precede the final equivalent label-condition simplification; the menu test and final exported workflows cover the final behavior. |
| Python tools | All 36 checks pass. [Log](part-actions-python.log.txt). |
| Rendered development helper | Female compact/expanded menus and the visibility submenu pass and were inspected individually. The host uses Linux software rendering; these timings are not performance evidence. [Rendered log](part-actions-rendered-helper.log.txt). |
| Exported content | Both final offline resource packs load all three references and pass saved views/notes, failed replacement, search, keyboard, expanded controls, orientation and part actions. Mac content is exercised using the development engine. [Build log](part-actions-native-build.log.txt), [fixed build report](windows-part-actions-build-report.json). |
| Actual Windows | Native AMD OpenGL workflows pass for all three references, including the new actions and submenu route. All 36 captures were inspected through nine contact sheets; the nine new menu captures were also inspected individually at full size. [Native report and image hashes](windows-part-actions-viewer-qa.json), [raw runtime log](windows-part-actions-viewer-runtime.log.txt). |
| Artifact identity | Archive CRCs, executable architectures, notices, companion anatomy and committed source hashes pass. [Fixed artifact audit](windows-part-actions-artifact-audit.json). |

The initial `8f671b1` native trial exited during scene-display verification before
part-action captures or pass markers. It is retained as a failed trial, not accepted
native evidence. A rendered local reproduction showed the QA helper opening a menu
before its inspection-banner layout settled; the ensuing layout change correctly
closed it. Commit `b9c23b4` settles that layout before capture and adds stage errors.
The subsequent native run passes. [Failed trial](windows-part-actions-initial-failed-trial.json),
[initial runtime log](windows-part-actions-initial-failed-runtime.log.txt).

## Selected captures

| Reference | Compact menu | Expanded menu | Visibility submenu |
|---|---|---|---|
| HRA female | [1100 × 720](../prototype/windows-part-actions-native-part-actions-compact-female.png) | [Body context](../prototype/windows-part-actions-native-part-actions-expanded-female.png) | [Show/hide/fade](../prototype/windows-part-actions-native-part-visibility-female.png) |
| HRA male | [1100 × 720](../prototype/windows-part-actions-native-part-actions-compact-male.png) | [Body context](../prototype/windows-part-actions-native-part-actions-expanded-male.png) | [Show/hide/fade](../prototype/windows-part-actions-native-part-visibility-male.png) |
| Separate male bone study | [Right femur](../prototype/windows-part-actions-native-part-actions-compact-bodyparts-male-bones-study.png) | [Surrounding bones](../prototype/windows-part-actions-native-part-actions-expanded-bodyparts-male-bones-study.png) | [Show/hide/fade](../prototype/windows-part-actions-native-part-visibility-bodyparts-male-bones-study.png) |

## Packages and limits

| Archive | Bytes | SHA-256 |
|---|---:|---|
| Windows x64 | 290,858,519 | `b3b4b7240560d5105767f1963587fa628872d0dfb579bbf0b7616e60853c859f` |
| macOS Universal | 313,305,108 | `7f943d70522340ccc0f13f3bd7ff18570c7a64eaba94bbcd7e4855855398249b` |

The anatomy pack remains 543,019,684 bytes, SHA-256
`d0ac48d536a2ff02c55d4416c366441160977c9d881f634ab7978bcd395d013b`. Geometry and source fingerprints are unchanged.
Archives stay local/private; Windows is unsigned and Mac is ad-hoc signed, not
notarized. Actual Mac execution and human mouse/trackpad, clipboard, picker,
accessibility and comprehension trials remain open. Source-copy QA checks the
formatter; it does not establish a human clipboard round trip.

No new sustained performance trial was run. The [full-HD profile](WINDOWS_FULLHD_PROFILE.md)
retains its `ae60019` snapshot. Medical review, wider anatomy and public-release gates
remain open. [Portable saved views and further implementation](../IMPLEMENTATION_BACKLOG.md)
can continue alongside those external trials.
