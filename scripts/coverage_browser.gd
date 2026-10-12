extends Window
## Technical coverage notes are bound to the pinned catalogue, separate from review.

signal explore_requested(id: String)

var pack: Dictionary
var notes: Dictionary
var body_id := "female"
var system_list: ItemList
var information: RichTextLabel
var explore_button: Button
var current_system: Dictionary = {}


func _ready() -> void:
	title = "Atlas coverage and gaps"
	visible = false
	transient = true
	exclusive = true
	min_size = Vector2i(760, 520)
	close_requested.connect(queue_free)
	var background := ColorRect.new()
	background.color = Color("0e1926")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var title_label := Label.new()
	title_label.text = "ATLAS COVERAGE · " + reference_label(body_id)
	title_label.add_theme_font_size_override("font_size", 22)
	layout.add_child(title_label)
	var notice := Label.new()
	notice.text = str(notes.notice)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_font_size_override("font_size", 14)
	notice.add_theme_color_override("font_color", Color("9fb4c7"))
	layout.add_child(notice)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(columns)
	system_list = ItemList.new()
	system_list.custom_minimum_size.x = 230
	system_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	system_list.item_selected.connect(show_system)
	columns.add_child(system_list)
	for system in notes.systems:
		system_list.add_item(str(system.label))
	information = RichTextLabel.new()
	information.bbcode_enabled = true
	information.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	information.size_flags_vertical = Control.SIZE_EXPAND_FILL
	information.add_theme_color_override("default_color", Color("c8d6e3"))
	columns.add_child(information)
	var actions := HBoxContainer.new()
	layout.add_child(actions)
	explore_button = Button.new()
	explore_button.text = "Explore supplied group"
	explore_button.custom_minimum_size.y = 38
	explore_button.pressed.connect(explore_current)
	actions.add_child(explore_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size = Vector2(100, 38)
	close.pressed.connect(queue_free)
	actions.add_child(close)
	system_list.select(0)
	show_system(0)


func structure_for(reference_id: String, id: String) -> Dictionary:
	for body in pack.bodies:
		if body.id == reference_id:
			for structure in body.structures:
				if structure.id == id:
					return structure
	return {}


func reference_label(id: String) -> String:
	for body in pack.bodies:
		if body.id == id:
			return str(body.get("short_label", body.label))
	return id.capitalize()


func show_system(index: int) -> void:
	if index < 0 or index >= notes.systems.size():
		return
	current_system = notes.systems[index]
	var sections: Array[String] = ["[b]" + str(current_system.label) + "[/b]", str(notes.get("source_label", "HRA United v1.1")) + " · technical inventory · anatomy review pending",
		"[b]Gaps and limits[/b]", str(current_system.gaps)]
	var references: Array = notes.get("reference_ids", ["female", "male"]).duplicate()
	references.erase(body_id)
	references.push_front(body_id)
	for reference_id in references:
		var structure := structure_for(reference_id, str(current_system.roots[reference_id]))
		sections.append("[b]" + reference_label(reference_id) + "[/b]")
		sections.append(str(current_system.supplied[reference_id]))
		if not structure.is_empty():
			sections.append("%d source meshes · %d immediate source groups/parts" % [structure.mesh_nodes.size(), structure.children.size()])
	sections.append("[b]Scope of this record[/b]")
	sections.append(str(notes.get("source_label", "Pinned HRA United v1.1 samples")) + " · inventory " + str(notes.audit_date) + ".\nMesh counts do not establish anatomical completeness. No percentage-complete score is assigned.")
	information.text = "\n\n".join(sections)
	explore_button.disabled = structure_for(body_id, str(current_system.roots[body_id])).is_empty()
	information.scroll_to_line(0)


func explore_current() -> void:
	var id := str(current_system.roots[body_id])
	if structure_for(body_id, id).is_empty():
		return
	explore_requested.emit(id)
	queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		queue_free()
		set_input_as_handled()
