extends RefCounted
## Local export identity for observations; it is not review or signing evidence.

const RESOURCE_PATH := "res://content/build_identity.json"
const MAX_BYTES := 4096


static func hex_value(value: Variant, length: int) -> bool:
	return value is String and value.length() == length and value == value.to_lower() and value.is_valid_hex_number(false)


static func valid(data: Variant) -> bool:
	if not data is Dictionary or data.size() != 8 or data.get("schema_version") != 1 or data.get("channel") != "private":
		return false
	if not hex_value(data.get("build_id"), 32) or not hex_value(data.get("source_revision"), 40) or not hex_value(data.get("source_snapshot_sha256"), 64):
		return false
	for key in ["application_version", "engine", "content_pack"]:
		if not data.get(key) is String or data[key].is_empty() or data[key].length() > 128 or "\n" in data[key] or "\r" in data[key]:
			return false
	return true


static func read(expected_pack: String, path: String = RESOURCE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not valid(parser.data) or parser.data.content_pack != expected_pack:
		return {}
	return parser.data


static func describe(expected_pack: String) -> String:
	var identity := read(expected_pack)
	var runtime := "Runtime: Godot %s · %s" % [Engine.get_version_info().string, OS.get_name()]
	if identity.is_empty():
		var kind := "Development checkout" if OS.has_feature("editor") else "Unrecorded export"
		return "%s · build identity unavailable\n%s\nContent pack: %s" % [kind, runtime, expected_pack]
	return "Praxis Corporis %s · private\nBuild ID: %s\nSource revision: %s\nSource inputs SHA-256: %s\nRecorded engine: %s\n%s\nContent pack: %s" % [
		identity.application_version, identity.build_id, identity.source_revision,
		identity.source_snapshot_sha256, identity.engine, runtime, identity.content_pack]
