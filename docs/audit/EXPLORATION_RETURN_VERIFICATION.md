# Continue keyboard exploration after Coverage or restoring a view

Source `5313611fc7c5458651af7c53754dcab132645520` returns keyboard focus to the 3D view after Coverage's
**Explore supplied group**, a successful named-view Restore, or a successful
**Restore previous quick save**. Checked on 2026-10-17 (America/Edmonton).

The [probe](exploration-return-before.gd.txt),
[before](exploration-return-before.log.txt) and [after](exploration-return-after.log.txt)
show Coverage and named Restore closing successfully but previously returning
focus to the old toolbar buttons. The saved pose restored correctly; camera keys
needed another focus action. Both now focus anatomy. The legacy quick-save loader
uses the same successful-return behavior.

Focus is deferred from the completed action. Coverage keeps its existing group
selection/focus behavior; saved views restore their existing snapshot. This adds
no anatomy edit or undo step. Escape/cancel keeps the opening control focused.

## Development checks

The [return check](../../tests/exploration_return_smoke.gd) passes all seven real
references, both layouts and 100%/130% text: 28 contexts for each of the three
actions, or 84 returns. Coverage uses the first available supplied group in each
reference. Each action opens with toolbar/Explore focus; afterward, an actual
Right-arrow event changes the camera while preserving anatomy edits and undo/redo.
Named and legacy restorations retain the exact saved snapshot. Fixture-library
and quick-save hashes stay unchanged during these returns.

It also checks 84 Escape/cancel paths, retaining the opener, exploration and files.
Two further female-reference cases exercise Restore through unsaved notes at 130%:
Save retains the draft and Discard retains the previously saved note. Both close
the nested windows, restore the snapshot and focus anatomy. Save uses Enter;
Discard dispatches the connected custom-action signal.
[Development log](exploration-return-development.log.txt).

The same return check deliberately rejects the prior viewer from
`1a729a5684589aff0d4193990fdec462568301fe` in a separate process. This
[negative fixture](exploration-return-baseline.gd.txt) uses the exact prior viewer
file reconstructed by the command in the [check identities](exploration-return-development-qa.json).
Its [log](exploration-return-baseline.log.txt) contains the expected rejection;
it is separate from passing application/runtime results.

Existing keyboard Coverage checks pass across all references; the exploration/
legacy-save regression passes both original HRA bodies. All 78 Python checks pass,
including rejection of missing native return-focus evidence.
[Coverage](exploration-return-coverage.log.txt),
[legacy/exploration](exploration-return-legacy.log.txt),
[Python](exploration-return-python.log.txt).

All fixture libraries are disposable. Medical text/review stages, source URLs,
geometry/identities, saved-view formats and inspection-history limits are unchanged.
The checks make no browser/network request or clipboard read/write.

## Private packages

The build retains unchanged runtime inputs and passes the embedded Mac resource
boundary, all seven reference workflows, the return-focus/cancel/note-prompt checks,
and two loading-shutdown cases on the development engine. This does not establish
actual Mac execution. [Build report](exploration-return-build-report.json),
[build log](exploration-return-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, including 84 action returns, 84 cancel paths and the two note-prompt
cases. Camera keys work after each successful return; edit histories, snapshots,
file hashes and the intended saved/discarded notes pass their checks. The workflow
retains 106 capture identities. Four normal launches pass reference/window
restoration and unavailable-reference fallback. Two early-close processes pass
resource cleanup while preserving user-file bytes, modification times and
identities. No runtime error or ObjectDB leak is reported. The successful isolated
session was removed and independently checked absent.
[Native report](exploration-return-windows-qa.json),
[runtime log](exploration-return-windows-runtime.log.txt),
[normal launches](exploration-return-normal-lifecycle.json),
[initial close](exploration-return-native-initial-anatomy.log.txt),
[replacement close](exploration-return-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](exploration-return-artifact-audit.json).
[Evidence identities](exploration-return-evidence.json) bind the retained results.

Private archives are under `dist/exploration-return-improvements/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328181987 | `d7be14c7e2b10de7006fe32c1bf0087f080ab24f90b8ed04cc35edfdabcb3e76` |
| PraxisCorporis-macOS-universal-private.zip | 350627931 | `33840fa109c31e6d11a448a39508db23072d9c9e98d4003ccd89d64ada42e414` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks use scripted input, including connected custom-action dispatch for
the Discard choice. Human keyboard/device, OS-picker and accessibility acceptance,
representative laptops and actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human source and expert medical review remain pending.
