#!/usr/bin/env python3
"""Validate raw rendered intervals and print a compact, reproducible summary."""

import argparse
import json
import math
from pathlib import Path


def finite_number(value: object, label: str, positive: bool = False) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ValueError(f"{label} must be a finite number")
    if positive and value <= 0:
        raise ValueError(f"{label} must be positive")
    return float(value)


def validate_report(report: dict) -> list[dict]:
    if report.get("schema_version") != 1 or not report.get("scenes"):
        raise ValueError("Unsupported or empty rendering profile")
    if not report.get("gpu") or not report.get("renderer"):
        raise ValueError("Profile must identify its actual renderer and GPU")
    rows = []
    for scene in report["scenes"]:
        samples = [finite_number(value, "frame interval", True) for value in scene["raw_frame_intervals_ms"]]
        if not samples or scene["frames"] != len(samples):
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
        if scene["frames_over_33_33_ms"] != slow:
            raise ValueError("Slow-frame count differs from raw intervals")
        rows.append({"reference": scene["reference"], "scene": scene["scene"], "frames": len(samples),
                     "seconds": elapsed, "fps": fps, "p95_ms": scene["frame_interval_ms"]["p95"],
                     "slow_percent": slow / len(samples) * 100})
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    args = parser.parse_args()
    report = json.loads(args.report.read_text())
    rows = validate_report(report)
    print(f"{report['platform']} · {report['gpu']} · {report['renderer']}")
    print("Reference | Scene | Cadence FPS | p95 ms | Frames >33.33ms")
    for row in rows:
        print(f"{row['reference']} | {row['scene']} | {row['fps']:.1f} | {row['p95_ms']:.2f} | {row['slow_percent']:.1f}%")
    print("PASS raw interval consistency; short observations, not hardware acceptance")


if __name__ == "__main__":
    main()
