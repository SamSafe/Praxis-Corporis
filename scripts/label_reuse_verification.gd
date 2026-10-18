extends RefCounted
## Explicit QA compares periodic placement with a fresh solve and real first hits.

const SceneChecks = preload("res://scripts/scene_render_verification.gd")


static func snapshot(viewer: Control) -> Dictionary:
	var labels: Control = viewer.anatomy_labels
	var pills := []
	for id in labels.visible_ids:
		var button: Button = labels.buttons[id]
		var point: Vector2 = labels.anchors[id]
		pills.append({"id": id, "anchor": [point.x, point.y],
			"rect": [button.position.x, button.position.y, button.size.x, button.size.y]})
	var actions: Control = viewer.part_actions
	var anchor: Vector2 = labels.action_anchor
	return {"pills": pills, "actions_visible": actions.visible,
		"actions_anchored": actions.anchored,
		"action_anchor": [anchor.x, anchor.y] if anchor.is_finite() else [],
		"actions_rect": [actions.position.x, actions.position.y, actions.size.x, actions.size.y]}


static func first_hits(viewer: Control) -> bool:
	for id in viewer.anatomy_labels.visible_ids:
		var point: Vector2 = viewer.anatomy_labels.anchors[id]
		var hit: Dictionary = viewer.model.ray_hit(viewer.orbit.camera, viewer.anatomy_labels.viewport_point(point))
		if hit.is_empty():
			return false
		var index := int(hit.collider.get_meta("mesh_index"))
		var allowed := {}
		for source_index in viewer.model.structures[id].mesh_nodes:
			allowed[int(source_index)] = true
		if not allowed.has(index) or viewer.model.effective_visibility(index) != "visible":
			return false
	return true


static func settle(viewer: Control) -> void:
	for index in range(3):
		await viewer.get_tree().process_frame
	await viewer.get_tree().physics_frame
	await viewer.get_tree().physics_frame


static func step(viewer: Control, action: Callable, name: String, report: Dictionary) -> bool:
	action.call()
	await settle(viewer)
	# Advance the same periodic path once after physics/layout settles. This avoids
	# adding a wall-clock delay to every case; idle frequency is measured separately.
	viewer.anatomy_labels._physics_process(0.11)
	var cached := snapshot(viewer)
	var truthful := first_hits(viewer)
	viewer.anatomy_labels.update_labels()
	var fresh := snapshot(viewer)
	var same := cached == fresh
	report.cases.append({"action": name, "expanded": viewer.scene_expanded,
		"resolution": viewer.scene_container.resolution_fraction, "text_scale": viewer.text_scale,
		"cached_sha256": JSON.stringify(cached, "", true, true).sha256_text(),
		"fresh_sha256": JSON.stringify(fresh, "", true, true).sha256_text(),
		"identical": same, "first_hits_valid": truthful, "visible_labels": cached.pills.size()})
	# A fresh solve invalidates the periodic cache. Re-prime it before the next
	# mutation so a missing invalidation cannot be concealed by the oracle itself.
	viewer.anatomy_labels._physics_process(0.11)
	if not same or not truthful:
		if not report.has("first_mismatch"):
			report.first_mismatch = {"action": name, "cached": cached, "fresh": fresh, "first_hits_valid": truthful}
			print("LABEL MISMATCH ", viewer.model.body.id, " ", JSON.stringify(report.first_mismatch))
		push_error("Label reuse failed: " + str(viewer.model.body.id) + " / " + name)
	return same and truthful


static func raw_offset(viewer: Control, original: Dictionary, delta: Vector3) -> void:
	for index in original:
		viewer.model.states[index].offset = original[index] + delta
	viewer.model.refresh_appearance()


static func cover_label(viewer: Control, overlay: Control) -> void:
	if viewer.anatomy_labels.visible_ids.is_empty():
		return
	var id: String = viewer.anatomy_labels.visible_ids[0]
	var button: Button = viewer.anatomy_labels.buttons[id]
	overlay.position = button.position - Vector2(8, 8)
	overlay.size = button.size + Vector2(16, 16)
	overlay.show()


static func run(viewer: Control, rendered: bool = false) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	var expanded: bool = viewer.scene_expanded
	var window_size: Vector2i = viewer.get_window().size
	var minimum: Vector2 = viewer.part_actions.custom_minimum_size
	var fallback: Vector2 = viewer.part_actions.fallback
	var report := {"reference": viewer.model.body.id, "cases": []}
	var group := "anatomy.heart" if viewer.model.structures.has("anatomy.heart") else str(viewer.model.body.get("inspection_root", "anatomy.system.skeletal"))
	var leaf := str(viewer.model.body.get("qa_leaf_id", "anatomy.heart.valve.mitral"))
	if not viewer.model.structures.has(leaf):
		leaf = "source.bodyparts3d-v4-male.FJ3365"
	var valid: bool = viewer.model.structures.has(leaf)
	if not valid:
		return false
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.hide()
	viewer.scene_container.add_child(overlay)
	viewer.anatomy_labels.exclusion_controls.append(overlay)
	var context := 0
	for layout in [false, true]:
		for scale in [1.0, 1.3]:
			viewer.set_scene_expanded(layout)
			var settings := preferences.duplicate(true)
			settings.text_scale = scale
			settings.resolution = 1.0 if context % 2 == 0 else 0.5
			context += 1
			viewer.apply_preferences(settings)
			viewer.labels_button.button_pressed = true
			viewer.local_labels_button.button_pressed = true
			viewer.label_density.value = 8
			viewer.select_structure(group, false)
			viewer.model.set_isolation(group)
			viewer.orbit.focus(viewer.model.bounds_for(group))
			valid = await step(viewer, func(): pass, "group setup", report) and valid
			var original_offsets := {}
			for index in viewer.model.structures[leaf].mesh_nodes:
				original_offsets[int(index)] = viewer.model.states[int(index)].offset
			var context_fallback: Vector2 = viewer.part_actions.fallback
			var actions: Array = [
				["orbit", func(): viewer.orbit.keyboard_orbit(Vector2(1, -1))],
				["pan", func(): viewer.orbit.keyboard_pan(Vector2(1, 1))],
				["zoom", func(): viewer.orbit.keyboard_zoom(true)],
				["local labels off", func(): viewer.local_labels_button.button_pressed = false],
				["local labels on", func(): viewer.local_labels_button.button_pressed = true],
				["density one", func(): viewer.label_density.value = 1],
				["density eight", func(): viewer.label_density.value = 8],
				["selection label off", func(): viewer.labels_button.button_pressed = false],
				["selection label on", func(): viewer.labels_button.button_pressed = true],
				["leaf selection", func(): viewer.model.select(leaf); viewer.model.set_isolation(leaf); viewer.orbit.focus(viewer.model.bounds_for(leaf))],
				["raw appearance movement", func(): raw_offset(viewer, original_offsets, Vector3(0.02, 0.01, 0))],
				["raw appearance reset", func(): raw_offset(viewer, original_offsets, Vector3.ZERO)],
				["visibility fixture", func(): SceneChecks.visibility_fixture(viewer, leaf)],
				["fade", func(): viewer.model.set_visibility(leaf, "faded")],
				["hide", func(): viewer.model.set_visibility(leaf, "hidden")],
				["show", func(): viewer.model.set_visibility(leaf, "visible")],
				["actions hidden", func(): viewer.part_actions.hide()],
				["actions shown", func(): viewer.part_actions.show()],
				["action fallback", func(): viewer.part_actions.fallback += Vector2(23, 17)],
				["action minimum", func(): viewer.part_actions.custom_minimum_size += Vector2(24, 6)],
				["overlay covering label", func(): cover_label(viewer, overlay)],
				["overlay moved", func(): overlay.position += Vector2(230, 80)],
				["overlay hidden", func(): overlay.hide()],
				["overlay shown", func(): overlay.show()],
				["labels suspended", func(): viewer.anatomy_labels.suspended = true],
				["labels resumed", func(): viewer.anatomy_labels.suspended = false],
				["window resized", func(): viewer.get_window().size = Vector2i(1100, 720) if viewer.get_window().size != Vector2i(1100, 720) else Vector2i(1440, 900)]
			]
			for item in actions:
				valid = await step(viewer, item[1], item[0], report) and valid
				if item[0] in ["leaf selection", "raw appearance reset", "show"]:
					valid = valid and viewer.anatomy_labels.visible_ids.has(leaf)
			viewer.part_actions.custom_minimum_size = minimum
			viewer.part_actions.fallback = context_fallback
			overlay.hide()
			viewer.restore_view_state(before)
	viewer.anatomy_labels.exclusion_controls.erase(overlay)
	overlay.queue_free()
	viewer.restore_view_state(before)
	viewer.model.undo_stack = undo
	viewer.model.redo_stack = redo
	viewer.back_views = back
	viewer.forward_views = forward
	viewer.apply_preferences(preferences)
	viewer.set_scene_expanded(expanded)
	viewer.part_actions.fallback = fallback
	viewer.get_window().size = window_size
	await settle(viewer)
	valid = valid and viewer.export_view_state() == before
	if rendered:
		var file := FileAccess.open("user://label-reuse-%s.json" % str(viewer.model.body.id), FileAccess.WRITE)
		if file == null:
			valid = false
		else:
			file.store_string(JSON.stringify(report, "\t", true, true))
			file.close()
	if valid:
		print("PASS bundled label reuse: %s · %d placement pairs" % [viewer.model.body.id, report.cases.size()])
	return valid
