extends SceneTree

const InformationDialog = preload("res://scripts/information_dialog.gd")
var failures := 0
var viewer
var rendered := false


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func key(window: Window, code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	window.push_input(event)
	await process_frame


func reference_button(dialog: Window) -> Button:
	for button in dialog.find_children("*", "Button", true, false):
		if button is Button and button.text == "Inspect reference anatomy":
			return button
	return null


func capture(name: String) -> void:
	if rendered:
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png("/tmp/medicine-improvements/condition-" + name + ".png") == OK, "Capture condition study")


func _initialize() -> void:
	rendered = DisplayServer.get_name() != "headless"
	call_deferred("run")


func run() -> void:
	viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	var dialog: Window
	for reference in ["female", "male"]:
		if viewer.model.body.id != reference:
			await viewer.switch_body(reference)
		viewer.select_structure("anatomy.heart")
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.02, 0.01, 0))
		var before: Dictionary = viewer.export_view_state().duplicate(true)
		var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
		var undo: Array = viewer.model.undo_stack.duplicate(true)
		var back: Array = viewer.back_views.duplicate(true)
		check(viewer.condition_links.visible and viewer.condition_links.get_child_count() == 7, "Heart exposes its six explicitly associated draft conditions")
		viewer.condition_links.get_child(1).pressed.emit()
		for child in viewer.get_children():
			if child is InformationDialog:
				dialog = child
		check(dialog != null and "Aortic stenosis" in dialog.title, "Condition link opens its named study text")
		check("REFERENCE ANATOMY ONLY" in dialog.message and "medical review pending" in dialog.message and "https://www.nhlbi.nih.gov/health/heart-valve-diseases/types" in dialog.message, "Condition explains depiction limits and retains supporting citations")
		await capture(reference + "-aortic")
		await key(dialog, KEY_ESCAPE)
		await process_frame
		check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.back_views == back, "Reading and closing condition text preserves the exploration and histories")
		var available: Array[String] = []
		for identity in viewer.study_content.data.conditions:
			if viewer.study_content.condition_available(identity, viewer.model.structures):
				available.append(str(identity))
		# Shared conditions, the 8 about anatomy no source models, and each body's own
		# supported anatomy; see tests/test_study_content.py.
		check(available.size() == (109 if reference == "female" else 101) and ("condition.bph" in available) == (reference == "male") and ("condition.endometriosis" in available) == (reference == "female"), "Each body offers exactly the conditions its supplied anatomy supports")
		for identity in available:
			undo = viewer.model.undo_stack.duplicate(true)
			dialog = viewer.show_condition(identity)
			await process_frame
			var action := reference_button(dialog)
			if viewer.study_content.condition_focus(identity, viewer.model.structures).is_empty():
				# Unmodelled anatomy with nothing nearby in this body: text only.
				check(action == null and "NO 3D MODEL" in dialog.message, "Text-only condition offers no location action")
				dialog.hide()
				dialog.queue_free()
				await process_frame
				continue
			check(action != null, "Condition has an explicit reference-location action")
			action.pressed.emit()
			await process_frame
			check(viewer.model.selected_id == viewer.study_content.condition_focus(identity, viewer.model.structures) and viewer.model.isolated_id == viewer.model.selected_id and viewer.orbit.target.is_equal_approx(viewer.model.bounds_for(viewer.model.selected_id).get_center()), "Reference action reveals and focuses the actual supplied valve")
			check(viewer.model.export_state() == anatomy and viewer.model.undo_stack == undo, "Locating a condition never deforms, fades or moves source anatomy")
			check("pathological changes are not depicted" in viewer.status.text, "Location feedback states the reference-only limit")
			check(viewer.validate_view_state(viewer.export_view_state()).is_empty(), "Condition reference location remains an ordinary compatible view")
			viewer.return_to_context()
			check(viewer.export_view_state() == before, "Reference inspection returns directly to the starting context and preserves edits")
			await viewer.restore_view_state(before)
		# Mapped organ structures list their conditions just like shared chest IDs.
		viewer.select_structure(viewer.study_content.structure_id("anatomy.gallbladder", viewer.model.structures))
		var titles: Array[String] = []
		for child in viewer.condition_links.get_children():
			if child is LinkButton:
				titles.append(child.text)
		check(viewer.condition_links.visible and titles == ["Gallstones"], "Gallbladder lists its mapped draft condition")
		check("Stores bile" in viewer.study_summary.text, "Mapped organ shows its authored card")
		# Either side of a paired part shows the shared card and its conditions.
		var lenses: Array = viewer.study_content.data.cards["anatomy.lens"].geometry[reference]
		viewer.select_structure(lenses[1].id)
		titles.clear()
		for child in viewer.condition_links.get_children():
			if child is LinkButton:
				titles.append(child.text)
		check(titles == ["Cataracts"] and "focus light" in viewer.study_summary.text, "Second lens shows the shared lens card and its condition")
		await viewer.restore_view_state(before)
		viewer.inspect_alone("anatomy.heart")
		var isolated: Dictionary = viewer.export_view_state().duplicate(true)
		dialog = viewer.show_condition("condition.aortic-stenosis")
		reference_button(dialog).pressed.emit()
		await process_frame
		viewer.navigate_history(true)
		check(viewer.export_view_state() == isolated, "Back restores the prior isolated context after condition inspection")
		await viewer.restore_view_state(before)
		var settings: Dictionary = viewer.preference_state()
		settings.text_scale = 1.3
		viewer.apply_preferences(settings)
		root.size = Vector2i(1100, 720)
		dialog = viewer.show_condition("condition.mitral-regurgitation")
		await process_frame
		await process_frame
		check(reference_button(dialog).get_global_rect().end.x <= dialog.size.x and dialog.get_ok_button().get_global_rect().end.y <= dialog.size.y, "Reference action and Close remain reachable at 130% text")
		await capture(reference + "-compact")
		await key(dialog, KEY_ESCAPE)
		await process_frame
		viewer.apply_preferences(viewer.ViewerPreferences.DEFAULTS)
		root.size = Vector2i(1440, 900)
		viewer.loading = true
		viewer.refresh_details()
		check(viewer.condition_links.get_child(1).disabled and viewer.show_condition("condition.aortic-stenosis") == null, "Loading cannot open or act on condition anatomy")
		viewer.loading = false
		viewer.refresh_details()
	dialog = viewer.show_condition("condition.aortic-stenosis")
	await viewer.switch_body("bodyparts-male-bones-study")
	var switched: Dictionary = viewer.export_view_state().duplicate(true)
	reference_button(dialog).pressed.emit()
	await process_frame
	check(viewer.export_view_state() == switched and not viewer.condition_links.visible, "A stale condition action cannot select anatomy in another source")
	check(viewer.show_condition("condition.aortic-stenosis") == null, "Unmapped source has no inferred disease location")
	viewer.queue_free()
	await process_frame
	print("Condition study failures: ", failures)
	quit(0 if failures == 0 else 1)
