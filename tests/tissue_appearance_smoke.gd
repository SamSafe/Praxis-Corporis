extends SceneTree
## Illustrative tissue classes: specific names win over broad ones, and look-alike words
## (renal cortex, brain ventricles, lung segments) reach the right tissue.

const TissueAppearance = preload("res://scripts/tissue_appearance.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	var expected := {
		"VH_F_renal_cortex": "kidney",
		"VH_M_heart_left_ventricle": "heart",
		"Allen_third_ventricle_L": "brain_fluid",
		"Allen_body_of_lateral_ventricle_R": "brain_fluid",
		"VH_F_left_anterior_basal_bronchopulmonary_segment": "lung",
		"VH_F_left_anterior_basal_bronchus": "cartilage",
		"VH_F_hepatic_portal_vein": "vein",
		"VH_F_left_branch_of_portal_vein": "vein",
		"VH_F_left_anterior_descending_artery": "artery",
		"VH_F_mitral_valve": "valve",
		"VH_F_patellar_ligament_L": "ligament",
		"VH_M_femur_R": "bone",
		"Right femur": "bone",
		"VH_M_vocalis": "muscle",
		"VH_F_left_optic_nerve": "nerve",
		"VH_F_cornea_L": "cornea",
		"VH_F_common_hepatic_duct": "bile",
		"VH_F_left_ureter": "urinary",
		"VH_F_skin": "skin",
		"VH_F_trabecular_meshwork_L": "",
		"diaphragm": "muscle",
		"linea alba": "ligament",
		"VH_F_sternum": "bone",
		"VH_F_rib_4_L": "bone",
		"VH_F_costal_cartilages": "cartilage",
		"VH_M_gluteus_medius_R": "muscle",
		"VH_F_iliopsoas_L": "muscle",
		"VH_F_deep_back_muscles_L": "muscle",
		"VH_F_esophagus": "gut",
		"VH_F_stomach": "gut",
		"VH_M_thyroid_gland": "gland",
		"VH_M_adrenal_gland_R": "gland",
		"VH_F_adrenal_gland_L": "gland",
		"VH_F_tongue": "muscle",
		"VH_M_medial_pterygoid_L": "muscle",
		"VH_F_temporalis_R": "muscle",
		"VH_M_quadratus_lumborum": "muscle",
		"VH_F_latissimus_dorsi_L": "muscle",
		"VH_M_pharyngeal_constrictors": "muscle",
		"VH_F_mandible": "bone",
		"VH_M_humeri": "bone",
		"VH_F_submandibular_gland_L": "gland",
		"VH_F_intervertebral_disc_L6_S1": "cartilage",
		"Intervertebral discs": "cartilage",
		"VH_M_vertebrae": "bone",
	}
	for name in expected:
		check(TissueAppearance.classify(name) == expected[name], "%s -> %s (got %s)" % [name, expected[name], TissueAppearance.classify(name)])
	# A mesh takes the class of its most specific structure, falling back to broader ones.
	var structures := {
		"system": {"source_name": "VH_F_circulatory_system", "label": "Circulatory system", "mesh_nodes": [1, 2, 3]},
		"heart": {"source_name": "VH_F_heart", "label": "Heart", "mesh_nodes": [1, 2]},
		"valve": {"source_name": "VH_F_mitral_valve", "label": "Mitral valve", "mesh_nodes": [2]},
		"unknown": {"source_name": "VH_F_trabecular_meshwork_L", "label": "Trabecular meshwork", "mesh_nodes": [4]},
	}
	var tissues := TissueAppearance.tissues_for(structures)
	check(tissues[1] == "heart" and tissues[2] == "valve", "The most specific containing structure decides")
	check(tissues[3] == "", "No class is invented from an unmatched system name")
	check(tissues[4] == "", "Unrecognised parts stay unclassified")
	var source := Color(0.2, 0.4, 0.9)
	check(TissueAppearance.base_color("", source) != source and TissueAppearance.base_color("", source).b > TissueAppearance.base_color("", source).r, "Unclassified parts keep a softened source hue")
	var material := StandardMaterial3D.new()
	TissueAppearance.apply_finish(material, "bone")
	check(material.roughness > 0.6 and material.metallic == 0.0, "Bone is matte")
	TissueAppearance.apply_finish(material, "liver")
	check(material.roughness < 0.45 and material.rim_enabled, "Wet organs have a soft sheen")
	print("Tissue appearance failures: ", failures)
	quit(0 if failures == 0 else 1)
