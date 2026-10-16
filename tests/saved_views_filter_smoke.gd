extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const Browser = preload("res://scripts/saved_views_browser.gd")
var failures := 0
var directory := "user://view-filter-" + Crypto.new().generate_random_bytes(8).hex_encode()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func filter(browser, text: String) -> void:
	browser.filter_input.text = text
	browser.filter_input.text_changed.emit(text)


func choose(browser, id: String) -> void:
	for index in browser.view_list.item_count:
		if browser.view_list.get_item_metadata(index) == id:
			browser.view_list.select(index)
			browser.select_entry(index)
			return
	check(false, "Expected saved view is visible: " + id)


func key(browser, code: Key, control: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.ctrl_pressed = control
	browser.push_input(event)


func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var library := SavedViews.new()
	library.path = directory + "/views.json"
	library.load_library()
	var state := {"body": "reference", "selection": "part"}
	library.add_view("Heart overview", state)
	var heart: String = library.entries[0].id
	library.set_notes(heart, "Deep source view\nNaïve λ 🫀")
	library.add_view("Bone study", state)
	var bone: String = library.entries[0].id
	library.set_notes(bone, "Review orientation")
	library.add_view("Review questions", state)
	var browser := Browser.new()
	browser.library = library
	browser.pack = {"bodies": []}
	browser.current_state = state.duplicate(true)
	browser.validate_state = func(_state: Dictionary): return ""
	root.add_child(browser)
	browser.popup_centered(Vector2i(820, 660))
	await process_frame
	await process_frame
	var bytes_before := FileAccess.get_file_as_bytes(library.path)
	var entries_before := library.entries.duplicate(true)
	var restored := [0]
	browser.restore_requested.connect(func(_state: Dictionary, _name: String): restored[0] += 1)
	check(browser.view_list.item_count == 3 and browser.filter_summary.text == "3 of 3 views", "Initial count includes the entire library")
	filter(browser, "  DEEP\t heart  ")
	check(browser.view_list.item_count == 1 and browser.view_list.get_item_metadata(0) == heart, "Every word matches across case, name and multiline notes")
	browser.filter_input.text_submitted.emit(browser.filter_input.text)
	check(browser.selected_entry().id == heart and browser.view_list.has_focus() and restored[0] == 0, "Search Enter selects a match without restoring anatomy")
	filter(browser, "λ 🫀 naïve")
	check(browser.selected_entry().get("id") == heart and browser.view_list.item_count == 1, "Matching a selected Unicode note retains selection")
	browser.notes_input.text = "Unsaved draft with temporaryword"
	browser.on_notes_changed()
	filter(browser, "bone")
	check(browser.selected_entry().is_empty() and browser.editing_id.is_empty() and browser.restore_button.disabled and browser.notes_button.disabled,
		"Filtering away a selection disables actions rather than choosing an unrelated view")
	check(browser.draft_notes.get(heart) == "Unsaved draft with temporaryword", "Filtering away a note retains its exact draft")
	filter(browser, "temporaryword")
	check(browser.view_list.item_count == 1 and browser.view_list.get_item_metadata(0) == heart, "Unsaved drafts can also be found")
	choose(browser, heart)
	check(browser.notes_input.text == browser.draft_notes[heart], "Selecting a filtered view recovers its typed draft")
	filter(browser, "absent term")
	browser.filter_input.text_submitted.emit(browser.filter_input.text)
	check(browser.view_list.item_count == 0 and "No matching views" in browser.information.text and browser.filter_summary.text == "0 of 3 views" and restored[0] == 0,
		"No-match state is explicit and Enter has no effect")
	check(FileAccess.get_file_as_bytes(library.path) == bytes_before and library.entries == entries_before and browser.current_state == state,
		"Searching never writes the library or changes saved/current anatomy snapshots")
	browser.request_close()
	check(browser.unsaved_dialog.visible and browser.draft_notes.size() == 1, "A filtered-out draft still protects browser close")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	key(browser, KEY_F, true)
	await process_frame
	check(browser.filter_input.has_focus(), "Ctrl+F focuses library search")
	key(browser, KEY_ESCAPE)
	await process_frame
	check(browser.filter_input.text.is_empty() and browser.view_list.item_count == 3 and not browser.is_queued_for_deletion(), "Escape in a nonempty search clears it and keeps the browser open")
	choose(browser, heart)
	browser.notes_input.grab_focus()
	key(browser, KEY_ESCAPE)
	await process_frame
	check(browser.unsaved_dialog.visible and browser.draft_notes.has(heart), "Escape from the note editor protects the draft")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	browser.notes_input.set_caret_column(11)
	browser.save_notes()
	check(browser.draft_notes.is_empty() and library.entries[2].notes == "Unsaved draft with temporaryword", "Recovered draft saves against its original view identity")
	check(browser.notes_input.get_caret_column() == 11, "Saving notes preserves the editor cursor when the view stays selected")
	filter(browser, "temporaryword")
	check(browser.notes_input.get_caret_column() == 11, "Filtering with the same selected view preserves the editor cursor")
	filter(browser, "temporaryword")
	choose(browser, heart)
	browser.notes_input.text = "Updated after search"
	browser.on_notes_changed()
	browser.save_notes()
	check(browser.view_list.item_count == 0 and browser.draft_notes.is_empty() and library.entries[2].notes == "Updated after search", "Saving a changed note refreshes matches without retaining its previous search text")
	filter(browser, "heart")
	choose(browser, heart)
	browser.name_input.text = "Renamed overview"
	browser.rename_selected()
	check(browser.filter_input.text.is_empty() and browser.selected_entry().id == heart and browser.view_list.item_count == 3, "Renaming outside the current search reveals and keeps the renamed view selected")
	filter(browser, "bone")
	browser.name_input.text = "New source view"
	browser.save_current()
	check(browser.filter_input.text.is_empty() and browser.selected_entry().name == "New source view" and browser.view_list.item_count == 4, "Saving outside a search reveals the new view")
	filter(browser, "bone")
	choose(browser, bone)
	browser.delete_selected()
	filter(browser, "review")
	check(browser.delete_pending.is_empty() and browser.delete_button.text == "Delete" and library.entries.size() == 4, "Changing search cancels pending deletion")
	filter(browser, "bone")
	choose(browser, bone)
	browser.delete_selected()
	browser.delete_selected()
	check(browser.view_list.item_count == 0 and browser.filter_summary.text == "0 of 3 views", "Deleting the only match updates the empty result and total")
	# A maximum-sized in-memory library stays complete after clearing a search.
	library.entries.clear()
	for index in SavedViews.MAX_VIEWS:
		library.entries.append({"id": "%032x" % index, "name": "View %03d" % index, "state": state, "notes": "lastmatch" if index == 199 else ""})
	browser.refresh_list()
	filter(browser, "lastmatch")
	check(browser.view_list.item_count == 1 and browser.filter_summary.text == "1 of 200 views", "Search covers the final view in a full library")
	filter(browser, " \t ")
	check(browser.view_list.item_count == 200, "Whitespace-only search reveals every view in storage order")
	browser.queue_free()
	await process_frame
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Saved-view search failures: ", failures)
	quit(0 if failures == 0 else 1)
