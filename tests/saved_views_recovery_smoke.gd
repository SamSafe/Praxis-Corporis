extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const Browser = preload("res://scripts/saved_views_browser.gd")
const StudyVerification = preload("res://scripts/study_verification.gd")
var failures := 0
var directory := "user://recovery-check-" + Crypto.new().generate_random_bytes(8).hex_encode()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var library := SavedViews.new()
	library.path = directory + "/views.json"
	library.load_library()
	library.add_view("First study", {"selection": "first"})
	library.set_notes(library.entries[0].id, "Notes to recover 🫀")
	library.add_view("Second study", {"selection": "second"})
	var known := library.entries.duplicate(true)
	var healthy := FileAccess.get_file_as_string(library.path)
	var backup := FileAccess.get_file_as_string(library.path + ".bak")
	write(library.path, "truncated { invalid JSON")
	check(not library.load_library().is_empty() and library.entries == known, "Invalid JSON retains the last known entries")
	check(library.can_recover() and FileAccess.get_file_as_string(library.path) == "truncated { invalid JSON", "Checking recovery leaves damaged bytes intact")
	# The recovery offer is stale when another window/editor replaces the main file.
	write(library.path, healthy)
	var error := library.recover_backup()
	check(not error.is_empty() and FileAccess.get_file_as_string(library.path) == healthy, "Stale recovery cannot replace a newly healthy library")
	check(library.entries == known and not FileAccess.file_exists(library.path + ".damaged"), "Rejected recovery does not change memory or create a damaged copy")
	write(library.path, "second damaged input")
	library.load_library()
	write(library.path, "changed damaged input")
	error = library.recover_backup()
	check(not error.is_empty() and FileAccess.get_file_as_string(library.path) == "changed damaged input", "A changed damaged file also invalidates the recovery offer")
	library.load_library()
	write(library.path + ".damaged", "Earlier damaged copy must survive")
	check(library.recover_backup().is_empty(), "An explicit recovery can restore a valid prior library")
	check(FileAccess.get_file_as_string(library.path + ".damaged") == "Earlier damaged copy must survive", "Recovery never replaces an earlier damaged copy")
	var copies := []
	for name in DirAccess.get_files_at(directory):
		if name.begins_with("views.json.damaged-"):
			copies.append(directory.path_join(name))
	check(copies.size() == 1 and FileAccess.get_file_as_string(copies[0]) == "changed damaged input", "A separate recovery copy preserves this damaged file exactly")
	check(FileAccess.get_file_as_string(library.path + ".bak") == backup and library.read_error.is_empty(), "Recovery keeps its prior valid backup and clears the read failure")
	check(library.entries.size() == 1 and library.entries[0].name == "First study" and library.entries[0].notes == "Notes to recover 🫀", "Recovery restores the backup's views and Unicode notes")
	var recovered := FileAccess.get_file_as_string(library.path)
	check(not library.recover_backup().is_empty() and FileAccess.get_file_as_string(library.path) == recovered, "A healthy loaded library cannot be rolled back through recovery")
	write(library.path, "\ufeff" + healthy)
	var bom_bytes := FileAccess.get_file_as_bytes(library.path)
	check(library.load_library().is_empty() and library.entries.size() == 2 and FileAccess.get_file_as_bytes(library.path) == bom_bytes, "UTF-8 BOM imports remain readable without rewriting their bytes")
	check(library.rename_view(library.entries[0].id, "Renamed after BOM read").is_empty(), "The exact input fingerprint permits an intentional update after a BOM read")
	# A missing main file can recover, but a file created after the offer is protected.
	DirAccess.remove_absolute(library.path)
	library.load_library()
	write(library.path, healthy)
	check(not library.recover_backup().is_empty() and FileAccess.get_file_as_string(library.path) == healthy, "Recovery for a missing file cannot overwrite a later replacement")
	DirAccess.remove_absolute(library.path)
	library.load_library()
	check(library.recover_backup().is_empty(), "A still-missing library recovers without a damaged copy")
	# Malformed imports and backups are expected input failures, not engine errors.
	var known_after := library.entries.duplicate(true)
	write(directory + "/import.json", "{")
	var plan := library.preview_import(directory + "/import.json", func(_state: Dictionary): return "")
	check(not plan.error.is_empty() and library.entries == known_after, "Malformed import retains the active library")
	write(library.path, "{")
	write(library.path + ".bak", "{")
	library.load_library()
	check(not library.can_recover() and not library.recover_backup().is_empty(), "A malformed backup cannot be offered or restored")
	var browser := Browser.new()
	browser.library = SavedViews.new()
	browser.library.path = library.path
	browser.pack = {"bodies": []}
	browser.current_state = {}
	browser.validate_state = func(_state: Dictionary): return ""
	root.add_child(browser)
	browser.popup_centered(Vector2i(720, 500))
	await process_frame
	check(browser.save_button.disabled and browser.import_button.disabled and browser.export_button.disabled and not browser.notes_input.editable and not browser.recovery_button.visible,
		"Damaged library and backup disable editing and do not offer unavailable recovery")
	write(library.path + ".bak", backup)
	browser.library.load_library()
	browser.refresh_list()
	check(browser.recovery_button.visible, "The browser offers a newly available valid backup")
	write(library.path, healthy)
	browser.recovery_button.pressed.emit()
	check("changed elsewhere" in browser.message.text and FileAccess.get_file_as_string(library.path) == healthy, "The recovery button reports a stale offer without replacing current data")
	write(library.path, "final damaged UI input")
	browser.library.load_library()
	browser.refresh_list()
	browser.recovery_button.pressed.emit()
	check(browser.library.read_error.is_empty() and browser.view_list.item_count == 1 and not browser.save_button.disabled and not browser.recovery_button.visible,
		"Successful browser recovery restores editing and removes the recovery action")
	check(browser.library.recovery_copy_path.get_file() in browser.message.text and FileAccess.get_file_as_string(browser.library.recovery_copy_path) == "final damaged UI input",
		"The browser names the preserved damaged file and retains its exact bytes")
	browser.queue_free()
	await process_frame
	check(StudyVerification.verify_recovery({"body": "fixture", "selection": "first"}), "The exported-runtime recovery protocol passes against disposable storage")
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Saved-view recovery failures: ", failures)
	quit(0 if failures == 0 else 1)
