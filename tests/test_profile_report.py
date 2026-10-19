"""Keep a human-readable baseline tied to its validated raw native measurements."""
import copy
import hashlib
import json
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from report_profile import markdown, native_binding
from summarize_profile import validate_report
from test_render_profile import fixture


def report_fixture():
    report = fixture()
    report.update(cpu='Fixture CPU', graphics_api='Fixture driver', engine_max_fps=0)
    report['scenes'][0].update(vsync_mode=1, msaa_3d=1)
    raw = json.dumps(report).encode()
    evidence = {'raw_profile': {'sha256': hashlib.sha256(raw).hexdigest()}, 'configuration': report['configuration'],
                'result': 'passed; native exit code 0', 'scene_summary': validate_report(report),
                'recorded_at_utc': '2026-10-12T20:00:00+00:00', 'source_revision': 'a' * 40,
                'artifact': {'file': 'Fixture-Windows.zip', 'bytes': 1234, 'sha256': 'b' * 64},
                'engine_actual': '4.7.2.stable.official.ed1daf0bf',
                'host': {'os_caption': 'Fixture OS', 'os_version': '10.0', 'os_build': '123',
                         'total_physical_ram_bytes': 16000000000, 'active_power_scheme': 'Fixture balanced'},
                'context': 'Fixture only', 'process_memory_observations': {'peak_working_set_bytes_observed': 123456,
                    'maximum_private_bytes_sampled': 234567, 'sampling_interval_ms': 500}}
    return raw, report, evidence


class ProfileReportTests(unittest.TestCase):
    def test_focus_counts_retain_unfocused_samples_and_their_stalls(self):
        _, report, evidence = report_fixture()
        report['configuration']['repetitions'] = 2
        second_scene = copy.deepcopy(report['scenes'][0])
        second_scene.update(repetition=2, window_focused_throughout_sample=False)
        second_load = copy.deepcopy(report['loads'][0])
        second_load['repetition'] = 2
        report['scenes'].append(second_scene)
        report['loads'].append(second_load)
        summary = markdown(report, evidence)
        self.assertIn('| Focused samples |', summary)
        self.assertIn('FPS ranges retain all samples.', summary)
        self.assertIn('| female | whole-body orbit | 1/2 | 3.7 | 1000.00 | 1000.00 | 1000.00 | 4 | 2 |', summary)
        self.assertIn('2 samples retain 8 rendered intervals', summary)
        self.assertIn('Window focus held throughout 1/2 samples.', summary)

    def test_summary_uses_the_actual_plan_and_recorded_label_settings(self):
        _, report, evidence = report_fixture()
        summary = markdown(report, evidence)
        self.assertIn('1 distinct reference/workload pairs', summary)
        self.assertIn('Label density is not recorded for every sample.', summary)
        report['scenes'][0]['label_density'] = 12
        self.assertIn('Recorded label densities: 12.', markdown(report, evidence))
        self.assertNotIn('eight-scene', markdown(report, evidence))
        second_plan = copy.deepcopy(report['measurement_plan'][0])
        second_plan['reference'] = 'male'
        second_load = copy.deepcopy(report['loads'][0])
        second_load['reference'] = 'male'
        second_scene = copy.deepcopy(report['scenes'][0])
        second_scene.update(reference='male', label_density=1)
        report['measurement_plan'].append(second_plan)
        report['loads'].append(second_load)
        report['scenes'].append(second_scene)
        summary = markdown(report, evidence)
        self.assertIn('2 distinct reference/workload pairs', summary)
        self.assertIn('Recorded label densities: 1, 12.', summary)

    def test_summary_preserves_raw_outliers_and_separates_measurement_scopes(self):
        raw, report, evidence = report_fixture()
        native_binding(raw, report, evidence)
        summary = markdown(report, evidence)
        self.assertIn('3.7 | 1000.00 | 1000.00 | 1000.00 | 2 | 1 |', summary)
        self.assertIn('0.270 | 0.200 | 200.00 | 1 | 16.00 |', summary)
        self.assertIn('Reference request | 0.010 |', summary)
        self.assertIn('Actual 3D viewport sizes: 1300 × 900.', summary)
        self.assertIn('123,456 bytes', summary)
        self.assertIn('not pooled percentiles', summary)
        self.assertIn('qualified medical review gates open', summary)
        self.assertIn(evidence['artifact']['sha256'], summary)

    def test_evidence_must_match_the_exact_raw_file_and_independent_summary(self):
        raw, report, evidence = report_fixture()
        with self.assertRaises(ValueError):
            native_binding(raw + b'\n', report, evidence)
        altered = copy.deepcopy(report)
        altered['engine_max_fps'] = 60
        with self.assertRaises(ValueError):
            native_binding(raw, altered, evidence)
        for mutate in [lambda e: e.update(configuration={}), lambda e: e.update(result='failed'),
                       lambda e: e['scene_summary'][0].update(fps=60)]:
            broken = copy.deepcopy(evidence)
            mutate(broken)
            with self.subTest(broken=broken), self.assertRaises(ValueError):
                native_binding(raw, report, broken)


if __name__ == '__main__':
    unittest.main()
