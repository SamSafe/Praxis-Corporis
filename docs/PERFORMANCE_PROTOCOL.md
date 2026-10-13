# Desktop performance protocol

Status: repeatable measurement plan. The developer profiler supplies configurable
diagnostic observations; it does not by itself pass the sustained laptop gate. Target performance
remains 30 sustained FPS at 1080p, with 60 FPS as a higher-quality goal, as proposed in
[RELEASE_CRITERIA.md](RELEASE_CRITERIA.md).

The first guarded repeated native observation is retained in
[WINDOWS_SUSTAINED_PROFILE.md](audit/WINDOWS_SUSTAINED_PROFILE.md). Its 1920 × 1080
window used 832 × 611/657 3D buffers; only one of 24 samples remained focused
throughout. The measurements validate the pipeline and describe that host/context.
They do not pass a foreground trial at the intended 1080p 3D resolution.

## Identify the test

Record the actual archive/hash and source revision, source geometry hashes, engine,
OS, CPU, total physical RAM, reported graphics adapter/driver, window and scene viewport
pixel sizes, display scaling, VSync, and any frame-rate limit. Include the quality preset,
MSAA, label settings, active geometry and whether the app is foreground/visible.
Use an extracted native executable and a separate local QA user-data directory.

Keep power mode, display resolution and background workload reasonably consistent
between before/after trials. Record uncontrolled factors instead of treating the run
as a minimum-hardware result. The development display uses software rendering;
its observations must be kept separate from the actual Windows AMD renderer.

## Workloads

| Workload | Purpose |
|---|---|
| First body load and first visible frame | Measures startup plus source verification and prepared-scene loading. |
| Revisit a body in the same process | Separates reused resources from first-in-process loading. |
| Whole-body orbit, both HRA references | Exercises all source geometry and ordinary navigation. |
| Chest orbit with faded lungs | Exercises overlapping opacity and surrounding context. |
| Chest at local-label densities 1, 8 and 12 | Measures bounded ray queries and UI layout alongside rendering. |
| Isolated heart part | Establishes a small-geometry comparison. |
| Moved organ with original-position overlays | Adds inspection/ghost rendering and reversible state changes. |
| Whole bone study and isolated femur | Samples a distinct, smaller source pack without implying HRA registration. |
| Several body switches and saved-view restores | Measures transition time, transient/retained memory and stability. |

There are no condition visuals or verified pathway animations to measure yet. Add
those workloads when actual versioned content exists.

## Measurements and interpretation

For a sustained acceptance trial, warm up each scene, then measure at least 60 seconds
of useful navigation; repeat three times on representative Windows and Mac laptops.
Do not infer sustained performance from an isolated peak FPS value. Report frame count,
actual duration, average frame cadence, p50/p95/p99/maximum interval, and counts over
33.33 ms and 100 ms. Retain the raw intervals and percentile convention.

The profiler defaults to eight five-second scenes after one-second warmups. Explicit
options can request 60 seconds, two-second warmups, three repetitions and a
1920 × 1080 window. Each repetition reloads all three references before reconstructing
the same workloads; later loads may reuse resources and OS caches. This initial suite
uses label density 8; densities 1/12, moved-organ overlays and saved-view transitions
remain additional acceptance workloads.
It samples intervals between rendered `frame_post_draw` callbacks during scripted
orbit. This reflects application frame cadence, including scheduling and VSync;
it is not GPU execution time or display presentation latency. Its interval percentiles
use nearest rank. Its output and validation command are described in
[NATIVE_BUILDS.md](NATIVE_BUILDS.md).

Record process working set and private memory separately with the native host's
process tools. A sampled maximum can miss brief spikes. The operating system's peak
working-set counter differs from private committed memory; neither measures GPU memory.
The high-water mark across several references is separate from a per-scene reading.
Do not label Godot debug-only counters as release process memory.

For loads, distinguish process startup, source verification, scene preparation and
first visible frame. A newly started process can still have warm OS file caches.
Do not call it a cold-cache trial without controlling/documenting the cache state.
The profiler records the complete `switch_body` wall time, raw intervals between
process callbacks with partial opening/closing boundaries, stage transitions and
the delay to the next post-draw callback after loading completes. Intervals sum to
the wall time; the maximum reveals stalls even when other portions yield UI frames.
Stage timestamps include scheduling and adjacent work, not isolated CPU execution
costs. The post-draw delay is separate from startup and is not an independently
verified first-visible-frame or presentation timestamp.

The repository Windows runner binds the profile to the archive hash, build/source
revision and actual pinned engine. It retains raw intervals, validates every planned
scene/repetition and reference load, and records the native OS, RAM, CPU, graphics
driver and active power scheme without changing host settings. Scene reports record
window focus throughout sampling, actual window/viewport dimensions, MSAA and VSync.
An active power scheme does not establish AC/battery or thermal state. The window
includes side panels, so its 3D viewport is smaller than 1920 × 1080. Unfocused scenes
must be interpreted accordingly. See the commands in [NATIVE_BUILDS.md](NATIVE_BUILDS.md).

Fixed-window sampling rejects changes to the window or 3D viewport during a scene.
Keep interrupted/rejected runs and their raw intervals; do not remove a long stall
or rewrite actual dimensions to create a passing trial. A frame gap alone cannot
establish whether rendering, window interaction, suspension or another host event
caused it. Document the observed focus and uncontrolled context and repeat the trial.

## Optimization evidence

Compare the same workload and source hashes on the same native hardware before and
after a change. Confirm that selection, hidden/faded picking, actual label surface
ownership, part inspection, original placement, undo/restore and saved-view identity
still work. Record visual differences and any tradeoff in detail or memory. Automatic
detail adaptation must preserve the selected structure and disclose the available
quality control; it cannot hide an anatomy-coverage gap.

A passing local diagnostic run leaves representative hardware, Mac execution,
trackpad/keyboard usability and qualified medical review as separate gates.

The guarded Windows baseline also observed approximately 2.0–2.2-second HRA process
gaps during the `Loading anatomy` stage despite yields elsewhere. Prioritize a
matched before/after investigation of that stage; the timestamps alone do not
identify a specific blocking engine operation. Preserve source geometry, selection,
labels and restore fidelity in any loading change.

New profiles retain individual durations for prepared-resource request, status polls,
collection, instantiation and node indexing. These measure time inside each call,
including synchronization and scheduling, rather than isolated CPU or GPU cost.
They occupy only part of the outer load wall time; process intervals still capture
pauses outside those calls. Historical profiles remain valid without this extension.
