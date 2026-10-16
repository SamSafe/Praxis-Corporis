"""Validate real normal-launch observations without substituting helper-only checks."""
import copy
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from window_lifecycle_windows import reference_cases, validate_observations


def complete_observations():
    normal = {'schema_version': 1, 'size': [1300, 800], 'maximized': False}
    maximum = dict(normal, maximized=True)
    return {'schema_version': 1, 'first_saved': normal, 'reopened_size': [1300, 800],
            'maximized_saved': maximum, 'reopened_maximized': True,
            'unmaximized_size': [1300, 800], 'final_saved': normal}


class WindowLifecycleTests(unittest.TestCase):
    def test_normal_startup_requires_loaded_titles_and_exact_source_records(self):
        bodies = [{'id': identity, 'label': identity.title(), 'sha256': str(index) * 64}
                  for index, identity in enumerate(['female', 'male', 'hra-v1-2-female-cord-study'], 1)]
        bodies[2]['short_label'] = 'Female cord · HRA study'
        cases = reference_cases(bodies)
        expected = [cases[key] for key in ['male', 'male', 'study', 'female']]
        complete = complete_observations()
        complete['reference_startup'] = {'saved': [case['record'].copy() for case in expected],
                                         'titles': [case['title'] for case in expected], 'written': [True] * 4}
        validate_observations(complete, cases)
        for malformed in [None, {}, {'saved': [], 'titles': []}]:
            broken = copy.deepcopy(complete)
            broken['reference_startup'] = malformed
            with self.subTest(malformed=malformed), self.assertRaises(ValueError):
                validate_observations(broken, cases)
        for index in range(4):
            broken = copy.deepcopy(complete)
            broken['reference_startup']['written'][index] = False
            with self.subTest(unwritten=index), self.assertRaises(ValueError):
                validate_observations(broken, cases)
            for field, value in [('body_id', 'wrong-reference'), ('source_sha256', 'f' * 64), ('schema_version', True)]:
                broken = copy.deepcopy(complete)
                broken['reference_startup']['saved'][index][field] = value
                with self.subTest(index=index, field=field), self.assertRaises(ValueError):
                    validate_observations(broken, cases)
            broken = copy.deepcopy(complete)
            broken['reference_startup']['titles'][index] = 'Window exists but reference has not loaded'
            with self.subTest(index=index), self.assertRaises(ValueError):
                validate_observations(broken, cases)

    def test_startup_cases_require_the_recorded_reference_and_study(self):
        with self.assertRaisesRegex(ValueError, 'Startup verification source is missing'):
            reference_cases([{'id': 'female', 'label': 'Female', 'sha256': 'a' * 64}])

    def test_complete_reopen_and_maximize_observations_pass(self):
        validate_observations(complete_observations())

    def test_missing_or_wrong_lifecycle_observations_cannot_pass(self):
        complete = complete_observations()
        for malformed in [None, [], 'not observations']:
            with self.subTest(malformed=malformed), self.assertRaises(ValueError):
                validate_observations(malformed)
        for key in complete:
            broken = copy.deepcopy(complete)
            del broken[key]
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_observations(broken)
        for key, value in [('reopened_size', [1440, 900]), ('unmaximized_size', [1920, 1080]),
                           ('reopened_maximized', False), ('schema_version', True)]:
            broken = copy.deepcopy(complete)
            broken[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_observations(broken)
        for key in ['first_saved', 'maximized_saved', 'final_saved']:
            broken = copy.deepcopy(complete)
            broken[key]['size'] = [1920, 1080]
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_observations(broken)
            broken[key] = None
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_observations(broken)
