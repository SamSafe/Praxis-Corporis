# Native Windows rendering observations

Recorded UTC: 2026-10-16T05:18:27.502264+00:00.

Source revision: `82120935bacc41a182a7d0b48c83bfceff4d6b8d`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(328,107,248 bytes), SHA-256 `0772f5f5e9f782465abf46a33e52dbe7a6d2933988b651f970a57593d82be47f`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 1-second samples, 0.25-second stationary warmups, 1 repetitions at a 1920 × 1080 window.
Scene view: expanded; 3D rendering resolution: 100% of displayed pixels.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Short lifecycle validation of the current private runtime and guarded QA-session cleanup; no sustained-performance claim.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

| Reference | Scene | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 59.9 | 17.49 | 18.49 | 18.49 | 0 | 0 |
| female | chest orbit with faded lungs and local labels | 60.8 | 19.88 | 22.72 | 22.72 | 0 | 0 |
| female | isolated supplied-part orbit | 59.9 | 17.68 | 18.31 | 18.31 | 0 | 0 |
| male | whole-body orbit | 59.9 | 17.34 | 18.12 | 18.12 | 0 | 0 |
| male | chest orbit with faded lungs and local labels | 59.9 | 23.77 | 27.28 | 27.28 | 0 | 0 |
| male | isolated supplied-part orbit | 59.9 | 17.67 | 18.01 | 18.01 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 59.9 | 17.89 | 19.98 | 19.98 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 59.9 | 17.68 | 18.18 | 18.18 | 0 | 0 |
| hra-v1-2-female-cord-study | whole-body orbit | 59.9 | 17.82 | 18.24 | 18.24 | 0 | 0 |
| hra-v1-2-female-cord-study | isolated supplied-part orbit | 59.9 | 18.02 | 18.52 | 18.52 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | whole-body orbit | 59.9 | 17.96 | 18.26 | 18.26 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | isolated supplied-part orbit | 59.9 | 17.93 | 18.50 | 18.50 | 0 | 0 |
| hra-v1-2-male-cord-study | whole-body orbit | 59.9 | 17.70 | 17.89 | 17.89 | 0 | 0 |
| hra-v1-2-male-cord-study | isolated supplied-part orbit | 60.0 | 17.79 | 18.38 | 18.38 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | whole-body orbit | 59.9 | 17.71 | 20.09 | 20.09 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | isolated supplied-part orbit | 59.9 | 17.93 | 18.21 | 18.21 | 0 | 0 |

16 samples retain 961 rendered intervals over 16.02 measured seconds.
Actual 3D viewport sizes: 1920 × 1080.
Window focus held throughout 16/16 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all 7 references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 3.379 | 3.310 | 287.61 | 4 | 846.36 |
| 1 | male | 4.332 | 4.250 | 168.89 | 7 | 42.56 |
| 1 | bodyparts-male-bones-study | 0.790 | 0.760 | 125.39 | 1 | 13.90 |
| 1 | hra-v1-2-female-cord-study | 0.406 | 0.387 | 83.74 | 0 | 8.40 |
| 1 | hra-v1-2-female-vertebrae-study | 0.593 | 0.576 | 89.00 | 0 | 6.54 |
| 1 | hra-v1-2-male-cord-study | 0.106 | 0.089 | 25.65 | 0 | 6.41 |
| 1 | hra-v1-2-male-vertebrae-study | 0.472 | 0.455 | 79.90 | 0 | 5.95 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.020 |
| 1 | female | Checking source file | 0.283 |
| 1 | female | Loading anatomy | 0.067 |
| 1 | female | Preparing view | 0.025 |
| 1 | female | Checking anatomy | 0.018 |
| 1 | female | Loading selection | 2.594 |
| 1 | female | Preparing selection | 0.317 |
| 1 | female | Opening reference | 0.055 |
| 1 | male | Reference request | 0.014 |
| 1 | male | Checking source file | 0.482 |
| 1 | male | Loading anatomy | 0.084 |
| 1 | male | Preparing view | 0.025 |
| 1 | male | Checking anatomy | 0.021 |
| 1 | male | Loading selection | 3.250 |
| 1 | male | Preparing selection | 0.294 |
| 1 | male | Opening reference | 0.162 |
| 1 | bodyparts-male-bones-study | Reference request | 0.014 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.084 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.002 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.475 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.056 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.124 |
| 1 | hra-v1-2-female-cord-study | Reference request | 0.013 |
| 1 | hra-v1-2-female-cord-study | Checking source file | 0.051 |
| 1 | hra-v1-2-female-cord-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-female-cord-study | Preparing view | 0.017 |
| 1 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-cord-study | Loading selection | 0.269 |
| 1 | hra-v1-2-female-cord-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-female-cord-study | Opening reference | 0.035 |
| 1 | hra-v1-2-female-vertebrae-study | Reference request | 0.014 |
| 1 | hra-v1-2-female-vertebrae-study | Checking source file | 0.051 |
| 1 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing view | 0.018 |
| 1 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-vertebrae-study | Loading selection | 0.478 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-female-vertebrae-study | Opening reference | 0.013 |
| 1 | hra-v1-2-male-cord-study | Reference request | 0.014 |
| 1 | hra-v1-2-male-cord-study | Checking source file | 0.017 |
| 1 | hra-v1-2-male-cord-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-male-cord-study | Preparing view | 0.018 |
| 1 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-cord-study | Loading selection | 0.025 |
| 1 | hra-v1-2-male-cord-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-male-cord-study | Opening reference | 0.013 |
| 1 | hra-v1-2-male-vertebrae-study | Reference request | 0.015 |
| 1 | hra-v1-2-male-vertebrae-study | Checking source file | 0.084 |
| 1 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing view | 0.018 |
| 1 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-vertebrae-study | Loading selection | 0.332 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-male-vertebrae-study | Opening reference | 0.004 |

## Memory and interpretation

Observed process peak working set: 1,790,124,032 bytes. Maximum sampled private memory: 1,938,907,136 bytes.
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

Raw profile SHA-256: `6b3ea044bdb83210e3e03792f48a4ea818f55b49a71d7801ad1978060959ccd6`. Full native evidence retains the archive identity, tool fingerprints and host observations.
