extends SceneTree

const WindowState = preload("res://scripts/window_state.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var original_size := root.size
	var original_position := root.position
	var state := WindowState.new()
	state.path = "user://window-state-test-" + Crypto.new().generate_random_bytes(8).hex_encode() + ".json"
	var wanted := Vector2i(4000, 2000)
	var fitted: Vector2i = WindowState.fitted_size(wanted, Vector2i(1920, 1040), Vector2i(16, 39))
	check(fitted.x + 16 <= 1920 and fitted.y + 39 <= 1040 and fitted.x >= 1100 and fitted.y >= 720, "A large saved layout fits a smaller supported display including decorations")
	check(WindowState.fitted_size(Vector2i(1300, 800), Vector2i(1920, 1040)) == Vector2i(1300, 800), "A fitting layout retains its exact size")
	var valid: Dictionary = {"schema_version": 1, "size": [1300, 800], "maximized": false}
	check(WindowState.valid(valid), "Window settings accept the implemented schema")
	for invalid in [null, [], {}, {"schema_version": true, "size": [1300, 800], "maximized": false}, {"schema_version": 2, "size": [1300, 800], "maximized": false}, {"schema_version": 1, "size": [999999, 800], "maximized": false}, {"schema_version": 1, "size": [1300, 800.5], "maximized": false}, {"schema_version": 1, "size": [true, 800], "maximized": false}, {"schema_version": 1, "size": [1300, 800], "maximized": "yes"}]:
		check(not WindowState.valid(invalid), "Damaged window records are rejected")
	check(state.attach(root, false).is_empty() and state.save().is_empty() and not FileAccess.file_exists(state.path), "Disabled scripted layout never creates preferences")
	state.detach()
	write_text(state.path, "broken")
	var before := root.size
	check(not state.load_settings().is_empty() and root.size == before and FileAccess.get_file_as_string(state.path) == "broken", "Invalid persisted layout leaves the current window and file intact")
	write_text(state.path, JSON.stringify(valid))
	check(state.load_settings().is_empty() and state.normal_size == Vector2i(1300, 800) and not state.maximized, "JSON settings reopen with their exact dimensions")
	state.normal_size = Vector2i(1400, 850)
	state.enabled = true
	check(state.save().is_empty(), "A new normal layout is saved")
	var reopened := WindowState.new()
	reopened.path = state.path
	check(reopened.load_settings().is_empty() and reopened.normal_size == Vector2i(1400, 850), "A changed layout survives a second reopen")
	if DisplayServer.get_name() != "headless":
		check(reopened.attach(root, true).is_empty(), "Desktop restoration attaches")
		await process_frame
		await process_frame
		check(root.size == Vector2i(1400, 850), "Reopening restores the actual client size")
		root.size = Vector2i(1300, 800)
		await process_frame
		check(reopened.save().is_empty(), "A native resize is saved")
		root.mode = Window.MODE_MAXIMIZED
		await process_frame
		await process_frame
		check(root.mode == Window.MODE_MAXIMIZED and reopened.save().is_empty(), "Native maximized mode can be persisted")
		var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(state.path))
		check(record.maximized and record["size"] == [1300.0, 800.0], "Maximizing keeps the preceding windowed dimensions")
		reopened.detach()
		root.mode = Window.MODE_WINDOWED
		check(reopened.attach(root, true).is_empty(), "Maximized settings reopen")
		await process_frame
		await process_frame
		check(root.mode == Window.MODE_MAXIMIZED, "Reopening restores native maximized state")
	else:
		check(reopened.attach(root, true).is_empty() and not reopened.enabled, "A headless process cannot apply or save desktop layout")
	reopened.detach()
	root.mode = Window.MODE_WINDOWED
	root.size = original_size
	root.position = original_position
	state.path += "/missing/file.json"
	state.enabled = true
	check(not state.save().is_empty(), "An actual file-open failure is reported")
	var clean_path: String = state.path.trim_suffix("/missing/file.json")
	DirAccess.remove_absolute(clean_path)
	DirAccess.remove_absolute(clean_path + ".tmp")
	check(not state.window, "Detaching releases the window and signal binding")
	print("Window state failures: ", failures)
	quit(0 if failures == 0 else 1)
