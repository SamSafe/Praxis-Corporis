extends RefCounted
## Startup reference only; camera, notes and anatomy edits stay in saved views.

const DEFAULT_REFERENCE := "female"
var path := "user://reference-state.json"
var enabled := false
var current: Dictionary = {}


static func valid(record: Variant) -> bool:
	return record is Dictionary and record.size() == 3 and typeof(record.get("schema_version")) in [TYPE_INT, TYPE_FLOAT] and record.get("schema_version") == 1 and record.get("body_id") is String and record.body_id.length() > 0 and record.body_id.length() <= 128 and record.get("source_sha256") is String and record.source_sha256.length() == 64 and record.source_sha256.is_valid_hex_number(false)


func choice(pack: Dictionary) -> Dictionary:
	var fallback := {"id": DEFAULT_REFERENCE, "message": ""}
	if not enabled or not FileAccess.file_exists(path):
		return fallback
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1024:
		fallback.message = "The remembered reference could not be read. Showing the female reference."
		return fallback
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not valid(parser.data):
		fallback.message = "The remembered reference was invalid. Showing the female reference."
		return fallback
	var record: Dictionary = parser.data
	for body in pack.bodies:
		if body.id == record.body_id and str(body.sha256).to_lower() == str(record.source_sha256).to_lower():
			return {"id": str(body.id), "message": ""}
	fallback.message = "The remembered reference is unavailable or has changed. Showing the female reference."
	return fallback


func remember(body: Dictionary) -> void:
	var record := {"schema_version": 1, "body_id": str(body.get("id", "")), "source_sha256": str(body.get("sha256", "")).to_lower()}
	if valid(record):
		current = record


func save() -> String:
	if not enabled or current.is_empty():
		return ""
	if not valid(current):
		return "The startup reference could not be saved."
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return "The startup reference could not be saved."
	file.store_string(JSON.stringify(current, "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(path + ".tmp", path)
	return "" if error == OK else "The startup reference could not be saved."
