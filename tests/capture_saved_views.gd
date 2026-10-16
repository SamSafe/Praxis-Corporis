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
	DirAccess.make_dir_recursive_absolute("/tmp/medicine-viewer-feasibility")
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
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.03, 0.01, 0))
	var preferences: Dictionary = viewer.preference_state()
	preferences.text_scale = 1.3
	viewer.apply_preferences(preferences)
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
	var anatomy_before: Dictionary = viewer.model.export_state()
	await click(browser, browser.notes_input)
	browser.notes_input.text = "Revisit this source bone view.\nQuestions for my next study session:\n• Which source structures are absent?\n• Compare my observations with course material."
	await process_frame
	var note: String = browser.notes_input.text
	browser.notes_input.insert_text_at_caret("Temporary text")
	await process_frame
	var undo := InputEventKey.new()
	undo.pressed = true
	undo.keycode = KEY_Z
	undo.ctrl_pressed = true
	root.push_input(undo)
	await process_frame
	if browser.notes_input.text != note or viewer.model.export_state() != anatomy_before:
		push_error("Text editing undo changed anatomy or failed to restore the note")
		quit(1)
		return
	await click(browser, browser.notes_button)
	if browser.library.entries[0].get("notes", "") != note or not browser.draft_notes.is_empty():
		push_error("Native Save notes click failed to preserve the study note")
		quit(1)
		return
	browser.notes_input.insert_text_at_caret("\nAnother draft to protect.")
	await process_frame
	browser.close_requested.emit()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	if not browser.unsaved_dialog.visible or root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-views-unsaved-notes.png") != OK:
		push_error("Unsaved-notes protection failed to render")
		quit(1)
		return
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	browser.notes_input.text = note
	browser.on_notes_changed()
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-views-library.png")
	for control in [browser.content_scroll, browser.restore_button, browser.rename_button, browser.delete_button, browser.close_button]:
		if not Rect2(Vector2.ZERO, Vector2(browser.size)).encloses(control.get_global_rect()):
			push_error("A saved-view action overflows the compact window")
			quit(1)
			return
	browser.filter_input.grab_focus()
	browser.filter_input.text = "source bone"
	browser.filter_input.text_changed.emit(browser.filter_input.text)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	if not browser.content_scroll.get_global_rect().encloses(browser.filter_input.get_global_rect()):
		push_error("Focusing saved-view search did not bring it into view")
		quit(1)
		return
	if browser.view_list.item_count != 1 or root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-views-search.png") != OK:
		push_error("Saved-view note search failed to render")
		quit(1)
		return
	var previous_size: Vector2i = browser.size
	browser.size = Vector2i(720, 500)
	browser.notes_input.grab_focus()
	await process_frame
	await process_frame
	var find := InputEventKey.new()
	find.keycode = KEY_F
	find.ctrl_pressed = true
	find.pressed = true
	browser.push_input(find)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	for control in [browser.content_scroll, browser.restore_button, browser.rename_button, browser.delete_button, browser.close_button]:
		if not Rect2(Vector2.ZERO, Vector2(browser.size)).encloses(control.get_global_rect()):
			push_error("A saved-view action overflows at the minimum dialog size")
			quit(1)
			return
	if not browser.filter_input.has_focus() or not browser.content_scroll.get_global_rect().encloses(browser.filter_input.get_global_rect()) or root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-views-search-minimum.png") != OK:
		push_error("Search cannot be reached from the note editor at minimum size")
		quit(1)
		return
	browser.size = previous_size
	await process_frame
	await process_frame
	browser.filter_input.text = ""
	browser.filter_input.text_changed.emit("")
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
	print("PASS rendered named views, study notes, text undo, native save/restore input and compact layout" if result == OK else "Named-view capture failed")
	quit(0 if result == OK else 1)
