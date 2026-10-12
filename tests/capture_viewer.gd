extends SceneTree
## Optional rendered inspection. Requires a working desktop display and GPU driver.


func _initialize() -> void:
	call_deferred("capture")


func save_image(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/medicine-viewer-feasibility/" + name + ".png"
	var error := root.get_texture().get_image().save_png(path)
	if error != OK:
		push_error("Screenshot failed: " + path)
	print("Screenshot: ", path)


func drag_in_viewport(viewer: Control, delta: Vector2) -> void:
	var container: Control = viewer.viewport.get_parent()
	var point: Vector2 = container.global_position + Vector2(viewer.viewport.size) / 2.0
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = point
	press.global_position = point
	root.push_input(press)
	var motion := InputEventMouseMotion.new()
	motion.position = point + delta
	motion.global_position = motion.position
	motion.relative = delta
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(motion)
	press = press.duplicate()
	press.pressed = false
	press.position = motion.position
	press.global_position = motion.global_position
	root.push_input(press)
	await process_frame


func capture() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	if viewer.model.body.is_empty():
		push_error("Could not load reference for rendered inspection")
		quit(1)
		return
	await physics_frame
	await physics_frame
	var rendered_pick: String = viewer.model.pick(viewer.orbit.camera, Vector2(viewer.viewport.size) / 2.0)
	if rendered_pick != "anatomy.skin":
		push_error("Rendered center click must pick the skin: " + rendered_pick)
		quit(1)
		return
	# Feed mouse events through the desktop UI to verify SubViewport forwarding.
	var container: Control = viewer.viewport.get_parent()
	var point: Vector2 = container.global_position + Vector2(viewer.viewport.size) / 2.0
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = point
	click.global_position = point
	click.pressed = true
	root.push_input(click)
	click = click.duplicate()
	click.pressed = false
	root.push_input(click)
	await process_frame
	if viewer.model.selected_id != "anatomy.skin":
		push_error("Viewport mouse input did not reach structure selection")
		quit(1)
		return
	print("PASS rendered viewport selection")
	viewer.whole_body()
	await save_image("whole-body-female")
	viewer.chest_view()
	await save_image("chest-female")
	var previous_yaw: float = viewer.orbit.yaw
	await drag_in_viewport(viewer, Vector2(90, 30))
	if is_equal_approx(previous_yaw, viewer.orbit.yaw):
		push_error("Viewport dragging did not orbit the camera")
		quit(1)
		return
	print("PASS rendered viewport orbit")
	await save_image("chest-female-orbit")
	viewer.move_button.button_pressed = true
	viewer.toggle_move()
	var original: AABB = viewer.model.bounds_for("anatomy.heart")
	await drag_in_viewport(viewer, Vector2(90, 0))
	if viewer.model.bounds_for("anatomy.heart").is_equal_approx(original):
		push_error("Move mode did not displace the selected heart")
		quit(1)
		return
	var moved: Dictionary = viewer.model.export_state()
	viewer.model.undo()
	if not viewer.model.bounds_for("anatomy.heart").is_equal_approx(original):
		push_error("Undo did not restore the original heart")
		quit(1)
		return
	viewer.model.redo()
	if viewer.model.export_state() != moved:
		push_error("Redo did not reapply the inspection")
		quit(1)
		return
	viewer.save_path = "user://capture_test_view.json"
	viewer.save_view()
	viewer.model.restore()
	await viewer.load_view()
	if viewer.model.export_state() != moved:
		push_error("Saved-view UI failed to restore inspection state")
		quit(1)
		return
	DirAccess.remove_absolute(viewer.save_path)
	print("PASS rendered move and saved-view workflow")
	await save_image("heart-moved-female")
	viewer.whole_body()
	if viewer.orbit.move_mode or viewer.move_button.button_pressed:
		push_error("Whole-body navigation must leave Move mode")
		quit(1)
		return
	viewer.select_structure("anatomy.heart")
	viewer.model.restore("anatomy.heart")
	viewer.move_button.button_pressed = false
	viewer.toggle_move()
	if "--female-only" not in OS.get_cmdline_user_args():
		await viewer.switch_body("male")
		viewer.chest_view()
		await save_image("chest-male")
	viewer.queue_free()
	await process_frame
	quit()
