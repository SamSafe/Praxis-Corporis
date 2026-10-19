"""Compatibility evidence must preserve existing data and restored scene state."""
import copy
import json
import pathlib
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from upgrade_windows import inspect_run, same_state, verify_entries


def fixture():
    state = dict(body='female', reference_hash='a' * 64, selection='leaf', isolation='leaf',
                 inspection_return=dict(selection='leaf', camera=dict(distance=1.25)),
                 camera=dict(target=[0.1, 0.2, 0.3], distance=0.25, yaw=0.2, pitch=0.3),
                 labels=False, local_labels=True, label_density=5,
                 changes=dict(leaf=dict(visibility='faded', offset=[0.005, 0, 0])))
    case = dict(id='female', sha256='a' * 64, leaf='leaf', name='QA current female',
                restore_name='QA baseline female', note='Current QA only\nCafé λ 🫀')
    old = dict(id='b' * 32, name=case['restore_name'], notes='Baseline QA only\nCafé λ 🫀',
               state=copy.deepcopy(state), created_unix=123)
    new = dict(id='c' * 32, name=case['name'], notes=case['note'], state=state, created_unix=456)
    return case, old, new


class UpgradeVerificationTests(unittest.TestCase):
    def test_decimal_reserialization_preserves_state_but_real_changes_fail(self):
        self.assertTrue(same_state({'target': [0.026717938482761383], 'density': 5},
                                   {'target': [0.02671793848276138], 'density': 5.0}))
        for value in [0.026717939, float('nan'), float('inf'), True, '0.026717938482761383']:
            with self.subTest(value=value):
                self.assertFalse(same_state([0.026717938482761383], [value]))
        self.assertFalse(same_state({'labels': False}, {'labels': 0}))
        self.assertFalse(same_state({'target': [0.1]}, {'target': [0.1, 0.2]}))
        self.assertFalse(same_state({'target': [0.1]}, {'target': [0.1], 'extra': 0}))

    def test_preserves_original_identity_notes_and_snapshot_while_capturing_restoration(self):
        case, old, new = fixture()
        before = {old['id']: old}
        after = dict(before, **{new['id']: new})
        restored = {old['name']: old}
        self.assertEqual(verify_entries(before, after, [case], restored), {new['name']: new})
        for field, value in [('notes', 'Lost Unicode'), ('name', 'Changed name'),
                             ('created_unix', 999), ('state', {})]:
            bad = copy.deepcopy(after)
            bad[old['id']][field] = value
            with self.subTest(field=field), self.assertRaisesRegex(ValueError, 'existing view'):
                verify_entries(before, bad, [case], restored)
        missing = dict(after)
        missing.pop(old['id'])
        with self.assertRaisesRegex(ValueError, 'existing view'):
            verify_entries(before, missing, [case], restored)

    def test_rejects_note_movement_visibility_camera_and_inspection_loss(self):
        case, old, new = fixture()
        before = {old['id']: old}
        for damage in ['notes', 'movement', 'visibility', 'camera', 'isolation', 'return', 'labels', 'density', 'source', 'extra']:
            after = dict(before, **{new['id']: copy.deepcopy(new)})
            entry = after[new['id']]
            if damage == 'notes': entry['notes'] = 'Current QA only Cafe lambda'
            if damage == 'movement': entry['state']['changes']['leaf']['offset'] = [0, 0, 0]
            if damage == 'visibility': entry['state']['changes']['leaf']['visibility'] = 'visible'
            if damage == 'camera': entry['state']['camera']['distance'] = 2.0
            if damage == 'isolation': entry['state']['isolation'] = ''
            if damage == 'return': entry['state']['inspection_return'] = {}
            if damage == 'labels': entry['state']['labels'] = True
            if damage == 'density': entry['state']['label_density'] = 8
            if damage == 'source': entry['state']['reference_hash'] = 'd' * 64
            if damage == 'extra': after['e' * 32] = dict(entry, id='e' * 32, name='Unexpected')
            with self.subTest(damage=damage), self.assertRaises(ValueError):
                verify_entries(before, after, [case], {old['name']: old})

    def test_requires_terminal_clean_process_and_complete_reference_layout_evidence(self):
        with tempfile.TemporaryDirectory() as folder:
            output = pathlib.Path(folder)
            data = {'exit.json': dict(closed=True, exit_code=0, completed=1),
                    'ready.json': dict(title='Expected reference', client_size=[1300, 800]),
                    'progress.json': dict(completed=[dict(reference='female')])}
            def write():
                for name, value in data.items():
                    (output / name).write_text(json.dumps(value))
            write()
            (output / 'engine.log').write_text('Godot Engine v4.7.2.stable.official.ed1daf0bf\n')
            self.assertEqual(inspect_run(output, 1, '4.7.2.stable.official.ed1daf0bf', 'Expected reference')['ready']['client_size'], [1300, 800])
            for log in ['ERROR: runtime failed', 'PASS stepERROR: interleaved error',
                        'Unicode parsing error', 'WARNING: 1 ObjectDB instance was leaked at exit']:
                (output / 'engine.log').write_text('Godot Engine v4.7.2.stable.official.ed1daf0bf\n' + log)
                with self.subTest(log=log), self.assertRaisesRegex(ValueError, 'error or leak'):
                    inspect_run(output, 1, '4.7.2.stable.official.ed1daf0bf', 'Expected reference')
            (output / 'engine.log').write_text('Godot Engine v4.7.2.stable.official.ed1daf0bf\n')
            data['exit.json']['completed'] = 0
            write()
            with self.assertRaisesRegex(ValueError, 'complete normally'):
                inspect_run(output, 1, '4.7.2.stable.official.ed1daf0bf', 'Expected reference')
            data['exit.json']['completed'] = 1
            data['exit.json']['forced'] = True
            write()
            with self.assertRaisesRegex(ValueError, 'complete normally'):
                inspect_run(output, 1, '4.7.2.stable.official.ed1daf0bf', 'Expected reference')
            data['exit.json']['forced'] = False
            data['ready.json']['client_size'] = [1440, 900]
            write()
            with self.assertRaisesRegex(ValueError, 'window layout'):
                inspect_run(output, 1, '4.7.2.stable.official.ed1daf0bf', 'Expected reference')
            data['ready.json']['client_size'] = [1300, 800]
            data['progress.json']['completed'] = []
            write()
            with self.assertRaisesRegex(ValueError, 'progress is incomplete'):
                inspect_run(output, 1, '4.7.2.stable.official.ed1daf0bf', 'Expected reference')


if __name__ == '__main__':
    unittest.main()
