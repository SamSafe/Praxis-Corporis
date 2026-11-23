extends RefCounted
## Illustrative tissue colours and surface finishes, chosen from structure names.
## These are display choices for legibility and realism, not medical data: the source
## geometry, labels and IDs are unchanged, and an unclassified part keeps a softened
## version of its source colour.

# Ordered: the first matching rule wins, so specific tissues come before broad systems.
const RULES := [
	["valve", ["valve", "chordae"]],
	["vein", ["vein", "vena_cava", "vena cava", "venous", "coronary_sinus", "coronary sinus", "sinus_of_"]],
	["artery", ["arter", "aorta", "aortic_arch", "trunk", "arch_of_aorta", "branch_of", "diagonal_branch", "marginal_branch"]],
	["brain_fluid", ["lateral_ventricle", "third_ventricle", "fourth_ventricle", "cerebral_aqueduct", "choroid_plexus"]],
	["heart", ["heart", "atrium", "atria", "ventric", "cardiac", "myocard", "papillary", "septum", "auricle"]],
	["nerve", ["nerve", "optic_chiasm", "chiasm", "optic tract", "optic_tract", "dura_mater"]],
	["cornea", ["cornea"]],
	["iris", ["iris", "pupil"]],
	["lens", ["lens"]],
	["retina", ["retina", "macula", "fovea"]],
	["choroid", ["choroid", "ciliary"]],
	["vitreous", ["vitreous", "aqueous"]],
	["sclera", ["sclera", "eyeball", "conjunctiva"]],
	["brain", ["allen_", "brain", "cerebr", "cerebell", "thalam", "gyrus", "pons", "medulla_oblongata", "midbrain", "hippocamp", "amygdal", "nucleus", "callosum", "pineal", "olfactory", "fornix", "putamen", "caudate", "pallidus", "insula", "lobule", "lobe_of_brain"]],
	["lung", ["bronchopulmonary"]],
	["cartilage", ["cartilage", "trachea", "bronch", "carina", "larynx", "epiglott", "cricoid", "arytenoid_cart", "corniculate", "cuneiform", "menisc"]],
	["ligament", ["ligament", "tendon", "fascia", "aponeuros", "linea alba", "rectus sheath", "sheath of"]],
	["muscle", ["muscle", "rectus", "oblique", "levator", "vocalis", "thyroarytenoid", "cricothyroid", "arytenoid", "thyroepiglott", "quadriceps", "sartorius", "gracilis", "gastrocnem", "popliteus", "biceps", "vastus", "muscular", "diaphragm", "gluteus", "iliopsoas", "psoas", "iliacus"]],
	["bone", ["bone", "femur", "tibia", "fibula", "patella", "pelvis", "hyoid", "ilium", "ischium", "pubis", "sacrum", "vertebra", "skull", "rib", "condyle", "epicondyle", "compact", "spongy", "marrow", "trochlea", "tuberosity", "malleolus", "skeletal", "sternum", "clavicle", "scapula", "humerus"]],
	["lung", ["lung", "pulmonary_lobe", "lobe_of_lung", "lingula", "pleura", "alveol"]],
	["liver", ["liver", "hepatic_lobe", "caudate_lobe", "quadrate_lobe"]],
	["bile", ["gallbladder", "gall_bladder", "bile", "cystic_duct", "hepatic_duct", "biliary"]],
	["spleen", ["spleen", "splenic"]],
	["pancreas", ["pancrea"]],
	["gland", ["adrenal", "suprarenal_gland"]],  # before kidney: "adrenal" contains "renal"
	["kidney", ["kidney", "renal", "calyx", "calyces", "nephron"]],
	["urinary", ["ureter", "bladder", "urethra", "vesical"]],
	["gut", ["intestin", "colon", "duoden", "jejun", "ileum", "ileal", "cecum", "caecum", "rectum", "appendix", "sigmoid", "esophag", "stomach", "ileocecal"]],
	["gland", ["thymus", "lymph", "lymphatic", "thyroid", "adrenal", "gland"]],
	["ovary", ["ovary", "ovarian"]],
	["reproductive", ["uterus", "uterine", "fallopian", "tube_infund", "infundibulum", "vagina", "cervix", "prostate", "seminal", "vas_deferens", "ejaculatory", "fundus_of_uterus", "endometr", "myometr"]],
	["skin", ["skin", "integument"]],
]

# Albedo, roughness, rim sheen. Wet soft tissue is glossier; bone and skin are matte.
const PALETTE := {
	"valve": [Color("dcc9b2"), 0.55, 0.1],
	"vein": [Color("3d4f8c"), 0.38, 0.25],
	"artery": [Color("a8282b"), 0.36, 0.25],
	"heart": [Color("9a3a32"), 0.42, 0.22],
	"nerve": [Color("e3cd88"), 0.5, 0.15],
	"cornea": [Color("cfe2e8"), 0.18, 0.35],
	"iris": [Color("6d4a30"), 0.45, 0.1],
	"lens": [Color("e8e0c2"), 0.2, 0.3],
	"retina": [Color("c45c42"), 0.4, 0.15],
	"choroid": [Color("5b2b2a"), 0.45, 0.1],
	"vitreous": [Color("d3e4ea"), 0.2, 0.3],
	"sclera": [Color("efebe3"), 0.32, 0.2],
	"brain_fluid": [Color("8cb3c8"), 0.3, 0.2],
	"brain": [Color("d8b4ab"), 0.5, 0.18],
	"cartilage": [Color("cdd6d6"), 0.42, 0.2],
	"ligament": [Color("e6dfcf"), 0.45, 0.2],
	"muscle": [Color("a4443a"), 0.5, 0.18],
	"bone": [Color("e2d7bd"), 0.68, 0.05],
	"lung": [Color("d99c96"), 0.5, 0.18],
	"liver": [Color("6f2b23"), 0.36, 0.22],
	"bile": [Color("6b8040"), 0.35, 0.22],
	"spleen": [Color("6b2f40"), 0.38, 0.2],
	"pancreas": [Color("d8b17d"), 0.5, 0.15],
	"kidney": [Color("8b3b31"), 0.4, 0.2],
	"urinary": [Color("d6b59c"), 0.42, 0.18],
	"gut": [Color("d49a89"), 0.42, 0.2],
	"gland": [Color("c9a38f"), 0.48, 0.15],
	"ovary": [Color("e0c3b1"), 0.45, 0.15],
	"reproductive": [Color("cf9387"), 0.42, 0.2],
	"skin": [Color("c8a48c"), 0.62, 0.12],
}


static func classify(text: String) -> String:
	var lower := text.to_lower()
	for rule in RULES:
		for keyword in rule[1]:
			if lower.contains(keyword):
				return rule[0]
	return ""


static func base_color(tissue: String, source: Color) -> Color:
	if PALETTE.has(tissue):
		return PALETTE[tissue][0]
	# Unclassified parts keep their source hue, softened towards a neutral tissue tone.
	return source.lerp(Color("b9a79a"), 0.35)


static func apply_finish(material: StandardMaterial3D, tissue: String) -> void:
	var finish: Array = PALETTE.get(tissue, [Color.WHITE, 0.55, 0.12])
	material.roughness = finish[1]
	material.metallic = 0.0
	material.metallic_specular = 0.5
	material.rim_enabled = finish[2] > 0.0
	material.rim = finish[2]
	material.rim_tint = 0.6


## Names describing each mesh: every structure containing it, most specific last.
static func mesh_names(structures: Dictionary) -> Dictionary:
	var names := {}
	var depth := {}
	for id in structures:
		var record: Dictionary = structures[id]
		var count: int = record.get("mesh_nodes", []).size()
		for index in record.get("mesh_nodes", []):
			var key := int(index)
			if not names.has(key):
				names[key] = []
			names[key].append([count, "%s %s" % [record.get("source_name", ""), record.get("label", "")]])
	for key in names:
		# Fewer meshes means a more specific structure; check it first.
		names[key].sort_custom(func(a, b): return a[0] < b[0])
		var text := PackedStringArray()
		for entry in names[key]:
			text.append(entry[1])
		depth[key] = text
	return depth


static func tissues_for(structures: Dictionary) -> Dictionary:
	var result := {}
	var described := mesh_names(structures)
	for index in described:
		var tissue := ""
		for text in described[index]:
			tissue = classify(text)
			if not tissue.is_empty():
				break
		result[index] = tissue
	return result
