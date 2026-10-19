# Native Windows rendering observations

Recorded UTC: 2026-10-19T06:30:19.782645+00:00.

Source revision: `c86cfba1e544b20917b66c14ea405f0b74abfd47`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(328,224,510 bytes), SHA-256 `7518559369a6b55f20fbcf37363b47edb5013e666136b675469426e35b649ec4`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 60-second samples, 2-second stationary warmups, 3 repetitions at a 1920 × 1080 window.
Scene view: expanded; 3D rendering resolution: 100% of displayed pixels.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Exact current c86cfba private archive; expanded Native 1920x1080 sustained observation, sixteen workloads repeated three times. No other build or test workloads during sampling. Background applications, power source and thermal state uncontrolled; actual focus retained per sample. One Windows development host; no Mac or minimum-hardware qualification.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

Focused samples retained window focus throughout the entire sample. FPS ranges retain all samples.

| Reference | Scene | Focused samples | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 2/3 | 39.9–59.8 | 18.30–36.11 | 22.36–40.25 | 64.87 | 445 | 0 |
| female | chest orbit with faded lungs and local labels | 2/3 | 40.8–59.9 | 22.64–51.43 | 24.13–56.20 | 62.77 | 415 | 0 |
| female | isolated supplied-part orbit | 1/3 | 59.8–59.9 | 17.55–18.33 | 18.19–19.18 | 111.37 | 1 | 1 |
| male | whole-body orbit | 1/3 | 49.3–59.9 | 18.65–33.87 | 22.16–36.89 | 69.61 | 205 | 0 |
| male | chest orbit with faded lungs and local labels | 1/3 | 59.7–59.9 | 21.87–24.20 | 23.89–26.49 | 54.34 | 12 | 0 |
| male | isolated supplied-part orbit | 1/3 | 59.9–59.9 | 17.67–18.26 | 18.20–18.96 | 20.94 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 1/3 | 59.9–59.9 | 17.52–18.22 | 18.20–18.89 | 25.07 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 1/3 | 59.9–59.9 | 17.52–18.25 | 18.08–19.04 | 33.07 | 0 | 0 |
| hra-v1-2-female-cord-study | whole-body orbit | 1/3 | 59.9–59.9 | 17.43–18.29 | 17.73–19.12 | 20.36 | 0 | 0 |
| hra-v1-2-female-cord-study | isolated supplied-part orbit | 1/3 | 59.9–59.9 | 17.71–18.34 | 18.23–19.15 | 23.25 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | whole-body orbit | 1/3 | 59.9–59.9 | 17.65–18.52 | 18.22–19.25 | 21.40 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | isolated supplied-part orbit | 1/3 | 59.9–59.9 | 17.61–18.29 | 18.17–19.14 | 24.66 | 0 | 0 |
| hra-v1-2-male-cord-study | whole-body orbit | 1/3 | 59.9–59.9 | 17.68–18.28 | 18.21–19.02 | 20.99 | 0 | 0 |
| hra-v1-2-male-cord-study | isolated supplied-part orbit | 1/3 | 59.9–59.9 | 17.47–18.36 | 17.75–19.21 | 25.97 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | whole-body orbit | 1/3 | 59.9–59.9 | 17.53–18.33 | 18.00–19.30 | 20.22 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | isolated supplied-part orbit | 1/3 | 59.9–59.9 | 17.50–18.43 | 17.88–19.27 | 20.15 | 0 | 0 |

48 samples retain 169,448 rendered intervals over 2880.38 measured seconds.
Actual 3D viewport sizes: 1920 × 1080.
Window focus held throughout 18/48 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all 7 references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 3.351 | 3.263 | 275.31 | 4 | 906.93 |
| 1 | male | 3.967 | 3.877 | 183.87 | 6 | 34.64 |
| 1 | bodyparts-male-bones-study | 0.817 | 0.779 | 155.90 | 1 | 14.33 |
| 1 | hra-v1-2-female-cord-study | 0.413 | 0.391 | 85.39 | 0 | 6.29 |
| 1 | hra-v1-2-female-vertebrae-study | 0.571 | 0.555 | 93.53 | 0 | 8.35 |
| 1 | hra-v1-2-male-cord-study | 0.107 | 0.090 | 28.99 | 0 | 7.93 |
| 1 | hra-v1-2-male-vertebrae-study | 0.478 | 0.461 | 83.24 | 0 | 7.71 |
| 2 | female | 3.862 | 3.797 | 292.10 | 5 | 22.93 |
| 2 | male | 4.919 | 4.805 | 234.73 | 7 | 31.38 |
| 2 | bodyparts-male-bones-study | 0.758 | 0.724 | 126.17 | 1 | 12.33 |
| 2 | hra-v1-2-female-cord-study | 0.414 | 0.393 | 86.51 | 0 | 15.71 |
| 2 | hra-v1-2-female-vertebrae-study | 0.558 | 0.541 | 85.31 | 0 | 8.02 |
| 2 | hra-v1-2-male-cord-study | 0.105 | 0.087 | 25.93 | 0 | 5.84 |
| 2 | hra-v1-2-male-vertebrae-study | 0.461 | 0.444 | 84.45 | 0 | 6.08 |
| 3 | female | 4.565 | 4.469 | 397.01 | 6 | 82.04 |
| 3 | male | 4.396 | 4.288 | 209.04 | 6 | 51.73 |
| 3 | bodyparts-male-bones-study | 0.729 | 0.695 | 130.27 | 1 | 21.95 |
| 3 | hra-v1-2-female-cord-study | 0.359 | 0.341 | 75.57 | 0 | 9.01 |
| 3 | hra-v1-2-female-vertebrae-study | 0.507 | 0.490 | 78.95 | 0 | 6.84 |
| 3 | hra-v1-2-male-cord-study | 0.106 | 0.088 | 25.34 | 0 | 4.12 |
| 3 | hra-v1-2-male-vertebrae-study | 0.439 | 0.421 | 75.80 | 0 | 4.76 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.015 |
| 1 | female | Checking source file | 0.284 |
| 1 | female | Loading anatomy | 0.083 |
| 1 | female | Preparing view | 0.026 |
| 1 | female | Checking anatomy | 0.017 |
| 1 | female | Loading selection | 2.549 |
| 1 | female | Preparing selection | 0.298 |
| 1 | female | Opening reference | 0.080 |
| 1 | male | Reference request | 0.014 |
| 1 | male | Checking source file | 0.464 |
| 1 | male | Loading anatomy | 0.083 |
| 1 | male | Preparing view | 0.027 |
| 1 | male | Checking anatomy | 0.022 |
| 1 | male | Loading selection | 2.884 |
| 1 | male | Preparing selection | 0.292 |
| 1 | male | Opening reference | 0.181 |
| 1 | bodyparts-male-bones-study | Reference request | 0.013 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.080 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.020 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.019 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.003 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.476 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.052 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.155 |
| 1 | hra-v1-2-female-cord-study | Reference request | 0.014 |
| 1 | hra-v1-2-female-cord-study | Checking source file | 0.049 |
| 1 | hra-v1-2-female-cord-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-female-cord-study | Preparing view | 0.016 |
| 1 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-cord-study | Loading selection | 0.281 |
| 1 | hra-v1-2-female-cord-study | Preparing selection | 0.004 |
| 1 | hra-v1-2-female-cord-study | Opening reference | 0.031 |
| 1 | hra-v1-2-female-vertebrae-study | Reference request | 0.013 |
| 1 | hra-v1-2-female-vertebrae-study | Checking source file | 0.051 |
| 1 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.016 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing view | 0.017 |
| 1 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-vertebrae-study | Loading selection | 0.457 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-female-vertebrae-study | Opening reference | 0.014 |
| 1 | hra-v1-2-male-cord-study | Reference request | 0.014 |
| 1 | hra-v1-2-male-cord-study | Checking source file | 0.015 |
| 1 | hra-v1-2-male-cord-study | Loading anatomy | 0.018 |
| 1 | hra-v1-2-male-cord-study | Preparing view | 0.017 |
| 1 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-cord-study | Loading selection | 0.028 |
| 1 | hra-v1-2-male-cord-study | Preparing selection | 0.004 |
| 1 | hra-v1-2-male-cord-study | Opening reference | 0.011 |
| 1 | hra-v1-2-male-vertebrae-study | Reference request | 0.013 |
| 1 | hra-v1-2-male-vertebrae-study | Checking source file | 0.083 |
| 1 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.018 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing view | 0.017 |
| 1 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-vertebrae-study | Loading selection | 0.338 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.003 |
| 1 | hra-v1-2-male-vertebrae-study | Opening reference | 0.005 |
| 2 | female | Reference request | 0.013 |
| 2 | female | Checking source file | 0.433 |
| 2 | female | Loading anatomy | 0.083 |
| 2 | female | Preparing view | 0.026 |
| 2 | female | Checking anatomy | 0.023 |
| 2 | female | Loading selection | 2.913 |
| 2 | female | Preparing selection | 0.310 |
| 2 | female | Opening reference | 0.061 |
| 2 | male | Reference request | 0.013 |
| 2 | male | Checking source file | 0.599 |
| 2 | male | Loading anatomy | 0.116 |
| 2 | male | Preparing view | 0.033 |
| 2 | male | Checking anatomy | 0.030 |
| 2 | male | Loading selection | 3.609 |
| 2 | male | Preparing selection | 0.287 |
| 2 | male | Opening reference | 0.231 |
| 2 | bodyparts-male-bones-study | Reference request | 0.014 |
| 2 | bodyparts-male-bones-study | Checking source file | 0.066 |
| 2 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 2 | bodyparts-male-bones-study | Preparing view | 0.020 |
| 2 | bodyparts-male-bones-study | Checking anatomy | 0.002 |
| 2 | bodyparts-male-bones-study | Loading selection | 0.450 |
| 2 | bodyparts-male-bones-study | Preparing selection | 0.064 |
| 2 | bodyparts-male-bones-study | Opening reference | 0.126 |
| 2 | hra-v1-2-female-cord-study | Reference request | 0.014 |
| 2 | hra-v1-2-female-cord-study | Checking source file | 0.050 |
| 2 | hra-v1-2-female-cord-study | Loading anatomy | 0.019 |
| 2 | hra-v1-2-female-cord-study | Preparing view | 0.014 |
| 2 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-female-cord-study | Loading selection | 0.284 |
| 2 | hra-v1-2-female-cord-study | Preparing selection | 0.003 |
| 2 | hra-v1-2-female-cord-study | Opening reference | 0.028 |
| 2 | hra-v1-2-female-vertebrae-study | Reference request | 0.014 |
| 2 | hra-v1-2-female-vertebrae-study | Checking source file | 0.049 |
| 2 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.021 |
| 2 | hra-v1-2-female-vertebrae-study | Preparing view | 0.013 |
| 2 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-female-vertebrae-study | Loading selection | 0.445 |
| 2 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.003 |
| 2 | hra-v1-2-female-vertebrae-study | Opening reference | 0.012 |
| 2 | hra-v1-2-male-cord-study | Reference request | 0.015 |
| 2 | hra-v1-2-male-cord-study | Checking source file | 0.016 |
| 2 | hra-v1-2-male-cord-study | Loading anatomy | 0.017 |
| 2 | hra-v1-2-male-cord-study | Preparing view | 0.016 |
| 2 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-male-cord-study | Loading selection | 0.025 |
| 2 | hra-v1-2-male-cord-study | Preparing selection | 0.003 |
| 2 | hra-v1-2-male-cord-study | Opening reference | 0.012 |
| 2 | hra-v1-2-male-vertebrae-study | Reference request | 0.014 |
| 2 | hra-v1-2-male-vertebrae-study | Checking source file | 0.067 |
| 2 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.017 |
| 2 | hra-v1-2-male-vertebrae-study | Preparing view | 0.017 |
| 2 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-male-vertebrae-study | Loading selection | 0.338 |
| 2 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.003 |
| 2 | hra-v1-2-male-vertebrae-study | Opening reference | 0.005 |
| 3 | female | Reference request | 0.014 |
| 3 | female | Checking source file | 0.417 |
| 3 | female | Loading anatomy | 0.080 |
| 3 | female | Preparing view | 0.016 |
| 3 | female | Checking anatomy | 0.024 |
| 3 | female | Loading selection | 3.602 |
| 3 | female | Preparing selection | 0.319 |
| 3 | female | Opening reference | 0.094 |
| 3 | male | Reference request | 0.014 |
| 3 | male | Checking source file | 0.401 |
| 3 | male | Loading anatomy | 0.076 |
| 3 | male | Preparing view | 0.016 |
| 3 | male | Checking anatomy | 0.020 |
| 3 | male | Loading selection | 3.359 |
| 3 | male | Preparing selection | 0.304 |
| 3 | male | Opening reference | 0.207 |
| 3 | bodyparts-male-bones-study | Reference request | 0.014 |
| 3 | bodyparts-male-bones-study | Checking source file | 0.067 |
| 3 | bodyparts-male-bones-study | Loading anatomy | 0.033 |
| 3 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 3 | bodyparts-male-bones-study | Checking anatomy | 0.002 |
| 3 | bodyparts-male-bones-study | Loading selection | 0.399 |
| 3 | bodyparts-male-bones-study | Preparing selection | 0.067 |
| 3 | bodyparts-male-bones-study | Opening reference | 0.129 |
| 3 | hra-v1-2-female-cord-study | Reference request | 0.013 |
| 3 | hra-v1-2-female-cord-study | Checking source file | 0.050 |
| 3 | hra-v1-2-female-cord-study | Loading anatomy | 0.019 |
| 3 | hra-v1-2-female-cord-study | Preparing view | 0.015 |
| 3 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 3 | hra-v1-2-female-cord-study | Loading selection | 0.233 |
| 3 | hra-v1-2-female-cord-study | Preparing selection | 0.003 |
| 3 | hra-v1-2-female-cord-study | Opening reference | 0.025 |
| 3 | hra-v1-2-female-vertebrae-study | Reference request | 0.014 |
| 3 | hra-v1-2-female-vertebrae-study | Checking source file | 0.050 |
| 3 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.017 |
| 3 | hra-v1-2-female-vertebrae-study | Preparing view | 0.017 |
| 3 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.001 |
| 3 | hra-v1-2-female-vertebrae-study | Loading selection | 0.393 |
| 3 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.002 |
| 3 | hra-v1-2-female-vertebrae-study | Opening reference | 0.012 |
| 3 | hra-v1-2-male-cord-study | Reference request | 0.014 |
| 3 | hra-v1-2-male-cord-study | Checking source file | 0.019 |
| 3 | hra-v1-2-male-cord-study | Loading anatomy | 0.014 |
| 3 | hra-v1-2-male-cord-study | Preparing view | 0.017 |
| 3 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 3 | hra-v1-2-male-cord-study | Loading selection | 0.024 |
| 3 | hra-v1-2-male-cord-study | Preparing selection | 0.003 |
| 3 | hra-v1-2-male-cord-study | Opening reference | 0.014 |
| 3 | hra-v1-2-male-vertebrae-study | Reference request | 0.015 |
| 3 | hra-v1-2-male-vertebrae-study | Checking source file | 0.082 |
| 3 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.017 |
| 3 | hra-v1-2-male-vertebrae-study | Preparing view | 0.017 |
| 3 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 3 | hra-v1-2-male-vertebrae-study | Loading selection | 0.300 |
| 3 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.003 |
| 3 | hra-v1-2-male-vertebrae-study | Opening reference | 0.005 |

## Memory and interpretation

Observed process peak working set: 1,755,348,992 bytes. Maximum sampled private memory: 1,967,280,128 bytes.
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

Raw profile SHA-256: `090827aedb2396adf0a0229d6b26271a0a8a6bbdb57b1705bf9a4f931e564238`. Full native evidence retains the archive identity, tool fingerprints and host observations.
