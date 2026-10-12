extends Control

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const OrbitCamera = preload("res://scripts/orbit_camera.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
const AnatomyLabels = preload("res://scripts/anatomy_labels.gd")
const CoverageBrowser = preload("res://scripts/coverage_browser.gd")
const SavedViews = preload("res://scripts/saved_views.gd")
const SavedViewsBrowser = preload("res://scripts/saved_views_browser.gd")
const RenderProfile = preload("res://scripts/render_profile.gd")
const ViewCapture = preload("res://scripts/view_capture.gd")
const AnatomySearch = preload("res://scripts/anatomy_search.gd")
const SourceRecord = preload("res://scripts/source_record.gd")
var save_path := "user://saved_view.json"
var views_path := "user://saved_views.json"

var pack: Dictionary
var coverage_notes: Dictionary = {}
var model: Node3D
var orbit: Node3D
var viewport: SubViewport
var body_choice: OptionButton
var search: LineEdit
var search_index := AnatomySearch.new()
var search_results: ItemList
var search_summary: Label
var search_items: Dictionary = {}
var search_total := 0
var tree: Tree
var tree_items: Dictionary = {}
var heading: Label
var detail: Label
var context: Label
var status: Label
var anatomy_labels: Control
var labels_button: CheckButton
var local_labels_button: CheckButton
var label_density: SpinBox
var back_button: Button
var forward_button: Button
var back_views: Array[Dictionary] = []
var forward_views: Array[Dictionary] = []
var move_button: Button
var undo_button: Button
var redo_button: Button
var original_positions_button: CheckButton
var inspect_button: Button
var return_button: Button
var inspection_banner: HBoxContainer
var inspection_note: Label
var inspection_return: Dictionary = {}
var parts_section: VBoxContainer
var parts_heading: Label
var parts_tree: Tree
var parts_items: Dictionary = {}
var parts_scope := ""
var syncing_parts := false
var selection_scroll_pending := false
var visibility_buttons: Array[Button] = []
var peel_button: Button
var chest_button: Button
var source_credit: Label
var coverage_hint: Label
var action_buttons: Array[Button] = []
var reference_buttons: Array[Button] = []
var loading := false
var loading_row: HBoxContainer
var loading_stage: Label
var loading_bar: ProgressBar
var load_frame_count := 0
var syncing_tree := false
var scene_container: SubViewportContainer
var explorer_panel: Control
var details_panel: Control
var panels_menu: MenuButton
var navigation_hint: Label
var capture_in_progress := false


func _ready() -> void:
	get_tree().auto_accept_quit = false
	get_window().close_requested.connect(request_exit)
	var content_error := ContentBundle.mount_if_needed()
	var parsed := ContentBundle.catalogue()
	if parsed.is_empty():
		push_error("Sample catalogue is missing or invalid.")
		get_tree().quit(1)
		return
	pack = parsed
	var coverage_parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/coverage_notes.json"))
	if coverage_parsed is Dictionary and coverage_parsed.get("pack_id") == pack.id and coverage_parsed.get("source_commit") == pack.source_commit:
		coverage_notes = coverage_parsed
	build_interface()
	if not content_error.is_empty():
		status.text = content_error
		context.text = "Anatomy unavailable"
		if "--verify-bundle" in OS.get_cmdline_user_args() or "--verify-rendered-bundle" in OS.get_cmdline_user_args() or "--profile-rendered-bundle" in OS.get_cmdline_user_args():
			push_error(content_error)
			get_tree().quit(1)
	elif "--profile-rendered-bundle" in OS.get_cmdline_user_args():
		call_deferred("profile_bundle")
	elif "--verify-bundle" in OS.get_cmdline_user_args() or "--verify-rendered-bundle" in OS.get_cmdline_user_args():
		call_deferred("verify_bundle")
	else:
		call_deferred("switch_body", "female")


func request_exit() -> void:
	for child in get_children():
		if child is SavedViewsBrowser and child.visible:
			child.request_action(get_tree().quit)
			return
	get_tree().quit()


func profile_bundle() -> void:
	var profiler := RenderProfile.new()
	var report: Dictionary = await profiler.run(self)
	if report.has("error"):
		push_error(report.error)
		get_tree().quit(1)
		return
	var file := FileAccess.open("user://render-profile.json.tmp", FileAccess.WRITE)
	if file == null:
		push_error("Could not write developer rendering profile")
		get_tree().quit(1)
		return
	file.store_string(JSON.stringify(report, "\t", true, true))
	file.close()
	if DirAccess.rename_absolute("user://render-profile.json.tmp", "user://render-profile.json") != OK:
		push_error("Could not replace developer rendering profile")
		get_tree().quit(1)
		return
	print("PASS rendering profile recorded: user://render-profile.json")
	get_tree().quit()


func verify_bundle() -> void:
	var rendered := "--verify-rendered-bundle" in OS.get_cmdline_user_args()
	if rendered and DisplayServer.get_name() == "headless":
		push_error("Rendered bundle verification needs a desktop display")
		get_tree().quit(1)
		return
	if coverage_notes.is_empty():
		push_error("Bundled coverage notes are missing or mismatched")
		get_tree().quit(1)
		return
	for reference in pack.bodies:
		await switch_body(reference.id)
		var expected_meshes := 0
		for structure in reference.structures:
			if structure.id == reference.root_id:
				expected_meshes = structure.mesh_nodes.size()
		if model.body.get("id") != reference.id or model.meshes.size() != expected_meshes:
			push_error("Bundled reference failed: " + str(reference.id))
			get_tree().quit(1)
			return
		if load_frame_count < 2 or model.load_wait_frames < 2:
			push_error("Bundled loading did not yield interface frames")
			get_tree().quit(1)
			return
		print("PASS interface frames while loading: %s · %d" % [reference.id, load_frame_count])
		var target := "anatomy.heart" if model.structures.has("anatomy.heart") else "anatomy.system.skeletal"
		var leaf := "anatomy.heart.valve.mitral"
		if target != "anatomy.heart":
			var first_index := int(model.structures[target].mesh_nodes[0])
			for id in model.structures:
				if int(model.structures[id].source_node) == first_index:
					leaf = str(id)
		var baseline_bounds: AABB = model.bounds_for(target)
		model.select(target)
		model.checkpoint()
		model.offset_selection(Vector3(0.1, 0.02, 0))
		var saved: Dictionary = model.export_state()
		model.restore()
		if not model.bounds_for(target).is_equal_approx(baseline_bounds) or not model.apply_saved_state(saved).is_empty():
			push_error("Bundled inspection restoration failed")
			get_tree().quit(1)
			return
		select_structure(target)
		var previous := current_view()
		select_structure(leaf)
		navigate_history(true)
		if current_view() != previous or model.export_state() != saved or (target == "anatomy.heart" and anatomy_labels.local_ids().size() != 14):
			push_error("Bundled exploration navigation failed")
			get_tree().quit(1)
			return
		inspect_alone()
		select_structure(leaf)
		var visible_count := 0
		for mesh in model.meshes.values():
			visible_count += int(mesh.visible)
		if model.isolated_id != leaf or visible_count != 1 or model.export_state() != saved:
			push_error("Bundled part inspection failed")
			get_tree().quit(1)
			return
		return_to_context()
		if current_view() != previous or model.export_state() != saved:
			push_error("Bundled return to context failed")
			get_tree().quit(1)
			return
		if not await verify_saved_view(rendered):
			get_tree().quit(1)
			return
		if not await verify_failed_replacement(reference, rendered):
			push_error("Bundled failed replacement changed the current exploration")
			get_tree().quit(1)
			return
		if not await verify_keyboard_workspace():
			get_tree().quit(1)
			return
		if not await verify_search(rendered):
			push_error("Bundled search or source-record identification failed")
			get_tree().quit(1)
			return
		if rendered:
			model.restore()
			if target == "anatomy.heart":
				chest_view()
			else:
				whole_body(false)
				select_structure(target, false)
			local_labels_button.button_pressed = true
			await get_tree().physics_frame
			await get_tree().physics_frame
			anatomy_labels.update_labels()
			await RenderingServer.frame_post_draw
			var captured := get_viewport().get_texture().get_image()
			var capture_error := captured.save_png("user://native-%s-%s.png" % ["chest" if target == "anatomy.heart" else "bones", str(reference.id)])
			if capture_error != OK or anatomy_labels.visible_ids.is_empty():
				push_error("Rendered bundle capture or surface labels failed")
				get_tree().quit(1)
				return
			var credited: Image = await capture_image()
			if credited == null or credited.get_height() <= captured.get_height() or ViewCapture.write_png(credited, "user://native-export-%s.png" % str(reference.id)) != OK:
				push_error("Credited native screenshot export failed")
				get_tree().quit(1)
				return
			print("PASS native credited screenshot: ", reference.id, " · ", credited.get_size())
			print("PASS native rendered reference: ", reference.id, " · ", captured.get_width(), " × ", captured.get_height())
		print("PASS bundled reference: ", reference.id, " · ", model.meshes.size(), " meshes")
	print("PASS offline native bundle")
	get_tree().quit()


func verify_search(rendered: bool) -> bool:
	var before := export_view_state()
	var query := "UBERON0002135" if model.structures.has("anatomy.heart") else "FMA24474"
	var expected := "anatomy.heart.valve.mitral" if model.structures.has("anatomy.heart") else "source.bodyparts3d-v4-male.FJ3365"
	search.text = query
	rebuild_tree()
	var valid: bool = search_total == 1 and search_results.get_item_metadata(0) == expected and export_view_state() == before
	activate_first_search_result()
	valid = valid and model.selected_id == expected and model.export_state() == before.changes and str(model.body.sha256) in source_record_text()
	if rendered and valid:
		inspect_alone()
		await get_tree().physics_frame
		await get_tree().physics_frame
		anatomy_labels.update_labels()
		await RenderingServer.frame_post_draw
		valid = get_viewport().get_texture().get_image().save_png("user://native-search-%s.png" % str(model.body.id)) == OK
	search.text = ""
	rebuild_tree()
	valid = valid and await restore_view_state(before)
	if valid:
		print("PASS bundled source search: ", model.body.id)
	return valid


func verify_failed_replacement(reference: Dictionary, rendered: bool) -> bool:
	# A real cached scene with an invalid mesh mapping must leave the old scene alive.
	var before := export_view_state()
	var old_scene: Node3D = model.source_scene
	var undo: Array = model.undo_stack.duplicate(true)
	var redo: Array = model.redo_stack.duplicate(true)
	var back: Array = back_views.duplicate(true)
	var forward: Array = forward_views.duplicate(true)
	var original_references: Array = pack.bodies
	pack.bodies = original_references.duplicate(true)
	for candidate in pack.bodies:
		if candidate.id == reference.id:
			for concept in candidate.structures:
				if concept.id == candidate.root_id:
					concept.mesh_nodes.append(concept.source_node)
	switch_body(reference.id)
	if rendered:
		await RenderingServer.frame_post_draw
		var capture := get_viewport().get_texture().get_image()
		if capture.save_png("user://native-loading-%s.png" % str(reference.id)) != OK:
			pack.bodies = original_references
			return false
	while loading:
		await get_tree().process_frame
	pack.bodies = original_references
	var preserved: bool = model.source_scene == old_scene and export_view_state() == before and model.undo_stack == undo and model.redo_stack == redo and back_views == back and forward_views == forward
	if preserved:
		print("PASS failed replacement preserves exploration: ", reference.id)
	return preserved


func verify_saved_view(rendered: bool) -> bool:
	# Developer verification uses its own random filename; user libraries/legacy
	# slots are never read or written, including when running a packaged build.
	var library := SavedViews.new()
	library.path = "user://bundle-check-%s.json" % Crypto.new().generate_random_bytes(16).hex_encode()
	library.load_library()
	var snapshot := export_view_state()
	var error := library.add_view("Bundle verification", snapshot)
	if error.is_empty():
		error = library.set_notes(library.entries[0].id, "Developer verification notes.\nRevisit this saved source view.")
	var reopened := SavedViews.new()
	reopened.path = library.path
	if error.is_empty():
		error = reopened.load_library()
	if error.is_empty() and (reopened.entries.size() != 1 or reopened.entries[0].get("notes", "") != "Developer verification notes.\nRevisit this saved source view." or not validate_view_state(reopened.entries[0].state).is_empty()):
		error = "Saved view did not survive reopening"
	if error.is_empty():
		model.restore()
		if not await restore_view_state(reopened.entries[0].state) or model.export_state() != snapshot.changes or model.selected_id != snapshot.selection:
			error = "Saved view did not restore bundled anatomy"
	if error.is_empty() and rendered and not await verify_note_editor(library.path, snapshot):
		error = "Rendered study-note editing failed"
	for suffix in ["", ".tmp", ".bak", ".bak.tmp"]:
		if FileAccess.file_exists(library.path + suffix):
			DirAccess.remove_absolute(library.path + suffix)
	if not error.is_empty():
		push_error(error)
		return false
	print("PASS bundled local saved view and study notes: ", model.body.id)
	return true


func verify_note_editor(library_path: String, snapshot: Dictionary) -> bool:
	var before := export_view_state()
	var library := SavedViews.new()
	library.path = library_path
	var browser := SavedViewsBrowser.new()
	browser.library = library
	browser.pack = pack
	browser.current_state = snapshot
	browser.validate_state = validate_view_state
	browser.theme = theme
	add_child(browser)
	browser.popup_centered_clamped(Vector2i(820, 620), 0.9)
	await get_tree().process_frame
	await get_tree().process_frame
	browser.view_list.select(0)
	browser.select_entry(0)
	browser.notes_input.insert_text_at_caret("Saved from the local note editor.\n")
	await get_tree().process_frame
	await get_tree().process_frame
	browser.notes_button.pressed.emit()
	var expected: String = browser.notes_input.text
	var reopened := SavedViews.new()
	reopened.path = library_path
	var valid: bool = reopened.load_library().is_empty() and reopened.entries.size() == 1 and reopened.entries[0].get("notes", "") == expected and browser.draft_notes.is_empty() and export_view_state() == before
	await RenderingServer.frame_post_draw
	var capture := get_viewport().get_texture().get_image()
	valid = valid and capture.save_png("user://native-study-notes-%s.png" % str(model.body.id)) == OK
	browser.queue_free()
	await get_tree().process_frame
	if valid:
		print("PASS native rendered study notes: ", model.body.id)
	return valid


func verify_keyboard_workspace() -> bool:
	var before := current_view()
	var anatomy: Dictionary = model.export_state()
	scene_container.grab_focus()
	var event := InputEventKey.new()
	event.keycode = KEY_RIGHT
	event.pressed = true
	get_viewport().push_input(event)
	await get_tree().process_frame
	if orbit.yaw == before.camera.yaw or model.export_state() != anatomy:
		push_error("Bundled keyboard camera navigation failed")
		return false
	apply_view(before)
	var original_width := viewport.size.x
	on_panel_action(0)
	on_panel_action(1)
	await get_tree().process_frame
	await get_tree().process_frame
	if viewport.size.x <= original_width or current_view() != before or model.export_state() != anatomy:
		push_error("Bundled panel collapse changed the anatomy view")
		return false
	on_panel_action(0)
	on_panel_action(1)
	await get_tree().process_frame
	await get_tree().process_frame
	print("PASS bundled keyboard workspace: ", model.body.id)
	return true


func make_label(text: String, size: int = 15, color: Color = Color("c6d2df")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func make_button(text: String, callback: Callable, parent: Node, hint: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = hint
	button.custom_minimum_size.y = 38
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func panel_style(background: Color, border: Color, radius: int = 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func build_interface() -> void:
	var palette := Theme.new()
	palette.default_font_size = 15
	for type in ["Button", "OptionButton", "CheckButton"]:
		palette.set_stylebox("normal", type, panel_style(Color("172433"), Color("2b3c50")))
		palette.set_stylebox("hover", type, panel_style(Color("23394a"), Color("6db9c2")))
		palette.set_stylebox("pressed", type, panel_style(Color("26535b"), Color("78c8c8")))
		palette.set_stylebox("focus", type, panel_style(Color(0, 0, 0, 0), Color("83d9d2")))
		palette.set_color("font_color", type, Color("e3edf5"))
	palette.set_stylebox("panel", "PanelContainer", panel_style(Color("0e1926"), Color("263447")))
	palette.set_stylebox("panel", "Tree", panel_style(Color("0e1926"), Color("263447")))
	palette.set_color("font_color", "Tree", Color("c8d6e3"))
	palette.set_stylebox("panel", "ItemList", panel_style(Color("0e1926"), Color("263447")))
	palette.set_color("font_color", "ItemList", Color("c8d6e3"))
	palette.set_constant("v_separation", "Tree", 8)
	palette.set_stylebox("normal", "LineEdit", panel_style(Color("172433"), Color("2b3c50")))
	palette.set_color("font_color", "LineEdit", Color("e3edf5"))
	theme = palette
	var background := ColorRect.new()
	background.color = Color("080f19")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	layout.add_child(top)
	var brand := VBoxContainer.new()
	brand.add_child(make_label("PRAXIS CORPORIS", 22, Color("f1f6fa")))
	brand.add_child(make_label("Anatomy exploration · private prototype", 13, Color("7d97ac")))
	top.add_child(brand)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	body_choice = OptionButton.new()
	body_choice.fit_to_longest_item = false
	for body in pack.bodies:
		body_choice.add_item(str(body.get("short_label", str(body.id).capitalize() + " reference")))
		body_choice.set_item_metadata(body_choice.item_count - 1, str(body.id))
	body_choice.custom_minimum_size.x = 250
	body_choice.item_selected.connect(func(index: int): switch_body(str(body_choice.get_item_metadata(index))))
	top.add_child(body_choice)
	reference_buttons.append(make_button("Saved views", show_saved_views, top, "Keep multiple named exploration setups on this computer."))
	reference_buttons.append(make_button("Coverage", show_coverage, top))
	make_button("Sources", show_sources, top)
	panels_menu = MenuButton.new()
	panels_menu.text = "Panels"
	panels_menu.flat = false
	panels_menu.custom_minimum_size.y = 38
	panels_menu.tooltip_text = "Show or hide side panels without changing the anatomy view."
	panels_menu.get_popup().add_check_item("Anatomy explorer", 0)
	panels_menu.get_popup().add_check_item("Structure details", 1)
	panels_menu.get_popup().add_separator()
	panels_menu.get_popup().add_item("Keyboard controls…", 2)
	panels_menu.get_popup().set_item_checked(0, true)
	panels_menu.get_popup().set_item_checked(1, true)
	panels_menu.get_popup().id_pressed.connect(on_panel_action)
	top.add_child(panels_menu)
	reference_buttons.append(make_button("Screenshot", export_screenshot, top, "Save the current workspace as a PNG with source credits and prototype status."))
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 14)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(columns)
	var left := VBoxContainer.new()
	explorer_panel = left
	left.custom_minimum_size.x = 255
	left.add_theme_constant_override("separation", 10)
	columns.add_child(left)
	left.add_child(make_label("EXPLORE ANATOMY", 13, Color("83cfc9")))
	search = LineEdit.new()
	search.placeholder_text = "Name or source ID…"
	search.max_length = 256
	search.tooltip_text = "Find structures in this reference by name, source name, ontology ID or catalogue ID. Enter selects the first result."
	search.clear_button_enabled = true
	search.custom_minimum_size.y = 40
	search.text_changed.connect(func(_text: String): rebuild_tree())
	search.text_submitted.connect(func(_text: String): activate_first_search_result())
	left.add_child(search)
	search_summary = make_label("", 12, Color("83cfc9"))
	search_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	search_summary.visible = false
	left.add_child(search_summary)
	search_results = ItemList.new()
	search_results.visible = false
	search_results.size_flags_vertical = Control.SIZE_EXPAND_FILL
	search_results.custom_minimum_size = Vector2(255, 160)
	search_results.icon_mode = ItemList.ICON_MODE_TOP
	search_results.max_text_lines = 2
	search_results.fixed_column_width = 235
	search_results.allow_reselect = true
	search_results.add_theme_constant_override("v_separation", 10)
	search_results.item_selected.connect(on_search_selected)
	search_results.item_activated.connect(on_search_selected)
	search_results.resized.connect(func():
		search_results.fixed_column_width = maxi(int(search_results.size.x) - 18, 1)
		if not search.text.strip_edges().is_empty():
			rebuild_tree())
	left.add_child(search_results)
	tree = Tree.new()
	tree.hide_root = true
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.custom_minimum_size.x = 255
	tree.item_selected.connect(on_tree_selected)
	left.add_child(tree)
	peel_button = make_button("Peel away skin", peel_skin, left)
	chest_button = make_button("Show chest", chest_view, left)
	coverage_hint = make_label("PARTIAL ATLAS\nSkeleton, muscles and nerves\ncover selected regions.", 13, Color("879db0"))
	left.add_child(coverage_hint)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.custom_minimum_size.x = 380
	center.add_theme_constant_override("separation", 8)
	columns.add_child(center)
	var navigation := HBoxContainer.new()
	center.add_child(navigation)
	back_button = make_button("Back", func(): navigate_history(true), navigation, "Return to the previous selection and camera view. Alt + Left.")
	forward_button = make_button("Forward", func(): navigate_history(false), navigation, "Return to the next selection and camera view. Alt + Right.")
	context = make_label("Loading reference anatomy…", 14, Color("b5c7d8"))
	context.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	context.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	navigation.add_child(context)
	inspection_banner = HBoxContainer.new()
	center.add_child(inspection_banner)
	loading_row = HBoxContainer.new()
	loading_stage = make_label("", 13, Color("83cfc9"))
	loading_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loading_stage.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	loading_row.add_child(loading_stage)
	loading_bar = ProgressBar.new()
	loading_bar.custom_minimum_size = Vector2(130, 14)
	loading_bar.show_percentage = false
	loading_row.add_child(loading_bar)
	loading_row.visible = false
	center.add_child(loading_row)
	return_button = make_button("Return to context", return_to_context, inspection_banner, "Restore the selection and camera from before Inspect alone; preserve current inspection changes.")
	inspection_note = make_label("", 13, Color("83cfc9"))
	inspection_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspection_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspection_banner.add_child(inspection_note)
	inspection_banner.visible = false
	var frame := PanelContainer.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(frame)
	var container := SubViewportContainer.new()
	scene_container = container
	container.stretch = true
	container.focus_mode = Control.FOCUS_ALL
	container.tooltip_text = "Focus the 3D view with Tab or a click. Arrows orbit; Shift-arrows pan; +/- zoom; F focuses selection; Home shows the body."
	container.gui_input.connect(on_scene_input)
	container.focus_entered.connect(func():
		frame.add_theme_stylebox_override("panel", panel_style(Color("0e1926"), Color("83d9d2")))
		navigation_hint.text = "Opening reference… exploration controls resume when ready" if loading else "Arrows orbit · Shift-arrows pan · +/- zoom · F focus · Home body")
	container.focus_exited.connect(func():
		frame.remove_theme_stylebox_override("panel")
		navigation_hint.text = "Opening reference… exploration controls resume when ready" if loading else "Drag to orbit · Shift/right-drag to pan · Scroll/pinch to zoom")
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(container)
	viewport = SubViewport.new()
	viewport.size = Vector2i(800, 650)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = Viewport.MSAA_2X
	container.add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("0b1522")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b1c4d9")
	environment.environment.ambient_light_energy = 0.55
	world.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-25, -35, 0)
	key.light_energy = 1.5
	world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(20, 130, 0)
	fill.light_color = Color("9dbdcc")
	fill.light_energy = 0.65
	world.add_child(fill)
	model = AnatomyModel.new()
	world.add_child(model)
	model.state_changed.connect(refresh_details)
	model.load_progress.connect(on_load_progress)
	orbit = OrbitCamera.new()
	world.add_child(orbit)
	orbit.clicked.connect(on_viewport_clicked)
	orbit.move_started.connect(func(): model.checkpoint())
	orbit.moved.connect(func(delta: Vector3): model.offset_selection(delta))
	anatomy_labels = AnatomyLabels.new()
	anatomy_labels.model = model
	anatomy_labels.camera = orbit.camera
	anatomy_labels.selected.connect(select_structure)
	# Match the SubViewport's content rectangle, including the panel's margins.
	container.add_child(anatomy_labels)
	anatomy_labels.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	navigation_hint = make_label("Drag to orbit · Shift/right-drag to pan · Scroll/pinch to zoom", 13, Color("7891a7"))
	navigation_hint.tooltip_text = container.tooltip_text
	center.add_child(navigation_hint)
	var right_panel := PanelContainer.new()
	details_panel = right_panel
	right_panel.custom_minimum_size.x = 265
	columns.add_child(right_panel)
	var right_scroll := ScrollContainer.new()
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_scroll.follow_focus = true
	right_panel.add_child(right_scroll)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	right_scroll.add_child(right)
	right.add_child(make_label("SELECTED STRUCTURE", 13, Color("83cfc9")))
	heading = make_label("Explore the body", 23, Color("f2f6fa"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(heading)
	detail = make_label("Select anatomy in the viewer or list.", 14)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(detail)
	var action_row := HBoxContainer.new()
	right.add_child(action_row)
	action_buttons.append(make_button("Focus", focus_selection, action_row))
	visibility_buttons.append(make_button("Show", func(): change_visibility("visible"), action_row))
	var visibility_row := HBoxContainer.new()
	right.add_child(visibility_row)
	visibility_buttons.append(make_button("Hide", func(): change_visibility("hidden"), visibility_row))
	visibility_buttons.append(make_button("Fade", func(): change_visibility("faded"), visibility_row, "Faded anatomy is click-through."))
	inspect_button = make_button("Inspect alone", inspect_alone, right, "Temporarily reveal only the selected supplied geometry at its current position.")
	action_buttons.append(make_button("Restore selected", restore_selected, right))
	action_buttons.append(make_button("Copy source record", copy_source_record, right, "Copy this structure’s source identity and reference fingerprint. Study notes are excluded."))
	parts_section = VBoxContainer.new()
	parts_section.add_theme_constant_override("separation", 8)
	right.add_child(parts_section)
	parts_heading = make_label("SUPPLIED PARTS", 13, Color("83cfc9"))
	parts_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parts_section.add_child(parts_heading)
	parts_tree = Tree.new()
	parts_tree.hide_root = true
	parts_tree.custom_minimum_size.y = 180
	parts_tree.item_selected.connect(on_part_selected)
	parts_section.add_child(parts_tree)
	var parts_hint := make_label("Select a part, then Inspect alone to see covered geometry.", 12, Color("879db0"))
	parts_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parts_section.add_child(parts_hint)
	original_positions_button = CheckButton.new()
	original_positions_button.text = "Show original positions"
	original_positions_button.button_pressed = true
	original_positions_button.tooltip_text = "A faint blue copy marks the original position of moved anatomy. It cannot be selected."
	original_positions_button.toggled.connect(func(enabled: bool):
		model.show_original_positions = enabled
		model.refresh_appearance())
	right.add_child(original_positions_button)
	local_labels_button = CheckButton.new()
	local_labels_button.text = "Local part labels"
	local_labels_button.tooltip_text = "Label supplied opaque parts with visible surfaces. Covered parts remain in the anatomy tree."
	local_labels_button.toggled.connect(func(enabled: bool): anatomy_labels.local_enabled = enabled)
	right.add_child(local_labels_button)
	var density_row := HBoxContainer.new()
	density_row.add_child(make_label("Maximum labels", 13))
	label_density = SpinBox.new()
	label_density.min_value = 1
	label_density.max_value = 12
	label_density.value = 8
	label_density.value_changed.connect(func(value: float): anatomy_labels.density = int(value))
	density_row.add_child(label_density)
	right.add_child(density_row)
	right.add_child(make_label("CONTENT IN DEVELOPMENT", 12, Color("8a9fb2")))
	var pending := make_label("Disease views, guided pathways and validated cutaways will be added progressively.", 14, Color("8a9fb2"))
	pending.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(pending)
	source_credit = make_label("Models: HuBMAP / Human Reference Atlas\n3D Reference Object Library v1.1\nCC BY 4.0 · draft catalogue", 12, Color("758ca2"))
	source_credit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(source_credit)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 12)
	layout.add_child(toolbar)
	reference_buttons.append(make_button("Whole body", whole_body, toolbar))
	move_button = make_button("Move selected", toggle_move, toolbar, "In Move mode, drag in the viewer to displace selected anatomy. Shift-drag still pans.")
	move_button.toggle_mode = true
	labels_button = CheckButton.new()
	labels_button.text = "Selection label"
	labels_button.button_pressed = true
	labels_button.toggled.connect(func(enabled: bool): anatomy_labels.selection_enabled = enabled)
	toolbar.add_child(labels_button)
	undo_button = make_button("Undo", func(): model.undo(), toolbar)
	redo_button = make_button("Redo", func(): model.redo(), toolbar)
	reference_buttons.append(make_button("Restore all", restore_all, toolbar))
	status = make_label("Preparing the local anatomy sample…", 13, Color("7891a7"))
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	toolbar.add_child(status)
	refresh_details()


func switch_body(id: String) -> void:
	if loading:
		return
	var record: Dictionary = {}
	for candidate in pack.bodies:
		if candidate.id == id:
			record = candidate
	if record.is_empty():
		return
	loading = true
	load_frame_count = 0
	orbit.input_enabled = false
	orbit.cancel_drag()
	loading_row.visible = true
	navigation_hint.text = "Opening reference… exploration controls resume when ready"
	anatomy_labels.suspended = true
	anatomy_labels.update_labels()
	refresh_details()
	body_choice.disabled = true
	context.text = "Loading %s…" % str(record.label)
	on_load_progress("Checking source file", -1.0)
	var previous_selection: String = model.selected_id
	await get_tree().process_frame
	await get_tree().process_frame
	var error: String = await model.load_body(record)
	loading = false
	orbit.input_enabled = true
	loading_row.visible = false
	navigation_hint.text = "Arrows orbit · Shift-arrows pan · +/- zoom · F focus · Home body" if scene_container.has_focus() else "Drag to orbit · Shift/right-drag to pan · Scroll/pinch to zoom"
	anatomy_labels.suspended = false
	body_choice.disabled = false
	if not error.is_empty():
		status.text = error
		context.text = "Reference unavailable"
		select_body_choice(str(model.body.get("id", "female")))
		refresh_details()
		return
	anatomy_labels.clear_labels()
	parts_scope = ""
	parts_items.clear()
	parts_tree.clear()
	back_views.clear()
	forward_views.clear()
	inspection_return = {}
	select_body_choice(id)
	move_button.button_pressed = false
	orbit.move_mode = false
	search_index.build(model.structures)
	rebuild_tree()
	if model.structures.has(previous_selection) and previous_selection != "anatomy.body":
		select_structure(previous_selection, false)
	else:
		whole_body(false)
	status.text = str(record.get("short_label", record.label)) + " ready"
	refresh_details()


func on_load_progress(stage: String, fraction: float) -> void:
	loading_stage.text = stage + "…"
	loading_bar.indeterminate = fraction < 0.0
	loading_bar.value = clampf(fraction, 0.0, 1.0) * 100.0
	loading_bar.tooltip_text = "Progress within this step; reference opening includes several steps."
	status.text = "Loading reference · " + stage


func select_body_choice(id: String) -> void:
	for index in range(body_choice.item_count):
		if body_choice.get_item_metadata(index) == id:
			body_choice.select(index)
			return


func rebuild_tree() -> void:
	if tree == null:
		return
	syncing_tree = true
	tree.clear()
	tree_items.clear()
	search_results.clear()
	search_items.clear()
	var query := search.text.strip_edges()
	tree.visible = query.is_empty()
	search_results.visible = not query.is_empty()
	search_summary.visible = not query.is_empty()
	if query.is_empty() and model.structures.has("anatomy.body"):
		var root := tree.create_item()
		for id in model.structures["anatomy.body"].children:
			append_tree_branch(id, root, 0)
		search_total = 0
	elif not query.is_empty():
		var result := search_index.find(query)
		search_total = result.total
		for match_record in result.results:
			var record: Dictionary = model.structures[match_record.id]
			var text := search_line(str(record.label), false) + "\n" + search_line(str(record.source_name), true)
			var index := search_results.add_item(text)
			search_results.set_item_metadata(index, match_record.id)
			search_results.set_item_tooltip(index, SourceRecord.tooltip(model.structures, match_record.id))
			search_items[match_record.id] = index
		var reference := str(model.body.get("short_label", model.body.get("label", "Current reference")))
		if search_total == 0:
			search_summary.text = "No matches · " + reference + "\nTry another name or source ID."
		elif search_total > AnatomySearch.RESULT_LIMIT:
			search_summary.text = "First %d of %d matches · %s\nRefine your search for more specific results." % [AnatomySearch.RESULT_LIMIT, search_total, reference]
		else:
			search_summary.text = "%d match%s · %s" % [search_total, "es" if search_total != 1 else "", reference]
	syncing_tree = false
	sync_selection_tree()


func search_line(value: String, keep_suffix: bool) -> String:
	# Elide display text by actual font width; complete source text stays in the tooltip/details.
	var font := search_results.get_theme_font("font")
	var font_size := search_results.get_theme_font_size("font_size")
	var width := maxf(float(search_results.fixed_column_width) - 8.0, 1.0)
	if font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= width:
		return value
	var left := value.left(8) if keep_suffix else ""
	var shortened := value.substr(8) if keep_suffix else value
	while not shortened.is_empty():
		var candidate := left + "…" + shortened if keep_suffix else shortened + "…"
		if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= width:
			return candidate
		shortened = shortened.substr(1) if keep_suffix else shortened.left(shortened.length() - 1)
	return "…"


func activate_first_search_result() -> void:
	if loading or search.text.strip_edges().is_empty() or search_results.item_count == 0:
		return
	search_results.select(0)
	on_search_selected(0)
	search_results.grab_focus()


func on_search_selected(index: int) -> void:
	if syncing_tree:
		return
	if loading:
		sync_selection_tree()
		return
	if index >= 0 and index < search_results.item_count:
		select_structure(str(search_results.get_item_metadata(index)))


func append_tree_branch(id: String, parent: TreeItem, depth: int) -> void:
	var record: Dictionary = model.structures[id]
	var item := tree.create_item(parent)
	item.set_text(0, str(record.label))
	item.set_metadata(0, id)
	item.set_tooltip_text(0, SourceRecord.tooltip(model.structures, id))
	item.collapsed = depth >= 1
	tree_items[id] = item
	for child in record.children:
		append_tree_branch(child, item, depth + 1)


func on_tree_selected() -> void:
	if syncing_tree:
		return
	if loading:
		sync_selection_tree()
		return
	if tree.get_selected() != null:
		select_structure(str(tree.get_selected().get_metadata(0)))


func select_structure(id: String, remember: bool = true) -> void:
	if loading or not model.structures.has(id):
		return
	var previous := current_view()
	anatomy_labels.set_selection(id)
	if not model.isolated_id.is_empty():
		if not model.set_isolation(id):
			end_isolation()
	model.select(id)
	focus_selection(false)
	sync_selection_tree()
	if remember:
		remember_view(previous)
	refresh_navigation()


func sync_selection_tree() -> void:
	syncing_tree = true
	tree.deselect_all()
	search_results.deselect_all()
	if search_items.has(model.selected_id):
		search_results.select(int(search_items[model.selected_id]))
		queue_selection_scroll()
	if tree_items.has(model.selected_id):
		var id: String = model.selected_id
		var parent: TreeItem = tree_items[id].get_parent()
		while parent != null:
			parent.collapsed = false
			parent = parent.get_parent()
		tree_items[id].select(0)
		queue_selection_scroll()
	syncing_tree = false
	sync_parts_selection()


func refresh_parts() -> void:
	if parts_tree == null:
		return
	var scope: String = anatomy_labels.context_id
	parts_section.visible = model.structures.has(scope)
	if not parts_section.visible:
		parts_scope = ""
		parts_items.clear()
		parts_tree.clear()
		return
	if scope != parts_scope:
		syncing_parts = true
		parts_tree.clear()
		parts_items.clear()
		parts_scope = scope
		parts_heading.text = "SUPPLIED PARTS · " + str(model.structures[scope].label)
		var root := parts_tree.create_item()
		for child in model.structures[scope].children:
			append_part_branch(str(child), root)
		syncing_parts = false
	sync_parts_selection()


func append_part_branch(id: String, parent: TreeItem) -> void:
	var record: Dictionary = model.structures[id]
	var item := parts_tree.create_item(parent)
	item.set_text(0, str(record.label))
	item.set_tooltip_text(0, SourceRecord.tooltip(model.structures, id))
	item.set_metadata(0, id)
	parts_items[id] = item
	for child in record.children:
		append_part_branch(str(child), item)


func sync_parts_selection() -> void:
	if parts_tree == null:
		return
	syncing_parts = true
	parts_tree.deselect_all()
	if parts_items.has(model.selected_id):
		var parent: TreeItem = parts_items[model.selected_id].get_parent()
		while parent != null:
			parent.collapsed = false
			parent = parent.get_parent()
		parts_items[model.selected_id].select(0)
		queue_selection_scroll()
	syncing_parts = false


func queue_selection_scroll() -> void:
	if not selection_scroll_pending:
		selection_scroll_pending = true
		scroll_current_selection.call_deferred()


func scroll_current_selection() -> void:
	selection_scroll_pending = false
	# Resolve current items after layout. Queuing a TreeItem directly can leave a
	# freed pointer when rapid navigation replaces a local tree before the callback.
	if not is_inside_tree():
		return
	if search_items.has(model.selected_id):
		search_results.ensure_current_is_visible()
	if tree_items.has(model.selected_id):
		tree.scroll_to_item(tree_items[model.selected_id])
	if parts_items.has(model.selected_id):
		parts_tree.scroll_to_item(parts_items[model.selected_id])


func on_part_selected() -> void:
	if syncing_parts:
		return
	if loading:
		sync_parts_selection()
		return
	if parts_tree.get_selected() != null:
		select_structure(str(parts_tree.get_selected().get_metadata(0)))


func camera_view() -> Dictionary:
	return {"selection": model.selected_id, "camera": orbit.export_state(), "label_context": anatomy_labels.context_id}


func current_view() -> Dictionary:
	var view := camera_view()
	view["isolation"] = model.isolated_id
	view["inspection_return"] = inspection_return.duplicate(true)
	return view


func apply_view(view: Dictionary) -> void:
	inspection_return = view.get("inspection_return", {}).duplicate(true)
	anatomy_labels.context_id = view.label_context
	model.set_isolation(view.get("isolation", ""))
	model.select(view.selection)
	orbit.apply_state(view.camera)
	sync_selection_tree()
	refresh_details()


func remember_view(previous: Dictionary) -> void:
	if previous == current_view():
		return
	back_views.append(previous)
	if back_views.size() > 40:
		back_views.pop_front()
	forward_views.clear()
	refresh_navigation()


func navigate_history(backward: bool) -> void:
	if loading:
		return
	var source: Array[Dictionary] = back_views if backward else forward_views
	var destination: Array[Dictionary] = forward_views if backward else back_views
	if source.is_empty():
		return
	destination.append(current_view())
	var view: Dictionary = source.pop_back()
	leave_move_mode()
	apply_view(view)
	refresh_navigation()
	status.text = "Earlier view restored" if backward else "Next view restored"


func refresh_navigation() -> void:
	if back_button == null:
		return
	back_button.disabled = loading or back_views.is_empty()
	forward_button.disabled = loading or forward_views.is_empty()
	if not loading and not model.body.is_empty():
		var region: String = str(model.structures[model.selected_id].label) if model.structures.has(model.selected_id) else "Whole body"
		context.text = "%s · %s" % [str(model.body.get("short_label", model.body.label)), region]
		if not model.isolated_id.is_empty():
			context.text += " · inspecting alone"


func on_viewport_clicked(position: Vector2) -> void:
	if loading:
		return
	scene_container.grab_focus()
	var id: String = model.pick(orbit.camera, position)
	if not id.is_empty():
		select_structure(id)


func on_panel_action(id: int) -> void:
	if id in [0, 1]:
		var panel: Control = explorer_panel if id == 0 else details_panel
		panel.visible = not panel.visible
		panels_menu.get_popup().set_item_checked(id, panel.visible)
		# Keep a keyboard route back to the workspace when hiding a focused control.
		scene_container.grab_focus()
	elif id == 2:
		var dialog := AcceptDialog.new()
		dialog.title = "Keyboard controls"
		dialog.dialog_text = "Tab / Shift-Tab moves between controls.\nSearch and anatomy lists provide a text selection route.\n\nWith the 3D view focused (teal border):\nArrow keys orbit · Shift + arrows pan\n+ / - zoom · F focuses selection · Home shows the body\nCamera keys leave Move mode and preserve inspection edits.\n\nAlt + Left/Right revisits views.\nCtrl/Cmd + Z undoes inspection; add Shift to redo.\nText fields keep their ordinary editing shortcuts.\nEscape leaves Move mode or closes the active dialog."
		dialog.confirmed.connect(dialog.queue_free)
		dialog.canceled.connect(dialog.queue_free)
		add_child(dialog)
		dialog.popup_centered_clamped(Vector2i(650, 430), 0.9)


func on_scene_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or loading or not scene_container.has_focus():
		return
	if event.alt_pressed or event.ctrl_pressed or event.meta_pressed:
		return
	var direction := Vector2.ZERO
	match event.keycode:
		KEY_LEFT: direction = Vector2.LEFT
		KEY_RIGHT: direction = Vector2.RIGHT
		KEY_UP: direction = Vector2.UP
		KEY_DOWN: direction = Vector2.DOWN
	var recognized: bool = direction != Vector2.ZERO or event.keycode in [KEY_PLUS, KEY_EQUAL, KEY_KP_ADD, KEY_MINUS, KEY_KP_SUBTRACT, KEY_F, KEY_HOME]
	if not recognized:
		return
	leave_move_mode()
	if direction != Vector2.ZERO:
		if event.shift_pressed:
			orbit.keyboard_pan(direction)
		else:
			orbit.keyboard_orbit(direction)
	elif event.keycode in [KEY_PLUS, KEY_EQUAL, KEY_KP_ADD, KEY_MINUS, KEY_KP_SUBTRACT]:
		orbit.keyboard_zoom(event.keycode in [KEY_PLUS, KEY_EQUAL, KEY_KP_ADD])
	elif event.keycode == KEY_F:
		focus_selection()
	elif event.keycode == KEY_HOME:
		whole_body()
	scene_container.accept_event()


func refresh_details() -> void:
	if heading == null:
		return
	refresh_navigation()
	refresh_parts()
	if coverage_hint:
		coverage_hint.text = "SEPARATE BONE STUDY\nSource geometry only.\nHRA alignment unreviewed." if model.body.get("study", false) else "PARTIAL ATLAS\nSkeleton, muscles and nerves\ncover selected regions."
	if source_credit:
		source_credit.text = "BodyParts3D · Database Center for Life Science\nSeparate male bone study · review pending\nLicence records: Sources" if model.body.get("study", false) else "HuBMAP / Human Reference Atlas\n3D Reference Object Library v1.1\nCC BY 4.0 · draft catalogue"
	for button in reference_buttons:
		button.disabled = loading or model.body.is_empty()
	for control in [labels_button, local_labels_button, original_positions_button]:
		if control:
			control.disabled = loading
	if label_density:
		label_density.editable = not loading
	if search:
		search.editable = not loading
	var selected: bool = model.structures.has(model.selected_id)
	var isolated: bool = not model.isolated_id.is_empty()
	if peel_button:
		peel_button.disabled = loading or isolated or not model.structures.has("anatomy.skin")
	if chest_button:
		chest_button.disabled = loading or not model.structures.has("anatomy.heart")
	if inspect_button:
		inspect_button.disabled = loading or not selected or model.isolated_id == model.selected_id or model.structures[model.selected_id].mesh_nodes.is_empty()
	if inspection_banner:
		inspection_banner.visible = isolated
		return_button.disabled = loading
		inspection_note.text = "Inspecting supplied geometry · surroundings temporarily hidden"
	for button in visibility_buttons:
		button.disabled = loading or not selected or isolated
		button.tooltip_text = "Return to context to edit visibility." if isolated else "Change the selected anatomy's visibility; faded parts are click-through."
	if move_button:
		move_button.disabled = not selected or loading
		if not selected:
			move_button.button_pressed = false
			orbit.move_mode = false
	if undo_button:
		undo_button.disabled = model.undo_stack.is_empty() or loading
	if redo_button:
		redo_button.disabled = model.redo_stack.is_empty() or loading
	for button in action_buttons:
		button.disabled = not selected or loading
	if not selected:
		heading.text = "Explore the body"
		detail.text = "Peel away the skin, select a structure, and explore its position in the body.\n\nUse Show chest for a first close view.\n\nSource names and geometry are a draft import; anatomical review is pending."
		if model.body.get("study", false):
			detail.text = str(model.body.coverage) + "\n\nSeparate source coordinates; no alignment to HRA or female anatomy. Select a source bone in the list or viewer."
		return
	var record: Dictionary = model.structures[model.selected_id]
	heading.text = str(record.label)
	var visibility_counts := {"visible": 0, "faded": 0, "hidden": 0}
	var displaced := false
	for index in record.mesh_nodes:
		visibility_counts[model.states[int(index)].visibility] += 1
		displaced = displaced or model.states[int(index)].offset != Vector3.ZERO
	detail.text = "%d source mesh%s\n%d visible · %d faded · %d hidden\n\n%s\n\nSource name: %s\nOntology: %s\nCatalogue ID: %s\nDraft import · review pending" % [
		record.mesh_nodes.size(), "es" if record.mesh_nodes.size() != 1 else "",
		visibility_counts.visible, visibility_counts.faded, visibility_counts.hidden,
		"Moved for inspection. Restore returns the original anatomy." if displaced else "In its original atlas position.",
		record.source_name, str(record.ontology) if not str(record.ontology).is_empty() else "Not supplied", record.id]
	if isolated:
		detail.text = "INSPECTING ALONE\nSupplied geometry temporarily revealed.\n\nContext settings:\n" + detail.text


func source_record_text() -> String:
	if loading or not model.structures.has(model.selected_id):
		return ""
	return SourceRecord.text_for(model.body, model.structures[model.selected_id], str(pack.id))


func copy_source_record() -> void:
	var text := source_record_text()
	if text.is_empty():
		return
	if DisplayServer.get_name() == "headless":
		status.text = "Copying a source record needs a desktop display."
		return
	DisplayServer.clipboard_set(text)
	status.text = "Source record copied"


func leave_move_mode() -> void:
	move_button.button_pressed = false
	orbit.move_mode = false
	orbit.cancel_drag()


func inspect_alone() -> void:
	if loading or not model.structures.has(model.selected_id) or model.structures[model.selected_id].mesh_nodes.is_empty():
		return
	var previous := current_view()
	if model.isolated_id.is_empty():
		inspection_return = camera_view()
	leave_move_mode()
	model.set_isolation(model.selected_id)
	focus_selection(false)
	remember_view(previous)
	status.text = "Temporary inspection view · Return to context preserves your changes"


func end_isolation() -> void:
	inspection_return = {}
	if not model.isolated_id.is_empty():
		model.set_isolation("")


func return_to_context() -> void:
	if loading or model.isolated_id.is_empty() or inspection_return.is_empty():
		return
	var previous := current_view()
	var view := inspection_return.duplicate(true)
	leave_move_mode()
	apply_view(view)
	remember_view(previous)
	status.text = "Body context restored · inspection changes preserved"


func focus_selection(remember: bool = true) -> void:
	if loading:
		return
	if model.structures.has(model.selected_id):
		var previous := current_view()
		orbit.focus(model.bounds_for(model.selected_id))
		if remember:
			remember_view(previous)


func whole_body(remember: bool = true) -> void:
	if loading or not model.structures.has("anatomy.body"):
		return
	var previous := current_view()
	end_isolation()
	model.select("")
	anatomy_labels.set_selection("")
	orbit.yaw = 0.0
	orbit.pitch = 0.0
	orbit.focus(model.bounds_for("anatomy.skin" if model.structures.has("anatomy.skin") else "anatomy.body"))
	sync_selection_tree()
	if remember:
		remember_view(previous)
	refresh_navigation()


func chest_view() -> void:
	if loading or not model.structures.has("anatomy.heart"):
		return
	var previous := current_view()
	end_isolation()
	model.set_visibility("anatomy.skin", "hidden")
	model.set_visibility("anatomy.lungs", "faded")
	select_structure("anatomy.heart", false)
	# Keep enough surrounding chest context after selection focus.
	orbit.distance *= 2.0
	orbit.update_camera()
	remember_view(previous)


func change_visibility(visibility: String) -> void:
	if loading or not model.isolated_id.is_empty():
		return
	model.set_visibility(model.selected_id, visibility)


func peel_skin() -> void:
	if not loading and model.isolated_id.is_empty():
		model.set_visibility("anatomy.skin", "hidden")


func restore_selected() -> void:
	if loading:
		return
	model.restore(model.selected_id)


func restore_all() -> void:
	if loading:
		return
	var previous := current_view()
	end_isolation()
	model.restore()
	remember_view(previous)


func toggle_move() -> void:
	if loading:
		return
	orbit.move_mode = move_button.button_pressed
	status.text = "Drag to move the selected structure · Shift-drag to pan" if orbit.move_mode else "Drag to orbit · click to select"


func _process(_delta: float) -> void:
	if loading:
		load_frame_count += 1
	if status:
		status.tooltip_text = status.text


func capture_image() -> Image:
	if loading or model.body.is_empty() or DisplayServer.get_name() == "headless":
		return null
	var before := export_view_state()
	await get_tree().physics_frame
	await get_tree().physics_frame
	anatomy_labels.update_labels()
	await RenderingServer.frame_post_draw
	if loading or export_view_state() != before:
		status.text = "The view changed during capture. Try again."
		return null
	var workspace := get_viewport().get_texture().get_image()
	var selected_label := str(model.structures[model.selected_id].label) if model.structures.has(model.selected_id) else "Whole body"
	var caption := ViewCapture.credits(model.body, selected_label)
	return await ViewCapture.compose(self, workspace, caption, theme)


func export_screenshot() -> void:
	if capture_in_progress or loading or model.body.is_empty():
		return
	capture_in_progress = true
	var captured: Image = await capture_image()
	if captured == null:
		capture_in_progress = false
		if DisplayServer.get_name() == "headless":
			status.text = "Screenshot export needs a desktop display."
		return
	var dialog := FileDialog.new()
	dialog.title = "Save anatomy screenshot with credits"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.png", "PNG image", "image/png")
	dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	dialog.current_file = "PraxisCorporis-view.png"
	dialog.file_selected.connect(func(path: String):
		var error := ViewCapture.write_png(captured, path)
		status.text = "Screenshot saved with source credits" if error == OK else "Could not save the screenshot (error %d)." % error
		capture_in_progress = false
		dialog.queue_free())
	dialog.canceled.connect(func():
		capture_in_progress = false
		dialog.queue_free())
	add_child(dialog)
	dialog.popup_file_dialog()


func export_view_state() -> Dictionary:
	if loading or model.body.is_empty():
		return {}
	return {"schema_version": 1, "pack_id": pack.id, "body": model.body.id,
		"selection": model.selected_id, "camera": orbit.export_state(),
		"labels": labels_button.button_pressed, "original_positions": original_positions_button.button_pressed,
		"local_labels": local_labels_button.button_pressed, "label_density": int(label_density.value),
		"label_context": anatomy_labels.context_id,
		"isolation": model.isolated_id, "inspection_return": inspection_return.duplicate(true),
		"reference_hash": model.body.sha256,
		"changes": model.export_state()}


func save_view() -> void:
	var state := export_view_state()
	if state.is_empty():
		return
	var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		status.text = "Could not write the saved view."
		return
	file.store_string(JSON.stringify(state, "\t", true, true))
	file.close()
	var error := DirAccess.rename_absolute(save_path + ".tmp", save_path)
	status.text = "View saved on this computer" if error == OK else "Could not replace the saved view."


func load_view() -> void:
	if loading:
		return
	if not FileAccess.file_exists(save_path):
		status.text = "No saved view on this computer yet."
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not parsed is Dictionary:
		status.text = "Saved view is not valid JSON."
		return
	await restore_view_state(parsed)


func validate_view_state(state: Dictionary) -> String:
	if state.get("schema_version") != 1 or state.get("pack_id") != pack.id:
		return "Saved view uses a different content or save version."
	if not state.get("camera") is Dictionary or not orbit.valid_state(state.camera) or not state.get("changes") is Dictionary:
		return "Saved view has invalid camera or anatomy data."
	if not state.get("body") is String or not state.get("selection") is String or not state.get("labels") is bool:
		return "Saved view has invalid body, selection or label settings."
	if state.has("original_positions") and not state.original_positions is bool:
		return "Saved view has an invalid original-position setting."
	if (state.has("local_labels") and not state.local_labels is bool) or (state.has("label_density") and
		(not (state.label_density is float or state.label_density is int) or not is_finite(float(state.label_density)) or
		float(state.label_density) != floorf(float(state.label_density)) or state.label_density < 1 or state.label_density > 12)):
		return "Saved view has invalid local-label settings."
	if state.has("label_context") and not state.label_context is String:
		return "Saved view has an invalid label context."
	var reference: Dictionary = {}
	for candidate in pack.bodies:
		if candidate.id == state.body:
			reference = candidate
	if reference.is_empty():
		return "Saved reference is unavailable. Prepare its source content first."
	if (state.has("reference_hash") and state.reference_hash != reference.sha256) or (reference.get("study", false) and not state.has("reference_hash")):
		return "Saved view belongs to a different reference geometry version."
	var validation: String = model.validate_saved_changes(state.changes, reference)
	if not validation.is_empty():
		return validation
	var selection_exists: bool = state.selection.is_empty()
	for structure in reference.structures:
		selection_exists = selection_exists or structure.id == state.selection
	if not selection_exists:
		return "Saved selection is missing from this sample pack."
	if not valid_label_context(state.selection, state.get("label_context", ""), reference):
		return "Saved label context does not match the selected anatomy."
	if not valid_inspection_view(state, reference):
		return "Saved inspection view has invalid anatomy or return context."
	return ""


func restore_view_state(state: Dictionary) -> bool:
	if loading:
		return false
	var validation := validate_view_state(state)
	if not validation.is_empty():
		status.text = validation
		return false
	if model.body.get("id") != state.body:
		await switch_body(state.body)
	if model.body.get("id") != state.body:
		return false
	var previous := current_view()
	leave_move_mode()
	var error: String = model.apply_saved_state(state.changes)
	if not error.is_empty():
		status.text = error
		return false
	anatomy_labels.context_id = ""
	anatomy_labels.set_selection(state.selection)
	if state.has("label_context"):
		anatomy_labels.context_id = state.label_context
	inspection_return = state.get("inspection_return", {}).duplicate(true)
	model.set_isolation(state.get("isolation", ""))
	model.select(state.selection)
	orbit.apply_state(state.camera)
	labels_button.button_pressed = state.labels
	local_labels_button.button_pressed = state.get("local_labels", false)
	label_density.value = state.get("label_density", 8)
	original_positions_button.button_pressed = state.get("original_positions", true)
	model.show_original_positions = original_positions_button.button_pressed
	model.refresh_appearance()
	sync_selection_tree()
	refresh_details()
	remember_view(previous)
	refresh_navigation()
	status.text = "Saved view restored"
	return true


func show_saved_views() -> Window:
	if loading or model.body.is_empty():
		return null
	var browser := SavedViewsBrowser.new()
	var library := SavedViews.new()
	library.path = views_path
	browser.library = library
	browser.pack = pack
	browser.current_state = export_view_state()
	browser.theme = theme
	browser.validate_state = validate_view_state
	browser.legacy_available = FileAccess.file_exists(save_path)
	browser.restore_requested.connect(func(state: Dictionary, view_name: String):
		if await restore_view_state(state):
			status.text = "Restored “" + view_name + "”")
	browser.legacy_requested.connect(load_view)
	add_child(browser)
	browser.popup_centered_clamped(Vector2i(780, 560), 0.9)
	return browser


func valid_inspection_view(state: Dictionary, reference: Dictionary) -> bool:
	var isolated = state.get("isolation", "")
	var return_view = state.get("inspection_return", {})
	if not isolated is String or not return_view is Dictionary:
		return false
	if isolated.is_empty():
		return return_view.is_empty()
	if isolated != state.selection:
		return false
	var available := {}
	for structure in reference.structures:
		available[str(structure.id)] = structure
	if not available.has(isolated) or available[isolated].mesh_nodes.is_empty():
		return false
	for key in return_view:
		if key not in ["selection", "camera", "label_context"]:
			return false
	if not return_view.get("selection") is String or not return_view.get("label_context") is String or not return_view.get("camera") is Dictionary:
		return false
	if not return_view.selection.is_empty() and not available.has(return_view.selection):
		return false
	return orbit.valid_state(return_view.camera) and valid_label_context(return_view.selection, return_view.label_context, reference)


func valid_label_context(selection: String, label_context: String, reference: Dictionary) -> bool:
	if label_context.is_empty():
		return true
	var available := {}
	for structure in reference.structures:
		available[str(structure.id)] = structure
	if not available.has(label_context) or available[label_context].mesh_nodes.size() <= 1 or available[label_context].mesh_nodes.size() > AnatomyLabels.MAX_CANDIDATES:
		return false
	while available.has(selection):
		if selection == label_context:
			return true
		selection = str(available[selection].parent)
	return false


func show_sources() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Sources and prototype status"
	dialog.dialog_text = "Anatomy: HuBMAP / Human Reference Atlas 3D Reference Object Library, United v1.1.\nCC BY 4.0. Source files unchanged; sampling sites excluded, cache conversion,\nselection colours, fading and temporary inspection movements applied.\n\nhttps://github.com/hubmapconsortium/ccf-3d-reference-object-library\nhttps://creativecommons.org/licenses/by/4.0/\n\nGodot Engine: MIT licence; https://godotengine.org/license/\n\nThis is a private, partial atlas prototype. Anatomy labels and coverage are draft\nimports; qualified medical review is pending. No disease content is included."
	if model.body.get("study", false):
		dialog.dialog_text = "BodyParts3D, © The Database Center for Life Science licensed under CC\nAttribution 4.0 International. Official archive v4.0; current grant from the\n2025 licence page. Original OBJ comments retain legacy CC BY-SA 2.1 Japan\nnotices. Both records are retained. Geometry was converted from millimetres\nto metres and Z-up to Y-up, with source normals preserved. Display colour\nand inspection effects are runtime modifications.\n\nhttps://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html\nhttps://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html\n\nSeparate male bone study; no registration to HRA or female anatomy. Geometry\nand labels are unreviewed. No disease content.\nGodot Engine: MIT licence; https://godotengine.org/license/"
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(760, 390))


func show_coverage() -> Window:
	if loading or model.body.is_empty():
		return null
	if coverage_notes.is_empty():
		status.text = "Coverage notes do not match this content pack."
		return null
	var browser := CoverageBrowser.new()
	browser.pack = pack
	browser.notes = coverage_notes
	if model.body.has("coverage_notes"):
		browser.notes = model.body.coverage_notes
	browser.body_id = str(model.body.id)
	browser.theme = theme
	browser.explore_requested.connect(select_structure)
	add_child(browser)
	browser.popup_centered_clamped(Vector2i(940, 620), 0.9)
	return browser


func _unhandled_key_input(event: InputEvent) -> void:
	if loading:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var focused := get_viewport().gui_get_focus_owner()
		if focused is LineEdit or focused is TextEdit:
			return
		if event.keycode == KEY_Z and (event.ctrl_pressed or event.meta_pressed):
			if event.shift_pressed:
				model.redo()
			else:
				model.undo()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			move_button.button_pressed = false
			orbit.move_mode = false
			orbit.cancel_drag()
			status.text = "Navigate mode · selection preserved"
			get_viewport().set_input_as_handled()
		elif event.alt_pressed and event.keycode in [KEY_LEFT, KEY_RIGHT]:
			navigate_history(event.keycode == KEY_LEFT)
			get_viewport().set_input_as_handled()
