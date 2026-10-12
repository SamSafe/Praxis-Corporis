"""Content ingestion checks against corrupt files and unintended source inclusions."""

import hashlib
import json
import pathlib
import struct
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from fetch_assets import fetch, verified
from glb_inventory import descendants, read_glb


class ContentToolsTests(unittest.TestCase):
    def test_reject_truncation_and_external_buffers(self):
        with tempfile.TemporaryDirectory() as folder:
            path = pathlib.Path(folder) / "sample.glb"
            path.write_bytes(b"glTF")
            with self.assertRaises(ValueError):
                read_glb(path)
            payload = json.dumps({"asset": {"version": "2.0"}, "buffers": [{"uri": "remote.bin"}]}).encode()
            payload += b" " * (-len(payload) % 4)
            path.write_bytes(struct.pack("<4sIIII", b"glTF", 2, 20 + len(payload), len(payload), 0x4E4F534A) + payload)
            with self.assertRaisesRegex(ValueError, "external"):
                read_glb(path)
            path.write_bytes(path.read_bytes()[:-4])
            with self.assertRaises(ValueError):
                read_glb(path)

    def test_cycle_and_out_of_range_node_rejected(self):
        for document in [{"nodes": [{"children": [0]}]}, {"nodes": [{"children": [5]}]}]:
            with self.assertRaises(ValueError):
                descendants(document, 0)

    def test_asset_check_detects_modification_and_prevents_path_escape(self):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            path = root / "asset.glb"
            path.write_bytes(b"expected")
            record = {"bytes": 8, "sha256": hashlib.sha256(b"expected").hexdigest(), "local_path": "asset.glb"}
            self.assertTrue(verified(path, record))
            path.write_bytes(b"modified")
            self.assertFalse(verified(path, record))
            record["local_path"] = "../outside.glb"
            with self.assertRaisesRegex(ValueError, "inside"):
                fetch(record, root)

    def test_both_catalogues_have_valid_mapping_and_no_extraction_sites(self):
        pack = json.loads((ROOT / "content/sample_pack.json").read_text())
        self.assertEqual({body["id"] for body in pack["bodies"]}, {"male", "female"})
        for body in pack["bodies"]:
            records = body["structures"]
            by_id = {record["id"]: record for record in records}
            self.assertEqual(len(by_id), len(records))
            self.assertTrue({"anatomy.body", "anatomy.skin", "anatomy.heart", "anatomy.lungs"} <= by_id.keys())
            for record in records:
                self.assertNotIn("extraction", record["source_name"].lower())
                self.assertEqual(record["review_status"], "draft")
                for child in record["children"]:
                    self.assertEqual(by_id[child]["parent"], record["id"])
                    self.assertTrue(set(by_id[child]["mesh_nodes"]) <= set(record["mesh_nodes"]))
            # Shared group visibility must refer to the same physical mesh IDs.
            self.assertTrue(set(by_id["anatomy.heart.valve.mitral"]["mesh_nodes"]) <= set(by_id["anatomy.heart"]["mesh_nodes"]))

    def test_coverage_notes_match_every_source_system_and_reference(self):
        pack = json.loads((ROOT / "content/sample_pack.json").read_text())
        notes = json.loads((ROOT / "content/coverage_notes.json").read_text())
        self.assertEqual(notes["pack_id"], pack["id"])
        self.assertEqual(notes["source_commit"], pack["source_commit"])
        self.assertEqual(notes["review_status"], "technical_inventory")
        self.assertEqual(len({entry["id"] for entry in notes["systems"]}), len(notes["systems"]))
        for body in pack["bodies"]:
            by_id = {record["id"]: record for record in body["structures"]}
            mapped = {entry["roots"][body["id"]] for entry in notes["systems"] if entry["roots"][body["id"]]}
            self.assertEqual(mapped, set(by_id[body["root_id"]]["children"]))
            for entry in notes["systems"]:
                self.assertEqual(set(entry["roots"]), {"female", "male"})
                self.assertTrue(entry["supplied"][body["id"]].strip())
                self.assertTrue(entry["gaps"].strip())
                if entry["roots"][body["id"]]:
                    self.assertTrue(by_id[entry["roots"][body["id"]]]["mesh_nodes"])


if __name__ == "__main__":
    unittest.main()
