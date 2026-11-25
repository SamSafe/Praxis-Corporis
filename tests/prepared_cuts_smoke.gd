extends SceneTree
## Prepared cut-aways: each one opens on both HRA bodies, selects its structure, turns
## the camera to its body direction and sets the cut, so the view centre lands inside
## that structure. Back returns the previous view, anatomy visibility is unchanged,
## and the cut stays a display setting.

const PreparedCuts = preload("res://scripts/prepared_cuts.gd")
const ReferenceOrientation = preload("res://scripts/reference_orientation.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func settle(frames: int = 40) -> void:
	for i in frames:
		await process_frame


func run() -> void:
	# A card without a mapping for the body, or a structure the body lacks, is unavailable.
	var cards := {"anatomy.heart": {}, "anatomy.eyes": {"geometry": {"female": [{"id": "a", "source_name": "VH_F_eye_R"}, {"id": "b", "source_name": "VH_F_eye_L"}]}}}
	check(PreparedCuts.structure_for(PreparedCuts.CUTS[0], "female", {"anatomy.heart": {}}, cards) == "anatomy.heart", "A card without mappings opens its own ID")
	check(PreparedCuts.structure_for(PreparedCuts.CUTS[0], "female", {}, cards) == "", "A missing structure is unavailable")
	check(PreparedCuts.structure_for(PreparedCuts.CUTS[3], "female", {"a": {}, "b": {}}, cards) == "b", "A paired card opens the named part")
	check(PreparedCuts.structure_for(PreparedCuts.CUTS[3], "male", {"a": {}, "b": {}}, cards) == "", "A body without a mapping is unavailable")
	var ids := {}
	for cut in PreparedCuts.CUTS:
		check(not ids.has(cut.id) and int(cut.view) >= 0 and int(cut.view) < ReferenceOrientation.VIEW_NAMES.size() and absf(float(cut.depth)) <= 15.0, "Cut %s is well formed" % cut.id)
		ids[cut.id] = true
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	for body in ["female", "male"]:
		if viewer.model.body.id != body:
			await viewer.switch_body(body)
			while viewer.loading:
				await process_frame
		await settle(5)
		check(viewer.available_cuts().size() == PreparedCuts.CUTS.size(), "%s offers every prepared cut" % body)
		check(not viewer.cuts_menu.disabled, "%s enables the menu" % body)
		viewer.refresh_cuts_menu()
		for index in PreparedCuts.CUTS.size():
			check(not viewer.cuts_menu.get_popup().is_item_disabled(index), "%s menu item %d is enabled" % [body, index])
		for index in PreparedCuts.CUTS.size():
			var cut: Dictionary = PreparedCuts.CUTS[index]
			viewer.whole_body()
			viewer.cut_button.button_pressed = false
			await settle(5)
			var before: Dictionary = viewer.current_view()
			var visibility: Array = viewer.model.states.values().map(func(state): return state.visibility)
			viewer.cuts_menu.get_popup().id_pressed.emit(index)
			await settle()
			var id := PreparedCuts.structure_for(cut, body, viewer.model.structures, viewer.study_content.data.cards)
			var name := "%s %s" % [body, cut.id]
			check(viewer.model.selected_id == id and not id.is_empty(), name + " selects its structure")
			var direction: Vector3 = (viewer.orbit.camera.position - viewer.orbit.target).normalized()
			check(direction.is_equal_approx(ReferenceOrientation.view_direction(viewer.orientation.frame, int(cut.view))), name + " turns the camera to its body direction")
			check(viewer.cut_button.button_pressed and is_equal_approx(viewer.cut_slider.value, float(cut.depth)), name + " turns the cut on at its depth")
			check(is_equal_approx(viewer.orbit.camera.near, viewer.orbit.cut_near()) and viewer.orbit.camera.near > viewer.orbit.NEAR, name + " moves the near plane to the cut")
			check(str(cut.title) in viewer.cut_note.text and "no caps" in viewer.cut_note.text, name + " explains the cut")
			check(viewer.model.states.values().map(func(state): return state.visibility) == visibility, name + " changes no visibility")
			var hit: Dictionary = viewer.model.ray_hit(viewer.orbit.camera, viewer.viewport.size * 0.5)
			check(not hit.is_empty() and float(hit.collider.get_meta("mesh_index")) in viewer.model.structures[id].mesh_nodes.map(func(n): return float(n)), name + " exposes its own structure at the view centre")
			viewer.navigate_history(true)
			await settle(5)
			check(viewer.current_view() == before, name + " Back returns the previous view")
			check(viewer.cut_button.button_pressed, name + " keeps the display-only cut after Back")
	viewer.cut_button.button_pressed = false
	print("Prepared cut-away failures: ", failures)
	quit(0 if failures == 0 else 1)
