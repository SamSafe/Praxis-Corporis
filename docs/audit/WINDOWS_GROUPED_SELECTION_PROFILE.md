# Native Windows rendering observations

Recorded UTC: 2026-10-13T06:59:50.534649+00:00.

Source revision: `e85e638db88a77ec821c17bdf890d607e20af4ba`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(290,831,020 bytes), SHA-256 `7d48b589c0b255f24b37f74110eead9b86de276099614430576aba32048a95d8`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 2-second samples, 0.5-second stationary warmups, 3 repetitions at a 1920 × 1080 window.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Matched loading diagnostic on the development Windows host; two-second navigation samples are not sustained acceptance. Background workload, power source, focus and thermal state uncontrolled.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

| Reference | Scene | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 59.9–59.9 | 17.21–17.42 | 17.57–17.78 | 17.95 | 0 | 0 |
| female | chest orbit with faded lungs and local labels | 59.8–59.9 | 17.26–17.52 | 17.70–25.38 | 30.76 | 0 | 0 |
| female | isolated supplied-part orbit | 59.9–59.9 | 17.48–17.59 | 17.73–17.87 | 18.25 | 0 | 0 |
| male | whole-body orbit | 59.9–59.9 | 17.38–17.46 | 17.44–19.39 | 19.45 | 0 | 0 |
| male | chest orbit with faded lungs and local labels | 59.4–59.9 | 17.40–17.43 | 17.52–18.30 | 35.03 | 1 | 0 |
| male | isolated supplied-part orbit | 59.9–59.9 | 17.39–17.59 | 17.57–18.08 | 19.17 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 59.9–59.9 | 17.31–17.64 | 17.61–17.92 | 18.00 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 59.9–59.9 | 17.45–17.74 | 17.57–17.88 | 18.10 | 0 | 0 |

24 samples retain 2,879 rendered intervals over 48.08 measured seconds.
Actual 3D viewport sizes: 832 × 611, 832 × 657.
Window focus held throughout 24/24 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all three references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 2.878 | 2.823 | 253.82 | 3 | 607.66 |
| 1 | male | 2.884 | 2.829 | 113.20 | 1 | 26.86 |
| 1 | bodyparts-male-bones-study | 0.530 | 0.502 | 79.69 | 0 | 15.67 |
| 2 | female | 2.837 | 2.786 | 233.50 | 2 | 26.55 |
| 2 | male | 2.897 | 2.843 | 110.02 | 1 | 19.22 |
| 2 | bodyparts-male-bones-study | 0.549 | 0.521 | 82.07 | 0 | 14.59 |
| 3 | female | 2.840 | 2.787 | 234.41 | 2 | 30.54 |
| 3 | male | 2.867 | 2.812 | 113.07 | 2 | 20.49 |
| 3 | bodyparts-male-bones-study | 0.537 | 0.507 | 86.39 | 0 | 12.50 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.019 |
| 1 | female | Checking source file | 0.230 |
| 1 | female | Loading anatomy | 0.051 |
| 1 | female | Preparing view | 0.023 |
| 1 | female | Checking anatomy | 0.014 |
| 1 | female | Loading selection | 2.180 |
| 1 | female | Preparing selection | 0.320 |
| 1 | female | Opening reference | 0.041 |
| 1 | male | Reference request | 0.017 |
| 1 | male | Checking source file | 0.234 |
| 1 | male | Loading anatomy | 0.059 |
| 1 | male | Preparing view | 0.015 |
| 1 | male | Checking anatomy | 0.014 |
| 1 | male | Loading selection | 2.130 |
| 1 | male | Preparing selection | 0.305 |
| 1 | male | Opening reference | 0.111 |
| 1 | bodyparts-male-bones-study | Reference request | 0.016 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.050 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.020 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.016 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.276 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.072 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.079 |
| 2 | female | Reference request | 0.016 |
| 2 | female | Checking source file | 0.234 |
| 2 | female | Loading anatomy | 0.062 |
| 2 | female | Preparing view | 0.011 |
| 2 | female | Checking anatomy | 0.015 |
| 2 | female | Loading selection | 2.128 |
| 2 | female | Preparing selection | 0.321 |
| 2 | female | Opening reference | 0.050 |
| 2 | male | Reference request | 0.017 |
| 2 | male | Checking source file | 0.250 |
| 2 | male | Loading anatomy | 0.046 |
| 2 | male | Preparing view | 0.011 |
| 2 | male | Checking anatomy | 0.013 |
| 2 | male | Loading selection | 2.149 |
| 2 | male | Preparing selection | 0.305 |
| 2 | male | Opening reference | 0.108 |
| 2 | bodyparts-male-bones-study | Reference request | 0.017 |
| 2 | bodyparts-male-bones-study | Checking source file | 0.049 |
| 2 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 2 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 2 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 2 | bodyparts-male-bones-study | Loading selection | 0.288 |
| 2 | bodyparts-male-bones-study | Preparing selection | 0.076 |
| 2 | bodyparts-male-bones-study | Opening reference | 0.082 |
| 3 | female | Reference request | 0.017 |
| 3 | female | Checking source file | 0.234 |
| 3 | female | Loading anatomy | 0.054 |
| 3 | female | Preparing view | 0.018 |
| 3 | female | Checking anatomy | 0.014 |
| 3 | female | Loading selection | 2.132 |
| 3 | female | Preparing selection | 0.319 |
| 3 | female | Opening reference | 0.052 |
| 3 | male | Reference request | 0.016 |
| 3 | male | Checking source file | 0.234 |
| 3 | male | Loading anatomy | 0.046 |
| 3 | male | Preparing view | 0.011 |
| 3 | male | Checking anatomy | 0.013 |
| 3 | male | Loading selection | 2.124 |
| 3 | male | Preparing selection | 0.312 |
| 3 | male | Opening reference | 0.111 |
| 3 | bodyparts-male-bones-study | Reference request | 0.017 |
| 3 | bodyparts-male-bones-study | Checking source file | 0.049 |
| 3 | bodyparts-male-bones-study | Loading anatomy | 0.018 |
| 3 | bodyparts-male-bones-study | Preparing view | 0.017 |
| 3 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 3 | bodyparts-male-bones-study | Loading selection | 0.280 |
| 3 | bodyparts-male-bones-study | Preparing selection | 0.069 |
| 3 | bodyparts-male-bones-study | Opening reference | 0.086 |

## Memory and interpretation

Observed process peak working set: 1,746,427,904 bytes. Maximum sampled private memory: 1,904,308,224 bytes.
The host samples every 500 ms over the entire process; brief spikes may be missed. These values do not measure GPU or per-scene memory.

Recorded active power scheme: Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced). This does not establish AC/battery or thermal state.

The 1080p window includes controls and panels; its 3D viewport is recorded above. These are frame-callback cadence and process-gap observations, not GPU execution or display latency.
The eight-scene suite uses label density 8; additional densities, moved-organ overlays and saved-view transitions remain outside this run. One Windows host leaves representative hardware, Mac, human-input, accessibility and qualified medical review gates open.

Source geometry fingerprints:

- female: `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5`.
- male: `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863`.
- bodyparts-male-bones-study: `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27`.

Raw profile SHA-256: `383c923dfe2cf301c7a75ea64530c27f0481d93682c8e9ffa7a06fb7a60e05e6`. Full native evidence retains the archive identity, tool fingerprints and host observations.
