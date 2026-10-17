extends SceneTree

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func wheel(orbit: Node3D, closer: bool, amount: float = 1.0, canceled: bool = false, pressed: bool = true) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_WHEEL_UP if closer else MOUSE_BUTTON_WHEEL_DOWN
	event.factor = amount
	event.pressed = pressed
	event.canceled = canceled
	orbit._unhandled_input(event)


func pinch(orbit: Node3D, factor: float) -> void:
	var event := InputEventMagnifyGesture.new()
	event.factor = factor
	orbit._unhandled_input(event)


func run() -> void:
	var script_path := "res://scripts/orbit_camera.gd"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--orbit-script="):
			script_path = argument.trim_prefix("--orbit-script=")
	var orbit = load(script_path).new()
	root.add_child(orbit)
	await process_frame
	var before: Dictionary = orbit.export_state()
	var unwanted := [0]
	orbit.clicked.connect(func(_point: Vector2): unwanted[0] += 1)
	orbit.move_started.connect(func(): unwanted[0] += 1)
	orbit.moved.connect(func(_delta: Vector3): unwanted[0] += 1)
	for repeat in 40:
		orbit.keyboard_zoom(true)
		orbit.keyboard_zoom(false)
	print("Keyboard reverse pairs: initial ", before.distance, " · final ", orbit.distance)
	check(is_equal_approx(orbit.distance, float(before.distance)), "Opposite keyboard steps do not accumulate zoom drift")
	orbit.apply_state(before)
	orbit.keyboard_zoom(true)
	var full_step: float = orbit.distance
	check(full_step < float(before.distance), "The existing zoom-in direction and useful step remain")
	orbit.apply_state(before)
	for repeat in 4:
		wheel(orbit, true, 0.25)
	check(is_equal_approx(orbit.distance, full_step), "Four quarter-wheel events equal one full zoom step")
	orbit.apply_state(before)
	for repeat in 40:
		wheel(orbit, true, 0.25)
		wheel(orbit, false, 0.25)
	check(is_equal_approx(orbit.distance, float(before.distance)), "Opposite fine-wheel events preserve framing")
	orbit.apply_state(before)
	for repeat in 4:
		orbit.keyboard_zoom(true)
	var four_steps: float = orbit.distance
	orbit.apply_state(before)
	wheel(orbit, true, 4.0)
	check(is_equal_approx(orbit.distance, four_steps), "Wheel amount honors a multi-step event")
	orbit.apply_state(before)
	wheel(orbit, true, 0.0)
	check(is_equal_approx(orbit.distance, full_step), "A platform without wheel amounts keeps one ordinary step")
	orbit.apply_state(before)
	wheel(orbit, true, -0.25)
	var signed_step: float = orbit.distance
	orbit.apply_state(before)
	wheel(orbit, true, 0.25)
	check(is_equal_approx(orbit.distance, signed_step) and orbit.distance < float(before.distance), "Signed wheel magnitudes retain the button's zoom direction")
	for amount in [NAN, INF, -INF]:
		orbit.apply_state(before)
		wheel(orbit, true, amount)
		check(orbit.export_state() == before, "Non-finite wheel amounts are ignored")
	orbit.apply_state(before)
	wheel(orbit, true, 1.0, true)
	wheel(orbit, false, 1.0, false, false)
	check(orbit.export_state() == before, "Canceled and release-only wheel events never zoom")
	wheel(orbit, true, 1e30)
	check(orbit.distance == 0.018 and orbit.valid_state(orbit.export_state()), "Very large inward amounts stop at the finite near limit")
	wheel(orbit, false, 1e30)
	check(orbit.distance == 12.0 and orbit.valid_state(orbit.export_state()), "Very large outward amounts stop at the finite far limit")
	for factor in [0.0, -1.0, NAN, INF, -INF]:
		orbit.apply_state(before)
		pinch(orbit, factor)
		check(orbit.export_state() == before, "Invalid pinch factors cannot jump or corrupt the camera")
	orbit.apply_state(before)
	pinch(orbit, 1.1)
	pinch(orbit, 1.0 / 1.1)
	check(is_equal_approx(orbit.distance, float(before.distance)), "Opposite valid pinch gestures retain framing")
	orbit.distance = 0.1
	pinch(orbit, 0.05)
	check(is_equal_approx(orbit.distance, 2.0), "Small positive pinch factors retain their reported amount")
	orbit.apply_state(before)
	orbit.input_enabled = false
	wheel(orbit, true, 0.25)
	pinch(orbit, 1.1)
	check(orbit.export_state() == before, "Suspended pointer input cannot zoom")
	check(unwanted[0] == 0 and orbit.target == Vector3(before.target[0], before.target[1], before.target[2]) and orbit.yaw == before.yaw and orbit.pitch == before.pitch,
		"Zoom never selects or moves anatomy or changes the camera's focus/orientation")
	orbit.queue_free()
	await process_frame
	print("Camera zoom failures: ", failures)
	quit(0 if failures == 0 else 1)
