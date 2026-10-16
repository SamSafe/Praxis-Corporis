extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const Browser = preload("res://scripts/saved_views_browser.gd")
var failures := 0
var directory := "user://view-undo-" + Crypto.new().generate_random_bytes(8).hex_encode()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func choose(browser, id: String) -> void:
	for index in browser.view_list.item_count:
		if browser.view_list.get_item_metadata(index) == id:
			browser.view_list.select(index)
			browser.select_entry(index)
			return
	check(false, "Expected saved view is visible: " + id)


func remove(browser, id: String) -> void:
	choose(browser, id)
	browser.delete_selected()
	browser.delete_selected()


func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var library := SavedViews.new()
	library.path = directory + "/views.json"
	library.load_library()
	var state := {"body": "reference", "selection": "part", "camera": [0.123456789012345, 2.0], "changes": {"part": [0.05, -0.03, 0.01]}}
	library.add_view("First view", state)
	var first: String = library.entries[0].id
	library.add_view("Middle view", state)
	var middle: String = library.entries[0].id
	library.set_notes(middle, "Saved observations\nλ 🫀")
	library.add_view("Last view", state)
	var last: String = library.entries[0].id
	var browser := Browser.new()
	browser.library = library
	browser.pack = {"bodies": []}
	browser.current_state = state.duplicate(true)
	browser.validate_state = func(_state: Dictionary): return ""
	root.add_child(browser)
	var original := library.entries.duplicate(true)
	browser.popup_centered(Vector2i(780, 660))
	await process_frame
	var restored := [0]
	browser.restore_requested.connect(func(_state: Dictionary, _name: String): restored[0] += 1)
	choose(browser, first)
	browser.notes_input.text = "Another view's pending note"
	browser.on_notes_changed()
	choose(browser, middle)
	var draft := "Unfinished note\nλ 🫀"
	browser.notes_input.text = draft
	browser.on_notes_changed()
	browser.delete_selected()
	check(browser.last_deleted.is_empty() and not browser.undo_delete_button.visible and library.entries.size() == 3,
		"The first Delete click does not create an undo record or remove anything")
	browser.cancel_delete()
	remove(browser, middle)
	check(library.entries.size() == 2 and browser.last_deleted.entry.id == middle and browser.undo_delete_button.visible and browser.undo_delete_button.has_focus(),
		"Confirmed deletion offers a focused Undo action")
	check(not browser.draft_notes.has(middle) and browser.draft_notes.get(first) == "Another view's pending note", "Deleting one draft leaves other drafts intact")
	browser.filter_input.text = "last"
	browser.apply_filter("last")
	browser.undo_delete()
	check(library.entries == original and browser.selected_entry().id == middle and browser.filter_input.text.is_empty(),
		"Undo preserves identity, original position, exact in-memory snapshot, date and stored notes, and reveals the result")
	check(browser.notes_input.text == draft and browser.draft_notes.get(middle) == draft and library.entries[1].notes == "Saved observations\nλ 🫀" and not browser.notes_button.disabled,
		"Undo restores unfinished notes as a draft without silently saving them")
	check(browser.last_deleted.is_empty() and not browser.undo_delete_button.visible and restored[0] == 0 and browser.current_state == state,
		"One-step undo clears after success without restoring or changing the current anatomy")
	browser.request_close()
	check(browser.unsaved_dialog.visible and browser.draft_notes.size() == 2, "Recovered drafts participate in the existing close protection")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	browser.save_notes()
	check(library.entries[1].notes == draft and not browser.draft_notes.has(middle), "Recovered draft can be saved against its original identity")
	remove(browser, middle)
	var deleted := browser.last_deleted.duplicate(true)
	# A real write failure must preserve both the prior undo and the selected draft.
	choose(browser, first)
	DirAccess.make_dir_absolute(library.path + ".tmp")
	var bytes := FileAccess.get_file_as_bytes(library.path)
	browser.delete_selected()
	browser.delete_selected()
	check(browser.last_deleted == deleted and browser.draft_notes.has(first) and FileAccess.get_file_as_bytes(library.path) == bytes,
		"Failed deletion preserves the prior undo, selected draft and on-disk library")
	browser.undo_delete()
	check(browser.last_deleted == deleted and not browser.draft_notes.has(middle) and FileAccess.get_file_as_bytes(library.path) == bytes,
		"Failed undo retains the full recovery record and does not change storage or active drafts")
	DirAccess.remove_absolute(library.path + ".tmp")
	browser.undo_delete()
	check(browser.last_deleted.is_empty() and library.entries.size() == 3, "Undo can be retried after a write failure")
	remove(browser, middle)
	library.add_view("MIDDLE VIEW", state)
	var collision: String = library.entries[0].id
	bytes = FileAccess.get_file_as_bytes(library.path)
	browser.undo_delete()
	check(not browser.last_deleted.is_empty() and "name" in browser.message.text and FileAccess.get_file_as_bytes(library.path) == bytes,
		"Undo never overwrites a new view with the deleted view's name")
	library.rename_view(collision, "New view")
	browser.undo_delete()
	check(browser.last_deleted.is_empty() and browser.selected_entry().id == middle, "Undo remains retryable after resolving a name conflict")
	remove(browser, middle)
	remove(browser, last)
	check(browser.last_deleted.entry.id == last, "A later confirmed deletion replaces the one-step undo record")
	browser.undo_delete()
	check(library.entries.size() == 3 and browser.selected_entry().id == last, "Only the most recent deletion returns")
	remove(browser, last)
	var external := SavedViews.new()
	external.path = library.path
	external.load_library()
	external.rename_view(first, "External update")
	bytes = FileAccess.get_file_as_bytes(library.path)
	browser.undo_delete()
	check("changed elsewhere" in browser.message.text and not browser.last_deleted.is_empty() and FileAccess.get_file_as_bytes(library.path) == bytes,
		"Undo refuses a stale library without overwriting external edits")
	browser.queue_free()
	await process_frame
	var reopened := Browser.new()
	reopened.library = external
	reopened.pack = {"bodies": []}
	reopened.current_state = state
	reopened.validate_state = func(_state: Dictionary): return ""
	root.add_child(reopened)
	check(reopened.last_deleted.is_empty() and not reopened.undo_delete_button.visible and external.entries.size() == 2,
		"Reopening the window has no hidden persistent undo or automatic restoration")
	reopened.queue_free()
	await process_frame
	# Backend guards cover invalid entries, duplicate identities, full libraries and read errors.
	var candidate: Dictionary = original[1].duplicate(true)
	for updates in [{"id": "invalid"}, {"name": " bad "}, {"state": []}, {"created_unix": -1}, {"created_unix": 1.5}, {"notes": "\u0001"}]:
		var invalid := candidate.duplicate(true)
		invalid.merge(updates, true)
		check(not external.restore_deleted(invalid, 1).is_empty(), "Undo rejects invalid entry fields: " + str(updates.keys()))
	check(FileAccess.get_file_as_bytes(library.path) == bytes, "Invalid undo records leave storage untouched")
	var duplicate: Dictionary = external.entries[0].duplicate(true)
	duplicate.name = "Different name, same identity"
	check("identifier" in external.restore_deleted(duplicate, 0), "Undo never duplicates an existing identity")
	external.read_error = "Unreadable library"
	check(external.restore_deleted(candidate, 0) == external.read_error, "A failed library read blocks undo writes")
	external.read_error = ""
	var full: Array[Dictionary] = []
	for index in SavedViews.MAX_VIEWS:
		full.append({"id": "%032x" % index, "name": "View %03d" % index, "created_unix": 0, "state": state, "notes": ""})
	check(external.persist(full).is_empty(), "Full-library fixture writes normally")
	bytes = FileAccess.get_file_as_bytes(library.path)
	check("200 views" in external.restore_deleted(candidate, 1) and FileAccess.get_file_as_bytes(library.path) == bytes and external.entries.size() == SavedViews.MAX_VIEWS,
		"Undo respects library capacity without removing another view")
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Saved-view deletion undo failures: ", failures)
	quit(0 if failures == 0 else 1)
