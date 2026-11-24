"""Register reviewed CT-traced parts with the supplement manifest and study cards.

usage: integrate_ct_parts.py PARTS_DIR
Copies each <body>-<group>.glb into assets/vhp-ct/, adds one supplement group per file
to content/hra_supplements_manifest.json, and maps the existing study cards to the new
parts on the female and male bodies. Run tools/build_hra_supplements.py and
tools/build_sample_pack.py afterwards; card mappings are written with the node names
and resolved to catalogue IDs by the second pass (--map).
"""
import hashlib, json, pathlib, shutil, sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
GROUPS = {  # group -> label for the parent node of a multi-part group, or None
    "stomach": None, "esophagus": None, "thyroid-gland": None,
    "adrenal-glands": "Adrenal glands", "ribs": "Ribs and costal cartilages", "sternum": None,
    "gluteal-muscles": "Gluteal muscles", "iliopsoas": "Iliopsoas muscles", "deep-back-muscles": "Deep back muscles",
    # Second round
    "submandibular-glands": "Submandibular glands", "tongue": None,
    "muscles-of-mastication": "Muscles of mastication", "mandible": None,
    "neck-muscles": "Neck muscles", "pharyngeal-constrictors": "Pharyngeal constrictor muscles", "hyoid": None,
    "chest-and-back-muscles": "Chest and back muscles", "abdominal-wall-muscles": "Abdominal wall muscles",
    "quadratus-lumborum": "Quadratus lumborum muscles", "diaphragm": None,
    "shoulder-girdle": "Shoulder girdle", "humeri": "Upper-arm bones",
}
# card -> traced nodes it covers (without the VH_F_/VH_M_ prefix); a group's parent node
# brings its parts with it, so selecting one side opens the same card.
CARDS = {
    "anatomy.stomach": ["stomach"], "anatomy.esophagus": ["esophagus"], "anatomy.thyroid": ["thyroid_gland"],
    "anatomy.adrenal-glands": ["adrenal_glands"], "anatomy.ribs": ["ribs"], "anatomy.sternum": ["sternum"],
    "anatomy.gluteus-maximus": ["gluteus_maximus_L", "gluteus_maximus_R"],
    "anatomy.gluteus-medius": ["gluteus_medius_L", "gluteus_medius_R"],
    "anatomy.gluteus-minimus": ["gluteus_minimus_L", "gluteus_minimus_R"],
    "anatomy.iliopsoas": ["iliopsoas"], "anatomy.deep-back-muscles": ["deep_back_muscles"],
    "anatomy.salivary-glands": ["submandibular_glands"], "anatomy.tongue": ["tongue"],
    "anatomy.muscles-of-mastication": ["muscles_of_mastication"], "anatomy.mandible": ["mandible"],
    "anatomy.scalenes": [f"{m}_scalene_{s}" for m in ("anterior", "middle", "posterior") for s in "LR"],
    "anatomy.pharynx-muscles": ["pharyngeal_constrictors"], "anatomy.hyoid": ["hyoid_bone"],
    "anatomy.pectoralis-major": ["pectoralis_major_L", "pectoralis_major_R"],
    "anatomy.serratus-anterior": ["serratus_anterior_L", "serratus_anterior_R"],
    "anatomy.latissimus-dorsi": ["latissimus_dorsi_L", "latissimus_dorsi_R"],
    "anatomy.trapezius": ["trapezius_L", "trapezius_R"],
    "anatomy.rectus-abdominis": ["rectus_abdominis_L", "rectus_abdominis_R"],
    "anatomy.abdominal-obliques": [f"{m}_oblique_{s}" for m in ("external", "internal") for s in "LR"],
    "anatomy.quadratus-lumborum": ["quadratus_lumborum"], "anatomy.diaphragm": ["diaphragm"],
    "anatomy.scapulae": ["scapula_L", "scapula_R"], "anatomy.clavicles": ["clavicle_L", "clavicle_R"],
    "anatomy.humerus": ["humeri"],
}
SOURCE = {"female": "Visible Human female normal CT (NLM), traced; tools/vhp_parotid",
          "male": "Visible Human male normal CT (NLM), traced; tools/vhp_parotid"}


def register(parts: pathlib.Path) -> None:
    manifest_path = ROOT / "content/hra_supplements_manifest.json"
    manifest = json.loads(manifest_path.read_text())
    (ROOT / "assets/vhp-ct").mkdir(exist_ok=True)
    (ROOT / "assets/vhp-ct/.gdignore").write_text("\n")
    for body in manifest["bodies"]:
        b = body["body_id"]; X = "VH_M" if b == "male" else "VH_F"
        body["groups"] = [g for g in body["groups"] if "vhp-ct/" not in g["files"][0]["local_path"]]
        for group, label in GROUPS.items():
            src = parts / f"{b}-{group}.glb"
            if not src.exists():
                continue
            dst = ROOT / "assets/vhp-ct" / src.name
            shutil.copyfile(src, dst)
            data = dst.read_bytes()
            record = {"source": SOURCE[b],
                      "license": "Derived from NLM Visible Human Project data under the NLM Terms and Conditions (acknowledge the National Library of Medicine)",
                      "derivation": "TotalSegmentator 2.18.0 total task (Apache-2.0); regional similarity fit to shared anatomy; see docs/audit/VHP_CT_PARTS.md",
                      "files": [{"local_path": str(dst.relative_to(ROOT)), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}]}
            if label:
                record = {"node_name": f"{X}_{group.replace('-', '_')}", "label": label, **record}
            body["groups"].append(record)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")


def map_cards() -> None:
    """Point the cards at the traced parts, by catalogue record (a parent brings its children)."""
    pack = json.loads((ROOT / "content/sample_pack.json").read_text())
    path = ROOT / "content/study_content.json"
    content = json.loads(path.read_text())
    for b in pack["bodies"]:
        if b["id"] not in ("female", "male"):
            continue
        X = "VH_M" if b["id"] == "male" else "VH_F"
        by_name = {s["source_name"]: s for s in b["structures"]}; by_id = {s["id"]: s for s in b["structures"]}
        for card, nodes in CARDS.items():
            found = []
            def add(s):
                if s not in found:
                    found.append(s)
                    for child in s.get("children", []):
                        add(by_id[child])
            for n in nodes:
                if f"{X}_{n}" in by_name:
                    add(by_name[f"{X}_{n}"])
            if not found:
                continue  # leave any mapping to the body's own anatomy (e.g. the male hyoid)
            mapping = [{"id": s["id"], "source_name": s["source_name"], "ontology": s["ontology"]} for s in found]
            content["cards"][card].setdefault("geometry", {})[b["id"]] = mapping[0] if len(mapping) == 1 else mapping
    path.write_text(json.dumps(content, indent=2, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    if sys.argv[1] == "--map":
        map_cards()
    else:
        register(pathlib.Path(sys.argv[1]))
