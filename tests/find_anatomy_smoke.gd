extends SceneTree

var failures := 0
var library_path := "user://find-anatomy-" + Crypto.new().generate_random_bytes(8).hex_encode() + ".json"


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func key(code: Key, control: bool = false, command: bool = false, alt: bool = false, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.ctrl_pressed = control
	event.meta_pressed = command
	event.alt_pressed = alt
	event.shift_pressed = shift
	root.push_input(event)
	await process_frame
	await process_frame


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	check(viewer.model.body.is_empty() and not viewer.search.editable, "Search stays read-only until its first reference index is available")
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.views_path = library_path
	viewer.chest_view()
	viewer.select_structure("anatomy.heart.valve.mitral")
	viewer.inspect_alone()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.02, 0.01, 0))
	viewer.move_button.button_pressed = true
	viewer.orbit.move_mode = true
	viewer.search.text = "heart"
	viewer.rebuild_tree()
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	viewer.on_panel_action(0)
	viewer.on_panel_action(1)
	viewer.scene_container.grab_focus()
	await key(KEY_F, true)
	check(viewer.explorer_panel.visible and not viewer.details_panel.visible and viewer.search.has_focus() and viewer.search.get_selected_text() == "heart",
		"Ctrl+F reveals only the anatomy panel, preserves the query and selects it for editing")
	check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward and viewer.orbit.move_mode,
		"Finding anatomy preserves selection, camera, isolation, edits, Move mode and both histories")
	viewer.scene_container.grab_focus()
	var immediate := InputEventKey.new()
	immediate.keycode = KEY_F
	immediate.ctrl_pressed = true
	immediate.pressed = true
	root.push_input(immediate)
	check(viewer.search.has_focus(), "Find transfers focus within the same input event")
	immediate = InputEventKey.new()
	immediate.keycode = KEY_M
	immediate.unicode = 109
	immediate.pressed = true
	root.push_input(immediate)
	check(viewer.search.text == "m" and viewer.orbit.move_mode and viewer.export_view_state() == before,
		"Immediate typing edits the search instead of toggling the 3D Move command")
	viewer.search.text = "heart"
	viewer.rebuild_tree()
	viewer.search.deselect()
	viewer.search.caret_column = 1
	await key(KEY_F, true)
	check(viewer.search.has_focus() and viewer.search.get_selected_text() == "heart", "Ctrl+F within search selects the existing query")
	await key(KEY_ESCAPE)
	check(viewer.search.text.is_empty() and viewer.tree.visible and not viewer.search_results.visible and viewer.search.has_focus() and viewer.export_view_state() == before,
		"First Escape clears the query and reveals the hierarchy without changing anatomy")
	await key(KEY_ESCAPE)
	check(viewer.scene_container.has_focus() and viewer.orbit.move_mode, "Escape in an empty search returns focus to 3D without changing Move mode")
	viewer.on_panel_action(0)
	await key(KEY_F, true, false, false, true)
	await key(KEY_F, true, false, true)
	check(not viewer.explorer_panel.visible and viewer.scene_container.has_focus(), "Modified shortcuts are left alone")
	viewer.set_scene_expanded(true)
	await key(KEY_F, false, true)
	check(not viewer.scene_expanded and viewer.explorer_panel.visible and viewer.search.has_focus() and viewer.export_view_state() == before,
		"Cmd+F returns from expanded anatomy and opens search without altering the source view")
	viewer.search.text = "anatomy.heart.valve.mitral"
	viewer.rebuild_tree()
	viewer.activate_first_search_result()
	var selected_view: Dictionary = viewer.export_view_state().duplicate(true)
	check(viewer.search_results.has_focus(), "Selecting a search result keeps list keyboard navigation available")
	await key(KEY_ESCAPE)
	check(viewer.search.text.is_empty() and viewer.tree.visible and viewer.search.has_focus() and viewer.export_view_state() == selected_view,
		"Escape from the result list clears the query without changing the selected source view")
	await key(KEY_ESCAPE)
	check(viewer.scene_container.has_focus(), "The second Escape after a result returns focus to 3D")
	viewer.start_guided_chest()
	viewer.apply_chest_step(2)
	var guided: Dictionary = viewer.export_view_state().duplicate(true)
	var guide_return: Dictionary = viewer.guided_chest.original.duplicate(true)
	viewer.set_scene_expanded(true)
	viewer.on_expanded_action(viewer.ExpandedAction.FIND_ANATOMY)
	await process_frame
	await process_frame
	check(not viewer.scene_expanded and viewer.search.has_focus() and viewer.guided_chest.active and viewer.guided_chest.step == 2 and viewer.guided_chest.original == guide_return and viewer.export_view_state() == guided,
		"The expanded Find action keeps the current study step and its exact return context")
	await viewer.finish_guided_chest()
	viewer.on_panel_action(0)
	var browser: Window = viewer.show_saved_views()
	await process_frame
	await key(KEY_F, true)
	check(browser.filter_input.has_focus() and not viewer.explorer_panel.visible and not viewer.search.has_focus(), "Saved views keeps its own Ctrl+F without revealing anatomy search behind it")
	browser.queue_free()
	await process_frame
	var help: Window = viewer.show_keyboard_help()
	await process_frame
	await key(KEY_F, true)
	check(help.visible and not viewer.explorer_panel.visible, "An exclusive information window keeps anatomy shortcuts out of its background")
	help.queue_free()
	await process_frame
	viewer.scene_container.grab_focus()
	var during := [false]
	viewer.model.load_progress.connect(func(stage: String, _fraction: float):
		if stage == "Checking source file" and not during[0]:
			during[0] = true
			viewer.focus_anatomy_search()
			check(not viewer.explorer_panel.visible and viewer.panels_menu.get_popup().is_item_disabled(viewer.panels_menu.get_popup().get_item_index(5)),
				"Find remains unavailable during an actual replacement load"))
	await viewer.switch_body("male")
	check(during[0] and not viewer.panels_menu.get_popup().is_item_disabled(viewer.panels_menu.get_popup().get_item_index(5)), "Find becomes available again after loading")
	viewer.on_panel_action(5)
	await process_frame
	await process_frame
	check(viewer.search.has_focus() and viewer.explorer_panel.visible and viewer.model.body.id == "male", "View menu Find works with the newly loaded reference")
	viewer.queue_free()
	await process_frame
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(library_path + suffix):
			DirAccess.remove_absolute(library_path + suffix)
	print("Find anatomy failures: ", failures)
	quit(0 if failures == 0 else 1)
