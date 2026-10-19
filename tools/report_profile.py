"""Create a reviewable Markdown summary from validated native profile evidence."""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib

from summarize_profile import validate_report


def span(values: list[float], decimals: int = 2) -> str:
    low, high = min(values), max(values)
    return f'{low:.{decimals}f}' if low == high else f'{low:.{decimals}f}–{high:.{decimals}f}'


def text(value: object) -> str:
    return ' '.join(str(value).replace('|', '\\|').splitlines())


def native_binding(raw: bytes, report: dict, evidence: dict) -> None:
    if json.loads(raw) != report:
        raise ValueError('Parsed measurements differ from the raw file')
    if evidence.get('raw_profile', {}).get('sha256') != hashlib.sha256(raw).hexdigest():
        raise ValueError('Native evidence describes a different raw profile')
    if evidence.get('configuration') != report.get('configuration') or report.get('platform') != 'Windows':
        raise ValueError('Native configuration/platform differs from the raw profile')
    if 'native exit code 0' not in evidence.get('result', ''):
        raise ValueError('Native evidence does not record successful completion')
    if evidence.get('scene_summary') != validate_report(report):
        raise ValueError('Native scene summary differs from independently recomputed measurements')


def markdown(report: dict, evidence: dict) -> str:
    rows = validate_report(report)
    config = report['configuration']
    host = evidence['host']
    artifact = evidence['artifact']
    workload_count = sum(len(item['scenes']) for item in report['measurement_plan'])
    densities = [scene.get('label_density') for scene in report['scenes']]
    density_note = ('Recorded label densities: ' + ', '.join(str(value) for value in sorted(set(densities))) + '.'
                    if all(type(value) is int and 1 <= value <= 12 for value in densities)
                    else 'Label density is not recorded for every sample.')
    lines = ['# Native Windows rendering observations', '',
             f"Recorded UTC: {text(evidence['recorded_at_utc'])}.", '',
             f"Source revision: `{text(evidence['source_revision'])}`. Archive: `{text(artifact['file'])}`",
             f"({artifact['bytes']:,} bytes), SHA-256 `{text(artifact['sha256'])}`.", '',
             f"Engine: {text(evidence['engine_actual'])}. OS: {text(host['os_caption'])}, "
             f"{text(host['os_version'])} (build {text(host['os_build'])}).",
             f"CPU: {text(report['cpu'])}. Reported physical RAM: {host['total_physical_ram_bytes']:,} bytes.",
             f"Actual rendering adapter: {text(report['gpu'])}; {text(report['renderer'])}, "
             f"graphics API/driver {text(report['graphics_api'])}.", '',
             f"Configuration: {config['seconds']:g}-second samples, {config['warmup_seconds']:g}-second stationary "
             f"warmups, {config['repetitions']} repetitions at a {config['window_pixels'][0]} × {config['window_pixels'][1]} window.",
             (f"Scene view: {text(config['scene_view'])}; 3D rendering resolution: {config['render_fraction'] * 100:g}% of displayed pixels."
              if report['schema_version'] >= 3 else 'Historical profile without explicit display-density metadata.'),
             'Each sample orbits at 0.5 rad/s. Frame intervals use post-draw callbacks and nearest-rank percentiles.',
             f"Operator context: {text(evidence['context'])}", '',
             '## Navigation cadence', '',
             'Ranges below are the minimum/maximum across separate repetitions, not pooled percentiles. '
             'The maximum interval and >100 ms counts retain outliers.', '',
             'Focused samples retained window focus throughout the entire sample. FPS ranges retain all samples.', '',
             '| Reference | Scene | Focused samples | Cadence FPS range | p95 ms range | p99 ms range | Maximum ms | >33.33 ms frames | >100 ms frames |',
             '|---|---|---:|---:|---:|---:|---:|---:|---:|']
    groups = {}
    for row in rows:
        groups.setdefault((row['reference'], row['scene']), []).append(row)
    for (reference, scene), group in groups.items():
        # Counts are recomputed from each raw scene, not rounded percentages.
        raw_group = [s for s in report['scenes'] if s['reference'] == reference and s['scene'] == scene]
        focused_count = sum(s['window_focused_throughout_sample'] for s in raw_group)
        slow = sum(s['frames_over_33_33_ms'] for s in raw_group)
        stalled = sum(s['frames_over_100_ms'] for s in raw_group)
        lines.append(f"| {text(reference)} | {text(scene)} | {focused_count}/{len(raw_group)} | {span([r['fps'] for r in group], 1)} | "
                     f"{span([r['p95_ms'] for r in group])} | {span([r['p99_ms'] for r in group])} | "
                     f"{max(r['maximum_ms'] for r in group):.2f} | {slow} | {stalled} |")
    pixels = sorted({tuple(s['scene_viewport_pixels']) for s in report['scenes']})
    focused = sum(s['window_focused_throughout_sample'] for s in report['scenes'])
    intervals = sum(row['frames'] for row in rows)
    duration = sum(row['seconds'] for row in rows)
    lines += ['', f'{len(rows)} samples retain {intervals:,} rendered intervals over {duration:.2f} measured seconds.',
              'Actual 3D viewport sizes: ' + ', '.join(f'{w} × {h}' for w, h in pixels) + '.',
              f'Window focus held throughout {focused}/{len(rows)} samples.',
              f"Recorded VSync modes: {sorted({s['vsync_mode'] for s in report['scenes']})}; "
              f"3D MSAA modes: {sorted({s['msaa_3d'] for s in report['scenes']})}; engine max FPS: {report['engine_max_fps']}.", '',
              '## Loading and process gaps', '',
              f"Each repetition visits all {len(report['measurement_plan'])} references. Revisit loads can reuse resources and OS caches. "
              'Raw process intervals include partial start/end boundaries and sum to switch wall time.', '',
              '| Repeat | Reference | Wall seconds | Verified/prepared seconds | Largest process gap ms | Gaps >100 ms | Next post-draw delay ms |',
              '|---:|---|---:|---:|---:|---:|---:|']
    for load in report['loads']:
        lines.append(f"| {load['repetition']} | {text(load['reference'])} | {load['wall_seconds']:.3f} | "
                     f"{load['verified_prepared_scene_seconds']:.3f} | {load['maximum_process_gap_ms']:.2f} | "
                     f"{load['intervals_over_100_ms']} | {load['first_post_draw_after_load_ms']:.2f} |")
    lines += ['', 'Stage durations are adjacent transition differences, including scheduling and intervening work. '
              'They do not isolate CPU execution cost or independently establish the first visible frame.', '',
              '| Repeat | Reference | Stage | Seconds to next transition |', '|---:|---|---|---:|']
    for load in report['loads']:
        stages = load['stage_events']
        for event, following in zip(stages, stages[1:]):
            lines.append(f"| {load['repetition']} | {text(load['reference'])} | {text(event['stage'])} | "
                         f"{following['at_seconds'] - event['at_seconds']:.3f} |")
    memory = evidence['process_memory_observations']
    lines += ['', '## Memory and interpretation', '',
              f"Observed process peak working set: {memory['peak_working_set_bytes_observed']:,} bytes. "
              f"Maximum sampled private memory: {memory['maximum_private_bytes_sampled']:,} bytes.",
              f"The host samples every {memory['sampling_interval_ms']} ms over the entire process; "
              'brief spikes may be missed. These values do not measure GPU or per-scene memory.', '',
              f"Recorded active power scheme: {text(host['active_power_scheme'])}. "
              'This does not establish AC/battery or thermal state.', '',
              'Workspace views include controls and panels; expanded native views cover the requested window pixels. '
              'These are frame-callback cadence and process-gap observations, not GPU execution or display latency.',
              f'The measurement plan contains {workload_count} distinct reference/workload pairs. ' + density_note,
              'These results cover only the listed workloads and settings. One Windows host leaves representative hardware, Mac, '
              'human-input, accessibility and qualified medical review gates open.', '',
              'Source geometry fingerprints:', '']
    for item in report['measurement_plan']:
        lines.append(f"- {text(item['reference'])}: `{text(item['reference_hash'])}`.")
    lines += ['', f"Raw profile SHA-256: `{text(evidence['raw_profile']['sha256'])}`. "
              'Full native evidence retains the archive identity, tool fingerprints and host observations.', '']
    return '\n'.join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('profile', type=pathlib.Path)
    parser.add_argument('--evidence', type=pathlib.Path, required=True, help='Companion exact-artifact report.json')
    parser.add_argument('--output', type=pathlib.Path, required=True, help='New Markdown path; existing evidence is retained')
    args = parser.parse_args()
    try:
        raw = args.profile.read_bytes()
        report = json.loads(raw)
        evidence = json.loads(args.evidence.read_text(encoding='utf-8'))
        native_binding(raw, report, evidence)
        result = markdown(report, evidence)
        with args.output.open('x', encoding='utf-8') as stream:
            stream.write(result)
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, str(error) + '\n')
    print('PASS validated native profile summary:', args.output)


if __name__ == '__main__':
    main()
