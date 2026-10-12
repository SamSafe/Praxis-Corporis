extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func click(window: Window, control: Control) -> void:
	var point := Vector2(window.position) + control.get_global_rect().get_center()
	# Positions are logical viewport coordinates; passing true avoids applying
	# the root window's stretch transform again at the smaller desktop size.
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
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


func capture() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.views_path = "user://capture_named_views.json"
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".damaged"]:
		if FileAccess.file_exists(viewer.views_path + suffix):
			DirAccess.remove_absolute(viewer.views_path + suffix)
	viewer.chest_view()
	var browser: Window = viewer.show_saved_views()
	await process_frame
	await process_frame
	browser.name_input.text = "Heart in chest · female HRA"
	await click(browser, browser.save_button)
	if browser.library.entries.size() != 1:
		push_error("Native Save current view click did not create a bookmark")
		quit(1)
		return
	browser.queue_free()
	await process_frame
	await viewer.switch_body("bodyparts-male-bones-study")
	viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
	viewer.inspect_alone()
	root.size = Vector2i(1100, 720)
	await process_frame
	browser = viewer.show_saved_views()
	await process_frame
	await process_frame
	browser.name_input.text = "Right femur · separate male study"
	await click(browser, browser.save_button)
	if browser.library.entries.size() != 2:
		print("Saved views UI result: ", browser.message.text, " · library read: ", browser.library.read_error)
		push_error("Native bookmark save did not retain both references")
		quit(1)
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-views-library.png")
	for control in [browser.name_input, browser.save_button, browser.restore_button, browser.rename_button, browser.delete_button, browser.information]:
		if not Rect2(Vector2.ZERO, Vector2(browser.size)).encloses(control.get_global_rect()):
			push_error("A saved-view action overflows the compact window")
			quit(1)
			return
	# Activate a list row and restore through ordinary UI input.
	browser.view_list.select(1)
	browser.select_entry(1)
	await click(browser, browser.restore_button)
	while viewer.loading:
		await process_frame
	if viewer.model.body.id != "female" or viewer.model.selected_id != "anatomy.heart":
		push_error("Native Restore click did not restore the named heart view")
		quit(1)
		return
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".damaged"]:
		if FileAccess.file_exists(viewer.views_path + suffix):
			DirAccess.remove_absolute(viewer.views_path + suffix)
	viewer.queue_free()
	await process_frame
	print("PASS rendered named views, native save/restore input and compact layout" if result == OK else "Named-view capture failed")
	quit(0 if result == OK else 1)
