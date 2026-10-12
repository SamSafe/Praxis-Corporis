"""Require complete native evidence and a matching artifact before launch."""
import copy
import hashlib
import pathlib
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from verify_windows import MARKERS, RENDERED_MARKERS, artifact_record, parse_result, ps_literal


def complete_log(rendered=True):
    lines = ['Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org']
    if rendered:
        lines.append('OpenGL API 3.3 core - Compatibility - Using Device: AMD Radeon(TM) Graphics')
    for reference, count in [('female', 801), ('male', 788), ('bodyparts-male-bones-study', 203)]:
        lines.append(f'PASS interface frames while loading: {reference} · 30')
        for marker in MARKERS + (RENDERED_MARKERS if rendered else []):
            lines.append(f'PASS {marker}: {reference}')
        lines.append(f'PASS bundled reference: {reference} · {count} meshes')
    lines.extend(['PASS private export resource boundary', 'PASS offline native bundle', 'QA observed peak working set bytes: 123456',
                  'QA sampled maximum private bytes: 234567', 'Windows native exit code: 0'])
    return '\n'.join(lines)


class WindowsVerificationTests(unittest.TestCase):
    def test_missing_or_failed_checks_cannot_pass_as_native_evidence(self):
        log = complete_log()
        report = parse_result(log, True)
        self.assertEqual(report['references']['bodyparts-male-bones-study'], 203)
        self.assertEqual(report['process_memory_observations']['maximum_private_bytes_sampled'], 234567)
        for marker in MARKERS + RENDERED_MARKERS:
            broken = log.replace(f'PASS {marker}: male\n', '')
            with self.subTest(marker=marker), self.assertRaises(ValueError):
                parse_result(broken, True)
        for broken in [log + '\nSCRIPT ERROR: Failure', log + '\nERROR: Invalid source',
                       log.replace('Windows native exit code: 0', 'Windows native exit code: 1'),
                       log.replace('PASS offline native bundle', ''),
                       log.replace('PASS private export resource boundary', ''),
                       log.replace('loading: female · 30', 'loading: female · 1'),
                       log.replace('OpenGL API 3.3 core - Compatibility - Using Device: AMD Radeon(TM) Graphics', '')]:
            with self.subTest(broken=broken[-40:]), self.assertRaises(ValueError):
                parse_result(broken, True)

    def test_headless_results_are_not_rendering_evidence(self):
        log = complete_log(False)
        report = parse_result(log, False)
        self.assertIsNone(report['renderer'])
        with self.assertRaises(ValueError):
            parse_result(log, True)

    def test_modified_or_wrong_platform_archives_are_rejected_before_launch(self):
        with tempfile.TemporaryDirectory() as folder:
            path = pathlib.Path(folder) / 'PraxisCorporis-Windows-x64-private.zip'
            path.write_bytes(b'artifact identity fixture')
            item = {'file': path.name, 'bytes': path.stat().st_size,
                    'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'architectures': ['x86_64']}
            report = {'artifacts': [item]}
            self.assertEqual(artifact_record(path, report), item)
            wrong = copy.deepcopy(report)
            wrong['artifacts'][0]['architectures'] = ['x86_64', 'arm64']
            with self.assertRaises(ValueError):
                artifact_record(path, wrong)
            path.write_bytes(b'modified content')
            with self.assertRaises(ValueError):
                artifact_record(path, report)

    def test_powershell_paths_are_literal_even_with_quotes_and_metacharacters(self):
        self.assertEqual(ps_literal("C:\\folder's\\$data`name"), "'C:\\folder''s\\$data`name'")


if __name__ == '__main__':
    unittest.main()
