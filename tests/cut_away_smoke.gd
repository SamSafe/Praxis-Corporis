extends SceneTree
## Cut-away view: a display-only plane facing the camera at a set depth from the focus
## point. Picking starts at the plane, the anatomy state, saved-view state and
## histories are unchanged, and turning it off restores the default near plane.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	if viewer.model.body.id != "female":
		await viewer.switch_body("female")
	var orbit = viewer.orbit
	var camera: Camera3D = orbit.camera
	check(is_equal_approx(camera.near, orbit.NEAR) and not viewer.cut_slider.editable and not viewer.cut_note.visible, "The cut is off by default")
	# Frame the chest from the front, then find what the centre of the view hits.
	viewer.select_structure("anatomy.heart")
	viewer.focus_selection()
	await process_frame
	var center: Vector2 = viewer.viewport.size * 0.5
	var before_hit: Dictionary = viewer.model.ray_hit(camera, center)
	check(not before_hit.is_empty(), "Without a cut the view centre hits anatomy")
	var view: Dictionary = viewer.export_view_state()
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	# Cut through the focus point.
	viewer.cut_button.button_pressed = true
	await process_frame
	check(viewer.cut_slider.editable and viewer.cut_note.visible and "focus point" in viewer.cut_note.text and "no caps" in viewer.cut_note.text, "Turning the cut on explains it and enables the depth")
	check(is_equal_approx(camera.near, orbit.distance), "A cut at depth 0 passes through the focus point")
	var cut_hit: Dictionary = viewer.model.ray_hit(camera, center)
	if not cut_hit.is_empty():
		var depth: float = (cut_hit.position - camera.global_position).dot(-camera.global_basis.z)
		check(depth >= camera.near - 0.0005, "Picking starts at the cut, not in front of it")
	if not before_hit.is_empty() and not cut_hit.is_empty():
		check(cut_hit.position.distance_to(camera.global_position) > before_hit.position.distance_to(camera.global_position), "The cut exposes anatomy farther from the camera")
	# Depth in front of and beyond the focus point.
	viewer.cut_slider.value = 5.0
	await process_frame
	check(is_equal_approx(camera.near, orbit.distance - 0.05) and "5.0 cm in front of" in viewer.cut_note.text, "A positive depth cuts in front of the focus point")
	viewer.cut_slider.value = -5.0
	await process_frame
	check(is_equal_approx(camera.near, orbit.distance + 0.05) and "beyond" in viewer.cut_note.text, "A negative depth cuts beyond the focus point")
	# The cut follows zoom: the plane stays at the same depth from the focus point.
	orbit.zoom_steps(1.0)
	await process_frame
	check(is_equal_approx(camera.near, orbit.distance + 0.05), "Zooming keeps the cut's depth from the focus point")
	orbit.zoom_steps(-1.0)
	# The cut never moves behind the camera.
	viewer.cut_slider.value = 15.0
	orbit.distance = 0.05
	orbit.update_camera()
	await process_frame
	check(is_equal_approx(camera.near, orbit.NEAR), "A cut nearer than the camera falls back to the default plane")
	orbit.apply_state(view.camera if view.has("camera") else orbit.export_state())
	# Display only: anatomy, histories and saved-view state are unchanged.
	check(viewer.model.export_state() == anatomy and viewer.model.undo_stack == undo and viewer.back_views == back, "The cut changes no anatomy state or history")
	viewer.cut_button.button_pressed = false
	await process_frame
	check(is_equal_approx(camera.near, orbit.NEAR) and not viewer.cut_slider.editable and not viewer.cut_note.visible, "Turning the cut off restores the default near plane")
	check(viewer.export_view_state() == view, "Saved-view state is the same before and after")
	print("Cut-away failures: ", failures)
	quit(0 if failures == 0 else 1)
