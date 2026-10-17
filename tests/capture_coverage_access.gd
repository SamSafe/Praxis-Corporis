extends SceneTree

const Verification = preload("res://scripts/study_verification.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/medicine-viewer-feasibility")
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	var settings: Dictionary = viewer.preference_state()
	settings.text_scale = 1.3
	viewer.apply_preferences(settings)
	root.size = Vector2i(1100, 720)
	for id in ["female", "hra-v1-2-female-cord-study"]:
		if viewer.model.body.id != id:
			await viewer.switch_body(id)
		viewer.set_scene_expanded(id != "female")
		var before: Dictionary = viewer.export_view_state().duplicate(true)
		var dialog: Window = viewer.show_coverage()
		dialog.size = Vector2i(760, 520)
		await process_frame
		await process_frame
		if id == "female":
			for index in 5:
				await Verification.coverage_key(dialog, KEY_DOWN)
		await Verification.coverage_key(dialog, KEY_TAB)
		while not dialog.information.is_finished():
			await process_frame
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		print("Coverage text ready: ", id, " · ", dialog.information.get_parsed_text().left(240).replace("\n", " / "))
		if not dialog.information.has_focus() or root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/coverage-keyboard-" + id + ".png") != OK:
			push_error("Coverage keyboard layout capture failed")
			quit(1)
			return
		await Verification.coverage_key(dialog, KEY_PAGEDOWN)
		await Verification.coverage_key(dialog, KEY_A, true)
		await RenderingServer.frame_post_draw
		if dialog.information.get_selected_text().is_empty() or root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/coverage-selected-" + id + ".png") != OK:
			push_error("Coverage text selection capture failed")
			quit(1)
			return
		await Verification.coverage_key(dialog, KEY_ESCAPE)
		await process_frame
		if is_instance_valid(dialog) or viewer.export_view_state() != before:
			push_error("Coverage capture changed the exploration or failed to close")
			quit(1)
			return
		if not await Verification.verify_coverage_access(viewer, true):
			quit(1)
			return
	viewer.queue_free()
	await process_frame
	print("PASS coverage keyboard captures at minimum size and 130% text")
	quit()
