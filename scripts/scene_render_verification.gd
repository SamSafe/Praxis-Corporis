extends RefCounted
## Explicit disposable QA: compare cached scene pixels with continuous rendering.


static func settle(viewer: Control, rendered: bool) -> void:
	for index in range(3):
		await viewer.get_tree().process_frame
		if rendered:
			await RenderingServer.frame_post_draw


static func digest(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


static func step(viewer: Control, action: Callable, name: String, rendered: bool, report: Dictionary, deferred_change: bool = false) -> bool:
	viewer.viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	action.call()
	var valid: bool = deferred_change or viewer.viewport.render_target_update_mode == SubViewport.UPDATE_ONCE
	await settle(viewer, rendered)
	if rendered:
		valid = valid and viewer.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED
		var cached: Image = viewer.viewport.get_texture().get_image()
		viewer.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await settle(viewer, true)
		var continuous: Image = viewer.viewport.get_texture().get_image()
		var same := cached.get_size() == continuous.get_size() and cached.get_format() == continuous.get_format() and cached.get_data() == continuous.get_data()
		valid = valid and same
		report.frames.append({"action": name, "expanded": viewer.scene_expanded,
			"resolution": viewer.scene_container.resolution_fraction, "text_scale": viewer.text_scale,
			"size": [cached.get_width(), cached.get_height()], "cached_sha256": digest(cached.get_data()),
			"continuous_sha256": digest(continuous.get_data()), "identical": same})
		viewer.request_scene_render()
		await settle(viewer, true)
	if not valid:
		push_error("Scene redraw failed: " + str(viewer.model.body.id) + " / " + name)
	return valid


static func idle_sample(viewer: Control, name: String) -> Dictionary:
	await settle(viewer, true)
	var counts: Array[int] = []
	for index in range(12):
		await viewer.get_tree().process_frame
		await RenderingServer.frame_post_draw
		counts.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	return {"mode": name, "global_draw_calls": counts,
		"scene_sha256": digest(viewer.viewport.get_texture().get_image().get_data())}


static func visibility_fixture(viewer: Control, target: String) -> void:
	# Remove the temporary isolation mask so Fade/Hide affect the visible leaf.
	for index in viewer.model.states:
		viewer.model.states[index].visibility = "hidden"
	for index in viewer.model.structures[target].mesh_nodes:
		viewer.model.states[int(index)].visibility = "visible"
	viewer.model.set_isolation("")


static func run(viewer: Control, rendered: bool = false) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	var window_size: Vector2i = viewer.get_window().size
	var expanded: bool = viewer.scene_expanded
	var ghosts: bool = viewer.model.show_original_positions
	var report := {"reference": viewer.model.body.id, "frames": [], "idle": []}
	var valid := true
	# A visible source leaf gives highlighting, movement and visibility real pixels.
	var target := "anatomy.heart" if viewer.model.structures.has("anatomy.heart") else str(viewer.model.body.get("inspection_root", "anatomy.system.skeletal"))
	var index := int(viewer.model.structures[target].mesh_nodes[0])
	for id in viewer.model.structures:
		if int(viewer.model.structures[id].source_node) == index:
			target = str(id)
			break
	viewer.select_structure(target, false)
	viewer.inspect_alone()
	for layout in [false, true]:
		for fraction in [1.0, 0.5]:
			valid = await step(viewer, func(): viewer.set_scene_expanded(layout), "layout", rendered, report, true) and valid
			valid = await step(viewer, func(): viewer.set_scene_resolution(fraction), "resolution", rendered, report, true) and valid
			valid = await step(viewer, func(): viewer.orbit.keyboard_orbit(Vector2(1, -1)), "orbit", rendered, report) and valid
			valid = await step(viewer, func(): viewer.orbit.keyboard_pan(Vector2(1, 1)), "pan", rendered, report) and valid
			valid = await step(viewer, func(): viewer.orbit.keyboard_zoom(true), "zoom", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.select(""), "clear highlight", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.select(target), "highlight", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.set_isolation(""), "context", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.set_isolation(target), "isolation", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.offset_selection(Vector3(0.02, 0.01, 0), true), "move", rendered, report) and valid
			valid = await step(viewer, func(): viewer.original_positions_button.button_pressed = not viewer.original_positions_button.button_pressed, "original position overlay", rendered, report) and valid
			valid = await step(viewer, viewer.model.undo, "undo", rendered, report) and valid
			valid = await step(viewer, viewer.model.redo, "redo", rendered, report) and valid
			valid = await step(viewer, func(): visibility_fixture(viewer, target), "visibility fixture", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.set_visibility(target, "faded"), "fade", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.set_visibility(target, "hidden"), "hide", rendered, report) and valid
			valid = await step(viewer, func(): viewer.model.restore(target), "restore part", rendered, report) and valid
			var settings: Dictionary = viewer.preference_state()
			settings.text_scale = 1.3 if viewer.text_scale == 1.0 else 1.0
			valid = await step(viewer, func(): viewer.apply_preferences(settings), "text size", rendered, report, true) and valid
			valid = await step(viewer, func(): viewer.get_window().size = Vector2i(1100, 720) if viewer.get_window().size != Vector2i(1100, 720) else Vector2i(1440, 900), "window size", rendered, report, true) and valid
	valid = await step(viewer, func(): viewer.restore_view_state(before), "restore saved view", rendered, report) and valid
	if viewer.model.structures.has("anatomy.heart"):
		viewer.start_guided_chest()
		valid = await step(viewer, func(): viewer.apply_chest_step(2), "guided study", rendered, report) and valid
		await viewer.finish_guided_chest()
		viewer.start_circulation_route()
		valid = await step(viewer, func(): viewer.apply_route_step("pulmonary-trunk", false), "circulation step", rendered, report) and valid
		await viewer.finish_guided_chest()
	viewer.restore_view_state(before)
	viewer.model.undo_stack = undo
	viewer.model.redo_stack = redo
	viewer.back_views = back
	viewer.forward_views = forward
	viewer.original_positions_button.button_pressed = ghosts
	viewer.apply_preferences(preferences)
	viewer.set_scene_expanded(expanded)
	viewer.get_window().size = window_size
	await settle(viewer, rendered)
	valid = valid and viewer.export_view_state() == before
	if rendered:
		viewer.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		report.idle.append(await idle_sample(viewer, "continuous"))
		viewer.request_scene_render()
		report.idle.append(await idle_sample(viewer, "cached"))
		valid = valid and report.idle[0].scene_sha256 == report.idle[1].scene_sha256
		var continuous_min: int = report.idle[0].global_draw_calls.min()
		var cached_max: int = report.idle[1].global_draw_calls.max()
		valid = valid and cached_max < continuous_min
		var file := FileAccess.open("user://scene-render-%s.json" % str(viewer.model.body.id), FileAccess.WRITE)
		if file == null:
			valid = false
		else:
			file.store_string(JSON.stringify(report, "\t"))
			file.close()
		if valid:
			print("PASS native scene redraw: %s · %d pixel pairs · idle draw calls %d -> %d" % [viewer.model.body.id, report.frames.size(), continuous_min, cached_max])
	if valid:
		print("PASS bundled scene redraw: ", viewer.model.body.id)
	return valid
