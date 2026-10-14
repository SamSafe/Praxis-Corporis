# Expanded anatomy controls verification

Recorded on the America/Edmonton client date 2026-10-13. Runtime snapshot:
`33071c11a3e5d7017a61f9f68003917810e5717e`, Godot
`4.7.2.stable.official.ed1daf0bf`. These are private local packages.

Expanded anatomy now retains an Explore menu for focus/whole body, Inspect alone
and Return to context, selection/local labels, explicit Move, inspection Undo/Redo,
Saved views, credited Screenshot, keyboard help and Native/75%/50% rendering.
The menu reuses the existing workspace actions. Selection, inspection/Move mode
and action feedback remain visible. Leaving Move clears its drag instruction.
Both View and Explore accept keyboard focus; Escape dismisses the open menu before
returning to the workspace. Loading guards preserve the existing anatomy.

## Retained evidence

| Check | Observed result and evidence |
|---|---|
| Python tools | All 32 checks pass, including required native markers, packaging and recorded-artifact validation. |
| Real geometry and GUI input | Picking, camera sensitivity, pan, Move and exact anatomy undo pass at three desktop sizes and all three rendering fractions. Expanded inspection/return, movement feedback, loading guards and keyboard menu opening/dismissal pass. |
| Expanded saved views | Label/resolution actions stay synchronized with workspace controls. A fresh temporary library saves, reopens and restores the expanded setup without leaving the display. Restored anatomy is compared exactly; camera JSON numbers allow the existing `1e-12` round-trip tolerance. |
| Compact rendering | Both 1100 × 720 menu/export captures were inspected. The menu stays visible, feedback is readable and the source footer is rendered. [Development evidence and logs](expanded-controls-development-qa.json). |
| Exported offline runtime | All three references pass in the isolated Linux QA executable, including missing-content handling. The Mac embedded pack passes content and resource-boundary checks on the development engine. These checks do not execute macOS. |
| Actual Windows rendering | The rebuilt Windows release passes the new controls, resolution/display checks and existing search, notes, keyboard, inspection, failed-replacement preservation and credited exports for female, male and the separate bone study. [Native record](windows-expanded-controls-viewer-qa.json), [runtime log](windows-expanded-controls-viewer-runtime.log.txt). |
| Native visual review | All 24 recorded Windows captures were inspected, including three expanded menus and three expanded credited exports. Review covers interface/geometry display, not medical accuracy. |
| Package identity | ZIP CRCs, architectures, retained notices, anatomy fingerprint and all recorded runtime hashes match the committed snapshot. [Build report](native-build-report.json), [independent artifact audit](native-artifact-audit.json). |

The Windows run uses native AMD Radeon graphics, OpenGL 3.3 Compatibility.
Its generated APPDATA/LOCALAPPDATA directory was isolated and removed after success;
the user's saved views and notes were untouched. The verifier exercises the PNG
composer/writer; human native-picker acceptance remains open.

## Inspect the result

- [Female expanded menu](../prototype/windows-expanded-controls-native-expanded-menu-female.png)
- [Male expanded menu](../prototype/windows-expanded-controls-native-expanded-menu-male.png)
- [Bone-study expanded menu](../prototype/windows-expanded-controls-native-expanded-menu-bodyparts-male-bones-study.png)
- [Female expanded export](../prototype/windows-expanded-controls-native-expanded-export-female.png)
- [Bone-study expanded export](../prototype/windows-expanded-controls-native-expanded-export-bodyparts-male-bones-study.png)
- [Compact menu](../prototype/expanded-controls-compact-menu.png) and [compact export](../prototype/expanded-controls-compact-export.png)

## Current packages

| Archive | Bytes | SHA-256 |
|---|---:|---|
| Windows x64 | 290,843,994 | `f54ff9ff2b46e86b07d07a3c91a867d0a5c813c58645a4c249acecf7189d3613` |
| macOS Universal | 313,289,134 | `561c921b910fa6454bbd0897316af5328c167f38f537d3ff5c46fd2b161581c4` |

The unchanged anatomy pack is 543,019,684 bytes, SHA-256
`d0ac48d536a2ff02c55d4416c366441160977c9d881f634ab7978bcd395d013b`.
Windows remains unsigned; Mac remains ad-hoc signed and not notarized.

## Remaining acceptance

Use the updated [private trial guide](../PRIVATE_TRIAL_GUIDE.md) for human mouse,
trackpad, keyboard, clipboard and picker observations, and run the package on an
actual Mac. Accessibility acceptance, representative hardware, broader anatomy
coverage and qualified review remain open. Disease and pathway content are unchanged.

No new sustained profile was run for this menu change. The retained
[full-HD profile](WINDOWS_FULLHD_PROFILE.md) belongs to the preceding `ae60019`
runtime and its Windows artifact; it is not a measurement of these rebuilt packages.
Development software-renderer load timings are functional-test observations only.
