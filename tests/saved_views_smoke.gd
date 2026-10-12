extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
var failures: Array[String] = []
var test_path := "user://named_views_test.json"


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func same_snapshot(actual: Variant, expected: Variant) -> bool:
	# JSON parsing can differ by one double-precision ULP; geometry is checked
	# separately against the original float32 displacement, without a tolerance.
	if (actual is float or actual is int) and (expected is float or expected is int):
		return absf(float(actual) - float(expected)) <= 1e-12
	if actual is Dictionary and expected is Dictionary:
		if actual.size() != expected.size():
			return false
		for key in expected:
			if not actual.has(key) or not same_snapshot(actual[key], expected[key]):
				return false
		return true
	if actual is Array and expected is Array:
		if actual.size() != expected.size():
			return false
		for index in expected.size():
			if not same_snapshot(actual[index], expected[index]):
				return false
		return true
	return actual == expected


func clean_files() -> void:
	for suffix in ["", ".tmp", ".bak", ".bak.tmp", ".damaged"]:
		if FileAccess.file_exists(test_path + suffix):
			DirAccess.remove_absolute(test_path + suffix)


func write_json(value: Variant) -> void:
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))
	file.close()


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	clean_files()
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.views_path = test_path
	var library := SavedViews.new()
	library.path = test_path
	check(library.load_library().is_empty(), "A new local library opens without a file")
	var expected := {}
	for body in ["female", "male", "bodyparts-male-bones-study"]:
		await viewer.switch_body(body)
		var selection := "source.bodyparts3d-v4-male.FJ3365" if body == "bodyparts-male-bones-study" else "anatomy.heart.valve.mitral"
		viewer.select_structure(selection)
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.05, 0.03, -0.02))
		viewer.inspect_alone()
		viewer.labels_button.button_pressed = false
		viewer.local_labels_button.button_pressed = true
		viewer.label_density.value = 5
		viewer.original_positions_button.button_pressed = false
		var state: Dictionary = viewer.export_view_state()
		expected[body] = state.duplicate(true)
		check(viewer.validate_view_state(state).is_empty(), "Each complete view validates against its own reference")
		check(library.add_view(body + " inspection", state).is_empty(), "Multiple reference views can be saved without overwriting")
	var file_before := FileAccess.get_file_as_string(test_path)
	check(not library.add_view("FEMALE INSPECTION", expected.female).is_empty(), "Names are unique irrespective of letter case")
	check(not library.add_view("\n", expected.female).is_empty(), "Blank/control-character names are rejected")
	check(FileAccess.get_file_as_string(test_path) == file_before and library.entries.size() == 3, "Rejected names leave the file and library unchanged")
	var reopened := SavedViews.new()
	reopened.path = test_path
	check(reopened.load_library().is_empty() and reopened.entries.size() == 3, "Three views survive closing and reopening storage")
	for entry in reopened.entries:
		viewer.move_button.button_pressed = true
		viewer.orbit.move_mode = true
		check(await viewer.restore_view_state(entry.state), "Named reference view restores")
		check(not viewer.orbit.move_mode and not viewer.move_button.button_pressed, "Restoring a view returns to navigation mode")
		var actual: Dictionary = viewer.export_view_state()
		check(same_snapshot(actual, expected[entry.state.body]), "Camera, source hash, labels, changes, isolation and return context round-trip together")
		check(actual.changes == expected[entry.state.body].changes, "Source geometry displacement round-trips at its original float32 precision")
		viewer.return_to_context()
		check(viewer.model.isolated_id.is_empty() and viewer.model.export_state() == expected[entry.state.body].changes, "Restored isolated views retain a working return action")
	var first_id: String = reopened.entries[0].id
	check(reopened.rename_view(first_id, "Initial rename").is_empty(), "An open library can update its own entries")
	var stale_file := FileAccess.get_file_as_string(test_path)
	check(not library.rename_view(first_id, "Stale window").is_empty() and FileAccess.get_file_as_string(test_path) == stale_file, "A stale window cannot overwrite another library edit")
	check(reopened.rename_view(first_id, "Femur study").is_empty(), "Renaming keeps the view identity")
	check(reopened.entries[0].id == first_id and reopened.entries[0].name == "Femur study", "Renaming retains the geometry snapshot")
	var browser: Window = viewer.show_saved_views()
	check(browser.view_list.item_count == 3 and browser.save_button.disabled == false, "The UI lists every named view")
	browser.view_list.select(0)
	browser.select_entry(0)
	check("BodyParts3D" in browser.information.text and "Right femur" in browser.information.text, "Selected bookmark explains its actual reference and structure")
	browser.delete_selected()
	check(browser.library.entries.size() == 3 and browser.delete_pending == first_id, "Deletion first asks for confirmation in the window")
	browser.view_list.select(1)
	browser.select_entry(1)
	check(browser.delete_pending.is_empty(), "Changing selection cancels pending deletion")
	browser.delete_selected()
	browser.delete_selected()
	check(browser.library.entries.size() == 2, "Confirmed deletion removes only the selected view")
	browser.queue_free()
	await process_frame
	reopened.load_library()
	var good_entries := reopened.entries.duplicate(true)
	var good_file := FileAccess.get_file_as_string(test_path)
	write_json({"schema_version": 99, "views": []})
	var damaged_file := FileAccess.get_file_as_string(test_path)
	check(not reopened.load_library().is_empty(), "Unsupported library versions are rejected")
	check(reopened.entries == good_entries and not reopened.add_view("New", expected.female).is_empty(), "A failed read preserves the known library and blocks overwrite")
	check(FileAccess.get_file_as_string(test_path) == damaged_file, "Damaged input remains unchanged")
	check(reopened.can_recover() and reopened.recover_backup().is_empty(), "The prior valid library can be recovered explicitly")
	check(FileAccess.get_file_as_string(test_path + ".damaged") == damaged_file, "Recovery retains the original damaged file")
	check(reopened.read_error.is_empty() and reopened.entries.size() == 3, "Recovery restores the version before deletion")
	var duplicate := {"schema_version": 1, "views": reopened.entries.duplicate(true)}
	duplicate.views.append(duplicate.views[0].duplicate(true))
	write_json(duplicate)
	check(not reopened.load_library().is_empty(), "Duplicate IDs/names cannot enter the library")
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string(good_file)
	file.close()
	reopened.load_library()
	var before: Dictionary = viewer.export_view_state()
	var invalid: Dictionary = expected.female.duplicate(true)
	invalid.reference_hash = "wrong-version"
	check(not await viewer.restore_view_state(invalid) and viewer.export_view_state() == before, "Incompatible cross-reference restores are rejected before mutation")
	invalid = expected.female.duplicate(true)
	invalid.body = "not-installed"
	check(not await viewer.restore_view_state(invalid) and viewer.export_view_state() == before, "Unavailable reference views do not alter the current scene")
	reopened.path = "user://missing-test-directory/library.json"
	check(not reopened.rename_view(reopened.entries[0].id, "Cannot write").is_empty() and reopened.entries == good_entries, "Write failures retain the previous in-memory entries")
	clean_files()
	viewer.queue_free()
	await process_frame
	print("Named saved-view failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
