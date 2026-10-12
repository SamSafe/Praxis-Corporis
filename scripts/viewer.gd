extends Control

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const OrbitCamera = preload("res://scripts/orbit_camera.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
var save_path := "user://saved_view.json"

var pack: Dictionary
var model: Node3D
var orbit: Node3D
var viewport: SubViewport
var body_choice: OptionButton
var search: LineEdit
var tree: Tree
var tree_items: Dictionary = {}
var heading: Label
var detail: Label
var context: Label
var status: Label
var selection_label: Label
var labels_button: CheckButton
var move_button: Button
var undo_button: Button
var redo_button: Button
var original_positions_button: CheckButton
var action_buttons: Array[Button] = []
var loading := false
var syncing_tree := false


func _ready() -> void:
	var content_error := ContentBundle.mount_if_needed()
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	if not parsed is Dictionary:
		push_error("Sample catalogue is missing or invalid.")
		get_tree().quit(1)
		return
	pack = parsed
	build_interface()
	if not content_error.is_empty():
		status.text = content_error
		context.text = "Anatomy unavailable"
		if "--verify-bundle" in OS.get_cmdline_user_args():
			push_error(content_error)
			get_tree().quit(1)
	elif "--verify-bundle" in OS.get_cmdline_user_args():
		call_deferred("verify_bundle")
	else:
		call_deferred("switch_body", "female")


func verify_bundle() -> void:
	for reference in pack.bodies:
		await switch_body(reference.id)
		if model.body.get("id") != reference.id or model.meshes.size() != (801 if reference.id == "female" else 788):
			push_error("Bundled reference failed: " + str(reference.id))
			get_tree().quit(1)
			return
		var baseline_bounds: AABB = model.bounds_for("anatomy.heart")
		model.select("anatomy.heart")
		model.checkpoint()
		model.offset_selection(Vector3(0.1, 0.02, 0))
		var saved: Dictionary = model.export_state()
		model.restore()
		if not model.bounds_for("anatomy.heart").is_equal_approx(baseline_bounds) or not model.apply_saved_state(saved).is_empty():
			push_error("Bundled inspection restoration failed")
			get_tree().quit(1)
			return
		print("PASS bundled reference: ", reference.id, " · ", model.meshes.size(), " meshes")
	print("PASS offline native bundle")
	get_tree().quit()


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
	body_choice.add_item("Female reference")
	body_choice.add_item("Male reference")
	body_choice.custom_minimum_size.x = 180
	body_choice.item_selected.connect(func(index: int): switch_body("female" if index == 0 else "male"))
	top.add_child(body_choice)
	make_button("Save view", save_view, top)
	make_button("Load view", load_view, top)
	make_button("Sources", show_sources, top)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 14)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(columns)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 255
	left.add_theme_constant_override("separation", 10)
	columns.add_child(left)
	left.add_child(make_label("EXPLORE ANATOMY", 13, Color("83cfc9")))
	search = LineEdit.new()
	search.placeholder_text = "Search structures…"
	search.clear_button_enabled = true
	search.custom_minimum_size.y = 40
	search.text_changed.connect(func(_text: String): rebuild_tree())
	left.add_child(search)
	tree = Tree.new()
	tree.hide_root = true
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.custom_minimum_size.x = 255
	tree.item_selected.connect(on_tree_selected)
	left.add_child(tree)
	make_button("Peel away skin", func(): model.set_visibility("anatomy.skin", "hidden"), left)
	make_button("Show chest", chest_view, left)
	var coverage := make_label("PARTIAL ATLAS\nSkeleton, muscles and nerves\ncover selected regions.", 13, Color("879db0"))
	left.add_child(coverage)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.custom_minimum_size.x = 380
	center.add_theme_constant_override("separation", 8)
	columns.add_child(center)
	context = make_label("Loading reference anatomy…", 15, Color("b5c7d8"))
	center.add_child(context)
	var frame := PanelContainer.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(frame)
	var container := SubViewportContainer.new()
	container.stretch = true
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
	orbit = OrbitCamera.new()
	world.add_child(orbit)
	orbit.clicked.connect(on_viewport_clicked)
	orbit.move_started.connect(func(): model.checkpoint())
	orbit.moved.connect(func(delta: Vector3): model.offset_selection(delta))
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(overlay)
	selection_label = make_label("", 15, Color("ffe0b6"))
	selection_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_label.add_theme_stylebox_override("normal", panel_style(Color("172433"), Color("c28c52")))
	selection_label.visible = false
	overlay.add_child(selection_label)
	center.add_child(make_label("Drag to orbit · Shift/right-drag to pan · Scroll/pinch to zoom", 13, Color("7891a7")))
	var right_panel := PanelContainer.new()
	right_panel.custom_minimum_size.x = 265
	columns.add_child(right_panel)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 12)
	right_panel.add_child(right)
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
	action_buttons.append(make_button("Show", func(): change_visibility("visible"), action_row))
	var visibility_row := HBoxContainer.new()
	right.add_child(visibility_row)
	action_buttons.append(make_button("Hide", func(): change_visibility("hidden"), visibility_row))
	action_buttons.append(make_button("Fade", func(): change_visibility("faded"), visibility_row, "Faded anatomy is click-through."))
	action_buttons.append(make_button("Restore selected", restore_selected, right))
	original_positions_button = CheckButton.new()
	original_positions_button.text = "Show original positions"
	original_positions_button.button_pressed = true
	original_positions_button.tooltip_text = "A faint blue copy marks the original position of moved anatomy. It cannot be selected."
	original_positions_button.toggled.connect(func(enabled: bool):
		model.show_original_positions = enabled
		model.refresh_appearance())
	right.add_child(original_positions_button)
	right.add_child(make_label("CONTENT IN DEVELOPMENT", 12, Color("8a9fb2")))
	var pending := make_label("Disease views, guided pathways and validated cutaways will be added progressively.", 14, Color("8a9fb2"))
	pending.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(pending)
	var source := make_label("Models: HuBMAP / Human Reference Atlas\n3D Reference Object Library v1.1\nCC BY 4.0 · draft catalogue", 12, Color("758ca2"))
	source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(source)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 12)
	layout.add_child(toolbar)
	make_button("Whole body", whole_body, toolbar)
	move_button = make_button("Move selected", toggle_move, toolbar, "In Move mode, drag in the viewer to displace selected anatomy. Shift-drag still pans.")
	move_button.toggle_mode = true
	labels_button = CheckButton.new()
	labels_button.text = "Selection label"
	labels_button.button_pressed = true
	toolbar.add_child(labels_button)
	undo_button = make_button("Undo", func(): model.undo(), toolbar)
	redo_button = make_button("Redo", func(): model.redo(), toolbar)
	make_button("Restore all", func(): model.restore(), toolbar)
	status = make_label("Preparing the local anatomy sample…", 13, Color("7891a7"))
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
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
	body_choice.disabled = true
	context.text = "Loading %s reference…" % id
	status.text = "Importing geometry and preparing selection…"
	var previous_selection: String = model.selected_id
	await get_tree().process_frame
	await get_tree().process_frame
	var error: String = model.load_body(record)
	loading = false
	body_choice.disabled = false
	if not error.is_empty():
		status.text = error
		context.text = "Reference unavailable"
		body_choice.select(0 if model.body.get("id", "female") == "female" else 1)
		return
	body_choice.select(0 if id == "female" else 1)
	move_button.button_pressed = false
	orbit.move_mode = false
	rebuild_tree()
	if model.structures.has(previous_selection) and previous_selection != "anatomy.body":
		select_structure(previous_selection)
	else:
		whole_body()
	context.text = "%s reference · continuous body view" % id.capitalize()
	status.text = "%s reference ready" % id.capitalize()
	refresh_details()


func rebuild_tree() -> void:
	if tree == null:
		return
	syncing_tree = true
	tree.clear()
	tree_items.clear()
	var root := tree.create_item()
	var query := search.text.strip_edges().to_lower()
	if query.is_empty() and model.structures.has("anatomy.body"):
		for id in model.structures["anatomy.body"].children:
			append_tree_branch(id, root, 0)
	elif not query.is_empty():
		var count := 0
		for id in model.structures:
			var record: Dictionary = model.structures[id]
			if query in str(record.label).to_lower() or query in str(record.source_name).to_lower():
				var item := tree.create_item(root)
				item.set_text(0, str(record.label))
				item.set_metadata(0, id)
				item.set_tooltip_text(0, str(record.label))
				tree_items[id] = item
				count += 1
				if count >= 100:
					break
		status.text = "%d search results%s" % [count, " (first 100)" if count == 100 else ""]
	syncing_tree = false


func append_tree_branch(id: String, parent: TreeItem, depth: int) -> void:
	var record: Dictionary = model.structures[id]
	var item := tree.create_item(parent)
	item.set_text(0, str(record.label))
	item.set_metadata(0, id)
	item.set_tooltip_text(0, str(record.label))
	item.collapsed = depth >= 1
	tree_items[id] = item
	for child in record.children:
		append_tree_branch(child, item, depth + 1)


func on_tree_selected() -> void:
	if not syncing_tree and tree.get_selected() != null:
		select_structure(str(tree.get_selected().get_metadata(0)))


func select_structure(id: String) -> void:
	if loading or not model.structures.has(id):
		return
	model.select(id)
	focus_selection()
	if tree_items.has(id):
		syncing_tree = true
		tree_items[id].select(0)
		var parent: TreeItem = tree_items[id].get_parent()
		while parent != null:
			parent.collapsed = false
			parent = parent.get_parent()
		tree.scroll_to_item(tree_items[id])
		syncing_tree = false


func on_viewport_clicked(position: Vector2) -> void:
	if loading:
		return
	var id: String = model.pick(orbit.camera, position)
	if not id.is_empty():
		select_structure(id)


func refresh_details() -> void:
	if heading == null:
		return
	var selected: bool = model.structures.has(model.selected_id)
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
		return
	var record: Dictionary = model.structures[model.selected_id]
	heading.text = str(record.label)
	var visibility_counts := {"visible": 0, "faded": 0, "hidden": 0}
	var displaced := false
	for index in record.mesh_nodes:
		visibility_counts[model.states[int(index)].visibility] += 1
		displaced = displaced or model.states[int(index)].offset != Vector3.ZERO
	detail.text = "%d source mesh%s\n%d visible · %d faded · %d hidden\n\n%s\n\nSource label: %s\n%s\nDraft import · review pending" % [
		record.mesh_nodes.size(), "es" if record.mesh_nodes.size() != 1 else "",
		visibility_counts.visible, visibility_counts.faded, visibility_counts.hidden,
		"Moved for inspection. Restore returns the original anatomy." if displaced else "In its original atlas position.",
		record.label, str(record.ontology)]


func focus_selection() -> void:
	if model.structures.has(model.selected_id):
		orbit.focus(model.bounds_for(model.selected_id))


func whole_body() -> void:
	if not model.structures.has("anatomy.body"):
		return
	model.select("")
	orbit.yaw = 0.0
	orbit.pitch = 0.0
	orbit.focus(model.bounds_for("anatomy.skin"))


func chest_view() -> void:
	if loading or not model.structures.has("anatomy.heart"):
		return
	model.set_visibility("anatomy.skin", "hidden")
	model.set_visibility("anatomy.lungs", "faded")
	select_structure("anatomy.heart")
	# Keep enough surrounding chest context after selection focus.
	orbit.distance *= 2.0
	orbit.update_camera()


func change_visibility(visibility: String) -> void:
	model.set_visibility(model.selected_id, visibility)


func restore_selected() -> void:
	model.restore(model.selected_id)


func toggle_move() -> void:
	orbit.move_mode = move_button.button_pressed
	status.text = "Drag to move the selected structure · Shift-drag to pan" if orbit.move_mode else "Drag to orbit · click to select"


func _process(_delta: float) -> void:
	if selection_label == null:
		return
	selection_label.visible = false
	if loading or not labels_button.button_pressed or not model.structures.has(model.selected_id):
		return
	var any_visible := false
	for index in model.structures[model.selected_id].mesh_nodes:
		any_visible = any_visible or model.states[int(index)].visibility != "hidden"
	if not any_visible:
		return
	var center: Vector3 = model.bounds_for(model.selected_id).get_center()
	if orbit.camera.is_position_behind(center):
		return
	var point: Vector2 = orbit.camera.unproject_position(center)
	if not Rect2(Vector2.ZERO, Vector2(viewport.size)).has_point(point):
		return
	selection_label.text = str(model.structures[model.selected_id].label)
	selection_label.reset_size()
	selection_label.position = Vector2(clampf(point.x + 18, 0, maxf(viewport.size.x - selection_label.size.x, 0)), clampf(point.y - 36, 0, maxf(viewport.size.y - selection_label.size.y, 0)))
	selection_label.visible = true


func save_view() -> void:
	if loading or model.body.is_empty():
		return
	var state := {"schema_version": 1, "pack_id": pack.id, "body": model.body.id,
		"selection": model.selected_id, "camera": orbit.export_state(),
		"labels": labels_button.button_pressed, "original_positions": original_positions_button.button_pressed,
		"changes": model.export_state()}
	var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		status.text = "Could not write the saved view."
		return
	file.store_string(JSON.stringify(state, "\t"))
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
	var state: Dictionary = parsed
	if state.get("schema_version") != 1 or state.get("pack_id") != pack.id:
		status.text = "Saved view uses a different content or save version."
		return
	if not state.get("camera") is Dictionary or not orbit.valid_state(state.camera) or not state.get("changes") is Dictionary:
		status.text = "Saved view has invalid camera or anatomy data."
		return
	if state.get("body") not in ["male", "female"] or not state.get("selection") is String or not state.get("labels") is bool:
		status.text = "Saved view has invalid body, selection or label settings."
		return
	if state.has("original_positions") and not state.original_positions is bool:
		status.text = "Saved view has an invalid original-position setting."
		return
	var reference: Dictionary = {}
	for candidate in pack.bodies:
		if candidate.id == state.body:
			reference = candidate
	var validation: String = model.validate_saved_changes(state.changes, reference)
	if not validation.is_empty():
		status.text = validation
		return
	var selection_exists: bool = state.selection.is_empty()
	for structure in reference.structures:
		selection_exists = selection_exists or structure.id == state.selection
	if not selection_exists:
		status.text = "Saved selection is missing from this sample pack."
		return
	if model.body.get("id") != state.body:
		await switch_body(state.body)
	if model.body.get("id") != state.body:
		return
	var error: String = model.apply_saved_state(state.changes)
	if not error.is_empty():
		status.text = error
		return
	model.select(state.selection)
	orbit.apply_state(state.camera)
	labels_button.button_pressed = state.labels
	original_positions_button.button_pressed = state.get("original_positions", true)
	model.show_original_positions = original_positions_button.button_pressed
	model.refresh_appearance()
	status.text = "Saved view restored"


func show_sources() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Sources and prototype status"
	dialog.dialog_text = "Anatomy: HuBMAP / Human Reference Atlas 3D Reference Object Library, United v1.1.\nCC BY 4.0. Source files unchanged; sampling sites excluded, cache conversion,\nselection colours, fading and temporary inspection movements applied.\n\nhttps://github.com/hubmapconsortium/ccf-3d-reference-object-library\nhttps://creativecommons.org/licenses/by/4.0/\n\nGodot Engine: MIT licence; https://godotengine.org/license/\n\nThis is a private, partial atlas prototype. Anatomy labels and coverage are draft\nimports; qualified medical review is pending. No disease content is included."
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(760, 390))


func _unhandled_key_input(event: InputEvent) -> void:
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
