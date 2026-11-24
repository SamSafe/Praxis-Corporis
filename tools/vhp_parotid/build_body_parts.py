"""Fit, mesh and check the CT-traced parts for one HRA body.

usage: build_body_parts.py female|male WORK_DIR OUT_DIR [SKIP,...]
SKIP names groups or traced masks to leave out after review (for example parts that
fall outside the skin, or a muscle cut off at the end of the scan's first pass).

Expects WORK_DIR/seg-<body>/merged (merged TotalSegmentator masks),
WORK_DIR/seg-<body>/glands (head task, for the eyes), WORK_DIR/<body>-anchors.npz
(anchor vertices from the body, see landmarks.py) and WORK_DIR/<body>-fit.json (the
eyes + cervical spine fit made for the parotid glands, reused for the skull).

Each region is placed by its own similarity fit to nearby anchors that exist in both
the CT and the body. Vertebrae are paired by position after an initial fit rather than
by label, because the female body has six lumbar vertebrae.
"""
import json, pathlib, subprocess, sys
import numpy as np, nibabel as nib

body, work, out = sys.argv[1], pathlib.Path(sys.argv[2]).resolve(), pathlib.Path(sys.argv[3]).resolve()
skip = set(sys.argv[4].split(",")) if len(sys.argv) > 4 else set()
X = "VH_M" if body == "male" else "VH_F"
tools = pathlib.Path(__file__).resolve().parent
py = sys.executable
merged = work / f"seg-{body}" / "merged"
anchors = work / f"{body}-anchors.npz"
out.mkdir(parents=True, exist_ok=True)
for eye in ("eye_left", "eye_right"):
    link = merged / f"{eye}.nii.gz"
    if link.is_symlink() and not link.exists():
        link.unlink()  # a broken link from an earlier run
    if not link.exists():
        link.symlink_to(work / f"seg-{body}" / "glands" / f"{eye}.nii.gz")
tgt = dict(np.load(anchors))
ribs = json.loads((work / "rib_ids.json").read_text())


def centroid(name):
    im = nib.load(merged / f"{name}.nii.gz"); d = np.asarray(im.dataobj) > 0
    c = nib.affines.apply_affine(im.affine, np.argwhere(d).mean(0))
    return np.array([-c[0], c[2], c[1]]) / 1000.0


def present(name, folder=None):
    p = (folder or merged) / f"{name}.nii.gz"
    return p.exists() and np.asarray(nib.load(p).dataobj).any()


def fit(name, pairs):
    pairs = [(c, t) for c, t in pairs if present(c) and t in tgt]
    result = subprocess.run([py, "-I", str(tools / "fit.py"), str(merged), str(anchors), str(work / f"{body}-fit-{name}.json")]
                            + [f"{c}={t}" for c, t in pairs], capture_output=True, text=True, check=True)
    print(f"[{name}] {len(pairs)} anchors\n" + result.stdout.strip())
    return work / f"{body}-fit-{name}.json"


def apply(fitfile, p):
    f = json.loads(pathlib.Path(fitfile).read_text())
    return (f["scale"] * (np.array(f["R"]) @ np.atleast_2d(p).T)).T + np.array(f["t"])


# Pair the traced vertebrae with the body's by position, after a fit on structures
# whose labels are unambiguous (thoracic vertebrae, lungs, heart).
lobes = ["lung_upper_lobe_left", "lung_lower_lobe_left", "lung_upper_lobe_right", "lung_middle_lobe_right", "lung_lower_lobe_right"]
initial = fit("initial", [(f"vertebrae_T{i}", f"T{i}") for i in range(1, 13)] + [(n, n) for n in lobes + ["heart"]])
body_vert = [k for k in tgt if k[0] in "CTL" and k[1:].isdigit()]
pairs_v = {}
for ct in [f"vertebrae_{p}{i}" for p, n in (("C", 7), ("T", 12), ("L", 5)) for i in range(1, n + 1)] + ["vertebrae_S1"]:
    if not present(ct):
        continue
    c = apply(initial, centroid(ct))[0]
    best = min(body_vert, key=lambda k: np.linalg.norm(tgt[k].mean(0) - c))
    if np.linalg.norm(tgt[best].mean(0) - c) < 0.015:
        pairs_v[ct] = best
print("vertebra pairing:", {k.split("_")[1]: v for k, v in pairs_v.items() if k.split("_")[1] != v})
V = lambda *names: [(c, t) for c, t in pairs_v.items() if t in names]

fits = {
    "skull": work / f"{body}-fit.json",  # eyes and cervical spine, from the parotid fit
    "thorax": fit("thorax", V("C6", "C7", *[f"T{i}" for i in range(1, 13)]) + [(n, n) for n in lobes + ["heart", "trachea"]]),
    "abdomen": fit("abdomen", V("T10", "T11", "T12", "L1", "L2", "L3") + [(n, n) for n in ("liver", "spleen", "kidney_left", "kidney_right", "pancreas")]),
    "spine": fit("spine", list(pairs_v.items())),
    # The femurs are left out: the scan's first pass ends mid-thigh, so its femurs are
    # partial and would bias the scale against the body's whole femurs.
    "pelvis": fit("pelvis", V("L3", "L4", "L5", "L6") + [(n, n) for n in ("sacrum", "hip_left", "hip_right")]),
}
# Per-side shoulder fits from shoulder_fit.py, run after the thorax fit above.
shoulder = {f"{side}-{g}": work / f"{body}-fit-shoulder-{side}-{g}.json" for side in ("left", "right") for g in ("girdle", "humerus")}
seg = work / f"seg-{body}"
extra = seg / "extra"


L, R = "left", "right"
groups = {
    "stomach": ("abdomen", [("stomach", "stomach", "Stomach", "FMA:7148", 8000)]),
    "esophagus": ("thorax", [("esophagus", "esophagus", "Esophagus", "FMA:7131", 5000)]),
    "thyroid_gland": ("thorax", [("thyroid_gland", "thyroid_gland", "Thyroid gland", "FMA:9603", 4000)]),
    "adrenal_glands": ("abdomen", [("adrenal_gland_left", "adrenal_gland_L", "Left adrenal gland", "FMA:15630", 2500),
                                   ("adrenal_gland_right", "adrenal_gland_R", "Right adrenal gland", "FMA:15629", 2500)]),
    "ribs": ("thorax", [(f"rib_{s}_{i}", f"rib_{i}_{s[0].upper()}", ribs[f"{s}_{i}"][0], ribs[f"{s}_{i}"][1], 2500)
                        for s in (L, R) for i in range(1, 13)]
                       + [("costal_cartilages", "costal_cartilages", "Costal cartilages", "FMA:85213", 6000)]),
    "sternum": ("thorax", [("sternum", "sternum", "Sternum", "FMA:7485", 4000)]),
    "skull": ("skull", [("skull", "skull", "Skull", "FMA:46565", 25000)]),
    "shoulder_girdle": ("thorax", [("scapula_left", "scapula_L", "Left scapula", "FMA:13396", 6000, shoulder["left-girdle"]),
                                   ("scapula_right", "scapula_R", "Right scapula", "FMA:13395", 6000, shoulder["right-girdle"]),
                                   ("clavicula_left", "clavicle_L", "Left clavicle", "FMA:13323", 3000, shoulder["left-girdle"]),
                                   ("clavicula_right", "clavicle_R", "Right clavicle", "FMA:13322", 3000, shoulder["right-girdle"])]),
    "humeri": ("thorax", [("humerus_left", "humerus_L", "Left humerus", "FMA:23131", 5000, shoulder["left-humerus"]),
                          ("humerus_right", "humerus_R", "Right humerus", "FMA:23130", 5000, shoulder["right-humerus"])]),
    "gluteal_muscles": ("pelvis", [(f"gluteus_{m}_{s}", f"gluteus_{m}_{s[0].upper()}", f"{s.capitalize()} gluteus {m}", fid, 6000)
                                   for m, ids in (("maximus", ("FMA:22329", "FMA:22328")), ("medius", ("FMA:22331", "FMA:22330")),
                                                  ("minimus", ("FMA:22333", "FMA:22332")))
                                   for s, fid in zip((L, R), ids)]),
    "iliopsoas": ("pelvis", [("iliopsoas_left", "iliopsoas_L", "Left iliopsoas", "FMA:64920", 6000),
                             ("iliopsoas_right", "iliopsoas_R", "Right iliopsoas", "FMA:64919", 6000)]),
    "deep_back_muscles": ("spine", [("autochthon_left", "deep_back_muscles_L", "Left deep back muscles", "", 8000),
                                    ("autochthon_right", "deep_back_muscles_R", "Right deep back muscles", "", 8000)]),
    # Second round: head, neck and trunk muscles, the jaw and the diaphragm.
    "submandibular_glands": ("skull", [("submandibular_gland_left", "submandibular_gland_L", "Left submandibular gland", "", 2500),
                                       ("submandibular_gland_right", "submandibular_gland_R", "Right submandibular gland", "", 2500)], seg / "glands"),
    "tongue": ("skull", [("tongue", "tongue", "Tongue", "FMA:54640", 6000)], extra / "head-head_muscles"),
    "muscles_of_mastication": ("skull", [(f"{m}_{s}", f"{m}_{s[0].upper()}", f"{s.capitalize()} {m.replace('_', ' ')}", "", 4000)
                                         for m in ("masseter", "temporalis", "medial_pterygoid", "lateral_pterygoid") for s in (L, R)],
                               extra / "head-head_muscles"),
    "mandible": ("skull", [("mandible", "mandible", "Mandible", "FMA:52748", 10000)], extra / "head-craniofacial_structures"),
    # Neck muscles are traced on the 0.75 mm head-and-neck volume (<body>-headneck.nii.gz,
    # 400 mm deep): headneck_muscles runs at 0.75 x 0.75 x 1 mm, so the 1.5 mm section
    # gave it upsampled data and the thin constrictors and scalene slips broke up.
    "neck_muscles": ("skull", [(f"{m}_{s}", f"{m}_{s[0].upper()}", f"{s.capitalize()} {m.replace('_', ' ')}", "", 4000)
                               for m in ("sternocleidomastoid", "anterior_scalene", "middle_scalene", "posterior_scalene") for s in (L, R)],
                     extra / "headneck-headneck_muscles"),
    "pharyngeal_constrictors": ("skull", [(f"{p}_pharyngeal_constrictor", f"{p}_pharyngeal_constrictor", f"{p.capitalize()} pharyngeal constrictor", "", 3000)
                                          for p in ("superior", "middle", "inferior")], extra / "headneck-headneck_muscles"),
    "hyoid": ("skull", [("hyoid", "hyoid_bone", "Hyoid bone", "FMA:52749", 2000)], extra / "neck-headneck_bones_vessels"),
    "chest_and_back_muscles": ("thorax", [(f"{m}_{s}", f"{m}_{s[0].upper()}", f"{s.capitalize()} {m.replace('_', ' ')}", "", 8000)
                                          for m in ("pectoralis_major", "serratus_anterior", "latissimus_dorsi", "trapezius") for s in (L, R)],
                               seg / "abd"),
    "abdominal_wall_muscles": ("abdomen", [(f"{m}_{s}", f"{m}_{s[0].upper()}", f"{s.capitalize()} {m.replace('_', ' ')}", "", 8000)
                                           for m in ("rectus_abdominis", "external_oblique", "internal_oblique") for s in (L, R)],
                               seg / "abd"),
    "quadratus_lumborum": ("spine", [(f"quadratus_lumborum_{s}", f"quadratus_lumborum_{s[0].upper()}", f"{s.capitalize()} quadratus lumborum", "", 4000)
                                     for s in (L, R)], seg / "abd"),
    "diaphragm": ("abdomen", [("diaphragm", "diaphragm", "Diaphragm", "FMA:13295", 8000)], seg / "cav"),
}
manifest = {}
for group, (region, parts, *where) in groups.items():
    folder = where[0] if where else merged
    if group in skip:
        print(f"[{group}] skipped after review"); continue
    parts = [p for p in parts if present(p[0], folder) and p[0] not in skip]
    if any(len(p) > 5 and not pathlib.Path(p[5]).exists() for p in parts):
        print(f"[{group}] needs shoulder_fit.py first"); continue
    if not parts:
        print(f"[{group}] nothing traced"); continue
    glb = out / f"{body}-{group.replace('_', '-')}.glb"
    specs = [f"{p[0]}={X}_{p[1]}={p[2]}={p[3]}={p[4]}" + (f"={p[5]}" if len(p) > 5 else "") for p in parts]
    r = subprocess.run([py, "-I", str(tools / "mesh.py"), str(folder), str(fits[region]), str(glb)] + specs, capture_output=True, text=True, check=True)
    print(f"[{group}] region {region}\n" + r.stdout.strip())
    manifest[group] = {"region": region, "fit": json.loads(pathlib.Path(fits[region]).read_text()), "file": glb.name,
                       "parts": [{"mask": p[0], "node": f"{X}_{p[1]}", "label": p[2], "ontology": p[3]}
                                 | ({"fit": json.loads(pathlib.Path(p[5]).read_text())} if len(p) > 5 else {}) for p in parts]}
(out / f"{body}-parts.json").write_text(json.dumps(manifest, indent=1))
