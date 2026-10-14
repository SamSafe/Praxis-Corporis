"""Reject unsupported source directions without needing downloaded anatomy."""
import hashlib
import json
import pathlib
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / 'tools'))
from audit_orientation import audit_reference


def fixture(folder, flip_axis=None, transformed=False):
    landmarks = [('Left femur', [0.09, 0.6, 0.08]), ('Right femur', [-0.09, 0.6, 0.08]),
                 ('Left patella', [0.08, 0.38, 0.11]), ('Right patella', [-0.08, 0.38, 0.11]),
                 ('Frontal bone', [0, 1.57, 0.14]), ('Occipital bone', [0, 1.53, 0.04])]
    document = {'asset': {'version': '2.0'}, 'nodes': [], 'meshes': [], 'accessors': [], 'bufferViews': []}
    binary, records = bytearray(), []
    for index, (label, point) in enumerate(landmarks):
        if flip_axis is not None:
            point[flip_axis] *= -1
        start = len(binary)
        for sign in [-1, 1]:
            binary.extend(struct.pack('<3f', *[value + sign * 0.001 for value in point]))
        document['nodes'].append({'mesh': index})
        document['meshes'].append({'primitives': [{'attributes': {'POSITION': index}}]})
        # Deliberately wrong authored bounds: the audit must read actual positions.
        document['accessors'].append({'bufferView': index, 'componentType': 5126, 'type': 'VEC3', 'count': 2, 'min': [0, 0, 0], 'max': [0, 0, 0]})
        document['bufferViews'].append({'buffer': 0, 'byteOffset': start, 'byteLength': 24})
        records.append({'id': str(index), 'label': label, 'source_name': 'fixture-' + str(index), 'mesh_nodes': [index]})
    if transformed:
        document['nodes'][0]['translation'] = [0, 0, 0]
    document['buffers'] = [{'byteLength': len(binary)}]
    encoded = json.dumps(document).encode()
    encoded += b' ' * (-len(encoded) % 4)
    data = struct.pack('<4sII', b'glTF', 2, 28 + len(encoded) + len(binary))
    data += struct.pack('<II', len(encoded), 0x4E4F534A) + encoded
    data += struct.pack('<II', len(binary), 0x004E4942) + binary
    path = folder / 'fixture.glb'
    path.write_bytes(data)
    return {'id': 'fixture', 'study': True, 'asset_path': path.name, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest(), 'structures': records}


class OrientationAuditTests(unittest.TestCase):
    def test_measurements_use_real_positions_and_exact_source_identity(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            reference = fixture(root)
            report = audit_reference(reference, root)
            self.assertEqual(len(report['checks']), 5)
            self.assertAlmostEqual(report['landmarks']['0']['center_metres'][0], 0.09, places=6)
            reference['sha256'] = '0' * 64
            with self.assertRaisesRegex(ValueError, 'fingerprint'):
                audit_reference(reference, root)

    def test_mirrors_and_unaccounted_transforms_cannot_support_named_views(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            for axis in [0, 2]:
                with self.subTest(axis=axis), self.assertRaisesRegex(ValueError, 'contradicts'):
                    audit_reference(fixture(root, flip_axis=axis), root)
            with self.assertRaisesRegex(ValueError, 'transformed'):
                audit_reference(fixture(root, transformed=True), root)

    def test_missing_or_ambiguous_landmarks_fail_instead_of_guessing(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            reference = fixture(root)
            reference['structures'][0]['label'] = 'Unknown'
            with self.assertRaisesRegex(ValueError, 'source identity'):
                audit_reference(reference, root)
            reference = fixture(root)
            reference['structures'].append(reference['structures'][0])
            with self.assertRaisesRegex(ValueError, 'source identity'):
                audit_reference(reference, root)


if __name__ == '__main__':
    unittest.main()
