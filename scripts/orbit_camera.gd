extends Node3D

signal clicked(position: Vector2)
signal double_clicked(position: Vector2)
signal move_started
signal moved(delta: Vector3)
signal view_changed

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
# Interactive motion: the drawn camera eases towards the logical state, a released orbit
# glides briefly, and the wheel zooms towards the cursor. The logical state (target,
# distance, yaw, pitch) still changes immediately, so saved views, picking rules and
# scripted checks see exact values. Off for scripted runs and when the user turns it off.
var interactive_motion := false
var shown_target := Vector3.ZERO
var shown_distance := 2.8
var shown_yaw := 0.0
var shown_pitch := 0.0
var response := 9.0
var glide := Vector2.ZERO
var last_motion_usec := 0
const JUMP_RESPONSE := 7.5
const KEY_RESPONSE := 16.0
const DRAG_RESPONSE := 30.0
const WHEEL_RESPONSE := 14.0


func _ready() -> void:
	camera = Camera3D.new()
	camera.fov = 38.0
	camera.near = 0.002
	camera.far = 40.0
	add_child(camera)
	camera.current = true
	set_process(false)
	snap_shown()


func update_camera(rate: float = JUMP_RESPONSE) -> void:
	target = target.clamp(Vector3.ONE * -100.0, Vector3.ONE * 100.0)
	yaw = wrapf(yaw, -PI, PI)
	if not interactive_motion or not is_inside_tree():
		snap_shown()
		return
	response = rate
	set_process(true)


func snap_shown() -> void:
	glide = Vector2.ZERO
	shown_target = target
	shown_distance = distance
	shown_yaw = yaw
	shown_pitch = pitch
	set_process(false)
	place_camera()


func place_camera() -> void:
	var direction := Vector3(sin(shown_yaw) * cos(shown_pitch), sin(shown_pitch), cos(shown_yaw) * cos(shown_pitch))
	camera.position = shown_target + direction * shown_distance
	camera.look_at(shown_target, Vector3.UP)
	view_changed.emit()


func set_interactive_motion(enabled: bool) -> void:
	interactive_motion = enabled
	if not enabled and camera:
		snap_shown()


func _process(delta: float) -> void:
	if not interactive_motion:
		snap_shown()
		return
	if active_button != 0 and glide != Vector2.ZERO and Time.get_ticks_usec() - last_motion_usec > 90000:
		glide = Vector2.ZERO # Held still: nothing to carry into a release.
	if glide != Vector2.ZERO and active_button == 0:
		yaw = wrapf(yaw + glide.x * delta, -PI, PI)
		pitch = clampf(pitch + glide.y * delta, -1.45, 1.45)
		glide *= exp(-4.5 * delta)
		if glide.length() < 0.05:
			glide = Vector2.ZERO
		response = DRAG_RESPONSE
	var k := 1.0 - exp(-response * minf(delta, 0.1))
	shown_target = shown_target.lerp(target, k)
	shown_distance = exp(lerpf(log(shown_distance), log(distance), k))
	shown_yaw = wrapf(shown_yaw + wrapf(yaw - shown_yaw, -PI, PI) * k, -PI, PI)
	shown_pitch = lerpf(shown_pitch, pitch, k)
	var settled: bool = glide == Vector2.ZERO and shown_target.distance_to(target) < distance * 1e-4 \
		and absf(log(shown_distance / distance)) < 1e-4 and absf(wrapf(yaw - shown_yaw, -PI, PI)) < 1e-4 and absf(pitch - shown_pitch) < 1e-4
	if settled:
		snap_shown()
	else:
		place_camera()


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
	update_camera(KEY_RESPONSE)


func keyboard_pan(direction: Vector2) -> void:
	target += (camera.global_basis.x * direction.x - camera.global_basis.y * direction.y) * pixel_scale() * 30.0
	update_camera(KEY_RESPONSE)


func keyboard_zoom(closer: bool) -> void:
	zoom_steps(1.0 if closer else -1.0)


func zoom_steps(steps: float, rate: float = KEY_RESPONSE) -> void:
	if not is_finite(steps):
		return
	# Equal opposite amounts are reciprocal; cap the exponent before arithmetic.
	distance = clampf(distance * pow(0.88, clampf(steps, -64.0, 64.0)), 0.018, 12.0)
	update_camera(rate)


## Interactive wheel zoom keeps the point under the cursor in place.
func zoom_at(steps: float, point: Vector2) -> void:
	if not is_finite(steps):
		return
	var before := distance
	var forward := -camera.global_basis.z
	var hit = Plane(forward, target).intersects_ray(camera.project_ray_origin(point), camera.project_ray_normal(point))
	distance = clampf(distance * pow(0.88, clampf(steps, -64.0, 64.0)), 0.018, 12.0)
	if hit is Vector3:
		target += (hit - target) * (1.0 - distance / before)
	update_camera(WHEEL_RESPONSE)


func cancel_drag() -> void:
	active_button = 0
	dragged = false
	move_checkpoint = false
	glide = Vector2.ZERO


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
			if is_finite(event.factor):
				var amount := absf(event.factor) if event.factor != 0.0 else 1.0
				var steps: float = amount if event.button_index == MOUSE_BUTTON_WHEEL_UP else -amount
				if interactive_motion:
					zoom_at(steps, event.position)
				else:
					zoom_steps(steps)
		elif event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if event.pressed:
				glide = Vector2.ZERO
				active_button = event.button_index
				press_position = event.position / ratio
				dragged = false
				move_checkpoint = false
				if event.double_click and event.button_index == MOUSE_BUTTON_LEFT and not move_mode:
					double_clicked.emit(event.position)
			elif active_button == event.button_index:
				if not dragged and active_button == MOUSE_BUTTON_LEFT:
					clicked.emit(event.position)
				elif dragged and interactive_motion and active_button == MOUSE_BUTTON_LEFT and not move_mode \
						and Time.get_ticks_usec() - last_motion_usec > 90000:
					glide = Vector2.ZERO # The pointer had stopped before release: no glide.
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
			update_camera(DRAG_RESPONSE)
		else:
			var turn := Vector2(-relative.x * 0.006, relative.y * 0.006)
			yaw += turn.x
			pitch = clampf(pitch + turn.y, -1.45, 1.45)
			if interactive_motion:
				# Track the recent turning speed so a flick keeps gliding after release.
				var now := Time.get_ticks_usec()
				var seconds := clampf((now - last_motion_usec) / 1000000.0, 0.004, 0.1)
				last_motion_usec = now
				glide = glide.lerp((turn / seconds).limit_length(6.0), 0.5)
			update_camera(DRAG_RESPONSE)
	elif event is InputEventPanGesture:
		target += (-camera.global_basis.x * event.delta.x + camera.global_basis.y * event.delta.y) * pixel_scale() * 12.0
		update_camera(DRAG_RESPONSE)
	elif event is InputEventMagnifyGesture:
		if not is_finite(event.factor) or event.factor <= 0.0:
			return
		distance = clampf(distance / event.factor, 0.018, 12.0)
		update_camera(WHEEL_RESPONSE)


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
