extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func type_query(viewer, text: String) -> void:
	viewer.search.text = ""
	viewer.rebuild_tree()
	viewer.search.grab_focus()
	for character in text:
		var event := InputEventKey.new()
		event.pressed = true
		event.unicode = character.unicode_at(0)
		root.push_input(event)
	await process_frame


func press(code: int) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = code
	root.push_input(event)
	await process_frame


func capture(name: String) -> bool:
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/" + name + ".png") == OK


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.chest_view()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.02, 0, 0))
	var anatomy: Dictionary = viewer.model.export_state()
	await type_query(viewer, "UBERON0002135")
	await press(KEY_ENTER)
	if viewer.model.selected_id != "anatomy.heart.valve.mitral" or not viewer.search_results.has_focus() or viewer.model.export_state() != anatomy:
		push_error("Typed identifier/Enter selection failed or changed inspection")
		quit(1)
		return
	viewer.inspect_alone()
	await physics_frame
	await physics_frame
	viewer.anatomy_labels.update_labels()
	if not await capture("search-ontology-valve"):
		quit(1)
		return
	await type_query(viewer, "dura mater")
	await process_frame
	await process_frame
	if viewer.search_results.item_count < 2 or not await capture("search-duplicate-source-names"):
		quit(1)
		return
	# The two-line result really occupies multiple lines and remains selectable.
	var first: Rect2 = viewer.search_results.get_item_rect(0)
	var second: Rect2 = viewer.search_results.get_item_rect(1)
	if first.size.y < 32.0 or first.intersects(second):
		push_error("Source result rows do not render readable separate lines")
		quit(1)
		return
	var point: Vector2 = viewer.search_results.global_position + first.get_center()
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.global_position = point
	event.pressed = true
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)
	await process_frame
	if viewer.model.selected_id != viewer.search_results.get_item_metadata(0) or viewer.model.export_state() != anatomy:
		push_error("Mouse selection of a repeated source label failed")
		quit(1)
		return
	root.size = Vector2i(1100, 720)
	await viewer.switch_body("bodyparts-male-bones-study")
	await type_query(viewer, "FMA24474")
	await press(KEY_ENTER)
	viewer.inspect_alone()
	await physics_frame
	await physics_frame
	viewer.anatomy_labels.update_labels()
	if viewer.heading.text != "Right femur" or not await capture("search-source-bone-compact"):
		quit(1)
		return
	for control in [viewer.search, viewer.search_summary, viewer.search_results]:
		if not Rect2(Vector2.ZERO, viewer.size).encloses(control.get_global_rect()):
			push_error("Search controls overflow the compact workspace")
			quit(1)
			return
	viewer.queue_free()
	await process_frame
	print("PASS rendered identifier typing, Enter selection, duplicate-row clicking and compact search layout")
	quit()
