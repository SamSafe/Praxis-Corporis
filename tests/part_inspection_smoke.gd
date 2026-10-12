extends SceneTree
## Inspect supplied real geometry while preserving the surrounding body/session.

var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func write_save(viewer: Control, state: Dictionary) -> void:
	var file := FileAccess.open(viewer.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(state))
	file.close()


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	if viewer.model.body.is_empty():
		push_error("Prepared anatomy is unavailable")
		quit(1)
		return
	viewer.save_path = "user://part_inspection_test_view.json"
	for body in ["female", "male"]:
		if viewer.model.body.id != body:
			await viewer.switch_body(body)
		check(viewer.model.isolated_id.is_empty() and viewer.inspection_return.is_empty(), "Body switching clears temporary inspection")
		viewer.chest_view()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.07, 0.02, 0))
		viewer.model.set_visibility("anatomy.heart.valve.mitral", "hidden")
		viewer.model.set_visibility("anatomy.heart.valve.aortic", "faded")
		var before: Dictionary = viewer.model.export_state()
		var before_view: Dictionary = viewer.current_view()
		var heart_bounds: AABB = viewer.model.bounds_for("anatomy.heart")
		var undo: Array = viewer.model.undo_stack.duplicate(true)
		check(viewer.parts_scope == "anatomy.heart" and viewer.parts_items.has("anatomy.heart.valve.mitral"), "The local parts list includes covered valves")
		for id in viewer.parts_items:
			check(viewer.model.structures.has(id), "Part-list IDs belong to the active body's catalogue")
		viewer.inspect_alone()
		check(viewer.model.export_state() == before and viewer.model.undo_stack == undo, "Inspect alone does not edit stored visibility, offsets or undo history")
		check(viewer.model.bounds_for("anatomy.heart").is_equal_approx(heart_bounds), "Isolation leaves supplied geometry at its current body position")
		check(viewer.model.isolated_id == "anatomy.heart" and viewer.inspection_banner.visible, "Inspection mode has an explicit return action")
		var shown := 0
		for index in viewer.model.meshes:
			if viewer.model.meshes[index].visible:
				shown += 1
			check(viewer.model.colliders[index].collision_layer == (1 if viewer.model.meshes[index].visible else 0), "Temporary visibility and picking agree")
		check(shown == 14, "Heart inspection temporarily reveals exactly its 14 supplied meshes")
		# Choose the otherwise hidden valve through the same Tree signal used by the UI.
		viewer.parts_items["anatomy.heart.valve.mitral"].select(0)
		check(viewer.model.selected_id == "anatomy.heart.valve.mitral" and viewer.model.isolated_id == viewer.model.selected_id,
			"Part-list selection updates the shared selection and inspection mask")
		check(viewer.tree.get_selected().get_metadata(0) == viewer.model.selected_id, "The main anatomy tree shares part-list selection")
		var index := int(viewer.model.structures[viewer.model.selected_id].source_node)
		check(viewer.model.states[index].visibility == "hidden" and viewer.model.meshes[index].visible, "Covered/hidden parts can be inspected without changing context visibility")
		check(viewer.anatomy_labels.context_id == "anatomy.heart", "Part inspection retains the organ's label context")
		for button in viewer.visibility_buttons:
			check(button.disabled, "Context visibility controls are disabled during the temporary view")
		check(viewer.peel_button.disabled, "Skin reveal is unavailable while its temporary mask hides context")
		await physics_frame
		await physics_frame
		viewer.anatomy_labels.update_labels()
		check(viewer.anatomy_labels.visible_ids == [viewer.model.selected_id], "The temporarily revealed hidden part gets a truthful surface label")
		if viewer.anatomy_labels.anchors.has(viewer.model.selected_id):
			check(viewer.model.pick(viewer.orbit.camera, viewer.anatomy_labels.anchors[viewer.model.selected_id]) == viewer.model.selected_id,
				"Actual ray picking selects the isolated valve")
		for ghost_index in viewer.model.original_ghosts:
			check(viewer.model.original_ghosts[ghost_index].visible == (int(ghost_index) == index), "Original-position overlays obey the same inspection scope")
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.04, 0, 0))
		var moved: Dictionary = viewer.model.export_state()
		viewer.model.undo()
		check(viewer.model.export_state() == before and viewer.model.isolated_id == viewer.model.selected_id, "Undo restores a part movement without leaving inspection")
		viewer.model.redo()
		check(viewer.model.export_state() == moved, "Redo preserves the temporary view and reapplies movement")
		viewer.return_to_context()
		check(viewer.current_view() == before_view, "Return restores the exact prior selection, camera and label context")
		check(viewer.model.export_state() == moved, "Return preserves edits made while inspecting a part")
		check(not viewer.model.meshes[index].visible, "The valve's original hidden context setting returns")
		viewer.navigate_history(true)
		check(viewer.model.isolated_id == "anatomy.heart.valve.mitral" and viewer.inspection_banner.visible, "Back restores temporary inspection with its return action")
		viewer.save_view()
		var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(viewer.save_path))
		viewer.restore_all()
		check(viewer.model.isolated_id.is_empty() and viewer.model.export_state().is_empty(), "Restore all leaves inspection and restores original anatomy")
		await viewer.load_view()
		check(viewer.model.isolated_id == "anatomy.heart.valve.mitral" and viewer.model.export_state() == moved, "Saved inspection restores mask and body edits together")
		check(viewer.inspection_return.selection == before_view.selection and viewer.inspection_return.label_context == before_view.label_context,
			"Saved inspection retains a usable return context")
		var prior: Dictionary = viewer.current_view()
		var invalid := saved.duplicate(true)
		invalid.isolation = "anatomy.skin"
		write_save(viewer, invalid)
		await viewer.load_view()
		check(viewer.current_view() == prior and viewer.model.export_state() == moved, "Mismatched saved isolation is rejected before changing the session")
		invalid = saved.duplicate(true)
		invalid.body = "male" if body == "female" else "female"
		invalid.inspection_return.selection = "missing.structure"
		write_save(viewer, invalid)
		await viewer.load_view()
		check(viewer.model.body.id == body and viewer.current_view() == prior, "Invalid saved return anatomy is rejected before switching bodies")
		invalid = saved.duplicate(true)
		invalid.inspection_return.camera.distance = -1
		write_save(viewer, invalid)
		await viewer.load_view()
		check(viewer.current_view() == prior, "Malformed return camera cannot partly alter the view")
		var legacy := saved.duplicate(true)
		legacy.erase("isolation")
		legacy.erase("inspection_return")
		write_save(viewer, legacy)
		await viewer.load_view()
		check(viewer.model.isolated_id.is_empty() and viewer.inspection_return.is_empty() and viewer.model.export_state() == moved,
			"Older saves load with ordinary context and unchanged inspection states")
		viewer.inspect_alone()
		viewer.whole_body()
		check(viewer.model.isolated_id.is_empty() and viewer.model.export_state() == moved, "Whole body removes the mask while preserving inspection changes")
		viewer.select_structure("anatomy.heart")
		viewer.inspect_alone()
		viewer.chest_view()
		check(viewer.model.isolated_id.is_empty(), "Show chest restores the surrounding context")
		viewer.inspect_alone()
		print("PASS real part inspection: ", body)
	DirAccess.remove_absolute(viewer.save_path)
	viewer.queue_free()
	await process_frame
	print("Part inspection failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
