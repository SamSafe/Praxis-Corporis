extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
var failures: Array[String] = []
var test_path := "user://study_notes_test.json"


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func clean_files() -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".damaged"]:
		DirAccess.remove_absolute(test_path + suffix)


func choose(browser, index: int) -> void:
	browser.view_list.select(index)
	browser.select_entry(index)


func edit(browser, text: String) -> void:
	browser.notes_input.text = text
	browser.on_notes_changed()


func run() -> void:
	clean_files()
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.views_path = test_path
	viewer.chest_view()
	var snapshot: Dictionary = viewer.export_view_state()
	var library := SavedViews.new()
	library.path = test_path
	library.load_library()
	check(library.add_view("Heart overview", snapshot).is_empty(), "First source view saves")
	check(library.add_view("Review questions", snapshot).is_empty(), "A second view saves independently")
	var first_id: String = library.entries[0].id
	var second_id: String = library.entries[1].id
	# An existing schema-1 library without notes opens without rewriting it.
	var legacy: Dictionary = {"schema_version": 1, "views": library.entries.duplicate(true)}
	for entry in legacy.views:
		entry.erase("notes")
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy, "\t", true, true))
	file.close()
	var legacy_bytes := FileAccess.get_file_as_bytes(test_path)
	check(library.load_library().is_empty() and library.entries[0].get("notes", "").is_empty(), "Earlier named libraries acquire an empty optional note")
	check(FileAccess.get_file_as_bytes(test_path) == legacy_bytes, "Opening an old library never rewrites its bytes")
	var note := "Question: what should I review here?\nMy notes: naïve – λ 🫀\tsecond line"
	var states := [library.entries[0].state.duplicate(true), library.entries[1].state.duplicate(true)]
	var created: Variant = library.entries[0].created_unix
	check(library.update_notes({first_id: note, second_id: "A different observation"}).is_empty(), "Several notes save in one library update")
	check(library.entries[0].state == states[0] and library.entries[1].state == states[1] and library.entries[0].created_unix == created, "Notes never change source snapshots or dates")
	var reopened := SavedViews.new()
	reopened.path = test_path
	check(reopened.load_library().is_empty() and reopened.entries[0].notes == note, "Unicode, tabs and multiline notes survive reopening exactly")
	var bytes_before := FileAccess.get_file_as_bytes(test_path)
	var entries_before := library.entries.duplicate(true)
	check(not library.update_notes({first_id: "Do not partly commit", "missing-id": "Missing view"}).is_empty(), "A missing view rejects the entire note batch")
	check(not library.set_notes(first_id, "x".repeat(10001)).is_empty(), "Oversized notes are rejected")
	check(FileAccess.get_file_as_bytes(test_path) == bytes_before and library.entries == entries_before, "Rejected batches retain file and memory exactly")
	check(library.set_notes(first_id, "x".repeat(10000)).is_empty(), "The declared note limit can be saved")
	check(library.set_notes(first_id, note).is_empty(), "Replacing notes retains the same saved view")
	check(library.set_notes(second_id, "Changed after the other reader opened").is_empty(), "An independent note update changes the stored library")
	check(not reopened.set_notes(first_id, "Stale note").is_empty(), "Stale library readers cannot overwrite notes")
	var failed_writer := SavedViews.new()
	failed_writer.path = "user://notes-missing-%s/library.json" % Crypto.new().generate_random_bytes(16).hex_encode()
	failed_writer.entries = library.entries.duplicate(true)
	entries_before = failed_writer.entries.duplicate(true)
	check(not failed_writer.set_notes(first_id, "Cannot write here").is_empty() and failed_writer.entries == entries_before,
		"An actual file-open failure retains the prior note in memory")
	var browser: Window = viewer.show_saved_views()
	choose(browser, 0)
	check(browser.notes_input.text == note and browser.notes_input.editable and browser.notes_button.disabled, "Selected notes display without an unsaved status")
	edit(browser, "Unsaved first view\n🫀")
	choose(browser, 1)
	edit(browser, "Unsaved second view")
	choose(browser, 0)
	check(browser.notes_input.text == "Unsaved first view\n🫀" and browser.draft_notes.size() == 2, "Switching views preserves both typed drafts")
	browser.request_close()
	check(browser.unsaved_dialog.visible and not browser.is_queued_for_deletion(), "Close protects all unsaved drafts")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	check(not browser.unsaved_dialog.visible and browser.draft_notes.size() == 2, "Keep editing returns to the original drafts")
	browser.request_close()
	browser.unsaved_dialog.get_ok_button().pressed.emit()
	await process_frame
	check(reopened.load_library().is_empty() and reopened.entries[0].notes == "Unsaved first view\n🫀" and reopened.entries[1].notes == "Unsaved second view", "Save and close persists every draft together")
	check(viewer.export_view_state() == snapshot, "Editing notes preserves the active anatomy and camera")
	browser = viewer.show_saved_views()
	choose(browser, 0)
	edit(browser, "Keep this draft after a write failure")
	var external := SavedViews.new()
	external.path = test_path
	external.load_library()
	external.rename_view(first_id, "Changed in another window")
	bytes_before = FileAccess.get_file_as_bytes(test_path)
	browser.request_close()
	browser.unsaved_dialog.get_ok_button().pressed.emit()
	check(browser.unsaved_dialog.visible and browser.notes_input.text == "Keep this draft after a write failure" and browser.draft_notes.size() == 1,
		"Failed save leaves both dialog and typed draft available")
	check(FileAccess.get_file_as_bytes(test_path) == bytes_before and not browser.is_queued_for_deletion(), "A failed save never closes or replaces the changed file")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	# A normal application close uses the same draft protection.
	viewer.window_state.path = test_path + ".window.json"
	viewer.window_state.enabled = true
	viewer.reference_state.path = test_path + ".reference.json"
	viewer.reference_state.enabled = true
	root.close_requested.emit()
	check(browser.unsaved_dialog.visible and browser.pending_action.is_valid(), "Root-window close protects the open note editor")
	check(not FileAccess.file_exists(viewer.window_state.path), "A canceled close does not persist a new window layout")
	check(not FileAccess.file_exists(viewer.reference_state.path), "A canceled close does not persist a new startup reference")
	browser.unsaved_dialog.get_cancel_button().pressed.emit()
	await process_frame
	viewer.window_state.enabled = false
	viewer.reference_state.enabled = false
	browser.request_close()
	browser.unsaved_dialog.custom_action.emit("discard")
	await process_frame
	check(FileAccess.get_file_as_bytes(test_path) == bytes_before, "Discard closes without writing any draft")
	browser = viewer.show_saved_views()
	choose(browser, 0)
	edit(browser, "Save before restoring")
	var restore_count := [0]
	browser.restore_requested.connect(func(_state: Dictionary, _name: String): restore_count[0] += 1)
	browser.restore_selected()
	check(restore_count[0] == 0 and browser.unsaved_dialog.visible, "Restore waits for a draft decision")
	browser.unsaved_dialog.get_ok_button().pressed.emit()
	await process_frame
	check(restore_count[0] == 1 and reopened.load_library().is_empty() and reopened.entries[0].notes == "Save before restoring", "Saving notes then restoring emits exactly one view restoration")
	# Invalid note types are rejected before overwriting a known library.
	var malformed: Dictionary = {"schema_version": 1, "views": reopened.entries.duplicate(true)}
	malformed.views[0].notes = ["not text"]
	file = FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(malformed))
	file.close()
	entries_before = reopened.entries.duplicate(true)
	check(not reopened.load_library().is_empty() and reopened.entries == entries_before, "Damaged note records retain the last known library")
	check(not reopened.set_notes(first_id, "Blocked").is_empty(), "Damaged libraries block note writes")
	check(reopened.recover_backup().is_empty(), "Valid backup recovery includes prior notes")
	clean_files()
	viewer.queue_free()
	await process_frame
	print("Study notes failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
