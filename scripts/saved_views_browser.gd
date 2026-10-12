extends Window

signal restore_requested(state: Dictionary, view_name: String)
signal legacy_requested

var library: RefCounted
var pack: Dictionary
var current_state: Dictionary
var validate_state: Callable
var legacy_available := false
var view_list: ItemList
var name_input: LineEdit
var information: Label
var message: Label
var save_button: Button
var restore_button: Button
var rename_button: Button
var delete_button: Button
var recovery_button: Button
var delete_pending := ""


func button(text: String, callback: Callable, parent: Node) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 38
	result.pressed.connect(callback)
	parent.add_child(result)
	return result


func _ready() -> void:
	title = "Saved views"
	visible = false
	transient = true
	exclusive = true
	min_size = Vector2i(720, 500)
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
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)
	var title_label := Label.new()
	title_label.text = "SAVED VIEWS"
	title_label.add_theme_font_size_override("font_size", 22)
	layout.add_child(title_label)
	var hint := Label.new()
	hint.text = "Keep your camera, labels and inspection setup. Stored on this computer."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(hint)
	var new_view := HBoxContainer.new()
	layout.add_child(new_view)
	name_input = LineEdit.new()
	name_input.placeholder_text = "Name this view…"
	name_input.max_length = 80
	name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_input.text_changed.connect(func(_text: String): cancel_delete())
	name_input.text_submitted.connect(func(_text: String): save_current())
	new_view.add_child(name_input)
	save_button = button("Save current view", save_current, new_view)
	view_list = ItemList.new()
	view_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view_list.custom_minimum_size.y = 160
	view_list.item_selected.connect(select_entry)
	view_list.item_activated.connect(func(_index: int): restore_selected())
	layout.add_child(view_list)
	information = Label.new()
	information.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	information.custom_minimum_size.y = 50
	layout.add_child(information)
	message = Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.add_theme_color_override("font_color", Color("83cfc9"))
	layout.add_child(message)
	var actions := HBoxContainer.new()
	layout.add_child(actions)
	restore_button = button("Restore", restore_selected, actions)
	rename_button = button("Rename", rename_selected, actions)
	delete_button = button("Delete", delete_selected, actions)
	recovery_button = button("Recover previous library", recover_library, actions)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	button("Close", queue_free, actions)
	if legacy_available:
		button("Restore previous quick save", func(): legacy_requested.emit(); queue_free(), layout)
	library.load_library()
	refresh_list()
	message.text = library.read_error
	name_input.grab_focus()


func selected_entry() -> Dictionary:
	var selected := view_list.get_selected_items()
	if selected.is_empty():
		return {}
	var id: String = view_list.get_item_metadata(selected[0])
	for entry in library.entries:
		if entry.id == id:
			return entry
	return {}


func refresh_list(selected_id: String = "") -> void:
	view_list.clear()
	for entry in library.entries:
		view_list.add_item(entry.name)
		var index := view_list.item_count - 1
		view_list.set_item_metadata(index, entry.id)
		view_list.set_item_tooltip(index, entry.name)
		if entry.id == selected_id:
			view_list.select(index)
	save_button.disabled = not library.read_error.is_empty()
	recovery_button.visible = not library.read_error.is_empty() and library.can_recover()
	select_entry(-1)
	if library.entries.is_empty() and library.read_error.is_empty():
		information.text = "No named views yet. Enter a name to save the current setup."


func cancel_delete() -> void:
	delete_pending = ""
	if delete_button:
		delete_button.text = "Delete"


func select_entry(_index: int) -> void:
	cancel_delete()
	var entry := selected_entry()
	var unavailable: bool = entry.is_empty() or not library.read_error.is_empty()
	restore_button.disabled = unavailable
	rename_button.disabled = unavailable
	delete_button.disabled = unavailable
	information.text = ""
	if entry.is_empty():
		return
	var body_label := str(entry.state.get("body", "Unavailable reference"))
	var part_label := str(entry.state.get("selection", ""))
	for body in pack.bodies:
		if body.id == entry.state.get("body"):
			body_label = str(body.get("short_label", body.label))
			for structure in body.structures:
				if structure.id == entry.state.get("selection"):
					part_label = str(structure.label)
	information.text = body_label + (" · " + part_label if not part_label.is_empty() else "")
	var error: String = validate_state.call(entry.state)
	if not error.is_empty():
		information.text += "\n" + error
		restore_button.disabled = true
	name_input.text = entry.name


func save_current() -> void:
	var error: String = validate_state.call(current_state)
	if error.is_empty():
		error = library.add_view(name_input.text.strip_edges(), current_state)
	message.text = error if not error.is_empty() else "View saved on this computer."
	if error.is_empty():
		refresh_list(library.entries[0].id)


func restore_selected() -> void:
	var entry := selected_entry()
	if entry.is_empty() or restore_button.disabled:
		return
	restore_requested.emit(entry.state.duplicate(true), entry.name)
	queue_free()


func rename_selected() -> void:
	var entry := selected_entry()
	if entry.is_empty() or rename_button.disabled:
		return
	var error: String = library.rename_view(entry.id, name_input.text.strip_edges())
	message.text = error if not error.is_empty() else "View renamed."
	if error.is_empty():
		refresh_list(entry.id)


func delete_selected() -> void:
	var entry := selected_entry()
	if entry.is_empty() or delete_button.disabled:
		return
	if delete_pending != entry.id:
		delete_pending = entry.id
		delete_button.text = "Confirm delete"
		message.text = "Delete “" + str(entry.name) + "”? Click Confirm delete, or select another view to cancel."
		return
	var error: String = library.delete_view(entry.id)
	message.text = error if not error.is_empty() else "View deleted."
	if error.is_empty():
		refresh_list()


func recover_library() -> void:
	var error: String = library.recover_backup()
	message.text = error if not error.is_empty() else "Previous library restored. Any damaged file has been retained."
	refresh_list()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		queue_free()
		set_input_as_handled()
