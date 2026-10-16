extends RefCounted
## Local desktop layout, independent of anatomy snapshots and scripted QA settings.

const DEFAULT_SIZE := Vector2i(1440, 900)
const MIN_SIZE := Vector2i(1100, 720)
const MAX_SIZE := Vector2i(16384, 16384)
var path := "user://window-state.json"
var enabled := false
var normal_size := DEFAULT_SIZE
var maximized := false
var window: Window
var restoring := false


static func valid_size(value: Variant) -> bool:
	if not value is Array or value.size() != 2:
		return false
	for axis in 2:
		var number = value[axis]
		if not (number is int or number is float) or not is_finite(float(number)) or number != floorf(float(number)) or number < MIN_SIZE[axis] or number > MAX_SIZE[axis]:
			return false
	return true


static func valid(record: Variant) -> bool:
	return record is Dictionary and record.size() == 3 and typeof(record.get("schema_version")) in [TYPE_INT, TYPE_FLOAT] and record.get("schema_version") == 1 and valid_size(record.get("size")) and record.get("maximized") is bool


func attach(target: Window, active: bool) -> String:
	detach()
	window = target
	enabled = active and DisplayServer.get_name() != "headless"
	remember()
	window.size_changed.connect(remember)
	if not enabled or not FileAccess.file_exists(path):
		return ""
	var error := load_settings()
	if error.is_empty():
		restore()
	return error


func load_settings() -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1024:
		return "Window settings could not be read; the default layout is in use."
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not valid(parser.data):
		return "Window settings were invalid; the default layout is in use."
	var record: Dictionary = parser.data
	normal_size = Vector2i(int(record["size"][0]), int(record["size"][1]))
	maximized = record["maximized"]
	return ""


func detach() -> void:
	if is_instance_valid(window) and window.size_changed.is_connected(remember):
		window.size_changed.disconnect(remember)
	window = null
	enabled = false


static func fitted_size(wanted: Vector2i, usable_size: Vector2i, decoration: Vector2i = Vector2i.ZERO) -> Vector2i:
	var result := wanted.clamp(MIN_SIZE, MAX_SIZE)
	if usable_size.x > 0 and usable_size.y > 0:
		result = result.min((usable_size - decoration).max(MIN_SIZE))
	return result


func restore() -> void:
	if not is_instance_valid(window):
		return
	restoring = true
	window.mode = Window.MODE_WINDOWED
	var usable := Rect2i()
	if DisplayServer.get_name() != "headless":
		usable = DisplayServer.screen_get_usable_rect(window.current_screen)
	var decoration := (window.get_size_with_decorations() - window.size).max(Vector2i.ZERO)
	var offset := window.position - window.get_position_with_decorations()
	normal_size = fitted_size(normal_size, usable.size, decoration)
	window.size = normal_size
	if usable.has_area():
		window.position = usable.position + (usable.size - normal_size - decoration).max(Vector2i.ZERO) / 2 + offset
	if maximized:
		window.mode = Window.MODE_MAXIMIZED
	restoring = false


func remember() -> void:
	if restoring or not is_instance_valid(window):
		return
	if window.mode == Window.MODE_WINDOWED:
		if valid_size([window.size.x, window.size.y]):
			normal_size = window.size
		maximized = false
	elif window.mode == Window.MODE_MAXIMIZED:
		maximized = true


func save() -> String:
	if not enabled:
		return ""
	remember()
	var record := {"schema_version": 1, "size": [normal_size.x, normal_size.y], "maximized": maximized}
	if not valid(record):
		return "Window layout could not be saved."
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return "Window layout could not be saved."
	file.store_string(JSON.stringify(record, "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(path + ".tmp", path)
	return "" if error == OK else "Window layout could not be saved."
