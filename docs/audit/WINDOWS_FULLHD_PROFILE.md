# Native Windows rendering observations

Recorded UTC: 2026-10-13T17:44:09.170955+00:00.

Source revision: `ae600197fd48730fa50d497b5243fc0acc7e419b`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(290,838,547 bytes), SHA-256 `ac1f3326b5a5e2be9a505074275b376131dbc5b522b03a1b0c84084256ee0c5e`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 60-second samples, 2-second stationary warmups, 3 repetitions at a 1920 × 1080 window.
Scene view: expanded; 3D rendering resolution: 100% of displayed pixels.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: First sustained full-client-window Native 1920x1080 diagnostic on the development Windows host. No other build/test workloads during sampling; background applications, power source and thermal state uncontrolled. Actual focus is recorded per sample.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

| Reference | Scene | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 59.9–59.9 | 17.45–17.47 | 17.70–17.84 | 25.22 | 0 | 0 |
| female | chest orbit with faded lungs and local labels | 59.5–59.9 | 17.55–17.61 | 17.97–23.59 | 50.80 | 17 | 0 |
| female | isolated supplied-part orbit | 59.9–59.9 | 17.51–17.59 | 17.95–18.09 | 18.89 | 0 | 0 |
| male | whole-body orbit | 59.9–59.9 | 17.41–17.43 | 17.69–17.79 | 23.97 | 0 | 0 |
| male | chest orbit with faded lungs and local labels | 59.8–59.9 | 17.68–17.72 | 18.30–18.91 | 43.32 | 5 | 0 |
| male | isolated supplied-part orbit | 59.9–59.9 | 17.51–17.56 | 17.93–18.08 | 19.55 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 59.9–59.9 | 17.52–17.53 | 17.95–18.10 | 22.95 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 59.9–59.9 | 17.51–17.52 | 17.93–17.96 | 19.11 | 0 | 0 |

24 samples retain 86,226 rendered intervals over 1440.19 measured seconds.
Actual 3D viewport sizes: 1920 × 1080.
Window focus held throughout 24/24 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all three references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 2.886 | 2.827 | 256.81 | 2 | 605.43 |
| 1 | male | 2.914 | 2.862 | 111.77 | 1 | 36.61 |
| 1 | bodyparts-male-bones-study | 0.531 | 0.503 | 83.04 | 0 | 10.60 |
| 2 | female | 2.887 | 2.839 | 231.16 | 2 | 20.29 |
| 2 | male | 2.928 | 2.878 | 109.26 | 2 | 19.03 |
| 2 | bodyparts-male-bones-study | 0.549 | 0.523 | 84.19 | 0 | 9.68 |
| 3 | female | 2.857 | 2.806 | 236.68 | 2 | 26.20 |
| 3 | male | 2.915 | 2.862 | 112.47 | 1 | 17.73 |
| 3 | bodyparts-male-bones-study | 0.534 | 0.508 | 85.86 | 0 | 10.07 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.023 |
| 1 | female | Checking source file | 0.268 |
| 1 | female | Loading anatomy | 0.053 |
| 1 | female | Preparing view | 0.014 |
| 1 | female | Checking anatomy | 0.014 |
| 1 | female | Loading selection | 2.161 |
| 1 | female | Preparing selection | 0.312 |
| 1 | female | Opening reference | 0.041 |
| 1 | male | Reference request | 0.014 |
| 1 | male | Checking source file | 0.251 |
| 1 | male | Loading anatomy | 0.074 |
| 1 | male | Preparing view | 0.014 |
| 1 | male | Checking anatomy | 0.013 |
| 1 | male | Loading selection | 2.140 |
| 1 | male | Preparing selection | 0.297 |
| 1 | male | Opening reference | 0.109 |
| 1 | bodyparts-male-bones-study | Reference request | 0.015 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.049 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.283 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.064 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.083 |
| 2 | female | Reference request | 0.015 |
| 2 | female | Checking source file | 0.250 |
| 2 | female | Loading anatomy | 0.051 |
| 2 | female | Preparing view | 0.022 |
| 2 | female | Checking anatomy | 0.014 |
| 2 | female | Loading selection | 2.172 |
| 2 | female | Preparing selection | 0.313 |
| 2 | female | Opening reference | 0.051 |
| 2 | male | Reference request | 0.014 |
| 2 | male | Checking source file | 0.250 |
| 2 | male | Loading anatomy | 0.046 |
| 2 | male | Preparing view | 0.011 |
| 2 | male | Checking anatomy | 0.013 |
| 2 | male | Loading selection | 2.179 |
| 2 | male | Preparing selection | 0.309 |
| 2 | male | Opening reference | 0.107 |
| 2 | bodyparts-male-bones-study | Reference request | 0.014 |
| 2 | bodyparts-male-bones-study | Checking source file | 0.050 |
| 2 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 2 | bodyparts-male-bones-study | Preparing view | 0.019 |
| 2 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 2 | bodyparts-male-bones-study | Loading selection | 0.292 |
| 2 | bodyparts-male-bones-study | Preparing selection | 0.073 |
| 2 | bodyparts-male-bones-study | Opening reference | 0.084 |
| 3 | female | Reference request | 0.015 |
| 3 | female | Checking source file | 0.233 |
| 3 | female | Loading anatomy | 0.053 |
| 3 | female | Preparing view | 0.020 |
| 3 | female | Checking anatomy | 0.014 |
| 3 | female | Loading selection | 2.153 |
| 3 | female | Preparing selection | 0.316 |
| 3 | female | Opening reference | 0.053 |
| 3 | male | Reference request | 0.015 |
| 3 | male | Checking source file | 0.250 |
| 3 | male | Loading anatomy | 0.050 |
| 3 | male | Preparing view | 0.022 |
| 3 | male | Checking anatomy | 0.013 |
| 3 | male | Loading selection | 2.152 |
| 3 | male | Preparing selection | 0.302 |
| 3 | male | Opening reference | 0.110 |
| 3 | bodyparts-male-bones-study | Reference request | 0.014 |
| 3 | bodyparts-male-bones-study | Checking source file | 0.050 |
| 3 | bodyparts-male-bones-study | Loading anatomy | 0.016 |
| 3 | bodyparts-male-bones-study | Preparing view | 0.019 |
| 3 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 3 | bodyparts-male-bones-study | Loading selection | 0.282 |
| 3 | bodyparts-male-bones-study | Preparing selection | 0.066 |
| 3 | bodyparts-male-bones-study | Opening reference | 0.085 |

## Memory and interpretation

Observed process peak working set: 1,757,601,792 bytes. Maximum sampled private memory: 1,951,006,720 bytes.
The host samples every 500 ms over the entire process; brief spikes may be missed. These values do not measure GPU or per-scene memory.

Recorded active power scheme: Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced). This does not establish AC/battery or thermal state.

Workspace views include controls and panels; expanded native views cover the requested window pixels. These are frame-callback cadence and process-gap observations, not GPU execution or display latency.
The eight-scene suite uses label density 8; additional densities, moved-organ overlays and saved-view transitions remain outside this run. One Windows host leaves representative hardware, Mac, human-input, accessibility and qualified medical review gates open.

Source geometry fingerprints:

- female: `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5`.
- male: `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863`.
- bodyparts-male-bones-study: `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27`.

Raw profile SHA-256: `6ae0250657c74f262ea23130c19e75522507336811c12af2b7a1081df4e3cb72`. Full native evidence retains the archive identity, tool fingerprints and host observations.
