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
	if viewer.model.body.id == "female":
		valid = await verify_cancel_loading(viewer) and valid
		valid = await verify_information(viewer, rendered) and valid
		valid = verify_recovery(before) and valid
	if viewer.model.structures.has("anatomy.heart"):
		valid = await verify_conditions(viewer, rendered) and valid
		viewer.model.undo_stack = undo.duplicate(true)
		viewer.model.redo_stack = redo.duplicate(true)
		viewer.back_views = back.duplicate(true)
		viewer.forward_views = forward.duplicate(true)
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


static func verify_cancel_loading(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var remembered: Dictionary = viewer.reference_state.current.duplicate(true)
	viewer.start_guided_chest()
	viewer.apply_chest_step(2)
	var during: Dictionary = viewer.export_view_state().duplicate(true)
	var staged := [null]
	var canceled := [false]
	var callback := func(stage: String, _fraction: float):
		if stage == "Loading selection" and not canceled[0]:
			canceled[0] = true
			staged[0] = viewer.model.staged_scene
			viewer.cancel_load_button.pressed.emit()
	viewer.model.load_progress.connect(callback)
	await viewer.switch_body("male")
	viewer.model.load_progress.disconnect(callback)
	var valid: bool = canceled[0] and not is_instance_valid(staged[0]) and viewer.model.staged_scene == null and viewer.model.hash_worker == null
	valid = valid and viewer.export_view_state() == during and viewer.guided_chest.active and viewer.guided_chest.visible and viewer.guided_chest.step == 2 and viewer.reference_state.current == remembered
	await viewer.finish_guided_chest()
	valid = valid and viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward
	if valid:
		print("PASS bundled canceled reference switch")
	return valid


static func verify_recovery(snapshot: Dictionary) -> bool:
	var path := "user://recovery-check-" + Crypto.new().generate_random_bytes(16).hex_encode() + ".json"
	var library := SavedViews.new()
	library.path = path
	var valid := library.load_library().is_empty()
	valid = library.add_view("Recover this source view", snapshot).is_empty() and valid
	valid = library.set_notes(library.entries[0].id, "Recovered source notes 🫀").is_empty() and valid
	valid = library.add_view("Later view", snapshot).is_empty() and valid
	var healthy := FileAccess.get_file_as_string(path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("truncated {")
	file.close()
	valid = not library.load_library().is_empty() and library.can_recover() and valid
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(healthy)
	file.close()
	valid = not library.recover_backup().is_empty() and FileAccess.get_file_as_string(path) == healthy and valid
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("truncated {")
	file.close()
	library.load_library()
	file = FileAccess.open(path + ".damaged", FileAccess.WRITE)
	file.store_string("Keep earlier damaged input")
	file.close()
	valid = library.recover_backup().is_empty() and valid
	valid = FileAccess.get_file_as_string(path + ".damaged") == "Keep earlier damaged input" and FileAccess.get_file_as_string(library.recovery_copy_path) == "truncated {" and valid
	valid = library.entries.size() == 1 and library.entries[0].notes == "Recovered source notes 🫀" and SavedViews.same_snapshot(library.entries[0].state, snapshot) and valid
	for suffix in ["", ".bak", ".damaged"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
	if not library.recovery_copy_path.is_empty():
		DirAccess.remove_absolute(library.recovery_copy_path)
	if valid:
		print("PASS bundled saved-view recovery")
	return valid


static func verify_information(viewer: Control, rendered: bool) -> bool:
	var preferences: Dictionary = viewer.preference_state()
	var previous_size := viewer.get_window().size
	var large: Dictionary = preferences.duplicate()
	large.text_scale = 1.3
	viewer.apply_preferences(large)
	viewer.get_window().size = Vector2i(1100, 720)
	var valid := true
	for kind in ["help", "sources"]:
		var dialog: Window = viewer.show_keyboard_help() if kind == "help" else viewer.show_sources()
		await viewer.get_tree().process_frame
		await viewer.get_tree().process_frame
		valid = valid and dialog.content.get_parsed_text() == dialog.message and dialog.size.y <= viewer.get_window().size.y
		valid = valid and dialog.get_ok_button().get_global_rect().end.y <= dialog.size.y
		var key := InputEventKey.new()
		key.pressed = true
		key.keycode = KEY_PAGEDOWN
		dialog.push_input(key)
		await viewer.get_tree().process_frame
		valid = valid and dialog.content.get_v_scroll_bar().value > 0
		if rendered:
			await RenderingServer.frame_post_draw
			valid = valid and viewer.get_viewport().get_texture().get_image().save_png("user://native-information-%s.png" % kind) == OK
		key = key.duplicate()
		key.keycode = KEY_ESCAPE
		dialog.push_input(key)
		await viewer.get_tree().process_frame
		await viewer.get_tree().process_frame
		valid = valid and not is_instance_valid(dialog)
	viewer.apply_preferences(preferences)
	viewer.get_window().size = previous_size
	if valid:
		print("PASS bundled information dialogs: female")
	return valid


static func verify_conditions(viewer: Control, rendered: bool) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	var previous_size := viewer.get_window().size
	var large: Dictionary = preferences.duplicate()
	large.text_scale = 1.3
	viewer.apply_preferences(large)
	viewer.get_window().size = Vector2i(1100, 720)
	var valid: bool = viewer.study_content.data.get("conditions", {}).size() == 2
	for id in ["condition.aortic-stenosis", "condition.mitral-regurgitation"]:
		var dialog: Window = viewer.show_condition(id)
		if dialog == null:
			return false
		await viewer.get_tree().process_frame
		valid = valid and "REFERENCE ANATOMY ONLY" in dialog.message and "medical review pending" in dialog.message
		valid = valid and dialog.get_ok_button().get_global_rect().end.y <= dialog.size.y
		if rendered and id == "condition.aortic-stenosis":
			await RenderingServer.frame_post_draw
			valid = valid and viewer.get_viewport().get_texture().get_image().save_png("user://native-condition-%s.png" % str(viewer.model.body.id)) == OK
		var pressed := false
		for button in dialog.find_children("*", "Button", true, false):
			if button is Button and button.text == "Inspect reference anatomy":
				button.pressed.emit()
				pressed = true
				break
		await viewer.get_tree().process_frame
		valid = valid and pressed and viewer.model.selected_id == viewer.study_content.condition(id).focus_id
		valid = valid and viewer.model.isolated_id == viewer.model.selected_id and viewer.model.export_state() == anatomy
		valid = valid and viewer.validate_view_state(viewer.export_view_state()).is_empty()
		viewer.return_to_context()
		valid = valid and viewer.export_view_state() == before
		valid = await viewer.restore_view_state(before) and valid
	viewer.apply_preferences(preferences)
	viewer.get_window().size = previous_size
	if valid:
		print("PASS bundled condition study: ", viewer.model.body.id)
	return valid
