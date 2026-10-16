extends SceneTree

const StudyVerification = preload("res://scripts/study_verification.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func cancel_at(viewer, stage: String, early: bool = false, target: String = "male", restore: Dictionary = {}) -> void:
	var before: Dictionary = viewer.export_view_state()
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var remembered: Dictionary = viewer.reference_state.current.duplicate(true)
	var old_scene: Node3D = viewer.model.source_scene
	var title := root.title
	var context_text: String = viewer.context.text
	var move_mode: bool = viewer.orbit.move_mode
	var canceled := [false]
	var staged := [null]
	var callback := func(actual_stage: String, _fraction: float):
		if actual_stage == stage and not canceled[0]:
			canceled[0] = true
			staged[0] = viewer.model.staged_scene
			var button: Button = viewer.expanded_cancel_load_button if viewer.scene_expanded else viewer.cancel_load_button
			check(button.visible and not button.disabled, "Cancel is offered for an existing reference")
			button.pressed.emit()
			check(viewer.cancel_load_button.disabled and viewer.load_cancel_requested, "Cancel requests disable repeated input while cleanup finishes")
	viewer.model.load_progress.connect(callback)
	if restore.is_empty():
		viewer.switch_body(target)
	else:
		viewer.restore_view_state(restore)
	if early:
		canceled[0] = true
		viewer.cancel_reference_load()
	while viewer.loading:
		await process_frame
	viewer.model.load_progress.disconnect(callback)
	check(canceled[0], "Cancellation reached the requested boundary: " + stage)
	check(viewer.export_view_state() == before and viewer.model.source_scene == old_scene, stage + ": cancellation preserves the exact current anatomy, camera, labels and isolation")
	check(viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward, stage + ": both edit and navigation histories survive")
	check(viewer.reference_state.current == remembered and root.title == title, stage + ": startup reference and title retain the last completed load")
	check(viewer.context.text == context_text and viewer.orbit.move_mode == move_mode and viewer.move_button.button_pressed == move_mode, stage + ": source context and Move mode are retained")
	check(viewer.model.staged_scene == null and viewer.model.hash_worker == null and not viewer.model.loading and not viewer.model.cancel_requested and not viewer.load_cancel_requested,
		stage + ": staged scenes, source worker and pending flags are released")
	check(not is_instance_valid(staged[0]), stage + ": a captured staged scene is freed")
	check(viewer.orbit.input_enabled and not viewer.loading_row.visible and not viewer.cancel_load_button.visible and not viewer.expanded_cancel_load_button.visible and "canceled" in viewer.status.text,
		stage + ": the interface resumes with a cancellation result")
	check(viewer.scene_container.has_focus(), stage + ": keyboard focus returns to anatomy exploration")
	print("PASS canceled reference boundary: ", stage)


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.chest_view()
	viewer.select_structure("anatomy.heart.valve.mitral")
	viewer.inspect_alone()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.02, 0.01, 0))
	viewer.model.set_visibility("anatomy.heart.valve.mitral", "faded")
	viewer.model.undo()
	viewer.move_button.button_pressed = true
	viewer.orbit.move_mode = true
	await cancel_at(viewer, "Before source loading", true)
	for stage in ["Checking source file", "Loading anatomy", "Preparing view", "Loading selection", "Preparing selection", "Opening reference"]:
		await cancel_at(viewer, stage)
	var original: Dictionary = viewer.export_view_state()
	viewer.start_guided_chest()
	viewer.apply_chest_step(2)
	var guided: Dictionary = viewer.guided_chest.original.duplicate(true)
	await cancel_at(viewer, "Loading selection")
	check(viewer.guided_chest.active and viewer.guided_chest.visible and viewer.guided_chest.step == 2 and viewer.guided_chest.original == guided, "Cancellation resumes the same chest guide and its original return context")
	await viewer.finish_guided_chest()
	check(viewer.export_view_state() == original, "Finishing a resumed guide still restores the original exploration")
	viewer.start_circulation_route()
	for node in ["right-atrium", "tricuspid", "right-ventricle", "pulmonary-valve", "pulmonary-trunk", "left-artery"]:
		viewer.apply_route_step(node)
	var route_node: String = viewer.guided_chest.route_node
	var route_history: Array = viewer.guided_chest.route_history.duplicate()
	viewer.set_scene_expanded(true)
	await cancel_at(viewer, "Opening reference")
	check(viewer.scene_expanded and viewer.guided_chest.active and viewer.guided_chest.visible and viewer.guided_chest.route_node == route_node and viewer.guided_chest.route_history == route_history,
		"Expanded cancellation retains the route node and both-branch history")
	await viewer.finish_guided_chest()
	check(viewer.export_view_state() == original, "Finishing a resumed route retains exact starting-view restoration")
	check(await StudyVerification.verify_cancel_loading(viewer), "The exported cancellation protocol retains its source study and restoration context")
	# A completed switch ends the guide and restores its original viewing controls.
	viewer.start_guided_chest()
	viewer.apply_chest_step(2)
	var controls: Dictionary = viewer.guided_chest.original.duplicate(true)
	await viewer.switch_body("male")
	check(viewer.model.body.id == "male" and not viewer.guided_chest.active and viewer.model.undo_stack.is_empty() and viewer.reference_state.current.body_id == "male", "The same reference loads successfully after cancellation and starts its own history")
	check(viewer.labels_button.button_pressed == controls.labels and viewer.local_labels_button.button_pressed == controls.local_labels and int(viewer.label_density.value) == controls.label_density,
		"A successful guide switch restores the pre-guide viewing controls")
	var male_before: Dictionary = viewer.export_view_state()
	viewer.start_guided_chest()
	viewer.apply_chest_step(2)
	await cancel_at(viewer, "Opening reference", false, "female", original)
	check(viewer.model.body.id == "male" and viewer.guided_chest.active and viewer.guided_chest.step == 2, "Canceling another-reference saved-view restoration keeps the current guide")
	await viewer.finish_guided_chest()
	check(viewer.export_view_state() == male_before, "The retained guide still restores the current reference after a canceled bookmark load")
	viewer.queue_free()
	await process_frame
	print("Reference cancellation failures: ", failures)
	quit(0 if failures == 0 else 1)
