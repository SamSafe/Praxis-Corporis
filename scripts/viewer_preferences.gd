extends RefCounted
## Device preferences are separate from anatomy snapshots and portable libraries.

const DEFAULTS := {"text_scale": 1.0, "resolution": 1.0, "explorer": true,
	"details": true, "selection_labels": true, "local_labels": false, "label_density": 8}
var path := "user://preferences.json"
var values: Dictionary = DEFAULTS.duplicate()


func valid(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("values") is Dictionary:
		return false
	var settings: Dictionary = data.values
	if settings.size() != DEFAULTS.size():
		return false
	for key in ["explorer", "details", "selection_labels", "local_labels"]:
		if not settings.get(key) is bool:
			return false
	var density = settings.get("label_density")
	return settings.get("text_scale") in [1.0, 1.15, 1.3] and settings.get("resolution") in [1.0, 0.75, 0.5] and (density is int or density is float) and is_finite(float(density)) and density == floorf(float(density)) and density >= 1 and density <= 12


func load_settings() -> String:
	values = DEFAULTS.duplicate()
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 8192:
		return "Preferences could not be read. Default settings are in use."
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not valid(parser.data):
		return "Preferences were invalid. Default settings are in use."
	var data: Dictionary = parser.data
	values = data.values.duplicate()
	return ""


func store(settings: Dictionary) -> String:
	var data := {"schema_version": 1, "values": settings}
	if not valid(data):
		return "These preferences could not be saved."
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return "Preferences apply for this session; they could not be saved."
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(path + ".tmp", path)
	if error != OK:
		return "Preferences apply for this session; they could not be saved."
	values = settings.duplicate()
	return ""
