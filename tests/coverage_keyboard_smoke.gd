extends SceneTree

const Verification = preload("res://scripts/study_verification.gd")
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
	for reference in viewer.pack.bodies:
		await viewer.switch_body(reference.id)
		var id: String = reference.get("qa_leaf_id", "anatomy.heart.valve.mitral")
		if reference.id == "bodyparts-male-bones-study":
			id = "source.bodyparts3d-v4-male.FJ3365"
		viewer.select_structure(id)
		viewer.inspect_alone()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.01, 0, 0))
		for expanded in [false, true]:
			viewer.set_scene_expanded(expanded)
			check(await Verification.verify_coverage_access(viewer), "Keyboard reading preserves the current reference and layout")
		viewer.set_scene_expanded(false)
		var before: Dictionary = viewer.model.export_state().duplicate(true)
		var dialog: Window = viewer.show_coverage()
		await process_frame
		var chosen := -1
		for index in dialog.notes.systems.size():
			if not dialog.structure_for(reference.id, str(dialog.notes.systems[index].roots[reference.id])).is_empty():
				chosen = index
				break
		check(chosen >= 0, "The reference has a supplied group to explore")
		if chosen >= 0:
			for step in chosen:
				await Verification.coverage_key(dialog, KEY_DOWN)
			var target: String = dialog.current_system.roots[reference.id]
			await Verification.coverage_key(dialog, KEY_TAB)
			await Verification.coverage_key(dialog, KEY_TAB)
			check(dialog.explore_button.has_focus(), "Tab reaches the Explore action after the inventory")
			await Verification.coverage_key(dialog, KEY_ENTER)
			await process_frame
			check(not is_instance_valid(dialog) and viewer.model.selected_id == target and viewer.model.body.id == reference.id and viewer.model.export_state() == before,
				"Keyboard Explore selects the active reference's supplied group without changing anatomy edits")
		else:
			dialog.queue_free()
	viewer.queue_free()
	await process_frame
	print("Coverage keyboard failures: ", failures)
	quit(0 if failures == 0 else 1)
