extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func key(code: Key, control: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.ctrl_pressed = control
	event.pressed = true
	root.push_input(event)
	await process_frame
	await process_frame


func click(control: Control) -> void:
	await process_frame
	await process_frame
	var point := control.get_global_rect().get_center()
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


func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/" + name + ".png") == OK, "Capture saved: " + name)


func run() -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/medicine-viewer-feasibility")
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.chest_view()
	var preferences: Dictionary = viewer.preference_state()
	preferences.text_scale = 1.3
	viewer.apply_preferences(preferences)
	root.size = Vector2i(1100, 720)
	viewer.search.text = "heart"
	viewer.rebuild_tree()
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	viewer.on_panel_action(0)
	viewer.scene_container.grab_focus()
	# Open the actual View popup by mouse and activate its Find row by keyboard.
	await click(viewer.panels_menu)
	var popup: PopupMenu = viewer.panels_menu.get_popup()
	check(popup.visible, "The View menu opens through mouse input")
	popup.set_focused_item(popup.get_item_index(5))
	await key(KEY_ENTER)
	check(not popup.visible and viewer.explorer_panel.visible and viewer.search.has_focus() and viewer.search.get_selected_text() == "heart",
		"Menu Find wins focus after the popup closes and retains the query")
	check(viewer.export_view_state() == before, "Menu Find preserves the actual source view")
	await capture("find-anatomy-menu-focus")
	await key(KEY_ESCAPE)
	await key(KEY_ESCAPE)
	check(viewer.scene_container.has_focus(), "Two Escapes return keyboard focus to anatomy")
	viewer.set_scene_expanded(true)
	await click(viewer.expanded_menu)
	popup = viewer.expanded_menu.get_popup()
	check(popup.visible and root.get_visible_rect().encloses(Rect2(Vector2(popup.position), Vector2(popup.size))), "Expanded menu stays within the minimum window at 130% text")
	popup.set_focused_item(popup.get_item_index(viewer.ExpandedAction.FIND_ANATOMY))
	await capture("find-anatomy-expanded-menu")
	await key(KEY_ENTER)
	check(not viewer.scene_expanded and viewer.search.has_focus() and viewer.export_view_state() == before, "Expanded menu Find returns to the same source view and focuses search")
	await key(KEY_ESCAPE)
	viewer.set_scene_expanded(true)
	await key(KEY_F, true)
	check(not viewer.scene_expanded and viewer.search.has_focus() and viewer.export_view_state() == before, "Ctrl+F also reaches search from the rendered expanded scene")
	await capture("find-anatomy-compact-focus")
	viewer.search.text = "heart"
	viewer.rebuild_tree()
	await key(KEY_ENTER)
	var selected_view: Dictionary = viewer.export_view_state().duplicate(true)
	check(viewer.search_results.has_focus(), "Enter selects a source result and focuses its list")
	await key(KEY_ESCAPE)
	check(viewer.search.has_focus() and viewer.search.text.is_empty() and viewer.export_view_state() == selected_view,
		"Escape from rendered results clears search while retaining the selected source view")
	await key(KEY_ESCAPE)
	check(viewer.scene_container.has_focus(), "Search results have a keyboard route back to 3D")
	viewer.queue_free()
	await process_frame
	print("Rendered Find anatomy failures: ", failures)
	quit(0 if failures == 0 else 1)
