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

The current display implementation offers an expanded Native view with a 3D buffer
matching the full client window. Schema-3 trials record view mode, displayed pixels,
rendering fraction and buffer pixels independently. Workspace/native renders only
the physical scene area beside the panels. Expanded/native at 1920 × 1080 must render
exactly 1920 × 1080; 75%/50% trials are explicit lower-resolution observations.
Window size alone still cannot establish a full-resolution result. The first
[full-resolution Windows trial](audit/WINDOWS_FULLHD_PROFILE.md) passed 24 one-minute
samples at actual 1920 × 1080, all focused throughout, observing 59.5–59.9 average
frame-cadence FPS. It meets the proposed 30-FPS baseline for the eight measured scenes
on that host. Representative Windows/Mac devices and the additional workloads below
remain required; historical measurements are retained unchanged.

The current `c86cfba` archive has a separate
[five-second diagnostic](audit/WINDOWS_CURRENT_DIAGNOSTIC.md): all sixteen workloads
across seven references at actual 1920 × 1080, with focus retained in 16/16 samples
and observed average frame cadence of 59.5–60.1 FPS. Its raw measurements and exact
artifact binding are retained. This short run does not meet the sustained protocol;
the current sixteen-workload plan requires 48 one-minute samples for three repeats.

The [current 48-sample observation](audit/CURRENT_PERFORMANCE_VERIFICATION.md) now
completes that measurement plan with all raw intervals retained. Eighteen samples
held focus throughout; thirty had a focus interruption. Average frame cadence was
59.8–59.9 FPS for the fully focused samples and 39.9–59.9 FPS across the interrupted
samples. This mixed-focus run does not pass an uninterrupted foreground trial.
Its report retains per-workload focus counts and all outliers. Controlled/device
acceptance remains open.

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

The profiler defaults to sixteen five-second scenes after one-second warmups. Explicit
options can request 60 seconds, two-second warmups, three repetitions and a
1920 × 1080 window. Each repetition reloads all seven references before reconstructing
the same workloads; later loads may reuse resources and OS caches. This suite
uses label density 8; densities 1/12, moved-organ overlays and saved-view transitions
remain additional acceptance workloads.
Current bundles add two scenes for each of four separate spinal references, so the
plan now contains sixteen workloads. The final report's measurement plan and full
scene/repetition validation determine completion. The `c86cfba` developer progress
file still reports the earlier eight-workload planned count; that counter is not
acceptance evidence.
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

New profiles retain individual durations for prepared-resource requests, status polls,
collection, instantiation and node indexing. These measure time inside each call,
including synchronization and scheduling, rather than isolated CPU or GPU cost.
They occupy only part of the outer load wall time; process intervals still capture
pauses outside those calls. Historical profiles remain valid without this extension.
Grouped picking data adds one request/collection per group; the independently checked
batch count distinguishes those calls from the single geometry-scene request.

The [matched loading comparison](audit/LOADING_OPTIMIZATION.md) retains the instrumented
baseline, runtime-rebuilding experiment and final precomputed-group trial. Median
peak HRA process gaps fell by 88.7–94.4%, while total loads stayed around 2.8–2.9 seconds
and observed peak working set stayed near the baseline. The final short profile
still does not pass the sustained or intended-render-resolution gates.
