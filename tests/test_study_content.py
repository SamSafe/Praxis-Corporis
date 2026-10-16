"""Keep authored explanations and supplemental source identities tied to real records."""

import copy
import json
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from build_spinal_studies import build


class StudyContentTests(unittest.TestCase):
    def test_assistant_source_checks_do_not_promote_human_review(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        records = [content, *content["cards"].values(), *content["routes"].values(), *content["conditions"].values()]
        for record in records:
            self.assertEqual(record["review_status"], "draft")
            self.assertEqual(record["human_source_review"], "pending")
            self.assertEqual(record["expert_review"], "pending")
        self.assertNotIn("source_checked_on", content)
        self.assertEqual(content["assistant_checks"]["actor"], "assistant")
        self.assertTrue(set(content["assistant_checks"]["source_ids"]) <= content["sources"].keys())

    def test_conditions_are_sourced_reference_locations_with_explicit_associations(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        catalogue = json.loads((ROOT / "content/sample_pack.json").read_text())
        self.assertEqual(set(content["conditions"]), {"condition.aortic-stenosis", "condition.mitral-regurgitation"})
        for body in catalogue["bodies"]:
            available = {s["id"] for s in body["structures"]}
            for condition in content["conditions"].values():
                self.assertEqual(condition["geometry_mode"], "reference_location_only")
                self.assertEqual(condition["review_status"], "draft")
                self.assertEqual(condition["human_source_review"], "pending")
                self.assertEqual(condition["expert_review"], "pending")
                self.assertIn(condition["focus_id"], condition["related_anatomy"])
                self.assertTrue(set(condition["related_anatomy"]) <= available)
                self.assertTrue(set(condition["display_on"]) <= available)
                self.assertTrue(condition["source_ids"])
                for source in condition["source_ids"]:
                    self.assertTrue(content["sources"][source]["url"].startswith("https://www.nhlbi.nih.gov/"))

    def test_circulation_route_has_explicit_source_mappings_and_coverage_gaps(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        route = content["routes"]["heart-lung"]
        self.assertEqual(route["expert_review"], "pending")
        self.assertEqual(route["nodes"]["pulmonary-trunk"]["next"], ["left-artery", "right-artery"])
        self.assertEqual(route["nodes"]["systemic-gap"]["next"], ["vena-cava"])
        bodies = json.loads((ROOT / "content/sample_pack.json").read_text())["bodies"]
        for body in bodies:
            available = {s["id"]: s for s in body["structures"]}
            for key, node in route["nodes"].items():
                mapping = node["geometry"][body["id"]]
                source = available[mapping["id"]]
                self.assertEqual(mapping["source_name"], source["source_name"])
                self.assertEqual(mapping["ontology"], source["ontology"])
                self.assertTrue(source["mesh_nodes"], key)
                self.assertTrue(set(node["source_ids"]) <= content["sources"].keys())
                self.assertTrue(set(node["next"]) <= route["nodes"].keys())
                if key.endswith("exchange") or key == "systemic-gap":
                    self.assertEqual(node["coverage"], "context_only")
                    self.assertTrue(node["gap"])
        # No rendered path or anatomical channel is inferred from this graph.
        self.assertIn("conceptual", route["scope"])

    def test_chest_cards_and_relationships_exist_in_both_bodies(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        catalogue = json.loads((ROOT / "content/sample_pack.json").read_text())
        self.assertEqual(content["expert_review"], "pending")
        self.assertEqual(len(content["cards"]), 15)
        for body in catalogue["bodies"]:
            available = {s["id"] for s in body["structures"]}
            for identity, card in content["cards"].items():
                self.assertIn(identity, available)
                self.assertTrue(set(card["related"]) <= available)
                self.assertEqual(card["review_status"], "draft")
                self.assertEqual(card["human_source_review"], "pending")
                self.assertEqual(card["expert_review"], "pending")
                self.assertTrue(card["source_ids"])
                for source in card["source_ids"]:
                    self.assertTrue(content["sources"][source]["url"].startswith("https://www.nhlbi.nih.gov/"))

    def test_spinal_studies_preserve_ambiguous_source_identity(self):
        studies = json.loads((ROOT / "content/spinal_studies.json").read_text())["bodies"]
        self.assertEqual(len(studies), 4)
        gaps = []
        for study in studies:
            available = {s["id"]: s for s in study["structures"]}
            self.assertIn(study["qa_leaf_id"], available)
            self.assertEqual(study["study_kind"], "hra-spinal")
            self.assertIn("No registration", study["coverage"])
            self.assertEqual(study["coverage_notes"]["reference_ids"], [study["id"]])
            for record in available.values():
                self.assertTrue(set(record["children"]) <= available.keys())
                self.assertEqual(record["review_status"], "draft")
                if record["metadata_gap"]:
                    gaps.append(record)
        self.assertEqual(len(gaps), 1)
        self.assertEqual(gaps[0]["source_name"], "VH_F_lumbar_vertebra_6")
        self.assertEqual(gaps[0]["ontology"], "-")
        self.assertEqual(gaps[0]["label"], "Unlabelled source: VH_F_lumbar_vertebra_6")

    @unittest.skipUnless((ROOT / "assets/hra-spinal/VH_F_Vertebrae.glb").exists(), "Pinned spinal download required")
    def test_spinal_catalogue_is_reproducible_and_modified_sources_fail(self):
        manifest = json.loads((ROOT / "content/spinal_source_manifest.json").read_text())
        studies = json.loads((ROOT / "content/spinal_studies.json").read_text())["bodies"]
        for source, expected in zip(manifest["files"], studies):
            self.assertEqual(build(source), expected)
        modified = copy.deepcopy(manifest["files"][0])
        modified["sha256"] = "0" * 64
        with self.assertRaisesRegex(ValueError, "pinned source"):
            build(modified)
