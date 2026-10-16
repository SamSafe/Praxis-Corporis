extends Node3D

signal clicked(position: Vector2)
signal move_started
signal moved(delta: Vector3)

var camera: Camera3D
var target := Vector3.ZERO
var distance := 2.8
var yaw := 0.0
var pitch := 0.0
var move_mode := false
var input_enabled := true
var active_button := 0
var press_position := Vector2.ZERO
var dragged := false
var move_checkpoint := false
var display_size := Vector2.ZERO


func _ready() -> void:
	camera = Camera3D.new()
	camera.fov = 38.0
	camera.near = 0.002
	camera.far = 40.0
	add_child(camera)
	camera.current = true
	update_camera()


func update_camera() -> void:
	target = target.clamp(Vector3.ONE * -100.0, Vector3.ONE * 100.0)
	yaw = wrapf(yaw, -PI, PI)
	var direction := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
	camera.position = target + direction * distance
	camera.look_at(target, Vector3.UP)


func focus(bounds: AABB) -> void:
	target = bounds.get_center()
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect := maxf(viewport_size.x / maxf(viewport_size.y, 1.0), 0.2)
	var radius := maxf(bounds.size.length() * 0.5, 0.015)
	distance = clampf(radius / sin(deg_to_rad(camera.fov * 0.5)) / minf(aspect, 1.0) * 1.1, 0.035, 12.0)
	update_camera()


func pixel_scale() -> float:
	var height := display_size.y if display_size.y > 0 else get_viewport().get_visible_rect().size.y
	return 2.0 * distance * tan(deg_to_rad(camera.fov * 0.5)) / maxf(height, 1.0)


func keyboard_orbit(direction: Vector2) -> void:
	yaw += direction.x * 0.08
	pitch = clampf(pitch - direction.y * 0.08, -1.45, 1.45)
	update_camera()


func keyboard_pan(direction: Vector2) -> void:
	target += (camera.global_basis.x * direction.x - camera.global_basis.y * direction.y) * pixel_scale() * 30.0
	update_camera()


func keyboard_zoom(closer: bool) -> void:
	distance = clampf(distance * (0.88 if closer else 1.12), 0.018, 12.0)
	update_camera()


func cancel_drag() -> void:
	active_button = 0
	dragged = false
	move_checkpoint = false


func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		cancel_drag()


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	var ratio := Vector2.ONE
	if display_size.x > 0 and display_size.y > 0:
		ratio = get_viewport().get_visible_rect().size / display_size
	if event is InputEventMouseButton:
		if event.canceled:
			cancel_drag()
			return
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			distance = clampf(distance * (0.88 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.12), 0.018, 12.0)
			update_camera()
		elif event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if event.pressed:
				active_button = event.button_index
				press_position = event.position / ratio
				dragged = false
				move_checkpoint = false
			elif active_button == event.button_index:
				if not dragged and active_button == MOUSE_BUTTON_LEFT:
					clicked.emit(event.position)
				active_button = 0
	elif event is InputEventMouseMotion and active_button != 0:
		# Recover when a release was consumed elsewhere or lost during a focus change.
		if (event.button_mask & (1 << (active_button - 1))) == 0:
			cancel_drag()
			return
		if not dragged and (event.position / ratio).distance_to(press_position) < 4.0:
			return
		dragged = true
		var relative: Vector2 = event.relative / ratio
		var lateral: Vector3 = -camera.global_basis.x * relative.x + camera.global_basis.y * relative.y
		if move_mode and active_button == MOUSE_BUTTON_LEFT and not event.shift_pressed:
			if not move_checkpoint:
				move_started.emit()
				move_checkpoint = true
			moved.emit(-lateral * pixel_scale())
		elif event.shift_pressed or active_button != MOUSE_BUTTON_LEFT:
			target += lateral * pixel_scale()
			update_camera()
		else:
			yaw -= relative.x * 0.006
			pitch = clampf(pitch + relative.y * 0.006, -1.45, 1.45)
			update_camera()
	elif event is InputEventPanGesture:
		target += (-camera.global_basis.x * event.delta.x + camera.global_basis.y * event.delta.y) * pixel_scale() * 12.0
		update_camera()
	elif event is InputEventMagnifyGesture:
		distance = clampf(distance / maxf(event.factor, 0.1), 0.018, 12.0)
		update_camera()


func export_state() -> Dictionary:
	return {"target": [target.x, target.y, target.z], "distance": distance, "yaw": yaw, "pitch": pitch}


func valid_state(state: Dictionary) -> bool:
	var center = state.get("target")
	if not center is Array or center.size() != 3:
		return false
	for value in center + [state.get("distance"), state.get("yaw"), state.get("pitch")]:
		if not (value is float or value is int) or not is_finite(float(value)) or absf(float(value)) > 100.0:
			return false
	return float(state.distance) >= 0.018 and float(state.distance) <= 12.0 and absf(float(state.pitch)) <= 1.45


func apply_state(state: Dictionary) -> void:
	target = Vector3(float(state.target[0]), float(state.target[1]), float(state.target[2]))
	distance = float(state.distance)
	yaw = float(state.yaw)
	pitch = float(state.pitch)
	update_camera()
