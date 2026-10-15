extends RefCounted
## Exported-runtime checks use disposable files and leave the live exploration intact.

const SavedViews = preload("res://scripts/saved_views.gd")
const Preferences = preload("res://scripts/viewer_preferences.gd")


static func run(viewer: Control, rendered: bool) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var valid: bool = viewer.study_content.data.get("cards", {}).size() == 15
	valid = valid and viewer.study_content.error.is_empty()
	viewer.scene_container.grab_focus()
	var camera: Dictionary = viewer.orbit.export_state().duplicate(true)
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	for code in [KEY_M, KEY_L]:
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = true
		viewer.get_viewport().push_input(event)
		await viewer.get_tree().process_frame
	valid = valid and viewer.orbit.move_mode and viewer.orbit.export_state() == camera and viewer.model.export_state() != anatomy
	var undo_key := InputEventKey.new()
	undo_key.keycode = KEY_Z
	undo_key.ctrl_pressed = true
	undo_key.pressed = true
	viewer.get_viewport().push_input(undo_key)
	await viewer.get_tree().process_frame
	viewer.leave_move_mode()
	valid = valid and viewer.model.export_state() == anatomy
	viewer.model.undo_stack = undo.duplicate(true)
	viewer.model.redo_stack = redo.duplicate(true)
	if valid:
		print("PASS bundled keyboard movement: ", viewer.model.body.id)
	if viewer.model.structures.has("anatomy.heart"):
		viewer.start_guided_chest()
		viewer.apply_chest_step(2)
		valid = valid and viewer.guided_chest.active and viewer.validate_view_state(viewer.export_view_state()).is_empty()
		if rendered:
			await viewer.get_tree().process_frame
			await RenderingServer.frame_post_draw
			valid = valid and viewer.get_viewport().get_texture().get_image().save_png("user://native-guided-%s.png" % str(viewer.model.body.id)) == OK
		await viewer.finish_guided_chest()
		valid = valid and viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward
		viewer.start_circulation_route()
		for node in ["right-atrium", "tricuspid", "right-ventricle", "pulmonary-valve", "pulmonary-trunk", "left-artery"]:
			viewer.apply_route_step(node)
		valid = valid and viewer.guided_chest.route_node == "left-artery"
		viewer.previous_route_step()
		valid = valid and viewer.guided_chest.route_node == "pulmonary-trunk" and viewer.guided_chest.branches.get_child_count() == 2
		if rendered:
			var previous_size := viewer.get_window().size
			var previous_preferences: Dictionary = viewer.preference_state()
			var large_text: Dictionary = previous_preferences.duplicate()
			large_text.text_scale = 1.3
			viewer.apply_preferences(large_text)
			viewer.get_window().size = Vector2i(1100, 720)
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			await RenderingServer.frame_post_draw
			valid = valid and viewer.scene_container.size.y >= 140
			valid = valid and viewer.get_viewport().get_texture().get_image().save_png("user://native-route-compact-%s.png" % str(viewer.model.body.id)) == OK
			viewer.apply_preferences(previous_preferences)
			viewer.get_window().size = previous_size
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
		for node in ["right-artery", "right-exchange"]:
			viewer.apply_route_step(node)
		valid = valid and "Coverage gap" in viewer.guided_chest.description.text
		if rendered:
			var expanded: bool = viewer.scene_expanded
			viewer.set_scene_expanded(true)
			await viewer.get_tree().process_frame
			await RenderingServer.frame_post_draw
			valid = valid and viewer.get_viewport().get_texture().get_image().save_png("user://native-route-%s.png" % str(viewer.model.body.id)) == OK
			viewer.set_scene_expanded(expanded)
		for node in ["pulmonary-veins", "left-atrium", "mitral", "left-ventricle", "aortic-valve", "aorta", "systemic-gap", "vena-cava"]:
			viewer.apply_route_step(node)
			valid = valid and viewer.validate_view_state(viewer.export_view_state()).is_empty()
		valid = valid and viewer.guided_chest.route_node == "vena-cava"
		await viewer.finish_guided_chest()
		valid = valid and viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward
		if valid:
			print("PASS bundled circulation route: ", viewer.model.body.id)
	var path := "user://study-check-" + Crypto.new().generate_random_bytes(16).hex_encode()
	var library := SavedViews.new()
	library.path = path + ".json"
	valid = valid and library.load_library().is_empty()
	valid = valid and library.add_view("Source study", before).is_empty()
	valid = valid and library.set_notes(library.entries[0].id, "Portable native study notes.\nKeep this source view.").is_empty()
	valid = valid and library.export_library(path + "-export.json").is_empty()
	var imported := SavedViews.new()
	imported.path = path + "-import.json"
	imported.load_library()
	var plan := imported.preview_import(path + "-export.json", viewer.validate_view_state)
	valid = valid and plan.get("error", "failure").is_empty() and plan.get("imported") == 1
	valid = valid and imported.apply_import(plan, viewer.validate_view_state).is_empty()
	valid = valid and imported.entries.size() == 1 and SavedViews.same_snapshot(imported.entries[0], library.entries[0])
	var preferences := Preferences.new()
	preferences.path = path + "-preferences.json"
	var settings: Dictionary = Preferences.DEFAULTS.duplicate()
	settings.text_scale = 1.3
	settings.explorer = false
	valid = valid and preferences.store(settings).is_empty() and preferences.load_settings().is_empty() and SavedViews.same_snapshot(preferences.values, settings)
	for suffix in [".json", ".json.bak", "-export.json", "-import.json", "-preferences.json"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
	valid = valid and viewer.export_view_state() == before
	if valid:
		print("PASS bundled study workspace: ", viewer.model.body.id)
	return valid
