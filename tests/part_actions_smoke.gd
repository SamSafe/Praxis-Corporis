extends SceneTree
## Real GUI events, selection-bound actions and exact inspection restoration.

const PartActions = preload("res://scripts/part_actions.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func settle() -> void:
	await process_frame
	await process_frame
	await physics_frame
	await physics_frame


func key(code: int, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.shift_pressed = shift
	event.pressed = true
	root.push_input(event, true)
	await process_frame


func pointer(viewer: Control, point: Vector2, pressed: bool, button: MouseButton) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = viewer.scene_container.get_global_transform_with_canvas() * point
	event.global_position = event.position
	root.push_input(event, true)


func activate(viewer: Control, id: int) -> void:
	viewer.open_part_actions()
	viewer.part_actions.menu_for(id).id_pressed.emit(id)


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await settle()
	while viewer.loading:
		await process_frame
	root.wrap_controls = false
	for reference in viewer.pack.bodies:
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		var id := "anatomy.heart" if reference.id in ["female", "male"] else "source.bodyparts3d-v4-male.FJ3365"
		viewer.select_structure(id)
		viewer.inspect_alone()
		await settle()
		for expanded in [false, true]:
			viewer.set_scene_expanded(expanded)
			for window_size in [Vector2i(1100, 720), Vector2i(1920, 1080)]:
				root.size = window_size
				for fraction in [1.0, 0.5]:
					viewer.set_scene_resolution(fraction)
					await settle()
					viewer.anatomy_labels.update_labels()
					check(viewer.part_actions.visible and viewer.part_actions.anchored, "An opaque isolated selection has an anchored Actions button")
					var rect := Rect2(viewer.part_actions.position, viewer.part_actions.size)
					check(Rect2(Vector2.ZERO, viewer.scene_container.size).encloses(rect), "Actions stays within the scene at all checked sizes and resolutions")
					for other in viewer.anatomy_labels.exclusion_controls:
						if other.is_visible_in_tree():
							var position: Vector2 = viewer.scene_container.get_global_transform().affine_inverse() * other.global_position
							check(not rect.grow(4).intersects(Rect2(position, other.size)), "Actions avoids orientation and expanded feedback/toolbars")
					for pill in viewer.anatomy_labels.buttons.values():
						if pill.visible:
							check(not rect.grow(4).intersects(Rect2(pill.position, pill.size)), "Actions and label pills do not overlap")
					var before: Dictionary = viewer.export_view_state()
					viewer.scene_container.grab_focus()
					await key(KEY_F10, true)
					check(viewer.part_actions.get_popup().visible, "Shift+F10 opens selection actions through root GUI input")
					var popup: PopupMenu = viewer.part_actions.get_popup()
					check(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(Rect2(popup.position, popup.size)), "Main popup remains within the window's logical canvas")
					await key(KEY_ESCAPE)
					check(not popup.visible and viewer.scene_expanded == expanded and viewer.export_view_state() == before,
						"Escape closes the popup before leaving the expanded view and preserves the exact setup")
					var centre: Vector2 = viewer.part_actions.position + viewer.part_actions.size * 0.5
					pointer(viewer, centre, true, MOUSE_BUTTON_LEFT)
					pointer(viewer, centre, false, MOUSE_BUTTON_LEFT)
					await process_frame
					check(popup.visible and viewer.orbit.active_button == 0 and viewer.export_view_state() == before,
						"Clicking Actions opens its menu without picking, navigating or moving anatomy")
					await key(KEY_ESCAPE)
		viewer.refresh_part_actions()
		check(viewer.part_actions.action_disabled(PartActions.Action.HIDE), "Visibility is unavailable under temporary isolation")
		var isolated: Dictionary = viewer.export_view_state()
		activate(viewer, PartActions.Action.HIDE)
		check(viewer.export_view_state() == isolated, "Disabled visibility routes cannot alter isolated context settings")
		viewer.part_actions.close_menu()
		activate(viewer, PartActions.Action.RETURN_CONTEXT)
		var baseline: Dictionary = viewer.model.export_state()
		activate(viewer, PartActions.Action.HIDE)
		await settle()
		check(not viewer.part_actions.anchored and viewer.part_actions.position == viewer.part_actions.fallback and viewer.model.selected_id == id,
			"Hidden anatomy keeps its selection and an accessible corner action menu")
		var hidden: Dictionary = viewer.model.export_state()
		check(hidden != baseline, "Hide changes real source visibility")
		activate(viewer, PartActions.Action.UNDO)
		check(viewer.model.export_state() == baseline, "Menu Undo exactly restores prior visibility")
		activate(viewer, PartActions.Action.REDO)
		check(viewer.model.export_state() == hidden, "Menu Redo exactly restores hidden state")
		activate(viewer, PartActions.Action.SHOW)
		activate(viewer, PartActions.Action.FADE)
		await settle()
		check(not viewer.part_actions.anchored, "Faded geometry has no misleading opaque-surface anchor")
		activate(viewer, PartActions.Action.RESTORE)
		await settle()
		viewer.open_part_actions()
		var popup: PopupMenu = viewer.part_actions.get_popup()
		await process_frame
		check(popup.visible, "The submenu keyboard check starts with a presented parent menu")
		popup.set_focused_item(popup.get_item_index(PartActions.VISIBILITY))
		await key(KEY_RIGHT)
		check(viewer.part_actions.visibility_menu.visible, "Keyboard opens the visibility submenu")
		check(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(Rect2(viewer.part_actions.visibility_menu.position, viewer.part_actions.visibility_menu.size)),
			"Visibility submenu remains inside the logical window")
		await key(KEY_ESCAPE)
		check(popup.visible and not viewer.part_actions.visibility_menu.visible, "Escape closes a submenu before its parent menu")
		await key(KEY_ESCAPE)
		check(not popup.visible and viewer.scene_expanded, "A second Escape closes the parent while preserving expanded anatomy")
		activate(viewer, PartActions.Action.MOVE)
		check(viewer.orbit.move_mode and viewer.move_button.button_pressed, "Menu Move explicitly activates the existing Move tool")
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.03, 0.01, 0))
		var moved: Dictionary = viewer.model.export_state()
		activate(viewer, PartActions.Action.RESTORE)
		check(not viewer.orbit.move_mode and viewer.model.export_state() == baseline, "Restore returns exact source positions and leaves Move mode")
		activate(viewer, PartActions.Action.UNDO)
		check(viewer.model.export_state() == moved, "Restoration is undoable through the part menu")
		activate(viewer, PartActions.Action.REDO)
		check(viewer.model.export_state() == baseline, "Restoration is redoable through the part menu")
		viewer.orbit.target += Vector3(10, 0, 0)
		viewer.orbit.update_camera()
		viewer.anatomy_labels.update_labels()
		check(viewer.part_actions.visible and not viewer.part_actions.anchored, "Off-screen selected anatomy retains corner actions")
		activate(viewer, PartActions.Action.FOCUS)
		check(viewer.orbit.target.is_equal_approx(viewer.model.bounds_for(id).get_center()) and viewer.model.export_state() == baseline,
			"Corner Focus finds the selected source part without changing anatomy")
		activate(viewer, PartActions.Action.INSPECT)
		activate(viewer, PartActions.Action.SELECTION_LABELS)
		viewer.anatomy_labels.update_labels()
		check(not viewer.labels_button.button_pressed and viewer.part_actions.anchored and viewer.anatomy_labels.visible_ids.is_empty(),
			"Selection actions retain a real surface anchor when name labels are off")
		activate(viewer, PartActions.Action.LOCAL_LABELS)
		check(viewer.local_labels_button.button_pressed == viewer.anatomy_labels.local_enabled, "Menu and workspace local-label controls share state")
		activate(viewer, PartActions.Action.LOCAL_LABELS)
		activate(viewer, PartActions.Action.SELECTION_LABELS)
		# The popup's captured selection cannot be reused against another selected part.
		viewer.open_part_actions()
		viewer.select_structure("anatomy.body")
		check(not viewer.part_actions.get_popup().visible, "A selection change closes the old menu")
		var stale: Dictionary = viewer.export_view_state()
		viewer.on_part_action(PartActions.Action.HIDE, id)
		check(viewer.export_view_state() == stale, "Stale menu actions cannot change a replacement selection")
		viewer.select_structure(id)
		viewer.open_part_actions()
		viewer.loading = true
		viewer.refresh_details()
		check(not viewer.part_actions.visible and not viewer.part_actions.get_popup().visible, "Reference loading suspends and closes part actions")
		viewer.on_part_action(PartActions.Action.RESTORE, id)
		viewer.loading = false
		viewer.refresh_details()
		viewer.inspect_alone()
		await settle()
		var prior_camera: Dictionary = viewer.orbit.export_state()
		var prior_changes: Dictionary = viewer.model.export_state()
		var start := Vector2(40, viewer.scene_container.size.y * 0.6)
		pointer(viewer, start, true, MOUSE_BUTTON_RIGHT)
		var motion := InputEventMouseMotion.new()
		motion.position = viewer.scene_container.get_global_transform_with_canvas() * (start + Vector2(25, 12))
		motion.global_position = motion.position
		motion.relative = Vector2(25, 12)
		motion.button_mask = MOUSE_BUTTON_MASK_RIGHT
		root.push_input(motion, true)
		pointer(viewer, start + Vector2(25, 12), false, MOUSE_BUTTON_RIGHT)
		check(viewer.orbit.export_state() != prior_camera and viewer.model.export_state() == prior_changes
			and not viewer.part_actions.get_popup().visible and viewer.model.selected_id == id, "Right-drag keeps panning without opening a menu or editing anatomy")
		viewer.orbit.apply_state(prior_camera)
		viewer.local_labels_button.button_pressed = false
		viewer.return_to_context()
		viewer.set_scene_expanded(false)
		print("PASS selection-bound part actions: ", reference.id)
	viewer.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS part action menus: actual GUI events, sizes, densities, guards and restoration")
	quit(0 if failures.is_empty() else 1)
