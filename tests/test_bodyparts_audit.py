import io
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "tools"))
from audit_bodyparts import obj_inventory
from build_bone_study import read_geometry


class BodyPartsAuditTests(unittest.TestCase):
    def test_indices_and_units_evidence_are_preserved(self):
        data = b"# Concept ID : FMA1\n# Bounds(mm): test\nv 0 0 0\nv 1 0 0\nv 1 1 0\nv 0 1 0\nf -4 -3 -2 -1\n"
        result = obj_inventory(io.BytesIO(data))
        self.assertEqual(result["triangles"], 2)
        self.assertEqual(result["headers"]["Concept ID"], "FMA1")
        self.assertEqual(result["maximum_mm"], [1.0, 1.0, 0.0])

    def test_invalid_faces_and_nonfinite_coordinates_are_rejected(self):
        for data in [b"v NaN 0 0\nf 1 1 1", b"v 0 0 0\nf 1 2 3", b"v 0 0 0\nf 0 1 1"]:
            with self.assertRaises(ValueError):
                obj_inventory(io.BytesIO(data))

    def test_conversion_preserves_source_normals_and_declared_units(self):
        data = b"# Bounds(mm): source\nv 1000 2000 3000\nv 2000 2000 3000\nv 1000 3000 3000\nvn 0 0 1\nf 1//1 2//1 3//1\n"
        headers, vertices, normals, indices = read_geometry(io.BytesIO(data))
        self.assertEqual(vertices[0], (1.0, 3.0, -2.0))
        self.assertEqual(normals[0], (0.0, 1.0, -0.0))
        self.assertEqual(indices, [0, 1, 2])
        self.assertIn("Bounds(mm)", headers)

    def test_conversion_rejects_unestablished_units_or_normals(self):
        for data in [b"v 0 0 0\nv 1 0 0\nv 0 1 0\nf 1 2 3\n", b"# Bounds(mm): source\nv 0 0 0\nv 1 0 0\nv 0 1 0\nf 1 2 3\n"]:
            with self.assertRaises(ValueError):
                read_geometry(io.BytesIO(data))
