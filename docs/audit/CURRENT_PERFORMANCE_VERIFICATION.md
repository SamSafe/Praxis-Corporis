# Current native performance observations

The exact `c86cfba` private Windows archive completed all 48 one-minute samples at
actual 1920 × 1080: sixteen workloads across seven references, repeated three times.
Checked 2026-10-19. **This is complete measurement evidence, not a passing
uninterrupted foreground trial:** only 18/48 samples retained focus throughout.

The current private build ID is `f962ce195f324c89a400cf07d8767c9d`. The Windows ZIP is
328,224,510 bytes, SHA-256
`7518559369a6b55f20fbcf37363b47edb5013e666136b675469426e35b649ec4`.
The application, geometry, draft content and current Mac candidate are unchanged.

## Observed results

| Measurement | Recorded result |
| --- | --- |
| Completed samples / reference loads | 48 / 21 |
| Retained rendered intervals / measured duration | 169,448 / 2,880.38 seconds |
| Fully focused samples | 18; 59.8–59.9 average frame-cadence FPS |
| Samples with a focus interruption | 30; 39.9–59.9 average frame-cadence FPS |
| Intervals above 33.33 ms / 100 ms | 1,078 / 1 |
| Largest rendered interval | 111.366 ms |
| Observed peak process working set | 1,755,348,992 bytes |
| Maximum sampled private memory | 1,967,280,128 bytes |

The focus flag records whether focus held for the entire sample. It does not record
the duration or cause of an interruption. Background activity, power source and
thermal state were uncontrolled; the data does not establish why some samples were
slower. All samples and outliers remain in the raw report. Each workload's summary
now shows its own focused-sample count alongside ranges across all three repeats.

The host reports Windows 11 Home build 26300, Ryzen 5 PRO 6650U, AMD Radeon Graphics
and 15,859,003,392 bytes of physical RAM. Detailed driver, active power scheme,
VSync, MSAA, loading stages and individual raw intervals are retained in the
[generated observations](WINDOWS_CURRENT_SUSTAINED.md). These are frame-callback
cadence and process-memory observations; they do not measure GPU execution or
presentation latency, or establish minimum hardware.

## Validation and evidence

The native process exits with code 0. Its complete workload plan, repetitions,
reference hashes, raw interval arithmetic/percentiles, exact viewport configuration,
content pack and pinned runtime engine pass independent validation. Runtime logs
contain no engine error, Unicode parsing diagnostic or ObjectDB leak. Its marked
temporary folder is removed and independently checked absent.

- [Raw measurements](current-sustained-profile.json).
- [Exact-artifact native report](current-sustained-profile-qa.json).
- [Derived scope and cleanup checks](current-sustained-validation.json).
- [Evidence hashes](current-sustained-evidence.json).
- [All 100 Python checks](current-sustained-python.log.txt).

Formatter/test checkpoint `8d2a175` exposes focus context without dropping
interrupted samples or their stalls. The regression fixture requires both focused
and interrupted samples to remain in frame counts and outlier totals. Historical
reports retain their original source/tool identities and formatting.

## Acceptance still required

Follow the [performance protocol](../PERFORMANCE_PROTOCOL.md) for controlled
foreground trials, representative Windows/Mac devices, additional label densities,
moved-organ overlays, saved-view transitions and agreed loading/memory budgets.
The current observation cannot substitute for those requirements. The earlier
`ae600197` all-focused trial remains historical evidence for its own eight workloads.

Mac execution is still untested by the user as of 2026-10-19. Actual device trials,
qualified content review, scope/rights and release decisions remain open in the
[production checkpoint](../PRODUCTION_READINESS.md).
