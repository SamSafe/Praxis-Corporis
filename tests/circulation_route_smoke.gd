extends SceneTree

var failures := 0
var rendered := false
var viewer


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func capture(name: String) -> void:
	if not rendered:
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("/tmp/medicine-improvements/route-" + name + ".png") == OK, "Capture " + name)


func _initialize() -> void:
	rendered = DisplayServer.get_name() != "headless"
	call_deferred("run")


func run() -> void:
	viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	for reference in ["female", "male"]:
		await viewer.switch_body(reference)
		viewer.select_structure("anatomy.heart")
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.01, 0.02, 0))
		viewer.labels_button.button_pressed = false
		viewer.local_labels_button.button_pressed = false
		viewer.original_positions_button.button_pressed = false
		var before: Dictionary = viewer.export_view_state().duplicate(true)
		var histories: Array = [viewer.model.undo_stack.duplicate(true), viewer.model.redo_stack.duplicate(true), viewer.back_views.duplicate(true), viewer.forward_views.duplicate(true)]
		viewer.start_circulation_route()
		check(viewer.guided_chest.active and viewer.guided_chest.mode == "circulation" and viewer.guided_chest.route_node == "vena-cava", "Route starts with explicit source selection")
		viewer.apply_route_step("aorta")
		check(viewer.guided_chest.route_node == "vena-cava", "Route rejects jumps across unspecified connections")
		for node in ["right-atrium", "tricuspid", "right-ventricle", "pulmonary-valve", "pulmonary-trunk"]:
			viewer.apply_route_step(node)
		check(viewer.guided_chest.branches.get_child_count() == 2, "Both lung branches are explicitly offered")
		await capture(reference + "-branches")
		if reference == "female":
			var preferences: Dictionary = viewer.preference_state()
			preferences.text_scale = 1.3
			viewer.apply_preferences(preferences)
			root.size = Vector2i(1100, 720)
			await process_frame
			await process_frame
			check(viewer.scene_container.size.y >= 140, "Large-text compact route preserves useful anatomy space")
			await capture("large-text-compact")
			viewer.apply_preferences(viewer.ViewerPreferences.DEFAULTS)
			root.size = Vector2i(1440, 900)
			await process_frame
			await process_frame
		viewer.guided_chest.branches.get_child(0).pressed.emit()
		check(viewer.guided_chest.route_node == "left-artery", "Left branch button selects its source artery")
		viewer.previous_route_step()
		check(viewer.guided_chest.route_node == "pulmonary-trunk" and viewer.guided_chest.branches.get_child_count() == 2, "Previous returns to branch choice")
		viewer.guided_chest.branches.get_child(1).pressed.emit()
		check(viewer.guided_chest.route_node == "right-artery", "Right branch button selects its source artery")
		viewer.set_scene_expanded(true)
		for node in ["right-exchange", "pulmonary-veins", "left-atrium", "mitral", "left-ventricle", "aortic-valve", "aorta", "systemic-gap", "vena-cava"]:
			viewer.apply_route_step(node)
			check(viewer.validate_view_state(viewer.export_view_state()).is_empty(), "Route snapshots remain compatible: " + node)
			if node == "right-exchange":
				check("Coverage gap" in viewer.guided_chest.description.text and "capillary" in viewer.guided_chest.description.text, "Missing gas-exchange anatomy is explicit")
				await capture(reference + "-gap-expanded")
		check(viewer.guided_chest.route_node == "vena-cava" and viewer.guided_chest.route_history.size() > 10, "Route returns through the body to its starting connection")
		viewer.set_scene_expanded(false)
		await viewer.finish_guided_chest()
		check(viewer.export_view_state() == before, "Finish restores camera, labels, selection, edits and inspection state exactly")
		check([viewer.model.undo_stack, viewer.model.redo_stack, viewer.back_views, viewer.forward_views] == histories, "Finish restores all four histories exactly")
		viewer.start_circulation_route()
		await viewer.start_guided_chest()
		check(viewer.guided_chest.mode == "chest" and viewer.guided_chest.active, "Switching to chest guide restores the route before starting")
		await viewer.start_circulation_route()
		check(viewer.guided_chest.mode == "circulation" and viewer.guided_chest.active, "Switching back to route restores chest guide first")
		check(await viewer.restore_view_state(before) and not viewer.guided_chest.active and viewer.export_view_state() == before, "Loading a view finishes the route cleanly")
	viewer.start_circulation_route()
	await viewer.switch_body("bodyparts-male-bones-study")
	check(not viewer.guided_chest.active and viewer.route_button.disabled and not viewer.route_supported, "Changing reference finishes route and disables unsupported mappings")
	viewer.start_circulation_route()
	check(not viewer.guided_chest.active, "Unmapped reference cannot start the route programmatically")
	viewer.queue_free()
	await process_frame
	print("Circulation route failures: ", failures)
	quit(0 if failures == 0 else 1)
