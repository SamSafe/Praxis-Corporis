extends SceneTree
## The complete BodyParts3D body: loads as its own reference, carries cards and conditions
## for organs the HRA bodies lack, and resolves mapped cards to its own parts.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	var ids: Array = viewer.pack.bodies.map(func(b): return b.id)
	check("bodyparts-male-complete" in ids, "The complete body is offered when its prepared source is present")
	if not "bodyparts-male-complete" in ids:
		print("Complete body failures: ", failures)
		quit(1)
		return
	await viewer.switch_body("bodyparts-male-complete")
	check(viewer.model.body.get("study_kind") == "bodyparts3d-complete" and viewer.model.meshes.size() > 2000, "Every kept source mesh loads")
	var content = viewer.study_content
	# Organs absent from the HRA bodies.
	for organ in ["anatomy.stomach", "anatomy.esophagus", "anatomy.diaphragm", "anatomy.spinal-cord", "anatomy.pituitary"]:
		check(viewer.model.structures.has(organ) and not content.card(organ).is_empty(), "Organ has geometry and a card: " + organ)
	var stomach_conditions: Array = content.conditions_for("anatomy.stomach")
	for condition in ["condition.gerd", "condition.peptic-ulcer", "condition.stomach-cancer", "condition.hiatal-hernia"]:
		check(condition in stomach_conditions and content.condition_available(condition, viewer.model.structures), "Stomach offers " + condition)
	# A card mapped by name resolves to this body's own part, and back.
	var adrenal: String = content.structure_id("anatomy.adrenal-glands", viewer.model.structures)
	check(not adrenal.is_empty() and "adrenal" in str(viewer.model.structures[adrenal].label).to_lower(), "Adrenal card resolves to an adrenal gland")
	check(content.card(adrenal) == content.card("anatomy.adrenal-glands"), "Selecting the adrenal part finds its card")
	var lad: String = content.structure_id("anatomy.coronary.lad", viewer.model.structures)
	check(not lad.is_empty(), "Existing heart cards also apply to the complete body")
	# Skin can be peeled like the HRA bodies.
	check(viewer.model.structures.has("anatomy.skin"), "The complete body has a peelable skin")
	var stored: Dictionary = viewer.model.export_state().duplicate(true)
	viewer.select_structure("anatomy.stomach")
	check("digest" in viewer.study_summary.text.to_lower(), "Selecting the stomach shows its study text")
	# Revealing a selection fades the layers in front of it for display only.
	var skin_mesh := int(viewer.model.structures["anatomy.skin"].mesh_nodes[0])
	check(viewer.model.effective_visibility(skin_mesh) == "faded" and viewer.model.states[skin_mesh].visibility == "visible", "Selecting an organ fades the skin for display only")
	check(viewer.model.colliders[skin_mesh].collision_layer == 0, "Faded skin lets clicks reach the organs behind it")
	check(viewer.model.export_state() == stored, "Revealing a selection changes no stored anatomy state")
	viewer.select_structure("anatomy.skin")
	check(viewer.model.effective_visibility(skin_mesh) == "visible", "Selecting the skin shows it again")
	viewer.select_structure("")
	check(viewer.model.effective_visibility(skin_mesh) == "visible", "Clearing the selection restores every layer")
	print("Complete body failures: ", failures)
	quit(0 if failures == 0 else 1)
