# Preserve history when visibility or restoration changes nothing

Source `5a75e63733beac151f8f22c4248f97c100198b2b` preserves anatomy history for
unchanged visibility and restoration requests. Development checks ran on
2026-10-16 (America/Edmonton); package verification continued on 2026-10-17.

Previously, undoing a move and then choosing Show, Restore selected, Restore all,
or applying the unchanged saved anatomy produced an undo entry and cleared redo.
The anatomy stayed unchanged, and the original move could no longer be recovered.
The retained [probe](unchanged-edits-before.gd.txt),
[before log](unchanged-edits-before.log.txt) and
[after log](unchanged-edits-after.log.txt) show all four cases changing from
`undo 1 / redo 0` to preserved `undo 0 / redo 1`, with the movement recoverable.

Visibility now checks all targeted mesh states before checkpointing. Restore
checks both visibility and offsets; empty groups return without a checkpoint.
Saved anatomy is validated and normalized before an exact comparison with current
mesh state. A matching request returns successfully without changing anatomy
undo/redo. Real edits still create one undo step and clear the old redo branch.
Restore all keeps its existing return-to-context and navigation behavior.

## Development checks

The [unchanged-edit check](../../tests/unchanged_edits_smoke.gd) passes all seven
real references in workspace and expanded layouts. It repeatedly invokes Show,
Hide, Fade, Restore selected/all, unchanged saved anatomy and an unchanged saved
view after undoing a move. It compares both edit stacks, anatomy/view state and
Undo/Redo availability, then recovers the original movement with redo.

It also checks a mixed-visibility group, genuine edits creating a new branch,
restoration undo/redo, invalid saved anatomy and empty groups where present. The
original exploration, edit and navigation histories are restored after the check.
[Workspace log](unchanged-edits-workspace.log.txt).

Existing real-mesh viewer, study-workspace and pointer-interruption checks pass
in sequential runs. All 72 Python checks pass, including rejection of native
results missing history evidence for any reference.
[Viewer](unchanged-edits-viewer.log.txt), [study](unchanged-edits-study.log.txt),
[pointer](unchanged-edits-pointer.log.txt), [Python](unchanged-edits-python.log.txt),
[check identities](unchanged-edits-development-qa.json).

Three initial concurrent development runs exceeded their 150-second limits while
loading the male reference. They are incomplete results, not passes. Their
sequential reruns completed normally; no cause for the concurrent timeouts was
established. [Concurrent viewer](unchanged-edits-concurrent-viewer.log.txt),
[study](unchanged-edits-concurrent-study.log.txt),
[pointer](unchanged-edits-concurrent-pointer.log.txt).

Medical content, review stages, source geometry and identities, save formats,
movement steps, gesture checkpoints and the 40-step edit-history limit are unchanged.

## Private packages

The [build report](unchanged-edits-build-report.json) records unchanged runtime
inputs, passed embedded Mac resource-boundary/reference checks on the development
engine, and two passed loading-shutdown cases. This is not Mac device execution.
The original build console log was under the temporary directory and is no longer
available after session cleanup; the build report, archive identities and new
independent archive/native verification records are retained.

The exact Windows archive passes native AMD OpenGL execution on 2026-10-17
across all seven references. Both workspace layouts pass repeated unchanged-command
history checks, including Redo availability and recovery of the undone movement.
The full workflow retains 103 capture identities. Four normal launches pass
reference/window restoration and unavailable-reference fallback; two early-close
processes pass resource cleanup while preserving user-file bytes, modification
times and identities. No runtime error or ObjectDB leak is reported. The
successful isolated session was removed and independently checked absent.
[Native report](unchanged-edits-windows-qa.json),
[runtime log](unchanged-edits-windows-runtime.log.txt),
[normal launches](unchanged-edits-normal-lifecycle.json),
[initial close](unchanged-edits-native-initial-anatomy.log.txt),
[replacement close](unchanged-edits-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](unchanged-edits-artifact-audit.json).
[Evidence identities](unchanged-edits-evidence.json) bind the retained results.

Private archives are under `dist/unchanged-edit-history/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328163343 | `0bad4b9b2479e7cf786193b58ca5884191343213fa0fb308c3373d4e8d11c4ee` |
| PraxisCorporis-macOS-universal-private.zip | 350609262 | `6fab037f239d0a934984a526b43fe24618382229e3a78f5fd24a7fc7df799ba1` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

Human keyboard/device and accessibility acceptance, representative laptop trials
and actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human medical source and expert review remain pending.
