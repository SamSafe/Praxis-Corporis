extends SceneTree
## Actual camera directions, geometry preservation and overlay input ownership.

const ReferenceOrientation = preload("res://scripts/reference_orientation.gd")
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


func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	root.push_input(event, true)
	await process_frame


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await settle()
	while viewer.loading:
		await process_frame
	var frames: Dictionary = viewer.orientation.document
	for reference in viewer.pack.bodies:
		check(not ReferenceOrientation.checked_frame(reference, frames).is_empty(), "Every installed reference has fingerprint-matched source directions")
		for kind in ["fingerprint", "reflection", "length", "nonfinite", "missing"]:
			var invalid := frames.duplicate(true)
			var record: Dictionary = invalid.references[reference.id]
			match kind:
				"fingerprint": record.source_sha256 = "0".repeat(64)
				"reflection": record.left = [-1, 0, 0]
				"length": record.superior = [0, 2, 0]
				"nonfinite": record.anterior = [0, 0, NAN]
				"missing": record.erase("anterior")
			check(ReferenceOrientation.checked_frame(reference, invalid).is_empty(), "Unsupported or invalid direction metadata is rejected: " + kind)
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		viewer.select_structure("anatomy.heart" if reference.id in ["female", "male"] else "source.bodyparts3d-v4-male.FJ3365")
		viewer.inspect_alone()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.03, 0.01, 0))
		var before: Dictionary = viewer.export_view_state()
		var undo: Array = viewer.model.undo_stack.duplicate(true)
		for expanded in [false, true]:
			viewer.set_scene_expanded(expanded)
			await settle()
			for fraction in [1.0, 0.5]:
				viewer.set_scene_resolution(fraction)
				await settle()
				for index in ReferenceOrientation.VIEW_NAMES.size():
					viewer.orientation.menu.get_popup().id_pressed.emit(index)
					await settle()
					var expected := ReferenceOrientation.view_direction(viewer.orientation.frame, index)
					check((viewer.orbit.camera.position - viewer.orbit.target).normalized().is_equal_approx(expected), "Camera faces the requested source-body direction")
					check(viewer.orbit.export_state().target == before.camera.target and viewer.orbit.distance == before.camera.distance
						and viewer.model.export_state() == before.changes and viewer.model.undo_stack == undo and viewer.model.isolated_id == before.isolation,
						"Named camera views preserve focus, distance, isolation, anatomy edits and undo")
					viewer.anatomy_labels.update_labels()
					for id in viewer.anatomy_labels.visible_ids:
						var button: Button = viewer.anatomy_labels.buttons[id]
						check(not Rect2(button.position, button.size).grow(4).intersects(Rect2(viewer.orientation.position, viewer.orientation.size)), "Labels remain outside the orientation controls")
				viewer.orient_camera(0)
				viewer.orientation.refresh_menu()
				check(viewer.orientation.menu.get_popup().is_item_checked(0), "The camera menu identifies an exact named view")
				var glyphs: Array = viewer.orientation.projected_directions()
				var left: Dictionary = {}
				var right: Dictionary = {}
				for glyph in glyphs:
					if glyph.label == "L": left = glyph
					if glyph.label == "R": right = glyph
				check(left.point.x > right.point.x, "Front view shows the body's left on the viewer's right")
				viewer.navigate_history(true)
				check(viewer.model.export_state() == before.changes, "Back restores camera history without undoing anatomy")
		viewer.orient_camera(0)
		viewer.move_button.button_pressed = true
		viewer.toggle_move()
		viewer.orient_camera(2)
		check(not viewer.orbit.move_mode and viewer.model.export_state() == before.changes, "A named camera action leaves explicit Move mode safely")
		var prior: Dictionary = viewer.current_view()
		viewer.loading = true
		viewer.refresh_details()
		viewer.orient_camera(1)
		check(viewer.current_view() == prior and not viewer.orientation.active, "Reference loading blocks orientation changes")
		viewer.loading = false
		viewer.refresh_details()
		viewer.orientation.menu.grab_focus()
		await key(KEY_ENTER)
		check(viewer.orientation.menu.get_popup().visible, "Keyboard opens Camera views")
		await key(KEY_ESCAPE)
		check(not viewer.orientation.menu.get_popup().visible and viewer.scene_expanded, "Escape dismisses Camera views before leaving expanded anatomy")
		if DisplayServer.get_name() != "headless":
			root.size = Vector2i(1100, 720)
			viewer.set_scene_resolution(1.0)
			await settle()
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/orientation-compact-%s.png" % reference.id) == OK, "Compact direction cue is captured for review")
			viewer.orientation.menu.show_popup()
			await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/orientation-compact-menu-%s.png" % reference.id) == OK, "Compact camera menu is captured for review")
			viewer.orientation.menu.get_popup().hide()
		viewer.set_scene_expanded(false)
		viewer.model.restore()
		print("PASS source orientation: ", reference.id)
	viewer.queue_free()
	await process_frame
	print("Orientation failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
