extends Control

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const OrbitCamera = preload("res://scripts/orbit_camera.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
const AnatomyLabels = preload("res://scripts/anatomy_labels.gd")
const CoverageBrowser = preload("res://scripts/coverage_browser.gd")
var save_path := "user://saved_view.json"

var pack: Dictionary
var coverage_notes: Dictionary = {}
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
	var coverage_parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/coverage_notes.json"))
	if coverage_parsed is Dictionary and coverage_parsed.get("pack_id") == pack.id and coverage_parsed.get("source_commit") == pack.source_commit:
		coverage_notes = coverage_parsed
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
	if coverage_notes.is_empty():
		push_error("Bundled coverage notes are missing or mismatched")
		get_tree().quit(1)
		return
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
		select_structure("anatomy.heart")
		var previous := current_view()
		select_structure("anatomy.heart.ventricle.left")
		navigate_history(true)
		if current_view() != previous or model.export_state() != saved or anatomy_labels.local_ids().size() != 14:
			push_error("Bundled exploration navigation failed")
			get_tree().quit(1)
			return
		inspect_alone()
		select_structure("anatomy.heart.valve.mitral")
		var visible_count := 0
		for mesh in model.meshes.values():
			visible_count += int(mesh.visible)
		if model.isolated_id != "anatomy.heart.valve.mitral" or visible_count != 1 or model.export_state() != saved:
			push_error("Bundled part inspection failed")
			get_tree().quit(1)
			return
		return_to_context()
		if current_view() != previous or model.export_state() != saved:
			push_error("Bundled return to context failed")
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
	make_button("Coverage", show_coverage, top)
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
	peel_button = make_button("Peel away skin", peel_skin, left)
	make_button("Show chest", chest_view, left)
	var coverage := make_label("PARTIAL ATLAS\nSkeleton, muscles and nerves\ncover selected regions.", 13, Color("879db0"))
	left.add_child(coverage)
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
	anatomy_labels = AnatomyLabels.new()
	anatomy_labels.model = model
	anatomy_labels.camera = orbit.camera
	anatomy_labels.selected.connect(select_structure)
	# Match the SubViewport's content rectangle, including the panel's margins.
	container.add_child(anatomy_labels)
	anatomy_labels.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.add_child(make_label("Drag to orbit · Shift/right-drag to pan · Scroll/pinch to zoom", 13, Color("7891a7")))
	var right_panel := PanelContainer.new()
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
	labels_button.toggled.connect(func(enabled: bool): anatomy_labels.selection_enabled = enabled)
	toolbar.add_child(labels_button)
	undo_button = make_button("Undo", func(): model.undo(), toolbar)
	redo_button = make_button("Redo", func(): model.redo(), toolbar)
	make_button("Restore all", restore_all, toolbar)
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
	anatomy_labels.suspended = true
	anatomy_labels.update_labels()
	refresh_details()
	body_choice.disabled = true
	context.text = "Loading %s reference…" % id
	status.text = "Importing geometry and preparing selection…"
	var previous_selection: String = model.selected_id
	await get_tree().process_frame
	await get_tree().process_frame
	var error: String = model.load_body(record)
	loading = false
	anatomy_labels.suspended = false
	body_choice.disabled = false
	if not error.is_empty():
		status.text = error
		context.text = "Reference unavailable"
		body_choice.select(0 if model.body.get("id", "female") == "female" else 1)
		refresh_details()
		return
	anatomy_labels.clear_labels()
	parts_scope = ""
	parts_items.clear()
	parts_tree.clear()
	back_views.clear()
	forward_views.clear()
	inspection_return = {}
	body_choice.select(0 if id == "female" else 1)
	move_button.button_pressed = false
	orbit.move_mode = false
	rebuild_tree()
	if model.structures.has(previous_selection) and previous_selection != "anatomy.body":
		select_structure(previous_selection, false)
	else:
		whole_body(false)
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
	item.set_tooltip_text(0, str(record.label))
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
	if tree_items.has(model.selected_id):
		tree.scroll_to_item(tree_items[model.selected_id])
	if parts_items.has(model.selected_id):
		parts_tree.scroll_to_item(parts_items[model.selected_id])


func on_part_selected() -> void:
	if not syncing_parts and parts_tree.get_selected() != null:
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
		context.text = "%s · %s" % [str(model.body.id).capitalize(), region]
		if not model.isolated_id.is_empty():
			context.text += " · inspecting alone"


func on_viewport_clicked(position: Vector2) -> void:
	if loading:
		return
	var id: String = model.pick(orbit.camera, position)
	if not id.is_empty():
		select_structure(id)


func refresh_details() -> void:
	if heading == null:
		return
	refresh_navigation()
	refresh_parts()
	var selected: bool = model.structures.has(model.selected_id)
	var isolated: bool = not model.isolated_id.is_empty()
	if peel_button:
		peel_button.disabled = loading or isolated
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
	if isolated:
		detail.text = "INSPECTING ALONE\nSupplied geometry temporarily revealed.\n\nContext settings:\n" + detail.text


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
	orbit.focus(model.bounds_for("anatomy.skin"))
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
	model.restore(model.selected_id)


func restore_all() -> void:
	if loading:
		return
	var previous := current_view()
	end_isolation()
	model.restore()
	remember_view(previous)


func toggle_move() -> void:
	orbit.move_mode = move_button.button_pressed
	status.text = "Drag to move the selected structure · Shift-drag to pan" if orbit.move_mode else "Drag to orbit · click to select"


func _process(_delta: float) -> void:
	if status:
		status.tooltip_text = status.text


func save_view() -> void:
	if loading or model.body.is_empty():
		return
	var state := {"schema_version": 1, "pack_id": pack.id, "body": model.body.id,
		"selection": model.selected_id, "camera": orbit.export_state(),
		"labels": labels_button.button_pressed, "original_positions": original_positions_button.button_pressed,
		"local_labels": local_labels_button.button_pressed, "label_density": int(label_density.value),
		"label_context": anatomy_labels.context_id,
		"isolation": model.isolated_id, "inspection_return": inspection_return.duplicate(true),
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
	if (state.has("local_labels") and not state.local_labels is bool) or (state.has("label_density") and
		(not (state.label_density is float or state.label_density is int) or not is_finite(float(state.label_density)) or
		float(state.label_density) != floorf(float(state.label_density)) or state.label_density < 1 or state.label_density > 12)):
		status.text = "Saved view has invalid local-label settings."
		return
	if state.has("label_context") and not state.label_context is String:
		status.text = "Saved view has an invalid label context."
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
	if not valid_label_context(state.selection, state.get("label_context", ""), reference):
		status.text = "Saved label context does not match the selected anatomy."
		return
	if not valid_inspection_view(state, reference):
		status.text = "Saved inspection view has invalid anatomy or return context."
		return
	if model.body.get("id") != state.body:
		await switch_body(state.body)
	if model.body.get("id") != state.body:
		return
	var previous := current_view()
	var error: String = model.apply_saved_state(state.changes)
	if not error.is_empty():
		status.text = error
		return
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
	browser.body_id = str(model.body.id)
	browser.theme = theme
	browser.explore_requested.connect(select_structure)
	add_child(browser)
	browser.popup_centered_clamped(Vector2i(940, 620), 0.9)
	return browser


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
		elif event.alt_pressed and event.keycode in [KEY_LEFT, KEY_RIGHT]:
			navigate_history(event.keycode == KEY_LEFT)
			get_viewport().set_input_as_handled()
