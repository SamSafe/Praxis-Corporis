extends SceneTree

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func click(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)


func run() -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/medicine-improvements")
	root.size = Vector2i(1100, 720)
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	check(not viewer.cancel_load_button.visible, "Initial reference opening does not offer a return to an absent view")
	while viewer.loading:
		await process_frame
	var preferences: Dictionary = viewer.preference_state()
	preferences.text_scale = 1.3
	viewer.apply_preferences(preferences)
	viewer.chest_view()
	viewer.inspect_alone()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.02, 0, 0))
	for expanded in [false, true]:
		if expanded:
			viewer.start_guided_chest()
			viewer.apply_chest_step(2)
		viewer.set_scene_expanded(expanded)
		await process_frame
		await process_frame
		var before: Dictionary = viewer.export_view_state()
		var old_scene: Node3D = viewer.model.source_scene
		viewer.switch_body("male")
		await process_frame
		await RenderingServer.frame_post_draw
		var button: Button = viewer.expanded_cancel_load_button if expanded else viewer.cancel_load_button
		check(viewer.loading and button.is_visible_in_tree() and not button.disabled, "Cancel is reachable during the actual desktop load")
		check(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(button.get_global_rect()), "The large-text cancel action fits the compact app window")
		var suffix := "expanded" if expanded else "workspace"
		check(root.get_texture().get_image().save_png("/tmp/medicine-improvements/cancel-" + suffix + ".png") == OK, "The visible cancel action is captured")
		click(button)
		check(viewer.load_cancel_requested and button.disabled, "A real mouse click requests cancellation")
		while viewer.loading:
			await process_frame
		check(viewer.export_view_state() == before and viewer.model.source_scene == old_scene and viewer.model.hash_worker == null and viewer.model.staged_scene == null,
			"Desktop cancellation retains the exact view and releases staged work")
		check(viewer.scene_container.has_focus(), "Desktop cancellation returns keyboard focus to anatomy")
		if expanded:
			check(viewer.guided_chest.active and viewer.guided_chest.visible and viewer.guided_chest.step == 2, "The expanded chest guide resumes")
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			check(viewer.guided_chest.get_global_rect().end.y < root.get_visible_rect().size.y - 140 and viewer.guided_chest.size.y <= viewer.guided_chest.get_combined_minimum_size().y + 1,
				"The resumed study panel fits its content and leaves anatomy visible below it")
			check(root.get_texture().get_image().save_png("/tmp/medicine-improvements/cancel-resumed-guide.png") == OK, "The resumed guide is captured")
			await viewer.finish_guided_chest()
	viewer.set_scene_expanded(false)
	await viewer.switch_body("male")
	check(viewer.model.body.id == "male", "A reference can open normally after both mouse cancellations")
	viewer.queue_free()
	await process_frame
	print("Desktop reference cancellation failures: ", failures)
	quit(0 if failures == 0 else 1)
