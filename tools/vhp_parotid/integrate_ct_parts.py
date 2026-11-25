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
    # Third round
    "levator-scapulae": "Levator scapulae muscles", "infrahyoid-muscles": "Infrahyoid muscles",
    "prevertebral-muscles": "Prevertebral muscles", "digastric": "Digastric muscles", "soft-palate": None, "teeth": "Teeth",
    "internal-jugular-veins": "Internal jugular veins", "right-neck-arteries": "Right common carotid and subclavian arteries",
    # Fourth round
    "intervertebral-discs": "Intervertebral discs",
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
    # Third round
    "anatomy.sternocleidomastoid": ["sternocleidomastoid_L", "sternocleidomastoid_R"],
    "anatomy.levator-scapulae": ["levator_scapulae"], "anatomy.infrahyoid-muscles": ["infrahyoid_muscles"],
    "anatomy.prevertebral-muscles": ["prevertebral_muscles"], "anatomy.digastric": ["digastric"],
    "anatomy.soft-palate": ["soft_palate"], "anatomy.teeth": ["teeth"],
    "anatomy.internal-jugular-veins": ["internal_jugular_veins"],
    "anatomy.carotid-arteries": ["right_common_carotid_artery"], "anatomy.subclavian-arteries": ["right_subclavian_artery"],
    # Fourth round
    "anatomy.intervertebral-disks": ["intervertebral_discs"],
}
# TotalSegmentator task each group was traced with (all free tasks); "total" otherwise.
TASK = {"submandibular-glands": "head_glands_cavities", "tongue": "head_muscles", "muscles-of-mastication": "head_muscles",
        "mandible": "craniofacial_structures", "neck-muscles": "headneck_muscles", "pharyngeal-constrictors": "headneck_muscles",
        "hyoid": "headneck_bones_vessels", "chest-and-back-muscles": "abdominal_muscles",
        "abdominal-wall-muscles": "abdominal_muscles", "quadratus-lumborum": "abdominal_muscles",
        "diaphragm": "trunk_cavities (the sheet between the thoracic and abdominal cavities)",
        "levator-scapulae": "headneck_muscles", "infrahyoid-muscles": "headneck_muscles", "prevertebral-muscles": "headneck_muscles",
        "digastric": "head_muscles", "soft-palate": "head_glands_cavities", "teeth": "craniofacial_structures",
        "internal-jugular-veins": "headneck_bones_vessels", "intervertebral-discs": "vertebrae_body"}
FIT = {"shoulder-girdle": "thorax fit refined per side by the skin around the shoulder",
       "humeri": "thorax fit refined per side by the skin around the shoulder"}
# Groups where some parts carry their own skin refit (skin_fit.py); the group record
# names it so the derivation stays accurate.
REFIT = "; some parts refitted by the skin around them (tools/vhp_parotid/skin_fit.py)"
SOURCE = {"female": "Visible Human female normal CT (NLM), traced; tools/vhp_parotid",
          "male": "Visible Human male normal CT (NLM), traced; tools/vhp_parotid"}


def register(parts: pathlib.Path) -> None:
    manifest_path = ROOT / "content/hra_supplements_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    (ROOT / "assets/vhp-ct").mkdir(exist_ok=True)
    (ROOT / "assets/vhp-ct/.gdignore").write_text("\n", encoding="utf-8", newline="\n")
    for body in manifest["bodies"]:
        b = body["body_id"]; X = "VH_M" if b == "male" else "VH_F"
        body["groups"] = [g for g in body["groups"] if "vhp-ct/" not in g["files"][0]["local_path"]]
        built = json.loads((parts / f"{b}-parts.json").read_text())
        for group, label in GROUPS.items():
            src = parts / f"{b}-{group}.glb"
            if not src.exists():
                continue
            dst = ROOT / "assets/vhp-ct" / src.name
            shutil.copyfile(src, dst)
            data = dst.read_bytes()
            record = {"source": SOURCE[b],
                      "license": "Derived from NLM Visible Human Project data under the NLM Terms and Conditions (acknowledge the National Library of Medicine)",
                      "derivation": f"TotalSegmentator 2.18.0 {TASK.get(group, 'total')} task (Apache-2.0); "
                                    f"{FIT.get(group, 'regional similarity fit to shared anatomy')}"
                                    f"{REFIT if group not in FIT and any('fit' in p for p in built.get(group.replace('-', '_'), {}).get('parts', [])) else ''}"
                                    "; see docs/audit/VHP_CT_PARTS.md",
                      "files": [{"local_path": dst.relative_to(ROOT).as_posix(), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}]}
            if label:
                record = {"node_name": f"{X}_{group.replace('-', '_')}", "label": label, **record}
            body["groups"].append(record)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")


def map_cards() -> None:
    """Point the cards at the traced parts, by catalogue record (a parent brings its children)."""
    pack = json.loads((ROOT / "content/sample_pack.json").read_text(encoding="utf-8"))
    path = ROOT / "content/study_content.json"
    content = json.loads(path.read_text(encoding="utf-8"))
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
    path.write_text(json.dumps(content, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    if sys.argv[1] == "--map":
        map_cards()
    else:
        register(pathlib.Path(sys.argv[1]))
