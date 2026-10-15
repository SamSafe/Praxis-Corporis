# Native Windows rendering observations

Recorded UTC: 2026-10-15T17:50:52.059531+00:00.

Source revision: `8a44cdb861e044b23b8fa73f2cd5ca6ba8f597e5`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(328,074,341 bytes), SHA-256 `2196875b10942fefb4810805af278284f874f762fa42b3b6dda38f01704ef645`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 1-second samples, 0.25-second stationary warmups, 1 repetitions at a 1920 × 1080 window.
Scene view: expanded; 3D rendering resolution: 100% of displayed pixels.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Short scripted validation of all sixteen mapped workloads after adding independent spinal studies; no sustained-performance or foreground-use claim.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

| Reference | Scene | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 59.9 | 17.50 | 17.67 | 17.67 | 0 | 0 |
| female | chest orbit with faded lungs and local labels | 60.7 | 17.41 | 20.02 | 20.02 | 0 | 0 |
| female | isolated supplied-part orbit | 59.9 | 17.21 | 17.97 | 17.97 | 0 | 0 |
| male | whole-body orbit | 59.9 | 17.30 | 17.71 | 17.71 | 0 | 0 |
| male | chest orbit with faded lungs and local labels | 59.9 | 17.99 | 23.26 | 23.26 | 0 | 0 |
| male | isolated supplied-part orbit | 59.9 | 17.62 | 17.70 | 17.70 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 60.0 | 17.45 | 17.76 | 17.76 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 59.9 | 17.59 | 18.15 | 18.15 | 0 | 0 |
| hra-v1-2-female-cord-study | whole-body orbit | 59.9 | 17.33 | 17.52 | 17.52 | 0 | 0 |
| hra-v1-2-female-cord-study | isolated supplied-part orbit | 59.9 | 17.38 | 17.87 | 17.87 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | whole-body orbit | 59.9 | 17.63 | 17.71 | 17.71 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | isolated supplied-part orbit | 59.9 | 17.31 | 17.86 | 17.86 | 0 | 0 |
| hra-v1-2-male-cord-study | whole-body orbit | 59.9 | 17.57 | 17.75 | 17.75 | 0 | 0 |
| hra-v1-2-male-cord-study | isolated supplied-part orbit | 59.9 | 17.29 | 17.74 | 17.74 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | whole-body orbit | 59.9 | 17.18 | 17.36 | 17.36 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | isolated supplied-part orbit | 59.9 | 17.27 | 17.67 | 17.67 | 0 | 0 |

16 samples retain 961 rendered intervals over 16.03 measured seconds.
Actual 3D viewport sizes: 1920 × 1080.
Window focus held throughout 16/16 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all 7 references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 2.924 | 2.861 | 260.13 | 3 | 607.88 |
| 1 | male | 2.885 | 2.831 | 116.36 | 1 | 25.78 |
| 1 | bodyparts-male-bones-study | 0.516 | 0.489 | 83.63 | 0 | 11.04 |
| 1 | hra-v1-2-female-cord-study | 0.294 | 0.275 | 56.54 | 0 | 7.00 |
| 1 | hra-v1-2-female-vertebrae-study | 0.373 | 0.356 | 60.06 | 0 | 5.92 |
| 1 | hra-v1-2-male-cord-study | 0.098 | 0.081 | 22.32 | 0 | 3.57 |
| 1 | hra-v1-2-male-vertebrae-study | 0.312 | 0.296 | 52.53 | 0 | 5.57 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.025 |
| 1 | female | Checking source file | 0.267 |
| 1 | female | Loading anatomy | 0.072 |
| 1 | female | Preparing view | 0.018 |
| 1 | female | Checking anatomy | 0.015 |
| 1 | female | Loading selection | 2.177 |
| 1 | female | Preparing selection | 0.306 |
| 1 | female | Opening reference | 0.044 |
| 1 | male | Reference request | 0.015 |
| 1 | male | Checking source file | 0.249 |
| 1 | male | Loading anatomy | 0.061 |
| 1 | male | Preparing view | 0.014 |
| 1 | male | Checking anatomy | 0.015 |
| 1 | male | Loading selection | 2.119 |
| 1 | male | Preparing selection | 0.297 |
| 1 | male | Opening reference | 0.114 |
| 1 | bodyparts-male-bones-study | Reference request | 0.015 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.049 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.286 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.046 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.083 |
| 1 | hra-v1-2-female-cord-study | Reference request | 0.016 |
| 1 | hra-v1-2-female-cord-study | Checking source file | 0.033 |
| 1 | hra-v1-2-female-cord-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-female-cord-study | Preparing view | 0.017 |
| 1 | hra-v1-2-female-cord-study | Checking anatomy | 0.000 |
| 1 | hra-v1-2-female-cord-study | Loading selection | 0.190 |
| 1 | hra-v1-2-female-cord-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-female-cord-study | Opening reference | 0.019 |
| 1 | hra-v1-2-female-vertebrae-study | Reference request | 0.015 |
| 1 | hra-v1-2-female-vertebrae-study | Checking source file | 0.033 |
| 1 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing view | 0.017 |
| 1 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.000 |
| 1 | hra-v1-2-female-vertebrae-study | Loading selection | 0.281 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-female-vertebrae-study | Opening reference | 0.008 |
| 1 | hra-v1-2-male-cord-study | Reference request | 0.015 |
| 1 | hra-v1-2-male-cord-study | Checking source file | 0.017 |
| 1 | hra-v1-2-male-cord-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-male-cord-study | Preparing view | 0.017 |
| 1 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-cord-study | Loading selection | 0.022 |
| 1 | hra-v1-2-male-cord-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-male-cord-study | Opening reference | 0.009 |
| 1 | hra-v1-2-male-vertebrae-study | Reference request | 0.015 |
| 1 | hra-v1-2-male-vertebrae-study | Checking source file | 0.051 |
| 1 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing view | 0.017 |
| 1 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.000 |
| 1 | hra-v1-2-male-vertebrae-study | Loading selection | 0.208 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-male-vertebrae-study | Opening reference | 0.003 |

## Memory and interpretation

Observed process peak working set: 1,748,660,224 bytes. Maximum sampled private memory: 1,926,459,392 bytes.
The host samples every 500 ms over the entire process; brief spikes may be missed. These values do not measure GPU or per-scene memory.

Recorded active power scheme: Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced). This does not establish AC/battery or thermal state.

Workspace views include controls and panels; expanded native views cover the requested window pixels. These are frame-callback cadence and process-gap observations, not GPU execution or display latency.
The eight-scene suite uses label density 8; additional densities, moved-organ overlays and saved-view transitions remain outside this run. One Windows host leaves representative hardware, Mac, human-input, accessibility and qualified medical review gates open.

Source geometry fingerprints:

- female: `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5`.
- male: `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863`.
- bodyparts-male-bones-study: `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27`.
- hra-v1-2-female-cord-study: `d9bfc840783a415068e34b8a1a9343fff40ad03d0025fafabf74f9d8664887f8`.
- hra-v1-2-female-vertebrae-study: `bdbea49a40e9e64cac1c8f0d67b6483686a3cc9617f7cae645e58159e4b02984`.
- hra-v1-2-male-cord-study: `a7858d88c2237aa7d559c4c1d638923d213d2a9f46c575dea03d6ba67a9975c0`.
- hra-v1-2-male-vertebrae-study: `981041904438bd74c14d671af8f87b3f407b675294bbf297af673c8df7144451`.

Raw profile SHA-256: `95df3f0d6a212333c5fea7557c81ae1b319f7133a4f27633be0b720cea521f7a`. Full native evidence retains the archive identity, tool fingerprints and host observations.
