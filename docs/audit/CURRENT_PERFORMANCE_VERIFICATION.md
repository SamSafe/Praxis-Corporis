# Current native performance observations

The exact `22e9943` private Windows archive completed all 57 one-minute samples at
actual 1920 × 1080: nineteen workloads across eight references, repeated three times.
Checked 2026-11-27. **Window focus held throughout every sample.** Power was on AC;
background work and thermal state were not observed or controlled, so this is a
complete measurement, not a controlled foreground trial.

Build `22e9943` is study content revision 17 (the `09970ee` content) with the
profiling fix below; the application, geometry and content are otherwise those of
`09970ee`. The Windows ZIP is 661,248,869 bytes, SHA-256
`f39ab87b5dae1e7938c37772b2d60644b1a062b4230e1ae88cdb39d0a2dde621`. The same archive
passes [native headless QA](windows-qa-22e9943/report.json).

## Observed results

| Measurement | Recorded result |
| --- | --- |
| Completed samples / reference loads | 57 / 24 |
| Retained rendered intervals / measured duration | 200,407 / 3,420.48 seconds |
| Fully focused samples | 57 of 57 |
| Average frame-cadence FPS, 17 of 19 workloads | 59.6–59.9 |
| Complete male body, whole-body orbit | 52.9–54.0 FPS; p95 19.4–21.1 ms |
| Complete male body, chest orbit with faded lungs and labels | 41.3–41.6 FPS; p95 36.6–37.3 ms |
| Intervals above 33.33 ms / 100 ms | 680 (all in the complete male body's chest orbit) / 0 |
| Largest rendered interval | 55.648 ms |
| Largest reference load (wall time) | 5.887 seconds (complete male body) |
| Largest process gap while loading | 365.00 ms |
| Observed peak process working set | 2,646,269,952 bytes |
| Maximum sampled private memory | 2,868,129,792 bytes |

The complete male body (3476 BodyParts3D structures) is the only reference below 59
FPS. Its chest orbit drops about 9% of intervals past 33.33 ms but none past 100 ms.
The data does not establish whether geometry, overdraw, labels or fading costs the
most. Repeats agree closely; all samples and outliers remain in the raw report.

The host reports Windows 11 Home build 26300, Ryzen 5 PRO 6650U, AMD Radeon Graphics
(driver 32.0.21037.3009) and 15,859,003,392 bytes of physical RAM, with the Balanced
power scheme. Per-workload ranges, percentiles, loading stages and source geometry
fingerprints are in the [generated observations](WINDOWS_22E9943_SUSTAINED.md).
These are frame-callback cadence and process-memory observations; they do not
measure GPU execution or presentation latency, or establish minimum hardware.

## Profiling fix

The complete male body was added after the last sustained measurement. Its recorded
plan listed two scenes while the profiler ran three, and the validator did not expect
the body, so no later build could produce an accepted profile; the fixed one-hour
limit also stopped a full run of `09970ee` at 56 of 57 samples. Commit `22e9943`
makes the recorded plan decide which scenes run, expects the complete body's three
workloads for builds that record it (older reports stay verifiable), and sizes the
time limit to the workload count.

## Validation and evidence

The native process exits with code 0. Its complete workload plan, repetitions,
reference hashes, raw interval arithmetic/percentiles, exact viewport configuration,
content pack and pinned runtime engine pass independent validation. Its marked
temporary folder is removed.

- [Raw measurements](22e9943-sustained-profile.json).
- [Exact-artifact native report](22e9943-sustained-profile-qa.json) and
  [attempt record](22e9943-sustained-profile-attempt.json).
- [Runtime](22e9943-sustained-profile-runtime.log.txt) and
  [engine](22e9943-sustained-profile-engine.log.txt) logs.
- [Derived scope checks](22e9943-sustained-validation.json).
- [Evidence hashes](22e9943-sustained-evidence.json).
- [All 102 Python checks](22e9943-sustained-python.log.txt).

The previous 48-sample `c86cfba` observation (sixteen workloads, 18/48 focused) is
retained unchanged as [historical evidence](WINDOWS_CURRENT_SUSTAINED.md) with its
`current-sustained-*` files.

## Acceptance still required

Follow the [performance protocol](../PERFORMANCE_PROTOCOL.md) for controlled
foreground trials, representative Windows/Mac devices, additional label densities,
moved-organ overlays, saved-view transitions and agreed loading/memory budgets.
The current observation cannot substitute for those requirements.

Mac execution is still untested. Actual device trials, qualified content review,
scope/rights and release decisions remain open in the
[production checkpoint](../PRODUCTION_READINESS.md).
