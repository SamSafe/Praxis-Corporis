extends SceneTree
## Interactive camera motion: eased display, glide after a flick, zoom towards the pointer.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func settle(orbit: Node3D, seconds: float = 3.0) -> void:
	var elapsed := 0.0
	while elapsed < seconds and orbit.is_processing():
		orbit._process(1.0 / 60.0)
		elapsed += 1.0 / 60.0


func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(800, 600)
	viewport.own_world_3d = true
	root.add_child(viewport)
	var orbit = load("res://scripts/orbit_camera.gd").new()
	viewport.add_child(orbit)
	await process_frame
	orbit.set_interactive_motion(true)
	orbit.set_process(false)

	# A jump changes the logical view at once and eases the drawn camera towards it.
	var start: Vector3 = orbit.camera.position
	orbit.target = Vector3(0.2, 0.1, 0.0)
	orbit.distance = 1.5
	orbit.yaw = 3.0
	orbit.update_camera()
	check(orbit.export_state().distance == 1.5 and orbit.camera.position == start, "Logical state changes immediately; the drawn camera has not jumped")
	orbit._process(1.0 / 60.0)
	var partway: Vector3 = orbit.camera.position
	check(partway != start, "The drawn camera starts moving towards the new view")
	settle(orbit)
	check(not orbit.is_processing(), "Easing finishes and stops updating")
	check(orbit.shown_target == orbit.target and orbit.shown_distance == orbit.distance and orbit.shown_yaw == orbit.yaw, "The drawn camera lands exactly on the logical view")

	# Easing takes the short way round across the yaw seam.
	orbit.yaw = PI - 0.05
	orbit.update_camera()
	settle(orbit)
	orbit.yaw = -PI + 0.05
	orbit.update_camera()
	var largest_step := 0.0
	var previous: float = orbit.shown_yaw
	while orbit.is_processing():
		orbit._process(1.0 / 60.0)
		largest_step = maxf(largest_step, absf(wrapf(orbit.shown_yaw - previous, -PI, PI)))
		previous = orbit.shown_yaw
	check(largest_step < 0.1, "Crossing the yaw seam does not spin the long way round")

	# A flick keeps gliding after release, slows down, and stops.
	orbit.glide = Vector2(2.0, 0.0)
	orbit.active_button = 0
	var yaw_before: float = orbit.yaw
	orbit.set_process(true)
	orbit._process(1.0 / 60.0)
	check(not is_equal_approx(orbit.yaw, yaw_before), "A released flick keeps turning the view")
	settle(orbit, 6.0)
	check(orbit.glide == Vector2.ZERO and not orbit.is_processing(), "The glide slows to a stop")
	orbit.glide = Vector2(2.0, 0.0)
	orbit.cancel_drag()
	check(orbit.glide == Vector2.ZERO, "Cancelling input also stops a glide")

	# Interactive wheel zoom keeps the point under the pointer in place.
	orbit.set_interactive_motion(false)
	orbit.target = Vector3.ZERO
	orbit.distance = 2.0
	orbit.yaw = 0.0
	orbit.pitch = 0.0
	orbit.update_camera()
	var pointer := Vector2(600, 200)
	var plane := Plane(-orbit.camera.global_basis.z, orbit.target)
	var before = plane.intersects_ray(orbit.camera.project_ray_origin(pointer), orbit.camera.project_ray_normal(pointer))
	orbit.set_interactive_motion(true)
	orbit.zoom_at(2.0, pointer)
	settle(orbit)
	var after = plane.intersects_ray(orbit.camera.project_ray_origin(pointer), orbit.camera.project_ray_normal(pointer))
	check(orbit.distance < 2.0 and before is Vector3 and after is Vector3 and before.distance_to(after) < 1e-4, "Zooming keeps the point under the pointer fixed")
	orbit.zoom_at(NAN, pointer)
	check(is_finite(orbit.distance) and orbit.target.is_finite(), "Invalid zoom amounts are ignored")

	# Turning motion off snaps to the logical view at once.
	orbit.yaw = 1.0
	orbit.update_camera()
	orbit.set_interactive_motion(false)
	check(orbit.shown_yaw == 1.0 and not orbit.is_processing(), "Turning smooth motion off snaps immediately")
	orbit.yaw = -1.0
	orbit.update_camera()
	check(orbit.shown_yaw == -1.0, "Without smooth motion every change is immediate")

	print("Camera motion failures: ", failures)
	quit(0 if failures == 0 else 1)
