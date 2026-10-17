# Keep movement and edit history aligned

Application source `4fcdd911886555a412ed170be14addeaae86239d` fixes two movement
history failures. Development checks ran on 2026-10-17 (America/Edmonton).

At the existing displacement boundary, an outward keyboard step or pointer drag
changed no offsets but still cleared redo and created an undo entry. The
[boundary probe](movement-history-limit-before.gd.txt),
[before](movement-history-limit-before.log.txt) and
[after](movement-history-limit-after.log.txt) show preserved history and recovery
of the previous edit after the fix.

Undo during a held Move drag restored anatomy, but later held-button motion could
move it again with no new undo entry. Undo/Redo now ends the active drag while
keeping Move selected. [Probe](movement-history-drag-undo-before.gd.txt),
[before](movement-history-drag-undo-before.log.txt),
[after](movement-history-drag-undo-after.log.txt). This before-run used the retained
[intermediate patch](movement-history-before-cancel-patch.json) on its recorded
base revision; Undo/Redo was still directly wired to the model at that point.

The model computes effective clamped offsets before recording movement history.
Zero, non-finite and ineffective deltas return without changing the edit stacks.
A keyboard step records one change when effective. A pointer gesture waits until
its first effective displacement to record its single undo boundary, including
when it starts blocked and then reverses. Existing explicit checkpoint callers,
including the chamber teaching layout, retain their behavior. Empty geometry
cannot enter Move through the UI. The existing ±10 m per-axis limit is unchanged.

## Development checks

The [movement-history check](../../tests/movement_history_smoke.gd) passes all seven
real references in workspace/expanded layouts at 100%/50% 3D resolution: 28
reference/layout/resolution combinations. It checks all six model boundary directions,
zero/non-finite requests, a partial clamp, normal/fine keyboard steps, limit feedback,
redo recovery, a blocked drag reversing into a single real gesture, focus interruption,
and Undo/Redo while a pointer button remains held. It restores the exact starting
view, geometry, edit/navigation histories, layout, rendering quality and Move state.
[Workspace log](movement-history-workspace.log.txt).

Existing keyboard movement, pointer interruption, real-mesh viewer and study
workspaces pass in sequential runs. All 73 Python checks pass, including rejection
of native results missing movement-history evidence for any reference.
[Keyboard](movement-history-keyboard.log.txt),
[pointer](movement-history-pointer.log.txt), [viewer](movement-history-viewer.log.txt),
[study](movement-history-study.log.txt), [Python](movement-history-python.log.txt),
[check identities](movement-history-development-qa.json).

## Packaging follow-up

Packaging source `3b4ad089862df2e51a63b005d944ba188722054f` also resolves the engine
path before changing working directories. A relative engine path previously
exported Windows but failed when the embedded Mac check ran from its temporary
folder. [Retained failure](movement-history-relative-engine-failure.log.txt).
Runtime application sources are unchanged by this follow-up.

The pinned development engine and template archives were restored to the ignored
build cache and verified against official release digests; the template digest also
matches the existing toolchain manifest. [Godot archive](https://godotengine.org/download/archive/4.7.2-stable/),
[official release metadata](https://api.github.com/repos/godotengine/godot-builds/releases/tags/4.7.2-stable).
The retained check index records their identities. Development tools, data and logs
now use the ignored build folder for this run, preserving them across temporary
directory cleanup.

Medical content/review stages, source geometry/identities, saved-view formats,
normal 5 mm / fine 1 mm requested steps and the 40-step history limit are unchanged.

## Private packages

The completed relative-path build keeps runtime inputs unchanged and passes the
embedded Mac resource boundary, every reference workflow including movement
history, and two loading-shutdown cases on the development engine. This does not
establish Mac device execution. [Build report](movement-history-build-report.json),
[build log](movement-history-build.log.txt).

The exact Windows archive passes native AMD OpenGL execution across all seven
references, both layouts and rendering resolutions. It retains 103 capture
identities and passes the new movement/history assertions, including effective
keyboard steps, blocked/reversed drags, interruption recovery and held-drag
Undo/Redo. Four normal launches pass reference/window restoration and unavailable
reference fallback; two early-close processes pass resource cleanup while
preserving user-file bytes, modification times and identities. No runtime error
or ObjectDB leak is reported. The successful isolated session was removed and
independently checked absent.
[Native report](movement-history-windows-qa.json),
[runtime log](movement-history-windows-runtime.log.txt),
[normal launches](movement-history-normal-lifecycle.json),
[initial close](movement-history-native-initial-anatomy.log.txt),
[replacement close](movement-history-native-replacement-selection.log.txt).

Archive CRCs, committed runtime hashes, architectures, notices, anatomy identity
and Mac resource-seal presence pass the independent
[artifact audit](movement-history-artifact-audit.json).
[Evidence identities](movement-history-evidence.json) bind the retained results.

Private archives are under `dist/movement-history-verified/`:

| Archive | Bytes | SHA-256 |
|---|---:|---|
| PraxisCorporis-Windows-x64-private.zip | 328166177 | `aa084e2d345251382901e7e0979ef8656cd7042bdf4c9fc500c25f92972e5f7c` |
| PraxisCorporis-macOS-universal-private.zip | 350611745 | `13638e30118380336fb564836370559390ec0e314f6833855d14bededae4dd3c` |

The anatomy pack remains 624166432 bytes, SHA-256
`5db1ab9a5e8d4630a63cfa68e701232ace4fc751dd9f8e8bab094e8b1317e109`.

## Limits

These checks inject input events. Human keyboard/device and accessibility acceptance,
representative laptop trials and actual Mac execution remain pending. The independent
[Linux-template popup limitation](POPUP_TEMPLATE_VERIFICATION.md) remains open;
Linux is not a release target. Human source and expert medical review remain pending.
