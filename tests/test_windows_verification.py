"""Require complete native evidence and a matching artifact before launch."""
import copy
import hashlib
import pathlib
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from verify_windows import MARKERS, RENDERED_MARKERS, artifact_record, parse_loading_shutdown, parse_result, ps_literal


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
    def test_saved_view_context_packages_require_every_reference_check(self):
        log = complete_log(False)
        for reference in ['female', 'male', 'bodyparts-male-bones-study']:
            with self.assertRaisesRegex(ValueError, 'saved-view anatomy search'):
                parse_result(log, False, saved_view_context=True)
            log += '\nPASS bundled saved-view anatomy search: ' + reference
        self.assertEqual(parse_result(log, False, saved_view_context=True)['saved_view_anatomy_search_references'],
                         ['female', 'male', 'bodyparts-male-bones-study'])

    def test_pointer_packages_require_every_reference_check(self):
        log = complete_log(False)
        for reference in ['female', 'male', 'bodyparts-male-bones-study']:
            with self.assertRaisesRegex(ValueError, 'pointer interruption'):
                parse_result(log, False, pointer_interruption=True)
            log += '\nPASS bundled pointer interruption: ' + reference
        self.assertEqual(parse_result(log, False, pointer_interruption=True)['pointer_interruption_references'],
                         ['female', 'male', 'bodyparts-male-bones-study'])

    def test_find_anatomy_packages_require_every_reference_check(self):
        log = complete_log(False)
        for reference in ['female', 'male']:
            with self.assertRaisesRegex(ValueError, 'Find anatomy'):
                parse_result(log, False, find_anatomy=True)
            log += '\nPASS bundled find anatomy: ' + reference
        with self.assertRaisesRegex(ValueError, 'Find anatomy'):
            parse_result(log, False, find_anatomy=True)
        log += '\nPASS bundled find anatomy: bodyparts-male-bones-study'
        self.assertIn('female', parse_result(log, False, find_anatomy=True)['references'])

    def test_shutdown_evidence_requires_its_actual_loading_boundary(self):
        marker = 'PASS loading shutdown: initial/anatomy · resource true · worker false · staged false'
        self.assertTrue(parse_loading_shutdown(marker, 'initial/anatomy')['owned_resource_at_close'])
        for broken in [marker.replace('resource true', 'resource false'), marker.replace('initial/', 'replacement/'),
                       marker + '\n' + marker, '']:
            with self.subTest(broken=broken), self.assertRaises(ValueError):
                parse_loading_shutdown(broken, 'initial/anatomy')
        with self.assertRaisesRegex(ValueError, 'Unknown'):
            parse_loading_shutdown(marker, 'initial/unsupported')

    def test_shutdown_errors_and_late_object_leaks_cannot_pass(self):
        marker = 'PASS loading shutdown: replacement/selection · resource true · worker false · staged true'
        for suffix in ['\nSCRIPT ERROR: invalid call', '\nERROR: Resource failed',
                       '\nWARNING: 1 ObjectDB instance was leaked at exit', '\nLeaked instance: RefCounted:1234',
                       '\nPASS stepERROR: duplicate signal']:
            with self.subTest(suffix=suffix), self.assertRaises(ValueError):
                parse_loading_shutdown(marker + suffix, 'replacement/selection')

    def test_condition_packages_require_both_reference_checks(self):
        log = complete_log(False)
        with self.assertRaisesRegex(ValueError, 'condition study'):
            parse_result(log, False, conditions=True)
        log += '\nPASS bundled condition study: female'
        with self.assertRaisesRegex(ValueError, 'condition study'):
            parse_result(log, False, conditions=True)
        log += '\nPASS bundled condition study: male'
        self.assertIn('male', parse_result(log, False, conditions=True)['references'])

    def test_information_packages_require_the_dialog_check(self):
        log = complete_log(False)
        with self.assertRaisesRegex(ValueError, 'information dialog'):
            parse_result(log, False, information=True)
        log += '\nPASS bundled information dialogs: female'
        self.assertIn('female', parse_result(log, False, information=True)['references'])

    def test_circulation_packages_require_both_route_checks(self):
        log = complete_log(False)
        with self.assertRaisesRegex(ValueError, 'keyboard movement'):
            parse_result(log, False, circulation=True)
        for identity in ['female', 'male', 'bodyparts-male-bones-study']:
            log += f'\nPASS bundled keyboard movement: {identity}'
        with self.assertRaisesRegex(ValueError, 'circulation route'):
            parse_result(log, False, circulation=True)
        log += '\nPASS bundled circulation route: female'
        with self.assertRaisesRegex(ValueError, 'circulation route'):
            parse_result(log, False, circulation=True)
        log += '\nPASS bundled circulation route: male'
        self.assertIn('male', parse_result(log, False, circulation=True)['references'])

    def test_expanded_catalogue_requires_study_workspace_checks(self):
        reference = 'hra-v1-2-female-cord-study'
        extra = [f'PASS interface frames while loading: {reference} · 30',
                 f'PASS bundled reference: {reference} · 29 meshes']
        extra.extend(f'PASS {marker}: {reference}' for marker in MARKERS)
        log = complete_log(False) + '\n' + '\n'.join(extra)
        with self.assertRaisesRegex(ValueError, 'study workspace'):
            parse_result(log, False)
        for identity in ['female', 'male', 'bodyparts-male-bones-study', reference]:
            log += f'\nPASS bundled study workspace: {identity}'
        self.assertIn(reference, parse_result(log, False)['references'])

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
                       log + '\nPASS stepERROR: duplicate signal',
                       log + '\nWARNING: 1 ObjectDB instance was leaked at exit',
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
