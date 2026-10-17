extends RefCounted
## Study checks use disposable files; shutdown checks run in a dedicated process.

const SavedViews = preload("res://scripts/saved_views.gd")
const Preferences = preload("res://scripts/viewer_preferences.gd")


static func movement_fixture(viewer: Control, offset: Vector3) -> Dictionary:
	viewer.orbit.cancel_drag()
	var leaf: String = viewer.model.selected_id
	var error: String = viewer.model.apply_saved_state({leaf: {"visibility": "visible", "offset": [offset.x, offset.y, offset.z]}})
	if not error.is_empty():
		push_error("Movement history fixture failed: " + error)
		return {}
	viewer.model.undo_stack.clear()
	viewer.model.redo_stack.clear()
	viewer.model.set_visibility(leaf, "faded")
	var redo: Dictionary = viewer.model.export_state().duplicate(true)
	viewer.model.undo()
	viewer.move_button.button_pressed = true
	viewer.orbit.move_mode = true
	viewer.scene_container.grab_focus()
	return redo


static func movement_key(viewer: Control, code: int, shift: bool = false, command: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	event.ctrl_pressed = command and not OS.has_feature("macos")
	event.meta_pressed = command and OS.has_feature("macos")
	viewer.get_viewport().push_input(event)
	await viewer.get_tree().process_frame
	event = event.duplicate()
	event.pressed = false
	viewer.get_viewport().push_input(event)
	await viewer.get_tree().process_frame


static func verify_movement_history(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var expanded: bool = viewer.scene_expanded
	var quality: float = viewer.scene_container.resolution_fraction
	var moving: bool = viewer.orbit.move_mode
	var leaf: String = viewer.model.body.get("qa_leaf_id", "anatomy.heart.valve.mitral")
	if viewer.model.body.id == "bodyparts-male-bones-study":
		leaf = "source.bodyparts3d-v4-male.FJ3365"
	viewer.end_isolation()
	viewer.select_structure(leaf, false)
	viewer.orbit.yaw = 0.0
	viewer.orbit.pitch = 0.0
	viewer.orbit.distance = 2.8
	viewer.orbit.target = Vector3.ZERO
	viewer.orbit.update_camera()
	var index := int(viewer.model.structures[leaf].mesh_nodes[0])
	var valid := true
	for direction in [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.BACK, Vector3.FORWARD]:
		var redo_state := movement_fixture(viewer, direction * 10.0)
		var unchanged: Dictionary = viewer.model.export_state().duplicate(true)
		valid = valid and not redo_state.is_empty() and not viewer.model.offset_selection(direction * 0.005, true)
		for delta in [Vector3.ZERO, Vector3(INF, 0, 0), Vector3(NAN, 0, 0)]:
			valid = not viewer.model.offset_selection(delta, true) and valid
		valid = valid and viewer.model.export_state() == unchanged and viewer.model.undo_stack.is_empty() and viewer.model.redo_stack.size() == 1
	movement_fixture(viewer, Vector3(9.999, 0, 0))
	var partial: Dictionary = viewer.model.export_state().duplicate(true)
	valid = viewer.model.offset_selection(Vector3(0.005, 0, 0), true) and valid
	valid = valid and viewer.model.states[index].offset.x == 10.0 and viewer.model.undo_stack.size() == 1 and viewer.model.redo_stack.is_empty()
	viewer.model.undo()
	valid = valid and viewer.model.export_state() == partial
	for layout in [false, true]:
		viewer.set_scene_expanded(layout)
		for fraction in [1.0, 0.5]:
			viewer.set_scene_resolution(fraction)
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			for fine in [false, true]:
				var redo_state := movement_fixture(viewer, Vector3(10, 0, 0))
				var unchanged: Dictionary = viewer.model.export_state().duplicate(true)
				await movement_key(viewer, KEY_L, fine)
				valid = valid and viewer.model.export_state() == unchanged and viewer.model.undo_stack.is_empty() and viewer.model.redo_stack.size() == 1 and not viewer.redo_button.disabled
				valid = valid and "limit" in viewer.status.text.to_lower()
				if layout:
					valid = valid and "limit" in viewer.expanded_status.text.to_lower()
				viewer.redo_inspection()
				valid = valid and viewer.model.export_state() == redo_state
				movement_fixture(viewer, Vector3(10, 0, 0))
				var boundary: Dictionary = viewer.model.export_state().duplicate(true)
				await movement_key(viewer, KEY_J, fine)
				var displaced: Dictionary = viewer.model.export_state().duplicate(true)
				valid = valid and is_equal_approx(viewer.model.states[index].offset.x, 10.0 - (0.001 if fine else 0.005)) and viewer.model.undo_stack.size() == 1 and viewer.model.redo_stack.is_empty()
				await movement_key(viewer, KEY_Z, false, true)
				valid = valid and viewer.model.export_state() == boundary
				await movement_key(viewer, KEY_Z, true, true)
				valid = valid and viewer.model.export_state() == displaced
			var start := Vector2(40, viewer.scene_container.size.y * 0.6)
			var outward := start + Vector2(24, 12)
			var inward := start - Vector2(24, 12)
			var redo_state := movement_fixture(viewer, Vector3(10, -10, 0))
			var boundary: Dictionary = viewer.model.export_state().duplicate(true)
			pointer_button(viewer, start, true)
			pointer_motion(viewer, outward, MOUSE_BUTTON_MASK_LEFT)
			pointer_button(viewer, outward, false)
			valid = valid and viewer.model.export_state() == boundary and viewer.model.undo_stack.is_empty() and viewer.model.redo_stack.size() == 1
			viewer.redo_inspection()
			valid = valid and viewer.model.export_state() == redo_state
			movement_fixture(viewer, Vector3(10, -10, 0))
			pointer_button(viewer, start, true)
			pointer_motion(viewer, outward, MOUSE_BUTTON_MASK_LEFT)
			viewer.get_window().propagate_notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			pointer_button(viewer, outward, false)
			valid = valid and viewer.model.export_state() == boundary and viewer.model.undo_stack.is_empty() and viewer.model.redo_stack.size() == 1
			pointer_button(viewer, start, true)
			pointer_motion(viewer, inward, MOUSE_BUTTON_MASK_LEFT, Vector2(-24, -12))
			pointer_button(viewer, inward, false)
			valid = valid and viewer.model.export_state() != boundary and viewer.model.undo_stack.size() == 1 and viewer.model.redo_stack.is_empty()
			viewer.undo_inspection()
			valid = valid and viewer.model.export_state() == boundary
			movement_fixture(viewer, Vector3(10, -10, 0))
			pointer_button(viewer, start, true)
			pointer_motion(viewer, outward, MOUSE_BUTTON_MASK_LEFT)
			valid = valid and viewer.model.undo_stack.is_empty() and viewer.model.redo_stack.size() == 1
			pointer_motion(viewer, inward, MOUSE_BUTTON_MASK_LEFT, Vector2(-24, -12))
			pointer_motion(viewer, inward - Vector2(24, 12), MOUSE_BUTTON_MASK_LEFT, Vector2(-24, -12))
			pointer_button(viewer, inward, false)
			var displaced: Dictionary = viewer.model.export_state().duplicate(true)
			valid = valid and displaced != boundary and viewer.model.undo_stack.size() == 1 and viewer.model.redo_stack.is_empty()
			viewer.undo_inspection()
			valid = valid and viewer.model.export_state() == boundary
			viewer.redo_inspection()
			valid = valid and viewer.model.export_state() == displaced
			# Undo/Redo during a held drag ends it; later held-button motion is inert.
			movement_fixture(viewer, Vector3.ZERO)
			pointer_button(viewer, start, true)
			pointer_motion(viewer, outward, MOUSE_BUTTON_MASK_LEFT)
			await movement_key(viewer, KEY_Z, false, true)
			var stopped: Dictionary = viewer.model.export_state().duplicate(true)
			valid = valid and stopped.is_empty() and viewer.orbit.active_button == 0 and viewer.orbit.move_mode
			pointer_motion(viewer, outward + Vector2(24, 12), MOUSE_BUTTON_MASK_LEFT)
			valid = valid and viewer.model.export_state() == stopped and viewer.model.undo_stack.is_empty() and viewer.model.redo_stack.size() == 1
			pointer_button(viewer, outward, false)
			pointer_button(viewer, start, true)
			await movement_key(viewer, KEY_Z, true, true)
			var redone: Dictionary = viewer.model.export_state().duplicate(true)
			pointer_motion(viewer, outward, MOUSE_BUTTON_MASK_LEFT)
			valid = valid and redone != stopped and viewer.model.export_state() == redone and viewer.orbit.active_button == 0
	viewer.orbit.cancel_drag()
	valid = await viewer.restore_view_state(before) and valid
	viewer.model.undo_stack = undo.duplicate(true)
	viewer.model.redo_stack = redo.duplicate(true)
	viewer.back_views = back.duplicate(true)
	viewer.forward_views = forward.duplicate(true)
	viewer.set_scene_expanded(expanded)
	viewer.set_scene_resolution(quality)
	viewer.move_button.button_pressed = moving
	viewer.orbit.move_mode = moving
	viewer.refresh_details()
	valid = valid and viewer.export_view_state() == before
	if valid:
		print("PASS bundled movement history: ", viewer.model.body.id)
	else:
		push_error("Movement bounds, gesture history or restoration failed: " + str(viewer.model.body.id))
	return valid


static func verify_unchanged_edits(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var leaf: String = viewer.model.body.get("qa_leaf_id", "anatomy.heart.valve.mitral")
	if viewer.model.body.id == "bodyparts-male-bones-study":
		leaf = "source.bodyparts3d-v4-male.FJ3365"
	viewer.end_isolation()
	viewer.select_structure(leaf, false)
	var valid := true
	for action in ["Show", "Hide", "Fade", "Restore selected", "Restore all", "Apply unchanged saved anatomy", "Restore unchanged view"]:
		valid = viewer.model.apply_saved_state({}).is_empty() and valid
		if action in ["Hide", "Fade"]:
			viewer.model.set_visibility(leaf, "hidden" if action == "Hide" else "faded")
		viewer.model.undo_stack.clear()
		viewer.model.redo_stack.clear()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.02, 0, 0))
		var moved: Dictionary = viewer.model.export_state().duplicate(true)
		viewer.model.undo()
		var unchanged: Dictionary = viewer.export_view_state().duplicate(true)
		var saved_undo: Array = viewer.model.undo_stack.duplicate(true)
		var saved_redo: Array = viewer.model.redo_stack.duplicate(true)
		for repeat in 4:
			match action:
				"Show": viewer.change_visibility("visible")
				"Hide": viewer.change_visibility("hidden")
				"Fade": viewer.change_visibility("faded")
				"Restore selected": viewer.restore_selected()
				"Restore all": viewer.restore_all()
				"Apply unchanged saved anatomy": valid = viewer.model.apply_saved_state(unchanged.changes).is_empty() and valid
				"Restore unchanged view": valid = await viewer.restore_view_state(unchanged) and valid
			valid = valid and viewer.export_view_state() == unchanged and viewer.model.undo_stack == saved_undo and viewer.model.redo_stack == saved_redo
			valid = valid and not viewer.redo_button.disabled and viewer.undo_button.disabled
		viewer.model.redo()
		valid = valid and viewer.model.export_state() == moved
	# An actual edit still creates one undo step and branches away from redo.
	valid = viewer.model.apply_saved_state({}).is_empty() and valid
	viewer.model.set_visibility(leaf, "hidden")
	var mixed: Dictionary = viewer.model.export_state().duplicate(true)
	viewer.model.undo_stack.clear()
	viewer.model.redo_stack.clear()
	viewer.model.set_visibility(viewer.model.body.root_id, "visible")
	valid = valid and viewer.model.export_state().is_empty() and viewer.model.undo_stack.size() == 1
	viewer.model.undo()
	valid = valid and viewer.model.export_state() == mixed and viewer.model.redo_stack.size() == 1
	viewer.model.set_visibility(leaf, "faded")
	valid = valid and viewer.model.redo_stack.is_empty() and viewer.model.undo_stack.size() == 1 and viewer.model.export_state() != mixed
	var changed: Dictionary = viewer.model.export_state().duplicate(true)
	viewer.restore_selected()
	valid = valid and viewer.model.export_state().is_empty() and viewer.model.undo_stack.size() == 2
	viewer.model.undo()
	valid = valid and viewer.model.export_state() == changed
	viewer.model.redo()
	valid = valid and viewer.model.export_state().is_empty()
	viewer.model.undo()
	var saved_undo: Array = viewer.model.undo_stack.duplicate(true)
	var saved_redo: Array = viewer.model.redo_stack.duplicate(true)
	valid = not viewer.model.apply_saved_state({"missing.structure": {"visibility": "hidden", "offset": [0, 0, 0]}}).is_empty() and valid
	valid = valid and viewer.model.export_state() == changed and viewer.model.undo_stack == saved_undo and viewer.model.redo_stack == saved_redo
	# Empty groups are harmless too, where the source catalogue supplies one.
	for structure in viewer.model.structures.values():
		if structure.mesh_nodes.is_empty():
			viewer.model.set_visibility(structure.id, "hidden")
			viewer.model.restore(structure.id)
	valid = valid and viewer.model.export_state() == changed and viewer.model.undo_stack == saved_undo and viewer.model.redo_stack == saved_redo
	valid = await viewer.restore_view_state(before) and valid
	viewer.model.undo_stack = undo.duplicate(true)
	viewer.model.redo_stack = redo.duplicate(true)
	viewer.back_views = back.duplicate(true)
	viewer.forward_views = forward.duplicate(true)
	viewer.refresh_details()
	valid = valid and viewer.export_view_state() == before
	if valid:
		print("PASS bundled unchanged edits: ", viewer.model.body.id)
	else:
		push_error("Unchanged anatomy commands lost history or real edits failed: " + str(viewer.model.body.id))
	return valid


static func verify_import_preview(viewer: Control, rendered: bool = false) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	var original_path: String = viewer.views_path
	var window_size := viewer.get_window().size
	var directory := "user://import-preview-check-" + Crypto.new().generate_random_bytes(16).hex_encode()
	var valid := DirAccess.make_dir_recursive_absolute(directory) == OK
	for scale in [1.0, 1.3]:
		var settings := preferences.duplicate(true)
		settings.text_scale = scale
		viewer.apply_preferences(settings)
		viewer.get_window().size = Vector2i(1100, 720)
		viewer.views_path = directory + "/library-%s.json" % str(scale)
		var original := SavedViews.new()
		original.path = viewer.views_path
		valid = original.load_library().is_empty() and valid
		valid = original.add_view("Keep original", before).is_empty() and valid
		valid = original.set_notes(original.entries[0].id, "Original saved notes").is_empty() and valid
		valid = original.add_view("Collision view", before).is_empty() and valid
		var saved: Array = original.entries.duplicate(true)
		var kept: Dictionary = original.entries[1].duplicate(true)
		var incoming: Array[Dictionary] = [kept.duplicate(true)]
		for index in 32:
			var entry := kept.duplicate(true)
			entry.id = Crypto.new().generate_random_bytes(16).hex_encode()
			entry.name = "Incoming [b]literal[/b] %02d" % index
			entry.notes = "Incoming notes %02d" % index
			if index == 0:
				entry.name = "Collision view"
			if index == 31:
				entry.state.reference_hash = "different source version"
			incoming.append(entry)
		var source := directory + "/incoming-%s.json" % str(scale)
		var file := FileAccess.open(source, FileAccess.WRITE)
		file.store_string(JSON.stringify({"schema_version": 1, "views": incoming}))
		file.close()
		var digest := FileAccess.get_sha256(viewer.views_path)
		var browser: Window = viewer.show_saved_views()
		browser.preview_import(source)
		await viewer.get_tree().process_frame
		await viewer.get_tree().process_frame
		if not str(browser.import_plan.get("error", "Missing import plan")).is_empty():
			push_error("Import preview fixture failed: " + str(browser.import_plan.get("error")))
			valid = false
			browser.queue_free()
			await viewer.get_tree().process_frame
			continue
		var dialog: Window = browser.import_dialog
		valid = valid and browser.import_plan.imported == 31 and browser.import_plan.skipped == 2
		valid = valid and dialog.content.has_focus() and dialog.content.selection_enabled and not dialog.content.bbcode_enabled
		var bar: VScrollBar = dialog.content.get_v_scroll_bar()
		valid = valid and bar.max_value > bar.page
		if rendered and viewer.model.body.id == "female" and scale == 1.3:
			await RenderingServer.frame_post_draw
			valid = viewer.get_viewport().get_texture().get_image().save_png("user://native-import-preview-long.png") == OK and valid
		await coverage_key(dialog, KEY_PAGEDOWN)
		valid = valid and bar.value > 0.0
		await coverage_key(dialog, KEY_A, true)
		valid = valid and "[b]literal[/b]" in dialog.content.get_selected_text() and "renamed to keep both views" in dialog.content.get_selected_text()
		for code in [KEY_ENTER, KEY_SPACE]:
			await coverage_key(dialog, code)
			valid = valid and dialog.visible and SavedViews.same_snapshot(browser.library.entries, saved) and FileAccess.get_sha256(viewer.views_path) == digest
		await coverage_key(dialog, KEY_ESCAPE)
		valid = valid and not dialog.visible and browser.visible and SavedViews.same_snapshot(browser.library.entries, saved) and FileAccess.get_sha256(viewer.views_path) == digest
		browser.preview_import(source)
		await viewer.get_tree().process_frame
		dialog = browser.import_dialog
		for step in 3:
			if dialog.get_ok_button().has_focus():
				break
			await coverage_key(dialog, KEY_TAB)
		valid = valid and dialog.get_ok_button().has_focus()
		if dialog.get_ok_button().has_focus():
			await coverage_key(dialog, KEY_ENTER)
		valid = valid and not dialog.visible and browser.library.entries.size() == 33 and SavedViews.same_snapshot(browser.library.entries.slice(0, 2), saved)
		for index in range(2, browser.library.entries.size()):
			valid = valid and browser.library.entries[index].notes == incoming[index - 1].notes and SavedViews.same_snapshot(browser.library.entries[index].state, before)
		browser.preview_import(source)
		await viewer.get_tree().process_frame
		dialog = browser.import_dialog
		valid = valid and browser.import_plan.imported == 0 and browser.import_plan.skipped == 33 and dialog.get_ok_button().disabled and dialog.content.has_focus()
		if rendered and viewer.model.body.id == "female" and scale == 1.3:
			await RenderingServer.frame_post_draw
			valid = viewer.get_viewport().get_texture().get_image().save_png("user://native-import-preview-duplicates.png") == OK and valid
			if valid:
				print("PASS native import preview: female")
		await coverage_key(dialog, KEY_A, true)
		await coverage_key(dialog, KEY_ESCAPE)
		valid = valid and not dialog.visible and browser.visible
		browser.queue_free()
		await viewer.get_tree().process_frame
		valid = valid and viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward
	viewer.views_path = original_path
	viewer.apply_preferences(preferences)
	viewer.get_window().size = window_size
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	await viewer.get_tree().process_frame
	await viewer.get_tree().process_frame
	valid = valid and viewer.export_view_state() == before and viewer.preference_state() == preferences
	if valid:
		print("PASS bundled import preview: ", viewer.model.body.id)
	else:
		push_error("Import preview reading, confirmation or preservation failed: " + str(viewer.model.body.id))
	return valid


static func study_navigation_key(viewer: Control, code: int) -> void:
	if code == KEY_ENTER and not viewer.get_window().gui_get_focus_owner() is Button:
		push_error("Study navigation must focus an action button before Enter")
		return
	await coverage_key(viewer.get_window(), code)
	await viewer.get_tree().process_frame


static func verify_study_navigation(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	var expanded: bool = viewer.scene_expanded
	var window_size := viewer.get_window().size
	var guide: Control = viewer.guided_chest
	var valid := true
	for layout in [false, true]:
		viewer.set_scene_expanded(layout)
		for scale in [1.0, 1.3]:
			var settings := preferences.duplicate(true)
			settings.text_scale = scale
			viewer.apply_preferences(settings)
			viewer.get_window().size = Vector2i(1100, 720)
			viewer.start_guided_chest()
			valid = valid and viewer.scene_container.has_focus() and guide.step == 0
			guide.next.grab_focus()
			for index in range(1, guide.STEPS.size()):
				await study_navigation_key(viewer, KEY_ENTER)
				valid = valid and guide.step == index
				valid = valid and (guide.next.has_focus() if index < guide.STEPS.size() - 1 else guide.finish.has_focus())
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and not guide.active and viewer.scene_container.has_focus() and viewer.export_view_state() == before
			viewer.start_guided_chest()
			viewer.apply_chest_step(2)
			guide.previous.grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and guide.step == 1 and guide.previous.has_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and guide.step == 0 and guide.previous.disabled and guide.next.has_focus()
			guide.finish.grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and not guide.active and viewer.scene_container.has_focus() and viewer.export_view_state() == before
			viewer.start_circulation_route()
			guide.branches.get_child(0).grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and guide.route_node == "right-atrium" and guide.branches.get_child(0).has_focus()
			guide.previous.grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and guide.route_node == "vena-cava" and guide.previous.disabled and guide.branches.get_child(0).has_focus()
			for target in ["right-atrium", "tricuspid", "right-ventricle", "pulmonary-valve", "pulmonary-trunk"]:
				await study_navigation_key(viewer, KEY_ENTER)
				valid = valid and guide.route_node == target and guide.branches.get_child(0).has_focus()
			if guide.route_node == "pulmonary-trunk" and guide.branches.get_child_count() == 2:
				await study_navigation_key(viewer, KEY_TAB)
				var right_branch: Button = guide.branches.get_child(1)
				valid = valid and right_branch.has_focus()
				if right_branch.has_focus():
					await study_navigation_key(viewer, KEY_ENTER)
			else:
				valid = false
			valid = valid and guide.route_node == "right-artery" and guide.branches.get_child(0).has_focus()
			guide.previous.grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and guide.route_node == "pulmonary-trunk" and guide.previous.has_focus()
			guide.branches.get_child(0).grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and guide.route_node == "left-artery" and guide.branches.get_child(0).has_focus()
			var route: Dictionary = viewer.study_content.route("heart-lung")
			var steps := 0
			while guide.route_node != "vena-cava" and steps < route.nodes.size():
				var target: String = route.nodes[guide.route_node].next[0]
				await study_navigation_key(viewer, KEY_ENTER)
				valid = valid and guide.route_node == target and guide.branches.get_child(0).has_focus()
				steps += 1
			valid = valid and guide.route_node == "vena-cava"
			guide.finish.grab_focus()
			await study_navigation_key(viewer, KEY_ENTER)
			valid = valid and not guide.active and viewer.scene_container.has_focus() and viewer.export_view_state() == before
			valid = valid and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward
	viewer.apply_preferences(preferences)
	viewer.set_scene_expanded(expanded)
	viewer.get_window().size = window_size
	await viewer.get_tree().process_frame
	await viewer.get_tree().process_frame
	valid = valid and viewer.export_view_state() == before and viewer.preference_state() == preferences
	if valid:
		print("PASS bundled study navigation: ", viewer.model.body.id)
	else:
		push_error("Study keyboard navigation or restoration failed: " + str(viewer.model.body.id))
	return valid


static func coverage_key(dialog: Window, code: int, select_all: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.ctrl_pressed = select_all and not OS.has_feature("macos")
	event.meta_pressed = select_all and OS.has_feature("macos")
	dialog.push_input(event)
	await dialog.get_tree().process_frame
	if is_instance_valid(dialog):
		event = event.duplicate()
		event.pressed = false
		dialog.push_input(event)


static func verify_coverage_access(viewer: Control, rendered: bool = false) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var preferences: Dictionary = viewer.preference_state()
	var window_size := viewer.get_window().size
	var expanded: bool = viewer.scene_expanded
	var valid := true
	for scale in [1.0, 1.3]:
		var settings := preferences.duplicate(true)
		settings.text_scale = scale
		viewer.apply_preferences(settings)
		viewer.get_window().size = Vector2i(1100, 720)
		var dialog: Window = viewer.show_coverage()
		if dialog == null:
			return false
		dialog.size = Vector2i(760, 520)
		await viewer.get_tree().process_frame
		await viewer.get_tree().process_frame
		valid = valid and dialog.system_list.has_focus() and dialog.information.selection_enabled
		var index := 1 if dialog.system_list.item_count > 1 else 0
		for candidate in dialog.notes.systems.size():
			if dialog.notes.systems[candidate].get("id", "") == "respiratory":
				index = candidate
		for step in index:
			await coverage_key(dialog, KEY_DOWN)
		valid = valid and dialog.current_system == dialog.notes.systems[index]
		await coverage_key(dialog, KEY_TAB)
		valid = valid and dialog.information.has_focus()
		if rendered and scale == 1.3:
			while not dialog.information.is_finished():
				await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			await RenderingServer.frame_post_draw
			valid = valid and viewer.get_viewport().get_texture().get_image().save_png("user://native-coverage-%s.png" % str(viewer.model.body.id)) == OK
			if valid:
				print("PASS native coverage reader: ", viewer.model.body.id)
		var bar: VScrollBar = dialog.information.get_v_scroll_bar()
		valid = valid and bar.max_value > bar.page
		await coverage_key(dialog, KEY_PAGEDOWN)
		valid = valid and bar.value > 0.0
		await coverage_key(dialog, KEY_A, true)
		valid = valid and "Mesh counts do not establish anatomical completeness" in dialog.information.get_selected_text()
		var bounds := Rect2(Vector2.ZERO, Vector2(dialog.size))
		for control in [dialog.heading, dialog.system_list, dialog.information, dialog.explore_button, dialog.close_button]:
			valid = valid and bounds.encloses(control.get_global_rect())
		await coverage_key(dialog, KEY_ESCAPE)
		await viewer.get_tree().process_frame
		valid = valid and not is_instance_valid(dialog)
		valid = valid and viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward and viewer.scene_expanded == expanded
	viewer.apply_preferences(preferences)
	viewer.get_window().size = window_size
	await viewer.get_tree().process_frame
	await viewer.get_tree().process_frame
	valid = valid and viewer.export_view_state() == before and viewer.preference_state() == preferences
	if valid:
		print("PASS bundled coverage keyboard: ", viewer.model.body.id)
	else:
		push_error("Coverage keyboard reading or restoration failed: " + str(viewer.model.body.id))
	return valid


static func wheel_zoom(viewer: Control, closer: bool, amount: float) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_WHEEL_UP if closer else MOUSE_BUTTON_WHEEL_DOWN
	event.pressed = true
	event.factor = amount
	event.position = viewer.scene_container.get_global_transform_with_canvas() * Vector2(40, viewer.scene_container.size.y * 0.6)
	event.global_position = event.position
	viewer.get_viewport().push_input(event, true)


static func pinch_zoom(viewer: Control, amount: float) -> void:
	var event := InputEventMagnifyGesture.new()
	event.factor = amount
	event.position = viewer.scene_container.get_global_transform_with_canvas() * Vector2(40, viewer.scene_container.size.y * 0.6)
	viewer.get_viewport().push_input(event, true)


static func zoom_key(viewer: Control, closer: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_EQUAL if closer else KEY_MINUS
	event.pressed = true
	viewer.get_viewport().push_input(event)


static func verify_camera_zoom(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var expanded: bool = viewer.scene_expanded
	var fraction: float = viewer.scene_container.resolution_fraction
	var moving: bool = viewer.orbit.move_mode
	var middle: Dictionary = before.camera.duplicate(true)
	middle.distance = clampf(float(middle.distance), 0.1, 6.0)
	var anatomy := before.duplicate(true)
	anatomy.erase("camera")
	for layout in [false, true]:
		viewer.set_scene_expanded(layout)
		for quality in [1.0, 0.5]:
			viewer.set_scene_resolution(quality)
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			viewer.scene_container.update_resolution()
			viewer.scene_container.grab_focus()
			viewer.orbit.apply_state(middle)
			zoom_key(viewer, true)
			var full_step: float = viewer.orbit.distance
			var valid: bool = full_step < float(middle.distance)
			zoom_key(viewer, false)
			valid = valid and is_equal_approx(viewer.orbit.distance, float(middle.distance))
			viewer.orbit.apply_state(middle)
			for repeat in 4:
				wheel_zoom(viewer, true, 0.25)
			valid = valid and is_equal_approx(viewer.orbit.distance, full_step)
			wheel_zoom(viewer, false, 1.0)
			valid = valid and is_equal_approx(viewer.orbit.distance, float(middle.distance))
			viewer.move_button.button_pressed = true
			viewer.orbit.move_mode = true
			for repeat in 12:
				wheel_zoom(viewer, true, 0.25)
				wheel_zoom(viewer, false, 0.25)
			pinch_zoom(viewer, 1.25)
			pinch_zoom(viewer, 0.8)
			valid = valid and is_equal_approx(viewer.orbit.distance, float(middle.distance)) and viewer.orbit.move_mode and viewer.move_button.button_pressed
			var stopped: Dictionary = viewer.orbit.export_state()
			for invalid in [0.0, -1.0, NAN, INF]:
				pinch_zoom(viewer, invalid)
			valid = valid and viewer.orbit.export_state() == stopped
			var current: Dictionary = viewer.export_view_state()
			var camera: Dictionary = current.camera
			current.erase("camera")
			valid = valid and current == anatomy and camera.target == middle.target and camera.yaw == middle.yaw and camera.pitch == middle.pitch
			valid = valid and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward
			if not valid:
				push_error("Camera zoom failed: %s / expanded %s / quality %s" % [viewer.model.body.id, layout, quality])
				return false
	viewer.orbit.apply_state(before.camera)
	viewer.move_button.button_pressed = moving
	viewer.orbit.move_mode = moving
	viewer.set_scene_resolution(fraction)
	viewer.set_scene_expanded(expanded)
	viewer.refresh_details()
	print("PASS bundled camera zoom: ", viewer.model.body.id)
	return true


static func pointer_button(viewer: Control, point: Vector2, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.canceled = canceled
	event.position = viewer.scene_container.get_global_transform_with_canvas() * point
	event.global_position = event.position
	viewer.get_viewport().push_input(event, true)


static func pointer_motion(viewer: Control, point: Vector2, mask: int, relative: Vector2 = Vector2(24, 12)) -> void:
	var event := InputEventMouseMotion.new()
	event.position = viewer.scene_container.get_global_transform_with_canvas() * point
	event.global_position = event.position
	event.relative = relative
	event.button_mask = mask
	viewer.get_viewport().push_input(event, true)


static func verify_pointer_interruption(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var expanded: bool = viewer.scene_expanded
	var fraction: float = viewer.scene_container.resolution_fraction
	var moving: bool = viewer.orbit.move_mode
	var valid := true
	for layout in [false, true]:
		viewer.set_scene_expanded(layout)
		for quality in [1.0, 0.5]:
			viewer.set_scene_resolution(quality)
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			viewer.scene_container.update_resolution()
			viewer.scene_container.grab_focus()
			viewer.move_button.button_pressed = true
			viewer.orbit.move_mode = true
			var start := Vector2(40, viewer.scene_container.size.y * 0.6)
			var finish := start + Vector2(24, 12)
			for interruption in ["missing release", "window focus", "application focus", "control focus", "canceled release"]:
				pointer_button(viewer, start, true)
				pointer_motion(viewer, finish, MOUSE_BUTTON_MASK_LEFT)
				var stopped: Dictionary = viewer.export_view_state().duplicate(true)
				valid = valid and stopped.changes != before.changes and stopped.camera == before.camera and viewer.model.undo_stack.size() == undo.size() + 1
				match interruption:
					"missing release": pointer_motion(viewer, finish, 0)
					"window focus": viewer.get_window().propagate_notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
					"application focus": viewer.get_window().propagate_notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
					"control focus":
						if layout:
							viewer.expanded_menu.grab_focus()
						else:
							viewer.search.grab_focus()
					"canceled release": pointer_button(viewer, finish, false, true)
				valid = valid and viewer.orbit.active_button == 0 and not viewer.orbit.dragged and not viewer.orbit.move_checkpoint and viewer.orbit.move_mode
				pointer_motion(viewer, finish, MOUSE_BUTTON_MASK_LEFT)
				pointer_button(viewer, finish, false)
				valid = valid and viewer.export_view_state() == stopped and viewer.model.undo_stack.size() == undo.size() + 1 and viewer.back_views == back and viewer.forward_views == forward
				# A new deliberate gesture retains a separate, exact undo boundary.
				pointer_button(viewer, start, true)
				pointer_motion(viewer, finish, MOUSE_BUTTON_MASK_LEFT)
				pointer_button(viewer, finish, false)
				valid = valid and viewer.model.export_state() != stopped.changes and viewer.model.undo_stack.size() == undo.size() + 2
				viewer.model.undo()
				valid = valid and viewer.export_view_state() == stopped
				viewer.model.undo()
				valid = valid and viewer.export_view_state() == before
				viewer.model.undo_stack = undo.duplicate(true)
				viewer.model.redo_stack = redo.duplicate(true)
				if not valid:
					push_error("Pointer interruption failed: %s / expanded %s / quality %s" % [interruption, layout, quality])
					return false
			pointer_button(viewer, start, true)
			pointer_button(viewer, start, false, true)
			valid = valid and viewer.export_view_state() == before and viewer.back_views == back and viewer.forward_views == forward
	viewer.move_button.button_pressed = moving
	viewer.orbit.move_mode = moving
	viewer.set_scene_resolution(fraction)
	viewer.set_scene_expanded(expanded)
	viewer.refresh_details()
	if valid:
		print("PASS bundled pointer interruption: ", viewer.model.body.id)
	return valid


static func verify_loading_shutdown(viewer: Control) -> void:
	var boundaries := {"source": ["Checking source file", false, true, false],
		"anatomy": ["Loading anatomy", true, false, false],
		"selection": ["Loading selection", true, false, true],
		"preparing": ["Preparing selection", false, false, true]}
	var boundary := "anatomy"
	var replacement := "--shutdown-replacement" in OS.get_cmdline_user_args()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--shutdown-stage="):
			boundary = argument.trim_prefix("--shutdown-stage=")
	var tree := viewer.get_tree()
	if not boundaries.has(boundary):
		push_error("Unknown shutdown verification boundary.")
		tree.quit(1)
		return
	if replacement:
		await viewer.switch_body("female")
		if viewer.model.body.get("id") != "female":
			push_error("Shutdown verification could not open its initial reference.")
			tree.quit(1)
			return
	var model: Node3D = viewer.model
	var expected: Array = boundaries[boundary]
	var phase := "replacement" if replacement else "initial"
	var context := {"triggered": false, "requested": false, "loading": false,
		"resource": false, "worker": false, "staged": false, "scene": null, "reference": {}}
	model.tree_exited.connect(func():
		var clean: bool = context.requested and context.loading and model.pending_resource_path.is_empty() and model.staged_scene == null
		clean = clean and (model.hash_worker == null or not model.hash_worker.is_started()) and not is_instance_valid(context.scene)
		clean = clean and context.resource == expected[1] and context.worker == expected[2] and context.staged == expected[3]
		clean = clean and viewer.reference_state.current == context.reference
		if clean:
			print("PASS loading shutdown: %s/%s · resource %s · worker %s · staged %s" % [phase, boundary, context.resource, context.worker, context.staged])
		else:
			push_error("Loading shutdown did not preserve its expected ownership and cleanup state.")
			tree.quit(1), CONNECT_ONE_SHOT)
	model.load_progress.connect(func(stage: String, _fraction: float):
		if stage != expected[0] or context.triggered:
			return
		context.triggered = true
		var close := func():
			context.requested = true
			context.loading = viewer.loading and model.loading
			context.resource = not model.pending_resource_path.is_empty()
			context.worker = model.hash_worker != null and model.hash_worker.is_started()
			context.staged = is_instance_valid(model.staged_scene)
			context.scene = model.staged_scene
			context.reference = viewer.reference_state.current.duplicate(true)
			viewer.get_window().close_requested.emit()
		close.call_deferred())
	viewer.switch_body("male" if replacement else "female")


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
	valid = await verify_pointer_interruption(viewer) and valid
	valid = await verify_camera_zoom(viewer) and valid
	valid = await verify_coverage_access(viewer, rendered) and valid
	var import_layout: bool = viewer.scene_expanded
	for layout in [false, true]:
		viewer.set_scene_expanded(layout)
		valid = await verify_import_preview(viewer, rendered and not layout) and valid
	viewer.set_scene_expanded(import_layout)
	var history_layout: bool = viewer.scene_expanded
	for layout in [false, true]:
		viewer.set_scene_expanded(layout)
		valid = await verify_unchanged_edits(viewer) and valid
	viewer.set_scene_expanded(history_layout)
	valid = await verify_movement_history(viewer) and valid
	if viewer.model.structures.has("anatomy.heart"):
		valid = await verify_study_navigation(viewer) and valid
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
	valid = verify_export_protection(before, viewer.model.body.id) and valid
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
	var deleted: Dictionary = library.entries[0].duplicate(true)
	var delete_ok := library.delete_view(deleted.id).is_empty()
	var undo_ok := library.restore_deleted(deleted, 0).is_empty()
	valid = delete_ok and undo_ok and library.entries.size() == 1 and library.entries[0] == deleted and valid
	if delete_ok and undo_ok and library.entries.size() == 1 and library.entries[0] == deleted:
		print("PASS bundled saved-view deletion undo: ", viewer.model.body.id)
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


static func verify_export_protection(snapshot: Dictionary, reference: String) -> bool:
	var library := SavedViews.new()
	library.path = "user://export-guard-" + Crypto.new().generate_random_bytes(16).hex_encode() + ".json"
	var valid := library.load_library().is_empty()
	valid = library.add_view("Export safeguard fixture", snapshot).is_empty() and valid
	var id: String = library.entries[0].id
	valid = library.set_notes(id, "Original visible note").is_empty() and valid
	var stale := SavedViews.new()
	stale.path = library.path
	valid = stale.load_library().is_empty() and valid
	var visible: Array = stale.entries.duplicate(true)
	valid = library.set_notes(id, "Keep this newer saved note").is_empty() and valid
	var expected := FileAccess.get_file_as_bytes(library.path)
	var absolute := SavedViews.filesystem_path(library.path)
	var fs := DirAccess.open(absolute.get_base_dir())
	var sensitive := fs.is_case_sensitive(absolute.get_base_dir())
	var case_alias := absolute.get_base_dir().path_join(absolute.get_file().to_upper())
	var result := stale.export_library(case_alias)
	valid = (result.is_empty() if sensitive else "outside the active" in result) and valid
	valid = FileAccess.get_file_as_bytes(library.path) == expected and valid
	valid = "outside the active" in stale.export_library(absolute.get_base_dir() + "/./" + absolute.get_file()) and valid
	var outside := absolute.trim_suffix(".json") + "-separate.json"
	valid = DirAccess.copy_absolute(absolute, outside) == OK and valid
	valid = stale.export_library(outside).is_empty() and valid
	var exported := stale.read_file(outside)
	valid = exported.error.is_empty() and exported.entries[0].notes == "Original visible note" and valid
	valid = DirAccess.rename_absolute(absolute, absolute + ".held") == OK and valid
	result = stale.export_library(absolute if sensitive else case_alias)
	valid = "outside the active" in result and not FileAccess.file_exists(absolute) and valid
	valid = DirAccess.rename_absolute(absolute + ".held", absolute) == OK and valid
	valid = FileAccess.get_file_as_bytes(absolute) == expected and stale.entries == visible and valid
	for file in [absolute, absolute + ".bak", absolute + ".held", outside, case_alias]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(file)
	if valid:
		print("PASS bundled export destination guard: ", reference, " · case-sensitive ", sensitive)
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
