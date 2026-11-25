extends SceneTree
## Integration checks use the real meshes and the same methods used by the UI.

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const OrbitCamera = preload("res://scripts/orbit_camera.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	var model := AnatomyModel.new()
	root.add_child(model)
	var orbit := OrbitCamera.new()
	root.add_child(orbit)
	for body in pack.bodies:
		var requested := ""
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--body="):
				requested = argument.trim_prefix("--body=")
		if not requested.is_empty() and body.id != requested:
			continue
		var error: String = await model.load_body(body)
		check(error.is_empty(), str(body.id) + ": " + error)
		if not error.is_empty():
			continue
		check(model.meshes.size() == (999 if body.id == "female" else 963), "Real mesh count must match the audited source")
		for structure in model.structures.values():
			check("extraction" not in str(structure.source_name).to_lower(), "Sampling-site anatomy must be excluded")
		var original: AABB = model.bounds_for("anatomy.heart")
		check(original.size.length() > 0.05 and original.size.length() < 0.5, "Heart bounds must be meaningful in the unchanged source frame")
		model.select("anatomy.heart")
		var selected_mesh_index := int(model.structures["anatomy.heart"].mesh_nodes[0])
		check(model.materials[selected_mesh_index][0].emission_enabled, "Selected group meshes must visibly highlight despite JSON numeric types")
		model.checkpoint()
		model.offset_selection(Vector3(0.12, 0.03, 0.0))
		check(model.bounds_for("anatomy.heart").get_center().is_equal_approx(original.get_center() + Vector3(0.12, 0.03, 0.0)), "Multi-mesh heart must move as one selection")
		var ghost_bounds := AABB()
		var first_ghost := true
		for index in model.structures["anatomy.heart"].mesh_nodes:
			var ghost: MeshInstance3D = model.original_ghosts[int(index)]
			var box: AABB = ghost.global_transform * ghost.get_aabb()
			ghost_bounds = box if first_ghost else ghost_bounds.merge(box)
			first_ghost = false
		check(ghost_bounds.is_equal_approx(original), "Inspection ghosts must retain original anatomical placement")
		model.set_visibility("anatomy.heart.valve.mitral", "faded")
		var saved: Dictionary = model.export_state()
		model.restore()
		check(model.bounds_for("anatomy.heart").is_equal_approx(original), "Restore must exactly recover the original anatomy")
		check(model.apply_saved_state(saved).is_empty(), "A valid saved inspection must round-trip")
		check(model.export_state() == saved, "Saved visibility and offsets must survive loading")
		model.restore("anatomy.heart")
		model.undo()
		check(model.export_state() == saved, "Undo must recover both geometry and visibility")
		model.redo()
		check(model.bounds_for("anatomy.heart").is_equal_approx(original), "Redo must reapply the restored heart placement")
		model.undo()
		check(model.export_state() == saved, "Redo followed by undo must recover the same inspection")
		model.set_visibility("anatomy.skin", "hidden")
		var branched: Dictionary = model.export_state()
		model.redo()
		check(model.export_state() == branched, "A new inspection edit must discard stale redo history")
		var before: Dictionary = model.export_state()
		check(not model.apply_saved_state({"missing.structure": {"visibility": "hidden", "offset": [0, 0, 0]}}).is_empty(), "Missing content must be rejected")
		check(model.export_state() == before, "An invalid save must leave the current body unchanged")
		model.restore()
		model.offset_selection(Vector3(1000.0, -1000.0, 1000.0))
		check(model.apply_saved_state(model.export_state()).is_empty(), "The viewer must be able to reload its own extreme inspection states")
		model.restore()
		# Use actual physics ray picking after a synchronization frame.
		# Nothing selected: no layer is faded to reveal a selection.
		model.select("")
		orbit.focus(model.bounds_for("anatomy.skin"))
		await physics_frame
		await physics_frame
		# In headless mode Window.size is 64x64; camera projection uses the scaled viewport.
		var click_position := root.get_visible_rect().get_center()
		var picked: String = model.pick(orbit.camera, click_position)
		check(picked == "anatomy.skin", "Visible skin must intercept a whole-body center click")
		model.set_visibility("anatomy.skin", "hidden")
		await physics_frame
		await physics_frame
		check(model.pick(orbit.camera, click_position) != "anatomy.skin", "Hidden skin must not intercept clicks")
		model.set_visibility("anatomy.body", "hidden")
		model.set_visibility("anatomy.heart", "visible")
		orbit.focus(model.bounds_for("anatomy.heart"))
		await physics_frame
		await physics_frame
		var heart_pick: String = model.pick(orbit.camera, click_position)
		check(not heart_pick.is_empty(), "A real heart component must be selectable after surrounding layers are hidden")
		if not heart_pick.is_empty():
			check(model.structures["anatomy.heart"].mesh_nodes.has(model.structures[heart_pick].source_node), "The picked component must map to heart geometry")
		model.set_visibility("anatomy.heart", "faded")
		await physics_frame
		await physics_frame
		check(model.pick(orbit.camera, click_position).is_empty(), "Faded anatomy must be click-through in actual ray picking")
		model.set_visibility("anatomy.heart", "visible")
		model.select("anatomy.heart")
		model.offset_selection(Vector3(0.8, 0, 0))
		await physics_frame
		await physics_frame
		check(model.pick(orbit.camera, click_position).is_empty(), "Original-position ghosts must not intercept anatomy picking")
		model.restore("anatomy.heart")
		for ghost in model.original_ghosts.values():
			check(not ghost.visible, "Restored anatomy must not retain a visible inspection ghost")
		print("PASS real-body integration: ", body.id, " · load %.2fs" % model.load_seconds)
	check(not orbit.valid_state({"target": [0, 0, 0], "distance": -5, "yaw": 0, "pitch": 0}), "Invalid camera distance must be rejected")
	check(orbit.valid_state(orbit.export_state()), "Camera state must round-trip")
	model.clear_body()
	model.free()
	orbit.free()
	print("Integration failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
