extends SceneTree
## Real picking, label ownership and pointer sensitivity across density/layout changes.

var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func settle(viewer: Control) -> void:
	for i in 3:
		await process_frame
	viewer.scene_container.update_resolution()
	await physics_frame
	await physics_frame


func pointer(viewer: Control, local_point: Vector2, pressed: bool, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = viewer.scene_container.get_global_transform_with_canvas() * local_point
	event.global_position = event.position
	root.push_input(event, true)


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	await viewer.switch_body("bodyparts-male-bones-study")
	var id := "source.bodyparts3d-v4-male.FJ3365"
	viewer.select_structure(id)
	viewer.inspect_alone()
	var observations := {"count": 0, "point": Vector2.ZERO}
	viewer.orbit.clicked.connect(func(point: Vector2): observations.count += 1; observations.point = point)
	root.wrap_controls = false
	for window_size in [Vector2i(1440, 900), Vector2i(1920, 1080), Vector2i(1100, 720)]:
		root.size = window_size
		await settle(viewer)
		for fraction in [1.0, 0.75, 0.5]:
			var before: Dictionary = viewer.export_view_state()
			var logical: Vector2 = viewer.scene_container.size
			viewer.set_scene_resolution(fraction)
			await settle(viewer)
			check(viewer.export_view_state() == before and viewer.scene_container.size == logical,
				"Resolution changes preserve anatomy, camera, labels and UI layout")
			check(viewer.viewport.size == Vector2i((Vector2(viewer.scene_container.displayed_pixels) * fraction).round()),
				"The buffer follows displayed pixels and the explicit rendering fraction")
			check(viewer.orbit.display_size == logical, "Input sensitivity uses the current logical display size")
			viewer.anatomy_labels.update_labels()
			var anchor: Dictionary = viewer.anatomy_labels.surface_anchor(id)
			check(not anchor.is_empty(), "The isolated real source femur has a surface anchor")
			if anchor.is_empty():
				continue
			var point: Vector2 = anchor.screen
			var native: Vector2 = viewer.scene_container.viewport_point(point)
			check(viewer.scene_container.control_point(native).is_equal_approx(point), "Screen/viewport mapping round-trips")
			check(viewer.model.pick(viewer.orbit.camera, native) == id, "The displayed label anchor hits its real source mesh")
			# Hide clickable label pills so the root GUI event must reach the rendered surface.
			viewer.anatomy_labels.selection_enabled = false
			viewer.anatomy_labels.local_enabled = false
			viewer.anatomy_labels.update_labels()
			var count: int = observations.count
			pointer(viewer, point, true)
			pointer(viewer, point, false)
			await process_frame
			check(observations.count == count + 1 and observations.point.is_equal_approx(native),
				"Root GUI clicks reach the 3D camera in the correct pixel coordinates")
			check(viewer.model.selected_id == id, "A real display click selects the source femur")
			var yaw: float = viewer.orbit.yaw
			pointer(viewer, point, true)
			var motion := InputEventMouseMotion.new()
			motion.position = viewer.scene_container.get_global_transform_with_canvas() * (point + Vector2(12, -5))
			motion.global_position = motion.position
			motion.relative = Vector2(12, -5)
			motion.button_mask = MOUSE_BUTTON_MASK_LEFT
			root.push_input(motion, true)
			pointer(viewer, point + Vector2(12, -5), false)
			await process_frame
			check(is_equal_approx(viewer.orbit.yaw, wrapf(yaw - 12 * 0.006, -PI, PI)),
				"Orbit sensitivity is unchanged by rendering resolution")
			viewer.apply_view(before)
			viewer.anatomy_labels.selection_enabled = true
		print("PASS screen-density picking: ", window_size)
	viewer.set_scene_resolution(1.0)
	root.size = Vector2i(1920, 1080)
	await settle(viewer)
	for fraction in [1.0, 0.75, 0.5]:
		viewer.set_scene_resolution(fraction)
		await settle(viewer)
		var view: Dictionary = viewer.current_view()
		var anatomy: Dictionary = viewer.model.export_state()
		var point: Vector2 = viewer.scene_container.size * 0.5
		var relative := Vector2(12, -5)
		var delta: Vector3 = (-viewer.orbit.camera.global_basis.x * relative.x + viewer.orbit.camera.global_basis.y * relative.y) * viewer.orbit.pixel_scale()
		pointer(viewer, point, true, MOUSE_BUTTON_MIDDLE)
		var motion := InputEventMouseMotion.new()
		motion.position = viewer.scene_container.get_global_transform_with_canvas() * (point + relative)
		motion.relative = relative
		motion.button_mask = MOUSE_BUTTON_MASK_MIDDLE
		root.push_input(motion, true)
		pointer(viewer, point + relative, false, MOUSE_BUTTON_MIDDLE)
		check(viewer.orbit.target.is_equal_approx(Vector3(view.camera.target[0], view.camera.target[1], view.camera.target[2]) + delta)
			and viewer.model.export_state() == anatomy, "Panning uses logical display pixels and preserves anatomy")
		viewer.apply_view(view)
		viewer.move_button.button_pressed = true
		viewer.toggle_move()
		var index: int = viewer.model.structures[id].mesh_nodes[0]
		var offset: Vector3 = viewer.model.states[index].offset
		pointer(viewer, point, true)
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		root.push_input(motion, true)
		pointer(viewer, point + relative, false)
		check(viewer.model.states[index].offset.is_equal_approx(offset - delta) and viewer.current_view() == view,
			"Move drag keeps its world-space sensitivity at every rendering fraction")
		viewer.model.undo()
		viewer.leave_move_mode()
		check(viewer.model.export_state() == anatomy, "Undo restores the exact source inspection state")
	viewer.set_scene_resolution(1.0)
	await settle(viewer)
	var before: Dictionary = viewer.export_view_state()
	var source_scene: Node3D = viewer.model.source_scene
	var normal: Vector2i = viewer.viewport.size
	viewer.set_scene_expanded(true)
	await settle(viewer)
	print("EXPANDED window=", root.size, " logical=", viewer.scene_container.size, " buffer=", viewer.viewport.size)
	check(viewer.viewport.size == root.size, "Expanded native anatomy renders the full requested window pixels")
	check(viewer.scene_expanded and not viewer.workspace.visible and viewer.expanded_scene.visible,
		"Expanded anatomy has a visible return route and hides the workspace")
	check(viewer.export_view_state() == before and viewer.model.source_scene == source_scene,
		"Expanding the display keeps the live 3D world and exact exploration setup")
	check(not viewer.anatomy_labels.visible_ids.is_empty(), "Resize updates visible labels immediately")
	for visible_id in viewer.anatomy_labels.visible_ids:
		var anchor_point: Vector2 = viewer.anatomy_labels.anchors[visible_id]
		var hit: Dictionary = viewer.model.ray_hit(viewer.orbit.camera, viewer.anatomy_labels.viewport_point(anchor_point))
		check(not hit.is_empty() and viewer.model.structures[visible_id].mesh_nodes.has(float(hit.collider.get_meta("mesh_index"))),
			"Expanded labels immediately point to their own first-hit source surface")
	check(await viewer.verify_expanded_actions(), "Expanded labels, quality and save/reopen/restore routes preserve the exploration setup")
	var popup: PopupMenu = viewer.expanded_menu.get_popup()
	viewer.on_expanded_action(viewer.ExpandedAction.RETURN_CONTEXT)
	check(viewer.model.isolated_id.is_empty() and viewer.scene_expanded, "Expanded Return to context retains the expanded display")
	viewer.select_structure(id)
	viewer.on_expanded_action(viewer.ExpandedAction.INSPECT)
	check(viewer.model.isolated_id == id and viewer.scene_expanded, "Expanded Inspect alone uses the selected real source part")
	viewer.on_expanded_action(viewer.ExpandedAction.MOVE)
	await process_frame
	check(viewer.orbit.move_mode and "MOVE MODE" in viewer.expanded_selection.text,
		"Expanded inspection movement remains explicit and visibly labelled")
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.01, 0, 0))
	var moved: Dictionary = viewer.model.export_state()
	popup.id_pressed.emit(viewer.ExpandedAction.UNDO)
	check(viewer.model.export_state() == before.changes, "Expanded Undo returns exact source positions")
	popup.id_pressed.emit(viewer.ExpandedAction.REDO)
	check(viewer.model.export_state() == moved, "Expanded Redo reapplies inspection movement")
	popup.id_pressed.emit(viewer.ExpandedAction.UNDO)
	viewer.leave_move_mode()
	check("move the selected" not in viewer.status.text, "Leaving Move mode clears its drag instruction")
	viewer.apply_view(before)
	# A visible menu owns its keyboard events; Escape dismisses it before the display.
	viewer.expanded_menu.grab_focus()
	var open := InputEventKey.new()
	open.keycode = KEY_ENTER
	open.pressed = true
	root.push_input(open, true)
	await process_frame
	check(popup.visible and viewer.scene_expanded, "Keyboard Enter opens the expanded Explore menu")
	var dismiss := InputEventKey.new()
	dismiss.keycode = KEY_ESCAPE
	dismiss.pressed = true
	root.push_input(dismiss, true)
	await process_frame
	check(not popup.visible and viewer.scene_expanded, "Escape dismisses the menu and retains expanded anatomy")
	viewer.loading = true
	viewer.refresh_details()
	viewer.refresh_expanded_menu()
	var guarded: Dictionary = viewer.model.export_state()
	popup.id_pressed.emit(viewer.ExpandedAction.MOVE)
	popup.id_pressed.emit(viewer.ExpandedAction.UNDO)
	check(popup.is_item_disabled(popup.get_item_index(viewer.ExpandedAction.SAVED_VIEWS))
		and popup.is_item_disabled(popup.get_item_index(viewer.ExpandedAction.SCREENSHOT))
		and not viewer.orbit.move_mode and viewer.model.export_state() == guarded,
		"Expanded actions pause safely during replacement loading")
	viewer.loading = false
	viewer.refresh_details()
	# Headless export exercises dispatch without opening a desktop picker.
	if DisplayServer.get_name() == "headless":
		popup.id_pressed.emit(viewer.ExpandedAction.SCREENSHOT)
		await process_frame
		check(not viewer.capture_in_progress and "desktop display" in viewer.status.text, "Expanded screenshot handles an unavailable display")
	else:
		root.size = Vector2i(1100, 720)
		await settle(viewer)
		var image: Image = await viewer.capture_image()
		check(image != null and image.get_width() == 1100 and image.get_height() > 720,
			"Expanded screenshot includes the full compact window and source footer")
		if image:
			check(viewer.ViewCapture.write_png(image, "/tmp/medicine-viewer-feasibility/expanded-controls-compact-export.png") == OK,
				"Compact expanded screenshot writes with attribution")
		viewer.expanded_menu.show_popup()
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/expanded-controls-compact-menu.png") == OK,
			"Compact expanded menu is captured for visual inspection")
		popup.hide()
		root.size = Vector2i(1920, 1080)
		await settle(viewer)
		viewer.scene_container.grab_focus()
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	root.push_input(event, true)
	await settle(viewer)
	check(not viewer.scene_expanded and viewer.workspace.visible and viewer.viewport.size == normal
		and viewer.export_view_state() == before and viewer.model.source_scene == source_scene,
		"Escape returns to the unchanged workspace and live world")
	viewer.queue_free()
	await process_frame
	print("Screen-density display failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
