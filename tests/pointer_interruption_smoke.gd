extends SceneTree

var failures := 0
var clicks := 0
var checkpoints := 0
var movements := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func button(orbit: Node3D, index: int, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = index
	event.pressed = pressed
	event.canceled = canceled
	event.position = Vector2(100, 100)
	orbit._unhandled_input(event)


func motion(orbit: Node3D, mask: int) -> void:
	var event := InputEventMouseMotion.new()
	event.position = Vector2(124, 112)
	event.relative = Vector2(24, 12)
	event.button_mask = mask
	orbit._unhandled_input(event)


func idle(orbit: Node3D) -> bool:
	return orbit.active_button == 0 and not orbit.dragged and not orbit.move_checkpoint


func run() -> void:
	var script_path := "res://scripts/orbit_camera.gd"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--orbit-script="):
			script_path = argument.trim_prefix("--orbit-script=")
	var orbit = load(script_path).new()
	root.add_child(orbit)
	orbit.clicked.connect(func(_point: Vector2): clicks += 1)
	orbit.move_started.connect(func(): checkpoints += 1)
	orbit.moved.connect(func(_delta: Vector3): movements += 1)
	await process_frame
	for index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		orbit.cancel_drag()
		var before: Dictionary = orbit.export_state()
		button(orbit, index, true)
		motion(orbit, 1 << (index - 1))
		check(orbit.export_state() != before, "A held button still navigates: " + str(index))
		before = orbit.export_state()
		motion(orbit, 0)
		check(idle(orbit) and orbit.export_state() == before,
			"A missing release stops navigation before an unheld motion: " + str(index))
	button(orbit, MOUSE_BUTTON_LEFT, true)
	var before: Dictionary = orbit.export_state()
	motion(orbit, MOUSE_BUTTON_MASK_RIGHT)
	check(idle(orbit) and orbit.export_state() == before, "A different held button cannot continue a stale drag")
	button(orbit, MOUSE_BUTTON_LEFT, true)
	motion(orbit, MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT)
	check(orbit.active_button == MOUSE_BUTTON_LEFT and orbit.export_state() != before, "Additional held buttons do not cancel the active button")
	orbit.cancel_drag()
	orbit.move_mode = true
	button(orbit, MOUSE_BUTTON_LEFT, true)
	motion(orbit, MOUSE_BUTTON_MASK_LEFT)
	var unheld_movements := movements
	motion(orbit, 0)
	check(idle(orbit) and movements == unheld_movements and orbit.move_mode, "A missing release cannot keep editing anatomy in Move mode")
	for notification in [Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT, Node.NOTIFICATION_APPLICATION_FOCUS_OUT]:
		button(orbit, MOUSE_BUTTON_LEFT, true)
		motion(orbit, MOUSE_BUTTON_MASK_LEFT)
		var moved_before := movements
		var clicks_before := clicks
		before = orbit.export_state()
		root.propagate_notification(notification)
		check(idle(orbit) and orbit.move_mode, "Focus loss stops the gesture and keeps the chosen Move mode")
		motion(orbit, MOUSE_BUTTON_MASK_LEFT)
		button(orbit, MOUSE_BUTTON_LEFT, false)
		check(movements == moved_before and clicks == clicks_before and orbit.export_state() == before,
			"Motion and a late release after focus loss cannot move or select anatomy")
	button(orbit, MOUSE_BUTTON_LEFT, true)
	var clicks_before := clicks
	button(orbit, MOUSE_BUTTON_LEFT, false, true)
	check(idle(orbit) and clicks == clicks_before, "A canceled click never requests an anatomy selection")
	button(orbit, MOUSE_BUTTON_LEFT, true, true)
	check(idle(orbit), "A canceled event cannot start a gesture")
	button(orbit, MOUSE_BUTTON_LEFT, true)
	motion(orbit, MOUSE_BUTTON_MASK_LEFT)
	var moved_before := movements
	button(orbit, MOUSE_BUTTON_LEFT, false, true)
	check(idle(orbit) and movements == moved_before and clicks == clicks_before, "Canceling a Move drag clears all gesture bookkeeping")
	var checkpoints_before := checkpoints
	button(orbit, MOUSE_BUTTON_LEFT, true)
	motion(orbit, MOUSE_BUTTON_MASK_LEFT)
	motion(orbit, MOUSE_BUTTON_MASK_LEFT)
	check(checkpoints == checkpoints_before + 1, "A continuous Move drag creates exactly one undo checkpoint")
	orbit.cancel_drag()
	button(orbit, MOUSE_BUTTON_LEFT, true)
	motion(orbit, MOUSE_BUTTON_MASK_LEFT)
	check(checkpoints == checkpoints_before + 2, "A fresh drag after interruption gets its own undo checkpoint")
	orbit.cancel_drag()
	button(orbit, MOUSE_BUTTON_LEFT, true)
	var clean_clicks := clicks
	button(orbit, MOUSE_BUTTON_LEFT, false)
	check(clicks == clean_clicks + 1, "An ordinary click still requests exactly one selection")
	orbit.queue_free()
	await process_frame
	print("Pointer interruption failures: ", failures)
	quit(0 if failures == 0 else 1)
