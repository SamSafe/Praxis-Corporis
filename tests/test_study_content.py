"""Keep authored explanations and supplemental source identities tied to real records."""

import copy
import json
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from build_spinal_studies import build


# NINDS, NIA and NIDCR were added at the user's request on 2026-11-25 (revision 16).
def is_government_source(url):
    return url.startswith(("https://www.nhlbi.nih.gov/", "https://www.ncbi.nlm.nih.gov/", "https://www.niddk.nih.gov/",
                           "https://www.nichd.nih.gov/", "https://training.seer.cancer.gov/", "https://www.nei.nih.gov/",
                           "https://www.niams.nih.gov/", "https://medlineplus.gov/", "https://www.cancer.gov/",
                           "https://www.cdc.gov/", "https://www.ninds.nih.gov/", "https://www.nia.nih.gov/",
                           "https://www.nidcr.nih.gov/"))


# Non-government anatomy references the user approved on 2026-11-21 for parts that have no
# fetchable government page. Every condition still cites at least one government source.
APPROVED_REFERENCES = ("https://teachmeanatomy.info/",)


def is_approved_source(url):
    return is_government_source(url) or url.startswith(APPROVED_REFERENCES)


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
        self.assertEqual(len(content["conditions"]), 173)
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
                urls = [content["sources"][source]["url"] for source in condition["source_ids"]]
                self.assertTrue(all(is_approved_source(url) for url in urls))
                self.assertTrue(any(is_government_source(url) for url in urls), identity)
                for anatomy in condition["display_on"]:
                    self.assertTrue(anatomy in available or anatomy in content["cards"], anatomy)
                # Anatomy no source models is text only, so its conditions stay readable.
                if all(resolve(content, anatomy, available) or "not_modelled" in content["cards"].get(anatomy, {})
                       for anatomy in condition["related_anatomy"]):
                    offered.add(identity)
            # Each adult reference offers the 71 shared conditions, the 8 about unmodelled
            # anatomy, the 12 its CT-traced stomach, oesophagus, thyroid and adrenal glands
            # support, the 3 its traced diaphragm, tongue and jaw support (hiatal hernia,
            # hiccups, oral cancer), plus those its own supplied anatomy supports (13 female
            # with the traced shoulder and submandibular glands, 6 male), tooth decay on both
            # (traced teeth, revision 14) and carotid artery disease on the female (traced
            # right common carotid), herniated disk on both (traced intervertebral discs,
            # revision 15), and the 31 conditions of revision 16 (30 on the male body: pelvic
            # inflammatory disease needs the female organs; three are about the unmodelled ears
            # and sinuses), and 15 of the 16 conditions of revision 17 (plantar fasciitis needs
            # the foot bones, which only the complete male body has); none is inferred from
            # missing anatomy.
            self.assertEqual(len(offered), 156 if body["id"] == "female" else 147)
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
        self.assertEqual(len(content["cards"]), 247)
        mapped = {}
        for identity, card in content["cards"].items():
            self.assertEqual(card["review_status"], "draft")
            self.assertEqual(card["human_source_review"], "pending")
            self.assertEqual(card["expert_review"], "pending")
            self.assertTrue(card["source_ids"])
            for source in card["source_ids"]:
                self.assertTrue(is_approved_source(content["sources"][source]["url"]))
            for mapping in [m for value in card.get("geometry", {}).values() for m in mapping_list(value)]:
                self.assertNotIn(mapping["id"], mapped, "one structure carries one card")
                self.assertNotIn(mapping["id"], content["cards"])
                mapped[mapping["id"]] = identity
        complete = {s["id"] for s in json.loads((ROOT / "content/bodyparts3d_complete_body.json").read_text())["structures"]}
        for body in catalogue["bodies"]:
            available = {s["id"]: s for s in body["structures"]}
            for identity, card in content["cards"].items():
                if "not_modelled" in card and body["id"] not in card.get("geometry", {}):
                    continue
                if "geometry" not in card:
                    # Shared IDs name the structure directly; some exist only in the
                    # complete BodyParts3D body (for example the stomach).
                    if identity not in available:
                        self.assertIn(identity, complete)
                        continue
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
                    # Shared IDs present only in the complete BodyParts3D body (the skull).
                    complete_only = "geometry" not in related_card and related not in available and related in complete
                    self.assertTrue(resolve(content, related, available) or sex_specific or complete_only, related)

    def test_unmodelled_structures_have_text_only_and_nearby_anatomy(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        cards = content["cards"]
        unmodelled = {k: c for k, c in cards.items() if "not_modelled" in c}
        self.assertEqual(sorted(unmodelled), ["anatomy.adenoids", "anatomy.ear", "anatomy.lingual-tonsils", "anatomy.parotid-glands", "anatomy.scrotum", "anatomy.sinuses", "anatomy.vulva"])
        for identity, card in unmodelled.items():
            # The parotid glands have geometry traced from the Visible Human CT for the two
            # bodies made from those donors; the complete body keeps the text-only card. The
            # ears are shown only on the complete body, whose source has the outer ears
            # (revision 17). Every other card is text-only on every body.
            expected = {"anatomy.parotid-glands": {"female", "male"}, "anatomy.ear": {"bodyparts-male-complete"}}
            self.assertEqual(set(card.get("geometry", {})), expected.get(identity, set()), identity)
            self.assertTrue(card["not_modelled"]["title"] and card["not_modelled"]["note"])
            self.assertTrue(any(is_government_source(content["sources"][s]["url"]) for s in card["source_ids"]), identity)
            for near in card["not_modelled"]["near"]:
                self.assertIn(near, cards)
                self.assertNotIn("not_modelled", cards[near])
        for identity, condition in content["conditions"].items():
            if condition["focus_id"] in unmodelled:
                self.assertEqual(condition["related_anatomy"], [condition["focus_id"]], identity)

    def test_complete_body_mappings_match_its_catalogue(self):
        content = json.loads((ROOT / "content/study_content.json").read_text())
        body = json.loads((ROOT / "content/bodyparts3d_complete_body.json").read_text())
        available = {s["id"]: s for s in body["structures"]}
        self.assertEqual(body["study_kind"], "bodyparts3d-complete")
        self.assertIn("No registration", body["coverage_notes"]["notice"].replace("no registration", "No registration"))
        for record in available.values():
            self.assertTrue(set(record["children"]) <= available.keys())
            self.assertTrue(record["mesh_nodes"])
        on_body = 0
        for identity, card in content["cards"].items():
            if identity in available:
                on_body += 1
                continue
            if body["id"] not in card.get("geometry", {}):
                continue
            on_body += 1
            for mapping in mapping_list(card["geometry"][body["id"]]):
                source = available[mapping["id"]]
                self.assertEqual(mapping["source_name"], source["source_name"])
                self.assertEqual(mapping["ontology"], source["ontology"])
                self.assertNotIn(mapping["id"], content["cards"])
        # Cards whose anatomy the complete male source supplies (no female or
        # source-absent parts); see docs/BODY_STUDY_CONTENT.md.
        self.assertEqual(on_body, 159)

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
