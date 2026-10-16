"""Validate real normal-launch observations without substituting helper-only checks."""
import copy
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from window_lifecycle_windows import validate_observations


def complete_observations():
    normal = {'schema_version': 1, 'size': [1300, 800], 'maximized': False}
    maximum = dict(normal, maximized=True)
    return {'schema_version': 1, 'first_saved': normal, 'reopened_size': [1300, 800],
            'maximized_saved': maximum, 'reopened_maximized': True,
            'unmaximized_size': [1300, 800], 'final_saved': normal}


class WindowLifecycleTests(unittest.TestCase):
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
