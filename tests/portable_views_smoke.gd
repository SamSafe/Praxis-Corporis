extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const Preferences = preload("res://scripts/viewer_preferences.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func validate(state: Dictionary) -> String:
	return "Different reference version" if state.get("reference_hash") != "installed" else ""


func _initialize() -> void:
	var directory := "user://portable-test-" + Crypto.new().generate_random_bytes(8).hex_encode()
	DirAccess.make_dir_recursive_absolute(directory)
	var original := SavedViews.new()
	original.path = directory + "/original.json"
	check(original.load_library().is_empty(), "Open an empty library")
	check(original.add_view("Heart", {"reference_hash": "installed"}).is_empty(), "Save compatible view")
	check(original.set_notes(original.entries[0].id, "A note\nwith two lines").is_empty(), "Save multiline notes")
	var snapshot := original.entries.duplicate(true)
	var exported := directory + "/export.json"
	check(original.export_library(exported).is_empty(), "Export the library")
	check(not original.export_library(original.path).is_empty(), "Never export over the active library")
	var target := SavedViews.new()
	target.path = directory + "/target.json"
	target.load_library()
	target.add_view("Heart", {"reference_hash": "installed"})
	var plan := target.preview_import(exported, validate)
	check(plan.error.is_empty() and plan.imported == 1 and plan.entries[1].name == "Heart (2)", "Preview name collisions without overwriting")
	check(target.entries.size() == 1, "Preview does not change the library")
	check(target.apply_import(plan, validate).is_empty() and target.entries.size() == 2, "Merge compatible views atomically")
	check(target.entries[1].notes == snapshot[0].notes and target.entries[1].state == snapshot[0].state, "Notes and snapshot survive transfer")
	plan = target.preview_import(exported, validate)
	check(plan.imported == 0, "Repeated import recognizes views even after a local collision rename")
	var clean := SavedViews.new()
	clean.path = directory + "/clean.json"
	clean.load_library()
	plan = clean.preview_import(exported, validate)
	clean.apply_import(plan, validate)
	check(clean.preview_import(exported, validate).imported == 0, "Unchanged exports are not imported twice")
	original.add_view("Missing geometry", {"reference_hash": "missing"})
	original.export_library(exported)
	plan = clean.preview_import(exported, validate)
	check(plan.imported == 0 and plan.skipped == 2 and "Different reference version" in plan.summary, "Preview explains incompatible references")
	var bytes_before := FileAccess.get_file_as_string(clean.path)
	var file := FileAccess.open(exported, FileAccess.WRITE)
	file.store_string('{"schema_version":1,"views":[{"name":"broken"}]}')
	file.close()
	check(not clean.preview_import(exported, validate).error.is_empty() and FileAccess.get_file_as_string(clean.path) == bytes_before, "Malformed import preserves the library")
	original.export_library(exported)
	plan = target.preview_import(exported, validate)
	target.rename_view(target.entries[0].id, "Elsewhere")
	check(not target.apply_import(plan, validate).is_empty(), "Stale import previews cannot overwrite later edits")
	var preferences := Preferences.new()
	preferences.path = directory + "/preferences.json"
	check(preferences.load_settings().is_empty(), "Missing preferences use defaults")
	var settings: Dictionary = preferences.values.duplicate()
	settings.text_scale = 1.3
	settings.resolution = 0.5
	settings.explorer = false
	check(preferences.store(settings).is_empty(), "Preferences write successfully")
	var load_error := preferences.load_settings()
	check(load_error.is_empty() and is_equal_approx(preferences.values.text_scale, 1.3) and not preferences.values.explorer, "Preferences survive reopening")
	# A file written before smooth camera motion existed still opens, with the new default.
	var legacy: Dictionary = settings.duplicate()
	legacy.erase("smooth_motion")
	file = FileAccess.open(preferences.path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 1, "values": legacy}))
	file.close()
	check(preferences.load_settings().is_empty() and preferences.values.smooth_motion == true and not preferences.values.explorer, "Earlier preference files keep their settings and gain smooth motion")
	settings.smooth_motion = false
	check(preferences.store(settings).is_empty() and preferences.load_settings().is_empty() and preferences.values.smooth_motion == false, "Turning smooth motion off is remembered")
	settings.smooth_motion = "yes"
	check(not preferences.store(settings).is_empty(), "A non-boolean motion setting is rejected")
	settings.smooth_motion = false
	settings.unknown = true
	check(not preferences.store(settings).is_empty(), "Unknown preference keys are rejected")
	settings.erase("unknown")
	file = FileAccess.open(preferences.path, FileAccess.WRITE)
	file.store_string('{"schema_version":1,"values":{"text_scale":99999}}')
	file.close()
	check(not preferences.load_settings().is_empty() and preferences.values == Preferences.DEFAULTS, "Damaged preferences recover to defaults")
	file = FileAccess.open(preferences.path, FileAccess.WRITE)
	file.store_string("not JSON")
	file.close()
	check(not preferences.load_settings().is_empty() and preferences.values == Preferences.DEFAULTS and FileAccess.get_file_as_string(preferences.path) == "not JSON", "Invalid JSON recovers quietly and preserves the original file")
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Portable views and preferences failures: ", failures)
	quit(0 if failures == 0 else 1)
