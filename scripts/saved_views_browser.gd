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
var notes_input: TextEdit
var notes_button: Button
var notes_status: Label
var draft_notes: Dictionary = {}
var editing_id := ""
var syncing_notes := false
var pending_action: Callable
var unsaved_dialog: ConfirmationDialog


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
	close_requested.connect(request_close)
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
	hint.text = "Keep your camera, labels and inspection setup. Add your study notes. Stored on this computer."
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
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(content)
	var saved_column := VBoxContainer.new()
	saved_column.custom_minimum_size.x = 240
	saved_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(saved_column)
	view_list = ItemList.new()
	view_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view_list.custom_minimum_size.y = 160
	view_list.item_selected.connect(select_entry)
	view_list.item_activated.connect(func(_index: int): restore_selected())
	saved_column.add_child(view_list)
	information = Label.new()
	information.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	information.custom_minimum_size.y = 50
	saved_column.add_child(information)
	var notes_column := VBoxContainer.new()
	notes_column.custom_minimum_size.x = 320
	notes_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(notes_column)
	var notes_header := HBoxContainer.new()
	notes_column.add_child(notes_header)
	var notes_title := Label.new()
	notes_title.text = "YOUR STUDY NOTES"
	notes_title.add_theme_font_size_override("font_size", 13)
	notes_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notes_header.add_child(notes_title)
	notes_button = button("Save notes", save_notes, notes_header)
	notes_input = TextEdit.new()
	notes_input.placeholder_text = "Select a saved view to add observations or questions."
	notes_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	notes_input.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notes_input.custom_minimum_size.y = 160
	notes_input.text_changed.connect(on_notes_changed)
	notes_column.add_child(notes_input)
	notes_status = Label.new()
	notes_status.add_theme_font_size_override("font_size", 13)
	notes_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notes_column.add_child(notes_status)
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
	button("Close", request_close, actions)
	if legacy_available:
		button("Restore previous quick save", restore_legacy, layout)
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
	remember_notes_draft()
	var entry := selected_entry()
	var unavailable: bool = entry.is_empty() or not library.read_error.is_empty()
	restore_button.disabled = unavailable
	rename_button.disabled = unavailable
	delete_button.disabled = unavailable
	information.text = ""
	editing_id = str(entry.get("id", ""))
	syncing_notes = true
	notes_input.text = str(draft_notes.get(editing_id, entry.get("notes", ""))) if not entry.is_empty() else ""
	syncing_notes = false
	notes_input.editable = not unavailable
	refresh_notes_status()
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
	var state: Dictionary = entry.state.duplicate(true)
	var view_name: String = entry.name
	request_action(func(): restore_requested.emit(state, view_name); queue_free())


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
		draft_notes.erase(entry.id)
		editing_id = ""
		refresh_list()


func recover_library() -> void:
	var error: String = library.recover_backup()
	message.text = error if not error.is_empty() else "Previous library restored. Any damaged file has been retained."
	refresh_list()


func remember_notes_draft() -> void:
	if syncing_notes or editing_id.is_empty():
		return
	for entry in library.entries:
		if entry.id == editing_id:
			if notes_input.text == str(entry.get("notes", "")):
				draft_notes.erase(editing_id)
			else:
				draft_notes[editing_id] = notes_input.text
			return


func on_notes_changed() -> void:
	if syncing_notes:
		return
	remember_notes_draft()
	refresh_notes_status()


func refresh_notes_status() -> void:
	var error: String = library.notes_format(notes_input.text)
	notes_button.disabled = editing_id.is_empty() or not draft_notes.has(editing_id) or not library.read_error.is_empty() or not error.is_empty()
	if editing_id.is_empty():
		notes_status.text = "Notes are attached to a saved view."
	else:
		notes_status.text = "%s · %d / 10,000 characters" % ["Unsaved" if draft_notes.has(editing_id) else "Saved", notes_input.text.length()]
		if not error.is_empty():
			notes_status.text += "\n" + error


func save_notes() -> void:
	remember_notes_draft()
	if editing_id.is_empty() or not draft_notes.has(editing_id):
		return
	var error: String = library.set_notes(editing_id, draft_notes[editing_id])
	message.text = error if not error.is_empty() else "Study notes saved on this computer."
	if error.is_empty():
		draft_notes.erase(editing_id)
	refresh_notes_status()


func request_close() -> void:
	request_action(queue_free)


func restore_legacy() -> void:
	request_action(func(): legacy_requested.emit(); queue_free())


func request_action(action: Callable) -> void:
	remember_notes_draft()
	if draft_notes.is_empty():
		action.call()
		return
	if is_instance_valid(unsaved_dialog) and unsaved_dialog.visible:
		return
	pending_action = action
	if not is_instance_valid(unsaved_dialog):
		unsaved_dialog = ConfirmationDialog.new()
		unsaved_dialog.title = "Unsaved study notes"
		unsaved_dialog.dialog_autowrap = true
		unsaved_dialog.dialog_hide_on_ok = false
		unsaved_dialog.ok_button_text = "Save notes"
		unsaved_dialog.cancel_button_text = "Keep editing"
		unsaved_dialog.add_button("Discard notes", false, "discard")
		unsaved_dialog.confirmed.connect(finish_pending_action.bind(true))
		unsaved_dialog.custom_action.connect(func(choice: StringName):
			if choice == "discard":
				finish_pending_action(false))
		unsaved_dialog.canceled.connect(func(): pending_action = Callable())
		add_child(unsaved_dialog)
	unsaved_dialog.dialog_text = "You have unsaved study notes for %d view%s. Save them before continuing?" % [draft_notes.size(), "s" if draft_notes.size() != 1 else ""]
	unsaved_dialog.popup_centered_clamped(Vector2i(510, 170), 0.9)


func finish_pending_action(save: bool) -> void:
	if not pending_action.is_valid():
		return
	if save:
		var error: String = library.update_notes(draft_notes)
		if not error.is_empty():
			message.text = error
			unsaved_dialog.dialog_text = error + "\nYour draft notes are still open."
			return
	draft_notes.clear()
	var action := pending_action
	pending_action = Callable()
	unsaved_dialog.hide()
	refresh_notes_status()
	action.call()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		request_close()
		set_input_as_handled()
