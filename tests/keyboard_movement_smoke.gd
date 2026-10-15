extends SceneTree

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func key(code: int, shift: bool = false, ctrl: bool = false, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = ctrl
	event.echo = echo
	root.push_input(event)
	await process_frame


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	for reference in viewer.pack.bodies:
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		var leaf: String = reference.get("qa_leaf_id", "source.bodyparts3d-v4-male.FJ3365" if reference.get("study") else "anatomy.heart.valve.mitral")
		viewer.select_structure(leaf)
		viewer.inspect_alone()
		viewer.orbit.yaw = 0.6
		viewer.orbit.pitch = 0.3
		viewer.orbit.update_camera()
		viewer.scene_container.grab_focus()
		var camera: Dictionary = viewer.orbit.export_state().duplicate(true)
		var original: Dictionary = viewer.model.export_state().duplicate(true)
		await key(KEY_L)
		check(viewer.model.export_state() == original, "Nudge keys require explicit Move mode: " + reference.id)
		await key(KEY_M)
		check(viewer.orbit.move_mode and viewer.move_button.button_pressed and "MOVE" in viewer.navigation_hint.text, "M enters Move with a visible hint")
		var index: int = viewer.model.structures[leaf].mesh_nodes[0]
		var offset: Vector3 = viewer.model.states[index].offset
		var undo_count: int = viewer.model.undo_stack.size()
		await key(KEY_L)
		check((viewer.model.states[index].offset - offset).is_equal_approx(viewer.orbit.camera.global_basis.x * 0.005), "Right step is exactly 5 mm in camera coordinates")
		var moved: Dictionary = viewer.model.export_state().duplicate(true)
		await key(KEY_L, false, false, true)
		check(viewer.model.export_state() == moved and viewer.model.undo_stack.size() == undo_count + 1, "Held-key repeat cannot flood movement or undo history")
		await key(KEY_Z, false, true)
		check(viewer.model.export_state() == original, "Ctrl-Z reverses one movement step")
		await key(KEY_Z, true, true)
		check(viewer.model.export_state() == moved, "Ctrl-Shift-Z redoes the exact movement")
		offset = viewer.model.states[index].offset
		await key(KEY_I, true)
		check((viewer.model.states[index].offset - offset).is_equal_approx(viewer.orbit.camera.global_basis.y * 0.001), "Shift gives a 1 mm up step")
		offset = viewer.model.states[index].offset
		await key(KEY_U)
		check((viewer.model.states[index].offset - offset).is_equal_approx(viewer.orbit.camera.global_basis.z * 0.005), "Toward step follows camera depth")
		await key(KEY_O)
		check(viewer.model.states[index].offset.is_equal_approx(offset), "Away step reverses the depth increment")
		check(viewer.orbit.export_state() == camera and viewer.model.isolated_id == leaf, "Movement preserves camera and isolation")
		check(viewer.validate_view_state(viewer.export_view_state()).is_empty(), "Moved view retains valid save format")
		viewer.search.grab_focus()
		moved = viewer.model.export_state().duplicate(true)
		await key(KEY_M)
		await key(KEY_I)
		check(viewer.model.export_state() == moved and viewer.orbit.move_mode, "Typing in search cannot move anatomy or toggle its mode")
		viewer.scene_container.grab_focus()
		viewer.set_scene_expanded(true)
		await key(KEY_J)
		check(viewer.model.export_state() != moved and viewer.scene_expanded, "Movement works in expanded anatomy")
		await key(KEY_ESCAPE)
		await key(KEY_ESCAPE)
		check(not viewer.orbit.move_mode and "MOVE" not in viewer.navigation_hint.text, "Escape returns to navigation and clears Move hint")
		await key(KEY_M)
		moved = viewer.model.export_state().duplicate(true)
		await key(KEY_RIGHT)
		check(not viewer.orbit.move_mode and viewer.model.export_state() == moved, "Camera arrows preserve edits while leaving Move")
	viewer.queue_free()
	await process_frame
	print("Keyboard movement failures: ", failures)
	quit(0 if failures == 0 else 1)
