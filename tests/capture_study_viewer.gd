extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func save_capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/" + name + ".png")
	if error != OK:
		push_error("Study capture failed")


func click_viewport(viewer: Control, local_point: Vector2) -> void:
	var container: Control = viewer.viewport.get_parent()
	var point: Vector2 = container.global_position + local_point
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.global_position = point
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame


func capture() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	await viewer.switch_body("bodyparts-male-bones-study")
	await physics_frame
	await physics_frame
	await save_capture("study-viewer-bones")
	# A skeleton has open spaces; target an actual visible femur surface, not the
	# viewport centre where an opaque skin used to make the earlier test reliable.
	viewer.anatomy_labels.update_labels()
	var anchor: Dictionary = viewer.anatomy_labels.surface_anchor("source.bodyparts3d-v4-male.FJ3365")
	if anchor.is_empty():
		push_error("Could not locate a visible source femur surface")
		quit(1)
		return
	await click_viewport(viewer, anchor.screen)
	if viewer.model.selected_id.is_empty():
		push_error("Rendered bone study could not select visible source geometry")
		quit(1)
		return
	viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
	await physics_frame
	await physics_frame
	viewer.anatomy_labels.update_labels()
	await save_capture("study-viewer-femur")
	viewer.inspect_alone()
	await save_capture("study-viewer-femur-alone")
	viewer.return_to_context()
	root.size = Vector2i(1100, 720)
	await process_frame
	await process_frame
	if not root.get_visible_rect().encloses(viewer.body_choice.get_global_rect()):
		push_error("Reference selector overflows the smaller window")
		quit(1)
		return
	await save_capture("study-viewer-compact")
	print("PASS rendered optional study reference and selection")
	viewer.queue_free()
	await process_frame
	quit()
