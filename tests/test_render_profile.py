"""Reject incomplete or internally inconsistent native performance evidence."""
import argparse
import copy
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from profile_windows import CURRENT_WORKLOADS, profile_options, validate_native_profile
from summarize_profile import validate_report


def fixture():
    samples = [10.0, 20.0, 40.0, 1000.0]
    digest = 'a' * 64
    scene = {'reference': 'female', 'reference_hash': digest, 'scene': 'whole-body orbit', 'repetition': 1,
             'raw_frame_intervals_ms': samples, 'frames': 4, 'elapsed_seconds': 1.07,
             'average_frame_cadence_fps': 4 / 1.07, 'frame_interval_ms': {'median': 20, 'p95': 1000, 'p99': 1000, 'maximum': 1000},
             'frames_over_33_33_ms': 2, 'frames_over_100_ms': 1, 'requested_seconds': 1.0, 'warmup_seconds': .25,
             'window_pixels': [1920, 1080], 'scene_viewport_pixels': [1300, 900], 'window_focused_throughout_sample': True}
    load = {'reference': 'female', 'reference_hash': digest, 'repetition': 1, 'raw_process_intervals_ms': [50, 200, 20],
            'interval_count': 3, 'wall_seconds': .27, 'maximum_process_gap_ms': 200,
            'verified_prepared_scene_seconds': .2, 'ui_process_frames_during_load': 3, 'loader_yield_frames': 2,
            'intervals_over_33_33_ms': 2, 'intervals_over_100_ms': 1, 'first_post_draw_after_load_ms': 16,
            'stage_events': [{'stage': 'Reference request', 'at_seconds': 0.0}, {'stage': 'Checking source file', 'at_seconds': .01},
                             {'stage': 'Opening reference', 'at_seconds': .2}, {'stage': 'Reference ready', 'at_seconds': .27}]}
    return {'schema_version': 2, 'gpu': 'AMD Radeon', 'renderer': 'gl_compatibility', 'platform': 'Windows',
            'engine_commit': 'ed1daf0bf', 'pack_id': 'fixture-pack',
            'configuration': {'seconds': 1.0, 'warmup_seconds': .25, 'repetitions': 1, 'window_pixels': [1920, 1080]},
            'measurement_plan': [{'reference': 'female', 'reference_hash': digest, 'scenes': ['whole-body orbit']}],
            'loads': [load], 'scenes': [scene]}


class RenderProfileTests(unittest.TestCase):
    def test_raw_intervals_determine_percentiles_and_stall_counts(self):
        report = fixture()
        rows = validate_report(report)
        self.assertEqual(rows[0]['p95_ms'], 1000)
        self.assertEqual(rows[0]['frames_over_100_ms'], 1)
        changes = [('frames', 3), ('frames', True), ('elapsed_seconds', 1), ('average_frame_cadence_fps', 60),
                   ('frames_over_33_33_ms', 0), ('frames_over_100_ms', 0), ('raw_frame_intervals_ms', [10, 20, 40, float('nan')]),
                   ('raw_frame_intervals_ms', [10, 20, 40, 0])]
        for key, value in changes:
            broken = copy.deepcopy(report)
            broken['scenes'][0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_report(broken)
        broken = copy.deepcopy(report)
        broken['scenes'][0]['frame_interval_ms']['median'] = 30
        with self.assertRaises(ValueError):
            validate_report(broken)

    def test_plan_requires_every_reference_scene_and_repetition(self):
        report = fixture()
        for mutate in [lambda r: r['configuration'].update(repetitions=2),
                       lambda r: r['scenes'].append(copy.deepcopy(r['scenes'][0])),
                       lambda r: r['scenes'][0].update(reference_hash='b' * 64),
                       lambda r: r['scenes'][0].update(requested_seconds=2),
                       lambda r: r['scenes'][0].update(window_pixels=[1440, 900]),
                       lambda r: r['scenes'][0].update(scene_viewport_pixels=[2000, 900]),
                       lambda r: r['loads'].clear(),
                       lambda r: r['loads'].append(copy.deepcopy(r['loads'][0]))]:
            broken = copy.deepcopy(report)
            mutate(broken)
            with self.subTest(broken=broken), self.assertRaises(ValueError):
                validate_report(broken)

    def test_dimension_variation_is_only_allowed_for_explicit_diagnostic_arithmetic(self):
        report = fixture()
        report['scenes'][0]['window_pixels'] = [1920, 1111]
        with self.assertRaises(ValueError):
            validate_report(report)
        self.assertEqual(len(validate_report(report, allow_window_variation=True)), 1)
        report['scenes'][0]['frames_over_100_ms'] = 0
        with self.assertRaises(ValueError):
            validate_report(report, allow_window_variation=True)
        report = fixture()
        report['error'] = 'Window changed during the last sample'
        with self.assertRaises(ValueError):
            validate_report(report, allow_window_variation=True)

    def test_load_gap_and_stage_evidence_must_match_the_outer_wall_time(self):
        report = fixture()
        for key, value in [('interval_count', 2), ('wall_seconds', .2), ('maximum_process_gap_ms', 100),
                           ('verified_prepared_scene_seconds', .3), ('intervals_over_100_ms', 0),
                           ('ui_process_frames_during_load', 1), ('first_post_draw_after_load_ms', -1),
                           ('stage_events', [{'stage': 'Reference request', 'at_seconds': 0}, {'stage': 'Reference ready', 'at_seconds': .3}])]:
            broken = copy.deepcopy(report)
            broken['loads'][0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_report(broken)
        broken = copy.deepcopy(report)
        broken['loads'][0]['stage_events'][1]['at_seconds'] = .25
        with self.assertRaises(ValueError):
            validate_report(broken)

    def test_historical_short_profile_remains_reproducible(self):
        import json
        report = json.loads((ROOT / 'docs/audit/windows-render-profile.json').read_text())
        self.assertEqual(len(validate_report(report)), 8)

    def test_resource_call_timings_reject_incomplete_or_impossible_observations(self):
        report = fixture()
        operations = {'request': [1], 'status': [0, 2], 'collect': [100], 'instantiate': [5], 'index': [1]}
        report['loads'][0]['resource_operation_intervals_ms'] = operations
        self.assertEqual(len(validate_report(report)), 1)
        for mutate in [lambda d: d.pop('collect'), lambda d: d.update(status=[]),
                       lambda d: d.update(request=[1, 2]), lambda d: d.update(index=[-1]),
                       lambda d: d.update(status=[True]), lambda d: d.update(status=[float('nan')]),
                       lambda d: d.update(collect=[300])]:
            broken = copy.deepcopy(report)
            mutate(broken['loads'][0]['resource_operation_intervals_ms'])
            with self.subTest(broken=broken), self.assertRaises(ValueError):
                validate_report(broken)

    def test_native_runner_bounds_duration_and_never_interpolates_free_text_arguments(self):
        args = argparse.Namespace(seconds=60, warmup=2, repetitions=3, window='1920x1080')
        config, arguments, timeout = profile_options(args)
        self.assertEqual(config['repetitions'], 3)
        self.assertIn('--profile-window=1920x1080', arguments)
        self.assertGreater(timeout, 8 * 62 * 3)
        for key, value in [('seconds', float('inf')), ('seconds', 0), ('warmup', -1), ('repetitions', 4),
                           ('window', '1920x1080 --headless'), ('window', '1920x1080`whoami'), ('window', '1099x720')]:
            broken = copy.copy(args)
            setattr(broken, key, value)
            with self.subTest(key=key), self.assertRaises(ValueError):
                profile_options(broken)

    def test_native_profile_cannot_substitute_configuration_platform_or_incomplete_workloads(self):
        report = fixture()
        log = '\n'.join(['Godot Engine v4.7.2.stable.official.ed1daf0bf', 'OpenGL API 3.3 core - Compatibility - AMD Radeon',
                         'QA observed peak working set bytes: 123456', 'QA sampled maximum private bytes: 234567',
                         'PASS private export resource boundary', 'PASS rendering profile recorded: user://render-profile.json', 'Windows native exit code: 0'])
        build = {'engine': '4.7.2.stable.official.ed1daf0bf', 'content_pack': 'fixture-pack'}
        # Construct all eight current workloads so the native binding check has a complete passing case.
        report['measurement_plan'], report['scenes'], report['loads'] = [], [], []
        for reference, scenes in CURRENT_WORKLOADS.items():
            plan = {'reference': reference, 'reference_hash': 'a' * 64, 'scenes': scenes.copy()}
            report['measurement_plan'].append(plan)
            load = fixture()['loads'][0]
            load['reference'] = reference
            report['loads'].append(load)
            for name in plan['scenes']:
                scene = fixture()['scenes'][0]
                scene.update(reference=reference, scene=name)
                report['scenes'].append(scene)
        _, rows = validate_native_profile(report, log, build, report['configuration'])
        self.assertEqual(len(rows), 8)
        for mutate in [lambda r: r.update(platform='Linux'), lambda r: r.update(engine_commit='wrong'),
                       lambda r: r.update(pack_id='another-pack'), lambda r: r['scenes'].pop()]:
            broken = copy.deepcopy(report)
            mutate(broken)
            with self.subTest(broken=broken), self.assertRaises(ValueError):
                validate_native_profile(broken, log, build, report['configuration'])
        with self.assertRaises(ValueError):
            validate_native_profile(report, log.replace('PASS rendering profile recorded:', 'unfinished:'), build, report['configuration'])
        with self.assertRaises(ValueError):
            validate_native_profile(report, log.replace('PASS private export resource boundary', ''), build, report['configuration'])
        broken = copy.deepcopy(report)
        broken['measurement_plan'][0]['scenes'][0] = 'another workload'
        broken['scenes'][0]['scene'] = 'another workload'
        validate_report(broken) # Internally consistent, but not the requested native workload.
        with self.assertRaises(ValueError):
            validate_native_profile(broken, log, build, report['configuration'])


if __name__ == '__main__':
    unittest.main()
