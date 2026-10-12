extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func key(code: int, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	root.push_input(event)
	await process_frame


func save_capture(name: String) -> Error:
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/" + name + ".png")


func capture() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	await viewer.switch_body("bodyparts-male-bones-study")
	viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
	viewer.inspect_alone()
	viewer.scene_container.grab_focus()
	var before: Dictionary = viewer.orbit.export_state()
	await key(KEY_RIGHT)
	await key(KEY_UP, true)
	await key(KEY_EQUAL)
	if viewer.orbit.export_state() == before or not viewer.scene_container.has_focus():
		push_error("Rendered keyboard navigation did not reach the focused scene")
		quit(1)
		return
	if await save_capture("workspace-keyboard-focus") != OK:
		quit(1)
		return
	viewer.return_to_context()
	viewer.orbit.focus(viewer.model.bounds_for("anatomy.body"))
	var saved: Dictionary = viewer.current_view()
	viewer.on_panel_action(0)
	viewer.on_panel_action(1)
	root.size = Vector2i(1100, 720)
	await process_frame
	await process_frame
	if viewer.current_view() != saved or viewer.explorer_panel.visible or viewer.details_panel.visible:
		push_error("Collapsing panels changed the source view")
		quit(1)
		return
	if await save_capture("workspace-open-scene") != OK:
		quit(1)
		return
	# A primary click on visible source geometry still selects after keyboard focus
	# and layout changes, using logical coordinates through the root stretch.
	await physics_frame
	await physics_frame
	viewer.anatomy_labels.update_labels()
	var anchor: Dictionary = viewer.anatomy_labels.surface_anchor("source.bodyparts3d-v4-male.FJ3365")
	if anchor.is_empty():
		push_error("Visible source femur has no surface hit after panel collapse")
		quit(1)
		return
	var point: Vector2 = viewer.scene_container.global_position + anchor.screen
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = point
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)
	await process_frame
	if viewer.model.selected_id != "source.bodyparts3d-v4-male.FJ3365" or not viewer.scene_container.has_focus():
		push_error("Source selection/focus failed after expanding the scene")
		quit(1)
		return
	viewer.on_panel_action(0)
	viewer.on_panel_action(1)
	viewer.queue_free()
	await process_frame
	print("PASS rendered keyboard focus, panel layout and source selection")
	quit()
