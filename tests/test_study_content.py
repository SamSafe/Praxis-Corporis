"""Keep authored explanations and supplemental source identities tied to real records."""

import copy
import json
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from build_spinal_studies import build


def is_government_source(url):
    return url.startswith(("https://www.nhlbi.nih.gov/", "https://www.ncbi.nlm.nih.gov/", "https://www.niddk.nih.gov/",
                           "https://www.nichd.nih.gov/", "https://training.seer.cancer.gov/", "https://www.nei.nih.gov/",
                           "https://www.niams.nih.gov/", "https://medlineplus.gov/", "https://www.cancer.gov/"))


def mapping_list(value):
    """Mirror study_content.gd: one body maps a single structure or a list of them."""
    return value if isinstance(value, list) else [value]


def resolve(content, identity, available):
    """Mirror study_content.gd: shared IDs, then explicit card geometry checked against the source."""
    if identity in available:
        return identity
    for value in content["cards"].get(identity, {}).get("geometry", {}).values():
        for mapping in mapping_list(value):
            source = available.get(mapping["id"])
            if source and source["source_name"] == mapping["source_name"] and source["ontology"] == mapping["ontology"]:
                return mapping["id"]
    return ""


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
        self.assertEqual(len(content["conditions"]), 66)
        for body in catalogue["bodies"]:
            available = {s["id"]: s for s in body["structures"]}
            offered = set()
            for identity, condition in content["conditions"].items():
                self.assertEqual(condition["geometry_mode"], "reference_location_only")
                self.assertEqual(condition["review_status"], "draft")
                self.assertEqual(condition["human_source_review"], "pending")
                self.assertEqual(condition["expert_review"], "pending")
                self.assertTrue(condition["not_depicted"].endswith("not depicted."))
                self.assertIn(condition["focus_id"], condition["related_anatomy"])
                self.assertTrue(condition["source_ids"])
                for source in condition["source_ids"]:
                    self.assertTrue(is_government_source(content["sources"][source]["url"]))
                for anatomy in condition["display_on"]:
                    self.assertTrue(anatomy in available or anatomy in content["cards"], anatomy)
                if all(resolve(content, anatomy, available) for anatomy in condition["related_anatomy"]):
                    offered.add(identity)
            # Each adult reference offers the 58 shared conditions plus its own
            # sex-specific ones (6 female, 2 male); none is inferred from missing anatomy.
            self.assertEqual(len(offered), 64 if body["id"] == "female" else 60)
            self.assertEqual("condition.bph" in offered, body["id"] == "male")
            self.assertEqual("condition.endometriosis" in offered, body["id"] == "female")

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

    def test_cards_and_relationships_map_to_supplied_geometry(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        catalogue = json.loads((ROOT / "content/sample_pack.json").read_text())
        self.assertEqual(content["expert_review"], "pending")
        self.assertEqual(len(content["cards"]), 125)
        mapped = {}
        for identity, card in content["cards"].items():
            self.assertEqual(card["review_status"], "draft")
            self.assertEqual(card["human_source_review"], "pending")
            self.assertEqual(card["expert_review"], "pending")
            self.assertTrue(card["source_ids"])
            for source in card["source_ids"]:
                self.assertTrue(is_government_source(content["sources"][source]["url"]))
            for mapping in [m for value in card.get("geometry", {}).values() for m in mapping_list(value)]:
                self.assertNotIn(mapping["id"], mapped, "one structure carries one card")
                self.assertNotIn(mapping["id"], content["cards"])
                mapped[mapping["id"]] = identity
        for body in catalogue["bodies"]:
            available = {s["id"]: s for s in body["structures"]}
            for identity, card in content["cards"].items():
                if "geometry" not in card:
                    self.assertIn(identity, available)
                elif body["id"] not in card["geometry"]:
                    continue
                else:
                    for mapping in mapping_list(card["geometry"][body["id"]]):
                        source = available[mapping["id"]]
                        self.assertEqual(mapping["source_name"], source["source_name"])
                        self.assertEqual(mapping["ontology"], source["ontology"])
                        self.assertTrue(source["mesh_nodes"], identity)
                for related in card["related"]:
                    related_card = content["cards"].get(related, {})
                    sex_specific = "geometry" in related_card and body["id"] not in related_card["geometry"]
                    self.assertTrue(resolve(content, related, available) or sex_specific, related)

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
