extends Window

const AnatomySearch = preload("res://scripts/anatomy_search.gd")

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
var delete_prompt := ""
var notes_input: TextEdit
var notes_button: Button
var save_all_notes_button: Button
var notes_status: Label
var draft_notes: Dictionary = {}
var editing_id := ""
var syncing_notes := false
var pending_action: Callable
var unsaved_dialog: ConfirmationDialog
var import_plan: Dictionary = {}
var import_dialog: ConfirmationDialog
var import_button: Button
var export_button: Button
var filter_input: LineEdit
var filter_summary: Label
var content_scroll: ScrollContainer
var close_button: Button
var undo_delete_button: Button
var last_deleted: Dictionary = {}
var reference_only: CheckBox
var references: Dictionary = {}


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
	var frame := VBoxContainer.new()
	frame.add_theme_constant_override("separation", 12)
	margin.add_child(frame)
	var heading := HBoxContainer.new()
	frame.add_child(heading)
	var title_label := Label.new()
	title_label.text = "SAVED VIEWS"
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title_label)
	filter_summary = Label.new()
	filter_summary.add_theme_color_override("font_color", Color("a1b7c9"))
	filter_summary.tooltip_text = "Matching views after search and reference filtering, out of the whole library."
	heading.add_child(filter_summary)
	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.follow_focus = true
	frame.add_child(content_scroll)
	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 12)
	content_scroll.add_child(layout)
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
	var transfer := HBoxContainer.new()
	layout.add_child(transfer)
	import_button = button("Import views…", func(): request_action(open_import), transfer)
	export_button = button("Export all views…", func(): request_action(open_export), transfer)
	save_all_notes_button = button("Save all notes", save_all_notes, transfer)
	save_all_notes_button.tooltip_text = "Save every unfinished note in this library and keep the window open. Ctrl / Cmd + S."
	var filter_row := HBoxContainer.new()
	layout.add_child(filter_row)
	filter_input = LineEdit.new()
	filter_input.placeholder_text = "Names, notes or anatomy…"
	filter_input.tooltip_text = "Search view names, notes, references and selected anatomy names or source IDs. All words must match. Ctrl / Cmd + F."
	filter_input.clear_button_enabled = true
	filter_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filter_input.text_changed.connect(apply_filter)
	filter_input.text_submitted.connect(func(_text: String): focus_first_match())
	filter_row.add_child(filter_input)
	reference_only = CheckBox.new()
	reference_only.text = "This reference"
	reference_only.disabled = str(current_state.get("body", "")).is_empty()
	reference_only.toggled.connect(func(_enabled: bool): apply_filter(""))
	filter_row.add_child(reference_only)
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
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var feedback := HBoxContainer.new()
	frame.add_child(feedback)
	feedback.add_child(message)
	undo_delete_button = button("Undo delete", undo_delete, feedback)
	undo_delete_button.tooltip_text = "Restore the most recently deleted view and its notes. Available while this Saved views window stays open."
	undo_delete_button.visible = false
	var actions := HBoxContainer.new()
	frame.add_child(actions)
	restore_button = button("Restore", restore_selected, actions)
	rename_button = button("Rename", rename_selected, actions)
	delete_button = button("Delete", delete_selected, actions)
	recovery_button = button("Recover previous library", recover_library, actions)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	close_button = button("Close", request_close, actions)
	if legacy_available:
		button("Restore previous quick save", restore_legacy, layout)
	build_reference_index()
	reference_only.tooltip_text = "Only show views for " + str(view_context(current_state).reference) + ". Restore still checks compatibility."
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


static func search_text(value: String) -> String:
	return value.to_lower().replace("\t", " ").replace("\n", " ").replace("\r", " ")


func build_reference_index() -> void:
	references.clear()
	for body in pack.get("bodies", []):
		var structures := {}
		for structure in body.get("structures", []):
			structures[str(structure.id)] = structure
		references[str(body.id)] = {"body": body, "structures": structures}


func view_context(state: Dictionary) -> Dictionary:
	var body_id := str(state.get("body", ""))
	var selection := str(state.get("selection", ""))
	var reference := body_id if not body_id.is_empty() else "Unavailable reference"
	var part := selection
	var searchable := body_id + " " + selection + " " + AnatomySearch.identifier(selection)
	var indexed: Dictionary = references.get(body_id, {})
	if not indexed.is_empty():
		var body: Dictionary = indexed.body
		# Resolve current labels only for the recorded pack and source geometry.
		var same_source: bool = state.get("pack_id", "") == pack.get("id", "")
		same_source = same_source and state.get("reference_hash", body.get("sha256", "")) == body.get("sha256", "")
		same_source = same_source and (state.has("reference_hash") or not body.get("study", false))
		if same_source:
			reference = str(body.get("short_label", body.get("label", body_id)))
			searchable += " " + str(body.get("label", "")) + " " + reference
			var structure: Dictionary = indexed.structures.get(selection, {})
			if not structure.is_empty():
				part = str(structure.label)
				var ontology := str(structure.get("ontology", ""))
				searchable += " " + part + " " + str(structure.get("source_name", "")) + " " + ontology + " " + AnatomySearch.identifier(ontology)
	return {"reference": reference, "summary": reference + (" · " + part if not part.is_empty() else ""), "search": searchable}


func matches_reference(entry: Dictionary) -> bool:
	return not reference_only.button_pressed or entry.state.get("body", "") == current_state.get("body", "")


func matches_filter(entry: Dictionary) -> bool:
	if not matches_reference(entry):
		return false
	var text := search_text(str(entry.name) + " " + str(entry.get("notes", "")) + " " + str(draft_notes.get(entry.id, "")) + " " + str(view_context(entry.state).search))
	for word in search_text(filter_input.text).split(" ", false):
		if word not in text:
			return false
	return true


func apply_filter(_text: String) -> void:
	refresh_list(str(selected_entry().get("id", "")))


func focus_first_match() -> void:
	if view_list.item_count == 0:
		return
	if view_list.get_selected_items().is_empty():
		view_list.select(0)
		select_entry(0)
	view_list.grab_focus()


func refresh_list(selected_id: String = "", reveal: bool = false) -> void:
	remember_notes_draft()
	if reveal:
		for entry in library.entries:
			if entry.id == selected_id:
				if not matches_reference(entry):
					reference_only.set_pressed_no_signal(false)
				if not matches_filter(entry):
					filter_input.text = ""
	view_list.clear()
	for entry in library.entries:
		if not matches_filter(entry):
			continue
		view_list.add_item(entry.name)
		var index := view_list.item_count - 1
		view_list.set_item_metadata(index, entry.id)
		view_list.set_item_tooltip(index, str(entry.name) + "\n" + str(view_context(entry.state).summary))
		if entry.id == selected_id:
			view_list.select(index)
	filter_summary.text = "%d of %d view%s" % [view_list.item_count, library.entries.size(), "" if library.entries.size() == 1 else "s"]
	save_button.disabled = not library.read_error.is_empty()
	import_button.disabled = not library.read_error.is_empty()
	export_button.disabled = not library.read_error.is_empty() or library.entries.is_empty()
	recovery_button.visible = not library.read_error.is_empty() and library.can_recover()
	undo_delete_button.visible = not last_deleted.is_empty()
	undo_delete_button.disabled = not library.read_error.is_empty()
	select_entry(-1)
	if library.entries.is_empty() and library.read_error.is_empty():
		information.text = "No named views yet. Enter a name to save the current setup."
	elif view_list.item_count == 0:
		information.text = "No matching views. Try another search or turn off This reference."


func cancel_delete() -> void:
	if not delete_prompt.is_empty() and message and message.text == delete_prompt:
		message.text = ""
	delete_prompt = ""
	delete_pending = ""
	if delete_button:
		delete_button.text = "Delete"


func select_entry(index: int) -> void:
	cancel_delete()
	remember_notes_draft()
	var entry := selected_entry()
	var previous_id := editing_id
	var unavailable: bool = entry.is_empty() or not library.read_error.is_empty()
	restore_button.disabled = unavailable
	rename_button.disabled = unavailable
	delete_button.disabled = unavailable
	information.text = ""
	editing_id = str(entry.get("id", ""))
	syncing_notes = true
	var note := str(draft_notes.get(editing_id, entry.get("notes", ""))) if not entry.is_empty() else ""
	if notes_input.text != note:
		notes_input.text = note
	syncing_notes = false
	notes_input.editable = not unavailable
	refresh_notes_status()
	if entry.is_empty():
		return
	information.text = str(view_context(entry.state).summary)
	var error: String = validate_state.call(entry.state)
	if not error.is_empty():
		information.text += "\n" + error
		restore_button.disabled = true
	# A notes refresh keeps any name the user is still typing.
	if index >= 0 or previous_id != editing_id:
		name_input.text = entry.name


func save_current() -> void:
	var error: String = validate_state.call(current_state)
	if error.is_empty():
		error = library.add_view(name_input.text.strip_edges(), current_state)
	message.text = error if not error.is_empty() else "View saved on this computer."
	if error.is_empty():
		refresh_list(library.entries[0].id, true)


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
		refresh_list(entry.id, true)


func delete_selected() -> void:
	var entry := selected_entry()
	if entry.is_empty() or delete_button.disabled:
		return
	if delete_pending != entry.id:
		delete_pending = entry.id
		delete_button.text = "Confirm delete"
		delete_prompt = "Delete “" + str(entry.name) + "”? Click Confirm delete, or select another view to cancel."
		message.text = delete_prompt
		return
	remember_notes_draft()
	var deleted := {"entry": entry.duplicate(true), "position": library.entries.find(entry),
		"has_draft": draft_notes.has(entry.id), "draft": draft_notes.get(entry.id, "")}
	var error: String = library.delete_view(entry.id)
	message.text = error if not error.is_empty() else "View deleted. Undo is available until this window closes."
	if error.is_empty():
		last_deleted = deleted
		draft_notes.erase(entry.id)
		editing_id = ""
		refresh_list()
		undo_delete_button.grab_focus()


func undo_delete() -> void:
	if last_deleted.is_empty():
		return
	var entry: Dictionary = last_deleted.entry
	var error: String = library.restore_deleted(entry, last_deleted.position)
	message.text = error
	if not error.is_empty():
		return
	var has_draft: bool = last_deleted.has_draft
	if has_draft:
		draft_notes[entry.id] = last_deleted.draft
	last_deleted.clear()
	refresh_list(entry.id, true)
	message.text = "Deleted view restored." + (" Your unfinished notes are back; use Save notes to keep them." if has_draft else "")
	view_list.grab_focus()
	view_list.ensure_current_is_visible()


func recover_library() -> void:
	var error: String = library.recover_backup()
	message.text = error if not error.is_empty() else "Previous library restored."
	if error.is_empty() and not library.recovery_copy_path.is_empty():
		message.text += " Damaged file retained as “" + str(library.recovery_copy_path).get_file() + "”."
	refresh_list()


func transfer_picker(save: bool) -> FileDialog:
	var picker := FileDialog.new()
	picker.title = "Export saved views and notes" if save else "Import saved views and notes"
	picker.file_mode = FileDialog.FILE_MODE_SAVE_FILE if save else FileDialog.FILE_MODE_OPEN_FILE
	picker.access = FileDialog.ACCESS_FILESYSTEM
	picker.use_native_dialog = true
	picker.filters = PackedStringArray(["*.json ; Saved views"])
	if save:
		picker.current_file = "praxis-corporis-views.json"
	picker.canceled.connect(picker.queue_free)
	add_child(picker)
	return picker


func open_export() -> void:
	var picker := transfer_picker(true)
	picker.file_selected.connect(func(destination: String):
		var error: String = library.export_library(destination)
		message.text = error if not error.is_empty() else "Exported %d views with saved study notes." % library.entries.size()
		picker.queue_free())
	picker.popup_file_dialog()


func open_import() -> void:
	var picker := transfer_picker(false)
	picker.file_selected.connect(func(source: String): preview_import(source); picker.queue_free())
	picker.popup_file_dialog()


func preview_import(source: String) -> void:
	import_plan = library.preview_import(source, validate_state)
	if not str(import_plan.error).is_empty():
		message.text = import_plan.error
		return
	if is_instance_valid(import_dialog):
		import_dialog.queue_free()
	import_dialog = ConfirmationDialog.new()
	import_dialog.title = "Import preview"
	import_dialog.ok_button_text = "Import %d views" % import_plan.imported
	import_dialog.get_ok_button().disabled = import_plan.imported == 0
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(540, 240)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var preview := Label.new()
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.text = "%d compatible views to add · %d skipped\nYour current views stay in the library.\n\n%s" % [import_plan.imported, import_plan.skipped, import_plan.summary]
	scroll.add_child(preview)
	import_dialog.add_child(scroll)
	import_dialog.confirmed.connect(confirm_import)
	add_child(import_dialog)
	import_dialog.popup_centered_clamped(Vector2i(600, 360), 0.9)


func confirm_import() -> void:
	var error: String = library.apply_import(import_plan, validate_state)
	message.text = error if not error.is_empty() else "Imported %d views and their saved notes." % import_plan.imported
	if error.is_empty():
		refresh_list()
	import_plan.clear()


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
	save_all_notes_button.disabled = draft_notes.is_empty() or not library.read_error.is_empty()
	if editing_id.is_empty():
		notes_status.text = "Notes are attached to a saved view."
		if not draft_notes.is_empty():
			notes_status.text += "\n%d unsaved note draft%s kept. Select their views to continue." % [draft_notes.size(), "s" if draft_notes.size() != 1 else ""]
	else:
		notes_status.text = "%s · %d / 10,000 characters" % ["Unsaved" if draft_notes.has(editing_id) else "Saved", notes_input.text.length()]
		if not error.is_empty():
			notes_status.text += "\n" + error
		var others := draft_notes.size() - (1 if draft_notes.has(editing_id) else 0)
		if others > 0:
			notes_status.text += "\n%d other view%s with unsaved notes." % [others, "s" if others != 1 else ""]


func save_notes() -> void:
	remember_notes_draft()
	if editing_id.is_empty() or not draft_notes.has(editing_id):
		return
	var error: String = library.set_notes(editing_id, draft_notes[editing_id])
	message.text = error if not error.is_empty() else "Study notes saved on this computer."
	if error.is_empty():
		draft_notes.erase(editing_id)
		refresh_list(editing_id)
	else:
		refresh_notes_status()


func save_all_notes() -> void:
	remember_notes_draft()
	if draft_notes.is_empty():
		return
	var count := draft_notes.size()
	var error: String = library.update_notes(draft_notes)
	message.text = error if not error.is_empty() else "Study notes saved for %d view%s." % [count, "s" if count != 1 else ""]
	if error.is_empty():
		draft_notes.clear()
		refresh_list(editing_id)
	else:
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
	syncing_notes = true
	var note := str(selected_entry().get("notes", ""))
	if notes_input.text != note:
		notes_input.text = note
	syncing_notes = false
	var action := pending_action
	pending_action = Callable()
	unsaved_dialog.hide()
	refresh_list(editing_id)
	action.call()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F and (event.ctrl_pressed or event.meta_pressed) and not event.alt_pressed:
		filter_input.grab_focus()
		filter_input.select_all()
		set_input_as_handled()
	elif event.keycode == KEY_S and (event.ctrl_pressed or event.meta_pressed) and not event.alt_pressed and not event.shift_pressed:
		save_all_notes()
		set_input_as_handled()
	elif event.keycode == KEY_ESCAPE:
		if filter_input.has_focus() and not filter_input.text.is_empty():
			filter_input.text = ""
			apply_filter("")
		else:
			request_close()
		set_input_as_handled()
