#!/usr/bin/env python3
"""Validate raw rendered intervals and print a compact, reproducible summary."""

import argparse
import json
import math
import re
from pathlib import Path


def finite_number(value: object, label: str, positive: bool = False) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ValueError(f"{label} must be a finite number")
    if positive and value <= 0:
        raise ValueError(f"{label} must be positive")
    return float(value)


def integer(value: object, label: str, minimum: int = 0) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < minimum:
        raise ValueError(f"{label} must be an integer >= {minimum}")
    return value


def same_number(actual: object, expected: float, label: str) -> None:
    if not math.isclose(finite_number(actual, label), expected, rel_tol=1e-9, abs_tol=1e-9):
        raise ValueError(f"Reported {label} differs from raw measurements")


def validate_configuration(config: dict) -> None:
    seconds = finite_number(config['seconds'], 'requested seconds')
    warmup = finite_number(config['warmup_seconds'], 'warmup seconds')
    repetitions = integer(config['repetitions'], 'repetitions', 1)
    pixels = config['window_pixels']
    if not 1 <= seconds <= 120 or not .25 <= warmup <= 10 or repetitions > 3:
        raise ValueError('Profile configuration is outside supported ranges')
    if not isinstance(pixels, list) or len(pixels) != 2:
        raise ValueError('Window dimensions must be a width/height pair')
    width, height = (integer(p, 'window pixels', 1) for p in pixels)
    if not 1100 <= width <= 3840 or not 720 <= height <= 2160:
        raise ValueError('Window dimensions are outside supported ranges')


def validate_load(load: dict) -> None:
    samples = [finite_number(v, 'load interval', True) for v in load['raw_process_intervals_ms']]
    if not samples or integer(load['interval_count'], 'load interval count', 1) != len(samples):
        raise ValueError('Load interval count differs from raw samples')
    wall = finite_number(load['wall_seconds'], 'load wall seconds', True)
    same_number(wall, sum(samples) / 1000, 'load wall seconds')
    same_number(load['maximum_process_gap_ms'], max(samples), 'maximum load process gap')
    for key, threshold in [('intervals_over_33_33_ms', 1000 / 30), ('intervals_over_100_ms', 100)]:
        if integer(load[key], key) != sum(v > threshold for v in samples):
            raise ValueError('Load gap count differs from raw samples')
    prepared = finite_number(load['verified_prepared_scene_seconds'], 'verified load seconds', True)
    if prepared > wall:
        raise ValueError('Prepared scene time exceeds outer load time')
    integer(load['ui_process_frames_during_load'], 'loading UI frames', 2)
    integer(load['loader_yield_frames'], 'loader yield frames', 2)
    finite_number(load['first_post_draw_after_load_ms'], 'post-draw delay', True)
    stages = load['stage_events']
    if not stages or stages[0] != {'stage': 'Reference request', 'at_seconds': 0.0} or stages[-1]['stage'] != 'Reference ready':
        raise ValueError('Load stage boundaries are missing')
    previous = 0.0
    for event in stages:
        at = finite_number(event['at_seconds'], 'stage timestamp')
        if not isinstance(event['stage'], str) or not event['stage'] or not previous <= at <= wall:
            raise ValueError('Load stage timestamps must be ordered within the load')
        previous = at
    same_number(previous, wall, 'last load stage timestamp')


def validate_plan(report: dict) -> None:
    config = report['configuration']
    validate_configuration(config)
    references, expected = {}, set()
    for item in report['measurement_plan']:
        reference, digest, scenes = item['reference'], item['reference_hash'], item['scenes']
        if not isinstance(reference, str) or not reference or reference in references or not re.fullmatch('[0-9a-f]{64}', digest):
            raise ValueError('Measurement plan must contain distinct reference identities and hashes')
        if not scenes or len(scenes) != len(set(scenes)) or any(not isinstance(s, str) or not s for s in scenes):
            raise ValueError('Measurement plan scenes must be nonempty and distinct')
        references[reference] = digest
        for repetition in range(1, config['repetitions'] + 1):
            expected.update((reference, scene, repetition) for scene in scenes)
    if not expected:
        raise ValueError('Measurement plan is empty')
    observed = set()
    for scene in report['scenes']:
        repetition = integer(scene['repetition'], 'scene repetition', 1)
        key = (scene['reference'], scene['scene'], repetition)
        if key not in expected or key in observed or scene['reference_hash'] != references.get(scene['reference']):
            raise ValueError('Scene identity/repetition differs from the measurement plan')
        observed.add(key)
        same_number(scene['requested_seconds'], config['seconds'], 'requested scene seconds')
        same_number(scene['warmup_seconds'], config['warmup_seconds'], 'scene warmup seconds')
        if scene['elapsed_seconds'] < config['seconds']:
            raise ValueError('Scene did not reach the requested duration')
        if scene['window_pixels'] != config['window_pixels']:
            raise ValueError('Actual window dimensions differ from the requested dimensions')
        pixels = scene['scene_viewport_pixels']
        if not isinstance(pixels, list) or len(pixels) != 2 or any(integer(p, 'scene viewport pixels', 1) > bound for p, bound in zip(pixels, config['window_pixels'])):
            raise ValueError('Scene viewport dimensions are invalid')
        if not isinstance(scene['window_focused_throughout_sample'], bool):
            raise ValueError('Scene focus observation must be boolean')
    if observed != expected:
        raise ValueError('Profile omits a planned scene/repetition')
    expected_loads = {(reference, r) for reference in references for r in range(1, config['repetitions'] + 1)}
    observed_loads = set()
    for load in report['loads']:
        key = (load['reference'], integer(load['repetition'], 'load repetition', 1))
        if key not in expected_loads or key in observed_loads or load['reference_hash'] != references.get(load['reference']):
            raise ValueError('Load identity/repetition differs from the measurement plan')
        observed_loads.add(key)
        validate_load(load)
    if observed_loads != expected_loads:
        raise ValueError('Profile omits a planned reference load/repetition')


def validate_report(report: dict) -> list[dict]:
    if isinstance(report.get('schema_version'), bool) or report.get("schema_version") not in [1, 2] or not report.get("scenes"):
        raise ValueError("Unsupported or empty rendering profile")
    if not report.get("gpu") or not report.get("renderer"):
        raise ValueError("Profile must identify its actual renderer and GPU")
    rows = []
    for scene in report["scenes"]:
        samples = [finite_number(value, "frame interval", True) for value in scene["raw_frame_intervals_ms"]]
        if not samples or integer(scene["frames"], 'frame count', 1) != len(samples):
            raise ValueError("Reported frame count differs from raw samples")
        elapsed = finite_number(scene["elapsed_seconds"], "elapsed seconds", True)
        if not math.isclose(sum(samples) / 1000, elapsed, rel_tol=1e-9, abs_tol=1e-9):
            raise ValueError("Reported duration differs from raw intervals")
        fps = len(samples) / elapsed
        if not math.isclose(finite_number(scene["average_frame_cadence_fps"], "FPS", True), fps, rel_tol=1e-9):
            raise ValueError("Reported cadence differs from raw intervals")
        ordered = sorted(samples)
        for key, fraction in [("median", 0.5), ("p95", 0.95), ("p99", 0.99), ("maximum", 1)]:
            expected = ordered[max(0, math.ceil(len(ordered) * fraction) - 1)]
            actual = finite_number(scene["frame_interval_ms"][key], key, True)
            if not math.isclose(actual, expected, rel_tol=1e-9, abs_tol=1e-9):
                raise ValueError(f"Reported {key} differs from raw nearest-rank percentile")
        slow = sum(value > 1000 / 30 for value in samples)
        if integer(scene["frames_over_33_33_ms"], 'slow frame count') != slow:
            raise ValueError("Slow-frame count differs from raw intervals")
        stalled = sum(value > 100 for value in samples)
        if report['schema_version'] == 2 and integer(scene['frames_over_100_ms'], 'stalled frame count') != stalled:
            raise ValueError('Stalled-frame count differs from raw intervals')
        rows.append({"reference": scene["reference"], "scene": scene["scene"], "frames": len(samples),
                     "seconds": elapsed, "fps": fps, "p95_ms": scene["frame_interval_ms"]["p95"],
                     "p99_ms": scene['frame_interval_ms']['p99'], 'maximum_ms': max(samples),
                     'repetition': scene.get('repetition', 1), 'frames_over_100_ms': stalled,
                     "slow_percent": slow / len(samples) * 100})
    if report['schema_version'] == 2:
        validate_plan(report)
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    args = parser.parse_args()
    report = json.loads(args.report.read_text())
    rows = validate_report(report)
    print(f"{report['platform']} · {report['gpu']} · {report['renderer']}")
    print("Repeat | Reference | Scene | Seconds | Cadence FPS | p95 ms | Frames >33.33ms | >100ms")
    for row in rows:
        print(f"{row['repetition']} | {row['reference']} | {row['scene']} | {row['seconds']:.1f} | {row['fps']:.1f} | {row['p95_ms']:.2f} | {row['slow_percent']:.1f}% | {row['frames_over_100_ms']}")
    if report['schema_version'] == 2:
        print('Repeat | Reference | Load seconds | Maximum process gap ms | Gaps >100ms')
        for load in report['loads']:
            print(f"{load['repetition']} | {load['reference']} | {load['wall_seconds']:.2f} | {load['maximum_process_gap_ms']:.2f} | {load['intervals_over_100_ms']}")
    print("PASS raw interval consistency and declared workload completeness; hardware acceptance remains separate")


if __name__ == "__main__":
    main()
