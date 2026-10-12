# Native Windows rendering observations

Recorded UTC: 2026-10-12T21:54:36.172544+00:00.

Source revision: `640cf573287e5436a0e55aa763807a8160fcdd49`. Archive: `PraxisCorporis-Windows-x64-private.zip`
(292,927,027 bytes), SHA-256 `5af7ded753be9c2f5e1c825621f6522825eca9356f97d336c5354a190b396632`.

Engine: 4.7.2.stable.official.ed1daf0bf. OS: Microsoft Windows 11 Home, 10.0.26300 (build 26300).
CPU: AMD Ryzen 5 PRO 6650U with Radeon Graphics. Reported physical RAM: 15,859,003,392 bytes.
Actual rendering adapter: AMD Radeon(TM) Graphics; gl_compatibility, graphics API/driver 3.3.0 Core Profile Context 25.10.37.03.260407.

Configuration: 60-second samples, 2-second stationary warmups, 3 repetitions at a 1920 × 1080 window.
Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.
Operator context: Fixed own application window; background workload, power source and thermal state uncontrolled; focus sampled without forcing foreground; no host settings changed.

## Navigation cadence

Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. The maximum interval and >100 ms counts retain outliers.

| Reference | Scene | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |
|---|---|---:|---:|---:|---:|---:|---:|
| female | whole-body orbit | 48.5–59.9 | 17.34–26.98 | 17.70–29.19 | 35.88 | 6 | 0 |
| female | chest orbit with faded lungs and local labels | 56.3–59.6 | 17.55–26.16 | 21.72–38.27 | 52.06 | 111 | 0 |
| female | isolated supplied-part orbit | 59.9–59.9 | 17.39–17.48 | 17.74–17.92 | 31.24 | 0 | 0 |
| male | whole-body orbit | 49.7–59.5 | 17.51–26.74 | 21.14–28.31 | 48.28 | 8 | 0 |
| male | chest orbit with faded lungs and local labels | 51.8–58.3 | 20.89–37.69 | 33.35–40.80 | 46.28 | 364 | 0 |
| male | isolated supplied-part orbit | 59.9–59.9 | 17.41–17.51 | 17.75–18.05 | 32.20 | 0 | 0 |
| bodyparts-male-bones-study | whole-body orbit | 59.9–59.9 | 17.66–18.28 | 19.46–20.03 | 26.57 | 0 | 0 |
| bodyparts-male-bones-study | isolated supplied-part orbit | 59.9–59.9 | 17.37–17.51 | 17.66–17.99 | 20.86 | 0 | 0 |

24 samples retain 83,190 rendered intervals over 1440.20 measured seconds.
Actual 3D viewport sizes: 832 × 611, 832 × 657.
Window focus held throughout 1/24 samples.
Recorded VSync modes: [1]; 3D MSAA modes: [1]; engine max FPS: 0.

## Loading and process gaps

Each repetition visits all three references. Revisit loads can reuse resources and OS caches. Raw process intervals include partial start/end boundaries and sum to switch wall time.

| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |
|---:|---|---:|---:|---:|---:|---:|
| 1 | female | 2.764 | 2.709 | 2012.29 | 1 | 607.28 |
| 1 | male | 2.827 | 2.772 | 2086.62 | 2 | 30.12 |
| 1 | bodyparts-male-bones-study | 0.538 | 0.506 | 277.49 | 2 | 31.72 |
| 2 | female | 2.884 | 2.825 | 2156.27 | 1 | 79.67 |
| 2 | male | 2.893 | 2.831 | 2107.66 | 2 | 43.52 |
| 2 | bodyparts-male-bones-study | 0.549 | 0.518 | 280.58 | 2 | 22.48 |
| 3 | female | 2.730 | 2.677 | 2037.35 | 1 | 30.54 |
| 3 | male | 2.997 | 2.939 | 2221.59 | 2 | 23.86 |
| 3 | bodyparts-male-bones-study | 0.597 | 0.566 | 313.65 | 2 | 30.28 |

Stage durations are adjacent transition differences, including scheduling and intervening work. They do not isolate CPU execution cost or independently establish the first visible frame.

| Repeat | Reference | Stage | Seconds to next transition |
|---:|---|---|---:|
| 1 | female | Reference request | 0.019 |
| 1 | female | Checking source file | 0.266 |
| 1 | female | Loading anatomy | 2.012 |
| 1 | female | Preparing view | 0.090 |
| 1 | female | Checking anatomy | 0.018 |
| 1 | female | Preparing selection | 0.317 |
| 1 | female | Opening reference | 0.041 |
| 1 | male | Reference request | 0.016 |
| 1 | male | Checking source file | 0.250 |
| 1 | male | Loading anatomy | 2.087 |
| 1 | male | Preparing view | 0.051 |
| 1 | male | Checking anatomy | 0.013 |
| 1 | male | Preparing selection | 0.288 |
| 1 | male | Opening reference | 0.123 |
| 1 | bodyparts-male-bones-study | Reference request | 0.015 |
| 1 | bodyparts-male-bones-study | Checking source file | 0.050 |
| 1 | bodyparts-male-bones-study | Loading anatomy | 0.277 |
| 1 | bodyparts-male-bones-study | Preparing view | 0.016 |
| 1 | bodyparts-male-bones-study | Checking anatomy | 0.003 |
| 1 | bodyparts-male-bones-study | Preparing selection | 0.071 |
| 1 | bodyparts-male-bones-study | Opening reference | 0.105 |
| 2 | female | Reference request | 0.015 |
| 2 | female | Checking source file | 0.251 |
| 2 | female | Loading anatomy | 2.156 |
| 2 | female | Preparing view | 0.066 |
| 2 | female | Checking anatomy | 0.018 |
| 2 | female | Preparing selection | 0.313 |
| 2 | female | Opening reference | 0.065 |
| 2 | male | Reference request | 0.016 |
| 2 | male | Checking source file | 0.268 |
| 2 | male | Loading anatomy | 2.108 |
| 2 | male | Preparing view | 0.048 |
| 2 | male | Checking anatomy | 0.015 |
| 2 | male | Preparing selection | 0.301 |
| 2 | male | Opening reference | 0.138 |
| 2 | bodyparts-male-bones-study | Reference request | 0.015 |
| 2 | bodyparts-male-bones-study | Checking source file | 0.050 |
| 2 | bodyparts-male-bones-study | Loading anatomy | 0.280 |
| 2 | bodyparts-male-bones-study | Preparing view | 0.015 |
| 2 | bodyparts-male-bones-study | Checking anatomy | 0.004 |
| 2 | bodyparts-male-bones-study | Preparing selection | 0.067 |
| 2 | bodyparts-male-bones-study | Opening reference | 0.117 |
| 3 | female | Reference request | 0.016 |
| 3 | female | Checking source file | 0.267 |
| 3 | female | Loading anatomy | 2.037 |
| 3 | female | Preparing view | 0.020 |
| 3 | female | Checking anatomy | 0.017 |
| 3 | female | Preparing selection | 0.312 |
| 3 | female | Opening reference | 0.061 |
| 3 | male | Reference request | 0.016 |
| 3 | male | Checking source file | 0.267 |
| 3 | male | Loading anatomy | 2.222 |
| 3 | male | Preparing view | 0.053 |
| 3 | male | Checking anatomy | 0.025 |
| 3 | male | Preparing selection | 0.290 |
| 3 | male | Opening reference | 0.126 |
| 3 | bodyparts-male-bones-study | Reference request | 0.016 |
| 3 | bodyparts-male-bones-study | Checking source file | 0.049 |
| 3 | bodyparts-male-bones-study | Loading anatomy | 0.314 |
| 3 | bodyparts-male-bones-study | Preparing view | 0.017 |
| 3 | bodyparts-male-bones-study | Checking anatomy | 0.005 |
| 3 | bodyparts-male-bones-study | Preparing selection | 0.065 |
| 3 | bodyparts-male-bones-study | Opening reference | 0.130 |

## Memory and interpretation

Observed process peak working set: 1,766,273,024 bytes. Maximum sampled private memory: 1,933,799,424 bytes.
The host samples every 500 ms over the entire process; brief spikes may be missed. These values do not measure GPU or per-scene memory.

Recorded active power scheme: Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced). This does not establish AC/battery or thermal state.

The 1080p window includes controls and panels; its 3D viewport is recorded above. These are frame-callback cadence and process-gap observations, not GPU execution or display latency.
The eight-scene suite uses label density 8; additional densities, moved-organ overlays and saved-view transitions remain outside this run. One Windows host leaves representative hardware, Mac, human-input, accessibility and qualified medical review gates open.

Source geometry fingerprints:

- female: `149c9dade4a914c02f73eed96cef68079fc98e70019fcf69185cae24050dcfe5`.
- male: `f8dce99e28b64109b4419b579f8c53bb3af5b6d7739eb1f0406c34289b4f5863`.
- bodyparts-male-bones-study: `30f8982452c0b4091652d14b523d7063a59aa0443e5ae766e79eb95112514c27`.

Raw profile SHA-256: `3663544e613d6d2cdfa69da9a502a9213441adee9d1142436b5d20e154025957`. Full native evidence retains the archive identity, tool fingerprints and host observations.
