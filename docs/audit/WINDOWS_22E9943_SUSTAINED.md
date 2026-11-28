# Native Windows rendering observations

Recorded UTC: 2026-11-28T01:14:50.535813+00:00.

Source revision: `22e99438096548e94a21e44cc91b738c3f6db008`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(661,248,869 bytes), SHA-256 `f39ab87b5dae1e7938c37772b2d60644b1a062b4230e1ae88cdb39d0a2dde621`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 60-second samples, 2-second stationary warmups, 3 repetitions at a 1920 × 1080 window.
Scene view: expanded; 3D rendering resolution: 100% of displayed pixels.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Mains power (Windows reported the battery on AC). Started unattended from Claude Code; the user was told the run is more reliable if the PC is left alone, but foreground use and background work were not observed.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

Focused samples retained window focus throughout the entire sample. FPS ranges retain all samples.

| Reference | Scene | Focused samples | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 3/3 | 59.9–59.9 | 17.11–17.13 | 17.28–17.32 | 20.24 | 0 | 0 |
| female | chest orbit with faded lungs and local labels | 3/3 | 59.6–59.7 | 22.95–23.01 | 25.37–25.56 | 29.17 | 0 | 0 |
| female | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 17.93–18.15 | 18.53–18.67 | 19.96 | 0 | 0 |
| male | whole-body orbit | 3/3 | 59.9–59.9 | 17.22–17.25 | 17.51–17.56 | 18.00 | 0 | 0 |
| male | chest orbit with faded lungs and local labels | 3/3 | 59.9–59.9 | 21.19–21.29 | 22.52–22.64 | 25.15 | 0 | 0 |
| male | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 18.02–18.18 | 18.56–18.72 | 19.80 | 0 | 0 |
| bodyparts-male-complete | whole-body orbit | 3/3 | 52.9–54.0 | 19.39–21.08 | 20.07–25.31 | 29.37 | 0 | 0 |
| bodyparts-male-complete | chest orbit with faded lungs and local labels | 3/3 | 41.3–41.6 | 36.55–37.28 | 40.18–40.30 | 55.65 | 680 | 0 |
| bodyparts-male-complete | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 17.81–18.04 | 18.45–18.61 | 19.97 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 3/3 | 59.9–59.9 | 17.87–17.96 | 18.42–18.50 | 19.78 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 17.92–18.19 | 18.55–18.66 | 19.84 | 0 | 0 |
| hra-v1-2-female-cord-study | whole-body orbit | 3/3 | 59.9–59.9 | 18.08–18.22 | 18.71–18.83 | 20.24 | 0 | 0 |
| hra-v1-2-female-cord-study | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 18.19–18.20 | 18.76–18.82 | 19.81 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | whole-body orbit | 3/3 | 59.9–59.9 | 18.11–18.19 | 18.71–18.81 | 20.14 | 0 | 0 |
| hra-v1-2-female-vertebrae-study | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 18.14–18.28 | 18.70–18.86 | 20.53 | 0 | 0 |
| hra-v1-2-male-cord-study | whole-body orbit | 3/3 | 59.9–59.9 | 18.06–18.20 | 18.63–18.79 | 20.02 | 0 | 0 |
| hra-v1-2-male-cord-study | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 18.14–18.19 | 18.69–18.75 | 19.99 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | whole-body orbit | 3/3 | 59.9–59.9 | 17.99–18.15 | 18.70–18.76 | 22.30 | 0 | 0 |
| hra-v1-2-male-vertebrae-study | isolated supplied-part orbit | 3/3 | 59.9–59.9 | 18.18–18.19 | 18.74–18.80 | 20.11 | 0 | 0 |

57 samples retain 200,407 rendered intervals over 3420.48 measured seconds.
Actual 3D viewport sizes: 1920 × 1080.
Window focus held throughout 57/57 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all 8 references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 4.563 | 4.485 | 303.75 | 5 | 659.79 |
| 1 | male | 3.578 | 3.476 | 227.02 | 1 | 81.72 |
| 1 | bodyparts-male-complete | 5.822 | 5.657 | 333.70 | 3 | 54.59 |
| 1 | bodyparts-male-bones-study | 0.671 | 0.623 | 222.12 | 1 | 14.28 |
| 1 | hra-v1-2-female-cord-study | 0.283 | 0.262 | 57.51 | 0 | 10.18 |
| 1 | hra-v1-2-female-vertebrae-study | 0.375 | 0.357 | 59.53 | 0 | 9.99 |
| 1 | hra-v1-2-male-cord-study | 0.107 | 0.087 | 24.96 | 0 | 9.47 |
| 1 | hra-v1-2-male-vertebrae-study | 0.314 | 0.296 | 53.99 | 0 | 10.12 |
| 2 | female | 4.542 | 4.470 | 310.13 | 4 | 40.09 |
| 2 | male | 3.702 | 3.599 | 233.28 | 1 | 38.19 |
| 2 | bodyparts-male-complete | 5.887 | 5.714 | 365.00 | 3 | 56.43 |
| 2 | bodyparts-male-bones-study | 0.660 | 0.613 | 214.03 | 1 | 16.34 |
| 2 | hra-v1-2-female-cord-study | 0.283 | 0.262 | 56.62 | 0 | 10.07 |
| 2 | hra-v1-2-female-vertebrae-study | 0.365 | 0.349 | 58.68 | 0 | 10.60 |
| 2 | hra-v1-2-male-cord-study | 0.109 | 0.089 | 23.57 | 0 | 8.31 |
| 2 | hra-v1-2-male-vertebrae-study | 0.315 | 0.298 | 54.13 | 0 | 11.96 |
| 3 | female | 4.504 | 4.434 | 304.09 | 4 | 33.29 |
| 3 | male | 3.590 | 3.489 | 221.28 | 1 | 43.42 |
| 3 | bodyparts-male-complete | 5.788 | 5.623 | 334.48 | 3 | 51.24 |
| 3 | bodyparts-male-bones-study | 0.650 | 0.605 | 203.56 | 1 | 16.59 |
| 3 | hra-v1-2-female-cord-study | 0.289 | 0.267 | 56.81 | 0 | 11.40 |
| 3 | hra-v1-2-female-vertebrae-study | 0.372 | 0.352 | 58.68 | 0 | 11.62 |
| 3 | hra-v1-2-male-cord-study | 0.107 | 0.090 | 22.91 | 0 | 8.87 |
| 3 | hra-v1-2-male-vertebrae-study | 0.315 | 0.296 | 56.40 | 0 | 9.88 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.019 |
| 1 | female | Checking source file | 0.417 |
| 1 | female | Loading anatomy | 0.082 |
| 1 | female | Preparing view | 0.028 |
| 1 | female | Checking anatomy | 0.018 |
| 1 | female | Loading selection | 3.507 |
| 1 | female | Preparing selection | 0.393 |
| 1 | female | Opening reference | 0.099 |
| 1 | male | Reference request | 0.014 |
| 1 | male | Checking source file | 0.318 |
| 1 | male | Loading anatomy | 0.059 |
| 1 | male | Preparing view | 0.014 |
| 1 | male | Checking anatomy | 0.016 |
| 1 | male | Loading selection | 2.549 |
| 1 | male | Preparing selection | 0.382 |
| 1 | male | Opening reference | 0.227 |
| 1 | bodyparts-male-complete | Reference request | 0.014 |
| 1 | bodyparts-male-complete | Checking source file | 0.552 |
| 1 | bodyparts-male-complete | Loading anatomy | 0.116 |
| 1 | bodyparts-male-complete | Preparing view | 0.032 |
| 1 | bodyparts-male-complete | Checking anatomy | 0.100 |
| 1 | bodyparts-male-complete | Loading selection | 3.776 |
| 1 | bodyparts-male-complete | Preparing selection | 0.901 |
| 1 | bodyparts-male-complete | Opening reference | 0.331 |
| 1 | bodyparts-male-bones-study | Reference request | 0.014 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.049 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.018 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 1 | bodyparts-male-bones-study | Loading selection | 0.275 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.073 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.222 |
| 1 | hra-v1-2-female-cord-study | Reference request | 0.014 |
| 1 | hra-v1-2-female-cord-study | Checking source file | 0.034 |
| 1 | hra-v1-2-female-cord-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-female-cord-study | Preparing view | 0.016 |
| 1 | hra-v1-2-female-cord-study | Checking anatomy | 0.000 |
| 1 | hra-v1-2-female-cord-study | Loading selection | 0.170 |
| 1 | hra-v1-2-female-cord-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-female-cord-study | Opening reference | 0.030 |
| 1 | hra-v1-2-female-vertebrae-study | Reference request | 0.014 |
| 1 | hra-v1-2-female-vertebrae-study | Checking source file | 0.034 |
| 1 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing view | 0.016 |
| 1 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-female-vertebrae-study | Loading selection | 0.279 |
| 1 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-female-vertebrae-study | Opening reference | 0.012 |
| 1 | hra-v1-2-male-cord-study | Reference request | 0.016 |
| 1 | hra-v1-2-male-cord-study | Checking source file | 0.016 |
| 1 | hra-v1-2-male-cord-study | Loading anatomy | 0.018 |
| 1 | hra-v1-2-male-cord-study | Preparing view | 0.015 |
| 1 | hra-v1-2-male-cord-study | Checking anatomy | 0.000 |
| 1 | hra-v1-2-male-cord-study | Loading selection | 0.024 |
| 1 | hra-v1-2-male-cord-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-male-cord-study | Opening reference | 0.016 |
| 1 | hra-v1-2-male-vertebrae-study | Reference request | 0.015 |
| 1 | hra-v1-2-male-vertebrae-study | Checking source file | 0.050 |
| 1 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.017 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing view | 0.016 |
| 1 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 1 | hra-v1-2-male-vertebrae-study | Loading selection | 0.207 |
| 1 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.002 |
| 1 | hra-v1-2-male-vertebrae-study | Opening reference | 0.006 |
| 2 | female | Reference request | 0.014 |
| 2 | female | Checking source file | 0.434 |
| 2 | female | Loading anatomy | 0.084 |
| 2 | female | Preparing view | 0.025 |
| 2 | female | Checking anatomy | 0.018 |
| 2 | female | Loading selection | 3.480 |
| 2 | female | Preparing selection | 0.388 |
| 2 | female | Opening reference | 0.101 |
| 2 | male | Reference request | 0.014 |
| 2 | male | Checking source file | 0.317 |
| 2 | male | Loading anatomy | 0.067 |
| 2 | male | Preparing view | 0.023 |
| 2 | male | Checking anatomy | 0.016 |
| 2 | male | Loading selection | 2.640 |
| 2 | male | Preparing selection | 0.391 |
| 2 | male | Opening reference | 0.233 |
| 2 | bodyparts-male-complete | Reference request | 0.013 |
| 2 | bodyparts-male-complete | Checking source file | 0.567 |
| 2 | bodyparts-male-complete | Loading anatomy | 0.117 |
| 2 | bodyparts-male-complete | Preparing view | 0.031 |
| 2 | bodyparts-male-complete | Checking anatomy | 0.100 |
| 2 | bodyparts-male-complete | Loading selection | 3.791 |
| 2 | bodyparts-male-complete | Preparing selection | 0.905 |
| 2 | bodyparts-male-complete | Opening reference | 0.362 |
| 2 | bodyparts-male-bones-study | Reference request | 0.012 |
| 2 | bodyparts-male-bones-study | Checking source file | 0.050 |
| 2 | bodyparts-male-bones-study | Loading anatomy | 0.018 |
| 2 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 2 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 2 | bodyparts-male-bones-study | Loading selection | 0.285 |
| 2 | bodyparts-male-bones-study | Preparing selection | 0.062 |
| 2 | bodyparts-male-bones-study | Opening reference | 0.214 |
| 2 | hra-v1-2-female-cord-study | Reference request | 0.014 |
| 2 | hra-v1-2-female-cord-study | Checking source file | 0.033 |
| 2 | hra-v1-2-female-cord-study | Loading anatomy | 0.017 |
| 2 | hra-v1-2-female-cord-study | Preparing view | 0.017 |
| 2 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-female-cord-study | Loading selection | 0.168 |
| 2 | hra-v1-2-female-cord-study | Preparing selection | 0.002 |
| 2 | hra-v1-2-female-cord-study | Opening reference | 0.031 |
| 2 | hra-v1-2-female-vertebrae-study | Reference request | 0.013 |
| 2 | hra-v1-2-female-vertebrae-study | Checking source file | 0.032 |
| 2 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.017 |
| 2 | hra-v1-2-female-vertebrae-study | Preparing view | 0.017 |
| 2 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.000 |
| 2 | hra-v1-2-female-vertebrae-study | Loading selection | 0.276 |
| 2 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.002 |
| 2 | hra-v1-2-female-vertebrae-study | Opening reference | 0.007 |
| 2 | hra-v1-2-male-cord-study | Reference request | 0.015 |
| 2 | hra-v1-2-male-cord-study | Checking source file | 0.017 |
| 2 | hra-v1-2-male-cord-study | Loading anatomy | 0.017 |
| 2 | hra-v1-2-male-cord-study | Preparing view | 0.016 |
| 2 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-male-cord-study | Loading selection | 0.023 |
| 2 | hra-v1-2-male-cord-study | Preparing selection | 0.002 |
| 2 | hra-v1-2-male-cord-study | Opening reference | 0.020 |
| 2 | hra-v1-2-male-vertebrae-study | Reference request | 0.014 |
| 2 | hra-v1-2-male-vertebrae-study | Checking source file | 0.050 |
| 2 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.017 |
| 2 | hra-v1-2-male-vertebrae-study | Preparing view | 0.017 |
| 2 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.001 |
| 2 | hra-v1-2-male-vertebrae-study | Loading selection | 0.209 |
| 2 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.002 |
| 2 | hra-v1-2-male-vertebrae-study | Opening reference | 0.006 |
| 3 | female | Reference request | 0.013 |
| 3 | female | Checking source file | 0.434 |
| 3 | female | Loading anatomy | 0.083 |
| 3 | female | Preparing view | 0.025 |
| 3 | female | Checking anatomy | 0.018 |
| 3 | female | Loading selection | 3.445 |
| 3 | female | Preparing selection | 0.387 |
| 3 | female | Opening reference | 0.099 |
| 3 | male | Reference request | 0.012 |
| 3 | male | Checking source file | 0.317 |
| 3 | male | Loading anatomy | 0.067 |
| 3 | male | Preparing view | 0.027 |
| 3 | male | Checking anatomy | 0.017 |
| 3 | male | Loading selection | 2.544 |
| 3 | male | Preparing selection | 0.385 |
| 3 | male | Opening reference | 0.221 |
| 3 | bodyparts-male-complete | Reference request | 0.014 |
| 3 | bodyparts-male-complete | Checking source file | 0.550 |
| 3 | bodyparts-male-complete | Loading anatomy | 0.117 |
| 3 | bodyparts-male-complete | Preparing view | 0.034 |
| 3 | bodyparts-male-complete | Checking anatomy | 0.100 |
| 3 | bodyparts-male-complete | Loading selection | 3.735 |
| 3 | bodyparts-male-complete | Preparing selection | 0.906 |
| 3 | bodyparts-male-complete | Opening reference | 0.332 |
| 3 | bodyparts-male-bones-study | Reference request | 0.013 |
| 3 | bodyparts-male-bones-study | Checking source file | 0.051 |
| 3 | bodyparts-male-bones-study | Loading anatomy | 0.017 |
| 3 | bodyparts-male-bones-study | Preparing view | 0.018 |
| 3 | bodyparts-male-bones-study | Checking anatomy | 0.001 |
| 3 | bodyparts-male-bones-study | Loading selection | 0.286 |
| 3 | bodyparts-male-bones-study | Preparing selection | 0.061 |
| 3 | bodyparts-male-bones-study | Opening reference | 0.203 |
| 3 | hra-v1-2-female-cord-study | Reference request | 0.015 |
| 3 | hra-v1-2-female-cord-study | Checking source file | 0.034 |
| 3 | hra-v1-2-female-cord-study | Loading anatomy | 0.016 |
| 3 | hra-v1-2-female-cord-study | Preparing view | 0.018 |
| 3 | hra-v1-2-female-cord-study | Checking anatomy | 0.001 |
| 3 | hra-v1-2-female-cord-study | Loading selection | 0.170 |
| 3 | hra-v1-2-female-cord-study | Preparing selection | 0.002 |
| 3 | hra-v1-2-female-cord-study | Opening reference | 0.034 |
| 3 | hra-v1-2-female-vertebrae-study | Reference request | 0.017 |
| 3 | hra-v1-2-female-vertebrae-study | Checking source file | 0.033 |
| 3 | hra-v1-2-female-vertebrae-study | Loading anatomy | 0.016 |
| 3 | hra-v1-2-female-vertebrae-study | Preparing view | 0.017 |
| 3 | hra-v1-2-female-vertebrae-study | Checking anatomy | 0.000 |
| 3 | hra-v1-2-female-vertebrae-study | Loading selection | 0.280 |
| 3 | hra-v1-2-female-vertebrae-study | Preparing selection | 0.002 |
| 3 | hra-v1-2-female-vertebrae-study | Opening reference | 0.008 |
| 3 | hra-v1-2-male-cord-study | Reference request | 0.013 |
| 3 | hra-v1-2-male-cord-study | Checking source file | 0.018 |
| 3 | hra-v1-2-male-cord-study | Loading anatomy | 0.016 |
| 3 | hra-v1-2-male-cord-study | Preparing view | 0.017 |
| 3 | hra-v1-2-male-cord-study | Checking anatomy | 0.001 |
| 3 | hra-v1-2-male-cord-study | Loading selection | 0.022 |
| 3 | hra-v1-2-male-cord-study | Preparing selection | 0.002 |
| 3 | hra-v1-2-male-cord-study | Opening reference | 0.019 |
| 3 | hra-v1-2-male-vertebrae-study | Reference request | 0.015 |
| 3 | hra-v1-2-male-vertebrae-study | Checking source file | 0.049 |
| 3 | hra-v1-2-male-vertebrae-study | Loading anatomy | 0.018 |
| 3 | hra-v1-2-male-vertebrae-study | Preparing view | 0.016 |
| 3 | hra-v1-2-male-vertebrae-study | Checking anatomy | 0.000 |
| 3 | hra-v1-2-male-vertebrae-study | Loading selection | 0.210 |
| 3 | hra-v1-2-male-vertebrae-study | Preparing selection | 0.002 |
| 3 | hra-v1-2-male-vertebrae-study | Opening reference | 0.006 |

## Memory and interpretation

Observed process peak working set: 2,646,269,952 bytes. Maximum sampled private memory: 2,868,129,792 bytes.
The host samples every 500 ms over the entire process; brief spikes may be missed. These values do not measure GPU or per-scene memory.

Recorded active power scheme: Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced). This does not establish AC/battery or thermal state.

Workspace views include controls and panels; expanded native views cover the requested window pixels. These are frame-callback cadence and process-gap observations, not GPU execution or display latency.
The measurement plan contains 19 distinct reference/workload pairs. Recorded label densities: 8.
These results cover only the listed workloads and settings. One Windows host leaves representative hardware, Mac, human-input, accessibility and qualified medical review gates open.

Source geometry fingerprints:

- female: `07f4d50b29add03126c7ba98253454f55818fb0545640ce86c1b16f95c740553`.
- male: `69c13b7c5cec3574007a2367470c2138baa23d2680d7edf01ce542170e19af56`.
- bodyparts-male-complete: `9e3b751a4f34cc018cc01c127a7e6187d29bf29c5b9ef9b222eb22353c6eac9c`.
- bodyparts-male-bones-study: `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27`.
- hra-v1-2-female-cord-study: `d9bfc840783a415068e34b8a1a9343fff40ad03d0025fafabf74f9d8664887f8`.
- hra-v1-2-female-vertebrae-study: `bdbea49a40e9e64cac1c8f0d67b6483686a3cc9617f7cae645e58159e4b02984`.
- hra-v1-2-male-cord-study: `a7858d88c2237aa7d559c4c1d638923d213d2a9f46c575dea03d6ba67a9975c0`.
- hra-v1-2-male-vertebrae-study: `981041904438bd74c14d671af8f87b3f407b675294bbf297af673c8df7144451`.

Raw profile SHA-256: `fc7dd5ad2e2ebeadd9028a5f96a1d3233c18a600f827c54ef1e3c4017ca569c7`. Full native evidence retains the archive identity, tool fingerprints and host observations.
