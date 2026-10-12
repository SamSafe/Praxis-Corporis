extends SceneTree

var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func key(code: int, shift: bool = false, alt: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	event.alt_pressed = alt
	root.push_input(event)
	await process_frame


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.select_structure("anatomy.heart.valve.mitral")
	viewer.inspect_alone()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.03, 0.01, 0))
	var anatomy: Dictionary = viewer.model.export_state()
	var history: int = viewer.model.undo_stack.size()
	viewer.scene_container.grab_focus()
	var before: Dictionary = viewer.orbit.export_state()
	await key(KEY_RIGHT)
	check(viewer.orbit.yaw != before.yaw and viewer.orbit.target == Vector3(before.target[0], before.target[1], before.target[2]), "Focused arrows orbit without panning")
	before = viewer.orbit.export_state()
	await key(KEY_UP, true)
	check(viewer.orbit.export_state().target != before.target and viewer.orbit.yaw == before.yaw, "Shift-arrow pans without changing orbit angle")
	var distance: float = viewer.orbit.distance
	await key(KEY_EQUAL)
	check(viewer.orbit.distance < distance, "Keyboard plus zooms in")
	distance = viewer.orbit.distance
	await key(KEY_MINUS)
	check(viewer.orbit.distance > distance, "Keyboard minus zooms out")
	check(viewer.model.export_state() == anatomy and viewer.model.undo_stack.size() == history, "Camera keyboard input preserves anatomy and inspection undo")
	viewer.move_button.button_pressed = true
	viewer.orbit.move_mode = true
	await key(KEY_LEFT)
	check(not viewer.orbit.move_mode and not viewer.move_button.button_pressed and viewer.model.export_state() == anatomy, "Keyboard camera control safely leaves Move mode")
	viewer.search.grab_focus()
	before = viewer.orbit.export_state()
	await key(KEY_RIGHT)
	await key(KEY_EQUAL)
	check(viewer.orbit.export_state() == before, "Typing/navigation in search never orbits or zooms the body")
	viewer.tree.grab_focus()
	before = viewer.orbit.export_state()
	await key(KEY_RIGHT)
	check(viewer.orbit.yaw == before.yaw, "Tree arrows remain tree navigation rather than camera rotation")
	viewer.scene_container.grab_focus()
	viewer.select_structure("anatomy.heart.valve.mitral")
	before = viewer.current_view()
	var size_before: Vector2i = viewer.viewport.size
	viewer.on_panel_action(0)
	viewer.on_panel_action(1)
	await process_frame
	await process_frame
	check(not viewer.explorer_panel.visible and not viewer.details_panel.visible and viewer.viewport.size.x > size_before.x, "Hiding both side panels gives the scene more width")
	check(viewer.current_view() == before and viewer.model.export_state() == anatomy, "Panel collapse preserves selection, camera, isolation and anatomy state")
	check(not viewer.panels_menu.get_popup().is_item_checked(0) and not viewer.panels_menu.get_popup().is_item_checked(1), "Panel menu reflects actual visibility")
	viewer.on_panel_action(0)
	viewer.on_panel_action(1)
	await process_frame
	await process_frame
	check(viewer.explorer_panel.visible and viewer.details_panel.visible and viewer.viewport.size == size_before, "Panels return without losing their contents or scene layout")
	viewer.scene_container.grab_focus()
	await key(KEY_HOME)
	check(viewer.model.isolated_id.is_empty() and viewer.model.export_state() == anatomy, "Home returns to body context while retaining inspection edits")
	viewer.select_structure("anatomy.heart.valve.mitral")
	viewer.scene_container.grab_focus()
	viewer.orbit.keyboard_pan(Vector2.RIGHT)
	await key(KEY_F)
	check(viewer.orbit.target.is_equal_approx(viewer.model.bounds_for(viewer.model.selected_id).get_center()), "F fits the actual selected source bounds")
	var earlier: Dictionary = viewer.back_views.back().duplicate(true)
	var forward_count: int = viewer.forward_views.size()
	await key(KEY_LEFT, false, true)
	check(viewer.current_view() == earlier and viewer.forward_views.size() == forward_count + 1 and viewer.model.export_state() == anatomy, "Alt-history remains available from the focused scene and preserves inspection")
	await viewer.switch_body("bodyparts-male-bones-study")
	viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
	viewer.inspect_alone()
	viewer.scene_container.grab_focus()
	before = viewer.orbit.export_state()
	await key(KEY_DOWN)
	check(viewer.orbit.pitch != before.pitch and viewer.model.selected_id == "source.bodyparts3d-v4-male.FJ3365", "Keyboard orbit works in the separate source study")
	viewer.queue_free()
	await process_frame
	print("Keyboard workspace failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
