# Prepared anatomy loading comparison

The `e85e638` private viewer loads precomputed triangle picking shapes in small
groups. On the same Windows host, median peak loading gaps fell by 88.7% for the
female HRA reference and 94.4% for the male reference. Total HRA switch times stayed
around 2.8–2.9 seconds, and process peak working set was 1,746,427,904 bytes.
These are repeated diagnostic observations, not a maximum-pause or hardware
acceptance guarantee.

## Workload and evidence

All three trials used Godot 4.7.2, Windows 11 Home 10.0.26300, the Ryzen 5 PRO 6650U,
the native AMD Radeon renderer/driver, the same pinned source hashes, a 1920 × 1080
window, two-second navigation samples, half-second warmups and three repetitions.
Each completed 24 navigation samples and nine reference switches. All navigation
samples retained window focus. The reported host identity and Balanced power scheme
match; background activity, power source, thermal state and OS file caches were not
controlled. Later references can reuse resources. This is not a cold-cache trial.

| Trial | Committed application | Raw measurements | Native binding | Build and archive audit |
|---|---|---|---|---|
| Instrumented baseline | `a2ee90f` | [raw](loading-baseline-profile.json) | [binding](loading-baseline-qa.json) | [build](loading-baseline-build-report.json), [audit](loading-baseline-artifact-audit.json) |
| Runtime shape rebuilding experiment | `d8771b1` | [raw](loading-runtime-shapes-profile.json) | [binding](loading-runtime-shapes-qa.json) | [build](loading-runtime-shapes-build-report.json), [audit](loading-runtime-shapes-artifact-audit.json) |
| Precomputed shape groups | `e85e638` | [raw](loading-grouped-profile.json) | [binding](loading-grouped-qa.json) | [build](loading-grouped-build-report.json), [audit](loading-grouped-artifact-audit.json) |

Each binding retains archive/source/tool hashes, startup host observations, exact raw
profile SHA-256 and independently recomputed workload summaries. Original intervals
remain unchanged. The [final generated report](WINDOWS_GROUPED_SELECTION_PROFILE.md)
also shows navigation, load stages, memory scope and actual rendering dimensions.

## Loading results

Ranges are the minimum/maximum of three separate switches per reference. Peak gap
means the largest interval between process callbacks during one switch, including
opening and closing boundaries; it is not isolated engine execution time.

| Reference | Baseline wall seconds | Final wall seconds | Baseline peak gap ms | Final peak gap ms | Reduction in median peak gap |
|---|---:|---:|---:|---:|---:|
| HRA female | 2.628–2.815 | 2.837–2.878 | 1940.128–2095.575 | 233.495–253.818 | 88.7% |
| HRA male | 2.678–2.784 | 2.867–2.897 | 1936.766–2009.385 | 110.022–113.198 | 94.4% |
| BodyParts3D male bone study | 0.499–0.526 | 0.530–0.549 | 253.202–267.196 | 79.687–86.390 | 68.8% |

The reduction is `100 × (1 − median(final peak gaps) / median(baseline peak gaps))`.
The final trial retained 11 load intervals above 100 ms: seven across female loads,
four across male loads, and none across bone-study loads. Loading is more responsive;
total loading time is slightly longer. Female loads processed 87 UI frames instead
of 37–39; male loads processed 89–90 instead of 37; bone loads processed 19 instead
of 11. Frame counts alone are not a latency bound.

## Why the implementation changed

Call-level baseline timings showed fast request/status/collection calls, roughly
9–11 ms scene instantiation and 1–2 ms node indexing. The two-second gap occurred
between these calls. This narrows the problem to work triggered by loading the
prepared resources, without identifying a specific CPU, physics or GPU operation.
Godot documents that resource/rendering synchronization can cause stalls:
[thread-safe API guidance](https://docs.godotengine.org/en/4.7/tutorials/performance/thread_safe_apis.html).

Removing bundled colliders and rebuilding picking shapes during runtime reduced the
gaps, but increased HRA wall times to 5.668–6.269 seconds and peak working set to
3,049,803,776 bytes. That experiment remains retained above. The final implementation
instead precomputes the exact picking shapes offline and reads them in 48 female,
52 male and eight bone-study groups. Group budgets are 80,000 triangles or 32 meshes;
a single mesh can exceed the triangle budget. No mesh is split or simplified.
Geometry scenes and picking groups retain the original source and engine identity.
Materials and collider nodes are prepared with an approximately 8 ms/40-mesh yield
budget after the resources are ready.

| Trial | OS peak working set bytes | Maximum sampled private bytes |
|---|---:|---:|
| Baseline | 1,781,235,712 | 1,908,994,048 |
| Runtime rebuilding | 3,049,803,776 | 3,213,475,840 |
| Precomputed groups | 1,746,427,904 | 1,904,308,224 |

These are whole-process observations, not per-reference or GPU memory. Private
memory is sampled every 500 ms and can miss brief peaks. One comparison does not
establish a general memory reduction.

## Fidelity, validation and remaining work

The engine comparison checks all 1,792 meshes against the prior caches: exact
surface arrays (vertices, normals, indices and other attributes), source transforms,
hierarchy, names, material settings and triangle picking faces. Fresh-import packing
also excludes runtime collider nodes. Seven independent picking-cache faults reject
missing/incompatible data, wrong source identity, unknown/duplicate nodes and missing
meshes while preserving the current real geometry, selection, edits and undo state.
The existing loading/input tests and 31 Python checks pass. Exported Linux workflows
and Mac embedded-content/resource-boundary checks pass for both rebuilt packages.
The final Windows release also passed its normal rendered source-search, inspection,
saved-view/note, loading/failure preservation, keyboard and credited-export workflows.
All fifteen captures were inspected and are retained with
[the exact-artifact workflow evidence](windows-grouped-selection-viewer-qa.json).

The final navigation samples observed 59.4–59.9 average frame-cadence FPS, a highest
scene p95 of 17.738 ms and no rendered intervals above 100 ms. Actual 3D buffers were
832 × 611/657, and samples lasted only two seconds. This does not replace the earlier
[sustained observation](WINDOWS_SUSTAINED_PROFILE.md) or pass foreground 1080p 3D,
representative Windows/Mac hardware, human-input or medical-review acceptance.
Single large shapes and final reference replacement can still pause. Improving those
operations and measuring the intended 3D resolution remain follow-up work.
