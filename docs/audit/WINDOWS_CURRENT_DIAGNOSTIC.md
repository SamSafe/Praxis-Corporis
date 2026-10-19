# Native Windows rendering observations

Recorded UTC: 2026-10-19T05:39:15.125221+00:00.

Source revision: `c86cfba1e544b20917b66c14ea405f0b74abfd47`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(328,224,510 bytes), SHA-256 `7518559369a6b55f20fbcf37363b47edb5013e666136b675469426e35b649ec4`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 5-second samples, 1-second stationary warmups, 1 repetitions at a 1920 × 1080 window.
Scene view: expanded; 3D rendering resolution: 100% of displayed pixels.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Exact current c86cfba private archive; expanded Native 1920x1080 diagnostic. No other build or test workloads during sampling. Background applications, power source and thermal state uncontrolled; actual window focus recorded per sample.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

| Reference | Scene | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 59.9 | 17.81 | 18.78 | 20.96 | 0 | 0 |
| female | chest orbit with faded lungs and local labels | 60.1 | 22.51 | 26.60 | 30.51 | 0 | 0 |
| female | isolated supplied-part orbit | 59.9 | 18.05 | 18.91 | 19.74 | 0 | 0 |
| male | whole-body orbit | 59.5 | 18.51 | 23.38 | 29.14 | 0 | 0 |
| male | chest orbit with faded lungs and local labels | 59.9 | 23.53 | 25.83 | 35.39 | 1 | 0 |
| male | isolated supplied-part orbit | 59.9 | 18.00 | 19.04 | 19.96 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 59.9 | 18.23 | 18.93 | 20.00 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 59.9 | 18.36 | 18.93 | 26.89 | 0 | 0 |
| hra-v1-2-female-cord-study | whole-body orbit | 59.9 | 18.19 | 19.32 | 19.77 | 0 | 0 |
| hra-v1-2-female-cord-study | isolated supplied-part orbit | 59.9 | 18.34 | 18.91 | 19.27 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | whole-body orbit | 59.9 | 18.38 | 18.87 | 19.60 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | isolated supplied-part orbit | 59.9 | 18.59 | 19.23 | 20.00 | 0 | 0 |
| hra-v1-2-male-cord-study | whole-body orbit | 59.9 | 17.83 | 18.91 | 19.62 | 0 | 0 |
| hra-v1-2-male-cord-study | isolated supplied-part orbit | 59.9 | 17.51 | 17.92 | 18.43 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | whole-body orbit | 59.9 | 17.53 | 18.02 | 18.35 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | isolated supplied-part orbit | 59.9 | 17.68 | 18.02 | 18.12 | 0 | 0 |

16 samples retain 4,799 rendered intervals over 80.11 measured seconds.
Actual 3D viewport sizes: 1920 × 1080.
Window focus held throughout 16/16 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all 7 references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 3.421 | 3.345 | 294.45 | 5 | 782.86 |
| 1 | male | 3.781 | 3.709 | 147.25 | 4 | 43.13 |
| 1 | bodyparts-male-bones-study | 0.771 | 0.737 | 140.90 | 1 | 12.28 |
| 1 | hra-v1-2-female-cord-study | 0.404 | 0.386 | 94.13 | 0 | 8.18 |
| 1 | hra-v1-2-female-vertebrae-study | 0.580 | 0.562 | 87.46 | 0 | 7.44 |
| 1 | hra-v1-2-male-cord-study | 0.117 | 0.097 | 27.63 | 0 | 9.64 |
| 1 | hra-v1-2-male-vertebrae-study | 0.387 | 0.369 | 65.30 | 0 | 4.96 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.023 |
| 1 | female | Checking source file | 0.282 |
| 1 | female | Loading anatomy | 0.067 |
| 1 | female | Preparing view | 0.024 |
| 1 | female | Checking anatomy | 0.017 |
| 1 | female | Loading selection | 2.623 |
| 1 | female | Preparing selection | 0.325 |
| 1 | female | Opening reference | 0.060 |
| 1 | male | Reference request | 0.012 |
| 1 | male | Checking source file | 0.501 |
| 1 | male | Loading anatomy | 0.084 |
| 1 | male | Preparing view | 0.023 |
| 1 | male | Checking anatomy | 0.020 |
| 1 | male | Loading selection | 2.705 |
| 1 | male | Preparing selection | 0.290 |
| 1 | male | Opening reference | 0.145 |
| 1 | bodyparts-male-bones-study | Reference request | 0.014 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.084 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.016 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.019 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.003 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.448 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.047 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.140 |
| 1 | hra-v1-2-female-cord-study | Reference request | 0.013 |
| 1 | hra-v1-2-female-cord-study | Checking source file | 0.050 |
| 1 | hra-v1-2-female-cord-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-female-cord-study | Preparing view | 0.017 |
| 1 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-cord-study | Loading selection | 0.276 |
| 1 | hra-v1-2-female-cord-study | Preparing selection | 0.004 |
| 1 | hra-v1-2-female-cord-study | Opening reference | 0.027 |
| 1 | hra-v1-2-female-vertebrae-study | Reference request | 0.014 |
| 1 | hra-v1-2-female-vertebrae-study | Checking source file | 0.067 |
| 1 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing view | 0.018 |
| 1 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-vertebrae-study | Loading selection | 0.450 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-female-vertebrae-study | Opening reference | 0.012 |
| 1 | hra-v1-2-male-cord-study | Reference request | 0.015 |
| 1 | hra-v1-2-male-cord-study | Checking source file | 0.014 |
| 1 | hra-v1-2-male-cord-study | Loading anatomy | 0.018 |
| 1 | hra-v1-2-male-cord-study | Preparing view | 0.017 |
| 1 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-cord-study | Loading selection | 0.026 |
| 1 | hra-v1-2-male-cord-study | Preparing selection | 0.006 |
| 1 | hra-v1-2-male-cord-study | Opening reference | 0.020 |
| 1 | hra-v1-2-male-vertebrae-study | Reference request | 0.015 |
| 1 | hra-v1-2-male-vertebrae-study | Checking source file | 0.067 |
| 1 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing view | 0.018 |
| 1 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-vertebrae-study | Loading selection | 0.262 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-male-vertebrae-study | Opening reference | 0.005 |

## Memory and interpretation

Observed process peak working set: 1,759,461,376 bytes. Maximum sampled private memory: 1,945,595,904 bytes.
The host samples every 500 ms over the entire process; brief spikes may be missed. These values do not measure GPU or per-scene memory.

Recorded active power scheme: Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced). This does not establish AC/battery or thermal state.

Workspace views include controls and panels; expanded native views cover the requested window pixels. These are frame-callback cadence and process-gap observations, not GPU execution or display latency.
The measurement plan contains 16 distinct reference/workload pairs. Recorded label densities: 8.
These results cover only the listed workloads and settings. One Windows host leaves representative hardware, Mac, human-input, accessibility and qualified medical review gates open.

Source geometry fingerprints:

- female: `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5`.
- male: `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863`.
- bodyparts-male-bones-study: `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27`.
- hra-v1-2-female-cord-study: `d9bfc840783a415068e34b8a1a9343fff40ad03d0025fafabf74f9d8664887f8`.
- hra-v1-2-female-vertebrae-study: `bdbea49a40e9e64cac1c8f0d67b6483686a3cc9617f7cae645e58159e4b02984`.
- hra-v1-2-male-cord-study: `a7858d88c2237aa7d559c4c1d638923d213d2a9f46c575dea03d6ba67a9975c0`.
- hra-v1-2-male-vertebrae-study: `981041904438bd74c14d671af8f87b3f407b675294bbf297af673c8df7144451`.

Raw profile SHA-256: `d406ba764c72751470a9d75d0cdeb7499052f6178a8a07a04b4eb8e30e490106`. Full native evidence retains the archive identity, tool fingerprints and host observations.
