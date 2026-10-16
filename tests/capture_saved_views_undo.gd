extends SceneTree

var failures := 0
var directory := "user://capture-view-undo-" + Crypto.new().generate_random_bytes(8).hex_encode()


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func click(window: Window, control: Control) -> void:
	var point := Vector2(window.position) + control.get_global_rect().get_center()
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
	await process_frame


func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	DirAccess.make_dir_recursive_absolute("/tmp/medicine-viewer-feasibility")
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.views_path = directory + "/views.json"
	viewer.chest_view()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.01, 0, 0))
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	preferences.text_scale = 1.3
	viewer.apply_preferences(preferences)
	root.size = Vector2i(1100, 720)
	var browser: Window = viewer.show_saved_views()
	for view_name in ["Heart in chest", "Source observations", "Questions to revisit"]:
		browser.name_input.text = view_name
		browser.save_current()
	var id: String = browser.library.entries[1].id
	browser.library.set_notes(id, "My saved observations about this source view.")
	browser.refresh_list(id)
	var stored: Dictionary = browser.selected_entry().duplicate(true)
	var draft := "My unfinished notes 🫀\nQuestions for the next study session."
	browser.notes_input.text = draft
	browser.on_notes_changed()
	browser.size = Vector2i(720, 500)
	await process_frame
	await process_frame
	await click(browser, browser.delete_button)
	await click(browser, browser.delete_button)
	check(browser.library.entries.size() == 2 and browser.undo_delete_button.visible and browser.undo_delete_button.has_focus(),
		"Real Delete clicks offer Undo after confirmation")
	var bounds := Rect2(Vector2.ZERO, Vector2(browser.size))
	for control in [browser.message, browser.undo_delete_button, browser.restore_button, browser.rename_button, browser.delete_button, browser.close_button]:
		check(bounds.encloses(control.get_global_rect()), "Saved-view action stays visible at minimum size with 130% text: " + control.name)
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-view-delete-undo.png") == OK, "Undo offer capture saved")
	await click(browser, browser.undo_delete_button)
	check(browser.library.entries.size() == 3 and browser.library.entries[1] == stored and browser.selected_entry().get("id") == id,
		"Real Undo click restores the exact entry at its prior position")
	check(browser.notes_input.text == draft and browser.draft_notes.get(id) == draft and browser.library.entries[1].notes == stored.notes and "Unsaved" in browser.notes_status.text,
		"Restored note remains visibly unsaved until Save notes")
	check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward,
		"Library deletion and undo preserve camera, reference, anatomy edits and both histories")
	browser.notes_input.grab_focus()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-view-delete-restored.png") == OK, "Recovered draft capture saved")
	await click(browser, browser.close_button)
	check(browser.unsaved_dialog.visible, "Closing after undo protects the recovered draft")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	browser.view_list.select(0)
	browser.select_entry(0)
	var other_id: String = browser.selected_entry().id
	var other_note := "Another view's unfinished observations."
	browser.notes_input.text = other_note
	browser.on_notes_changed()
	check(browser.draft_notes.size() == 2 and "1 other view with unsaved notes" in browser.notes_status.text, "Other pending notes are counted without switching away")
	browser.content_scroll.ensure_control_visible(browser.save_all_notes_button)
	await process_frame
	await process_frame
	check(browser.content_scroll.get_global_rect().encloses(browser.save_all_notes_button.get_global_rect()), "Save all notes can be reached at minimum size with 130% text")
	var unfinished_name := "A name for my next view"
	browser.name_input.text = unfinished_name
	browser.name_input.caret_column = 8
	await click(browser, browser.save_all_notes_button)
	check(browser.draft_notes.is_empty() and browser.library.entries[1].notes == draft and browser.library.entries[0].notes == other_note and browser.selected_entry().id == other_id and not browser.is_queued_for_deletion(),
		"Real Save all notes click persists both drafts while keeping the selected view and library open")
	check(browser.name_input.text == unfinished_name and browser.name_input.caret_column == 8, "Saving all notes keeps an unfinished view name and its cursor")
	check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward,
		"Saving all notes preserves the entire anatomy view and both histories")
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/saved-notes-save-all-minimum.png") == OK, "Save all notes capture saved")
	await click(browser, browser.close_button)
	await process_frame
	browser = viewer.show_saved_views()
	check(browser.last_deleted.is_empty() and not browser.undo_delete_button.visible and browser.library.entries[1].id == id and browser.library.entries[1].notes == draft,
		"Reopened library retains the restored view and saved notes without a lingering undo")
	browser.queue_free()
	viewer.queue_free()
	await process_frame
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Rendered saved-view deletion undo failures: ", failures)
	if failures == 0:
		print("PASS rendered save all study notes: real mouse, 130% text and minimum library size")
	quit(0 if failures == 0 else 1)
