extends RefCounted
## Local bookmark storage. Failed reads/writes never replace the in-memory library.

const MAX_VIEWS := 200
const MAX_BYTES := 32 * 1024 * 1024
const MAX_NOTE_CHARACTERS := 10000
var path := "user://saved_views.json"
var entries: Array[Dictionary] = []
var read_error := ""
var loaded_hash := ""


func read_file(file_path: String) -> Dictionary:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {"error": "Saved views could not be read. The file has been kept unchanged."}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("views") is Array or parsed.views.size() > MAX_VIEWS:
		return {"error": "Saved views have an unsupported or damaged format. The file has been kept unchanged."}
	var ids := {}
	var names := {}
	var loaded: Array[Dictionary] = []
	for entry in parsed.views:
		if not entry is Dictionary or not entry.get("id") is String or entry.id.length() != 32 or not entry.id.is_valid_hex_number(false):
			return {"error": "Saved views contain an invalid identifier. The file has been kept unchanged."}
		if not entry.get("name") is String or not name_format(entry.name).is_empty() or not entry.get("state") is Dictionary:
			return {"error": "Saved views contain invalid names or view data. The file has been kept unchanged."}
		if not (entry.get("created_unix") is int or entry.get("created_unix") is float) or not is_finite(float(entry.created_unix)) or entry.created_unix < 0 or entry.created_unix > 253402300799 or floorf(float(entry.created_unix)) != entry.created_unix:
			return {"error": "Saved views contain an invalid date. The file has been kept unchanged."}
		if not notes_format(entry.get("notes", "")).is_empty():
			return {"error": "Saved views contain invalid study notes. The file has been kept unchanged."}
		if ids.has(entry.id) or names.has(entry.name.to_lower()):
			return {"error": "Saved views contain duplicate names or identifiers. The file has been kept unchanged."}
		ids[entry.id] = true
		names[entry.name.to_lower()] = true
		loaded.append(entry.duplicate(true))
	return {"error": "", "entries": loaded}


func load_library() -> String:
	if not FileAccess.file_exists(path):
		read_error = "Saved views are missing, but a previous library is available." if FileAccess.file_exists(path + ".bak") else ""
		if read_error.is_empty():
			entries.clear()
			loaded_hash = ""
		return read_error
	var result := read_file(path)
	read_error = result.error
	if read_error.is_empty():
		entries.assign(result.entries)
		loaded_hash = FileAccess.get_sha256(path)
	return read_error


func name_format(value: String) -> String:
	if value != value.strip_edges() or value.is_empty() or value.length() > 80:
		return "Use a name of 1–80 characters without surrounding spaces."
	for character in value:
		if character.unicode_at(0) < 32 or character.unicode_at(0) == 127:
			return "Use a single-line name."
	return ""


func valid_name(value: String, except_id: String = "") -> String:
	var error := name_format(value)
	if not error.is_empty():
		return error
	for entry in entries:
		if entry.id != except_id and entry.name.to_lower() == value.to_lower():
			return "That name is already used. Choose another name."
	return ""


func persist(next_entries: Array[Dictionary], keep_backup: bool = true) -> String:
	var current_hash := FileAccess.get_sha256(path) if FileAccess.file_exists(path) else ""
	if keep_backup and current_hash != loaded_hash:
		return "Saved views changed elsewhere. Close and reopen Saved views before editing."
	var text := JSON.stringify({"schema_version": 1, "views": next_entries}, "\t", true, true)
	if text.to_utf8_buffer().size() > MAX_BYTES:
		return "The saved-view library is too large to write."
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return "Could not write saved views."
	file.store_string(text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return "Could not finish writing saved views."
	if keep_backup and FileAccess.file_exists(path):
		if DirAccess.copy_absolute(path, path + ".bak.tmp") != OK or DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak") != OK:
			return "Could not keep the previous saved-view library. No views were changed."
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		# Some platforms may remove an old destination before a failed rename.
		if not FileAccess.file_exists(path) and FileAccess.file_exists(path + ".bak"):
			DirAccess.copy_absolute(path + ".bak", path)
		return "Could not replace saved views. The previous library is retained."
	entries = next_entries.duplicate(true)
	loaded_hash = FileAccess.get_sha256(path)
	return ""


func add_view(name: String, state: Dictionary) -> String:
	if not read_error.is_empty():
		return read_error
	var error := valid_name(name)
	if not error.is_empty():
		return error
	if entries.size() >= MAX_VIEWS:
		return "This library holds up to 200 views. Delete a view before saving another."
	var next := entries.duplicate(true)
	next.push_front({"id": Crypto.new().generate_random_bytes(16).hex_encode(), "name": name,
		"created_unix": int(Time.get_unix_time_from_system()), "state": state.duplicate(true), "notes": ""})
	return persist(next)


func rename_view(id: String, name: String) -> String:
	if not read_error.is_empty():
		return read_error
	var error := valid_name(name, id)
	if not error.is_empty():
		return error
	var next := entries.duplicate(true)
	for entry in next:
		if entry.id == id:
			entry.name = name
			return persist(next)
	return "That saved view is no longer available."


func notes_format(value: Variant) -> String:
	if not value is String or value.length() > MAX_NOTE_CHARACTERS:
		return "Study notes can contain up to 10,000 characters."
	for character in value:
		var code: int = character.unicode_at(0)
		if (code < 32 and code not in [9, 10, 13]) or code == 127:
			return "Study notes contain an unsupported control character."
	return ""


func set_notes(id: String, notes: String) -> String:
	return update_notes({id: notes})


func update_notes(updates: Dictionary) -> String:
	# All draft notes are written together; view snapshots and names remain intact.
	if not read_error.is_empty():
		return read_error
	var next := entries.duplicate(true)
	for id in updates:
		var error := notes_format(updates[id])
		if not error.is_empty():
			return error
		var found := false
		for entry in next:
			if entry.id == id:
				entry.notes = updates[id]
				found = true
		if not found:
			return "That saved view is no longer available."
	if updates.is_empty():
		return ""
	return persist(next)


func delete_view(id: String) -> String:
	if not read_error.is_empty():
		return read_error
	var next := entries.duplicate(true)
	for index in next.size():
		if next[index].id == id:
			next.remove_at(index)
			return persist(next)
	return "That saved view is no longer available."


func can_recover() -> bool:
	return FileAccess.file_exists(path + ".bak") and read_file(path + ".bak").error.is_empty()


func recover_backup() -> String:
	var result := read_file(path + ".bak")
	if not result.error.is_empty():
		return "The previous library is unavailable or invalid."
	if FileAccess.file_exists(path) and DirAccess.copy_absolute(path, path + ".damaged") != OK:
		return "Could not preserve the damaged library. Recovery was cancelled."
	var recovered: Array[Dictionary] = []
	recovered.assign(result.entries)
	var error := persist(recovered, false)
	if error.is_empty():
		read_error = ""
	return error


func export_library(destination: String) -> String:
	if not read_error.is_empty():
		return read_error
	if not destination.to_lower().ends_with(".json"):
		return "Choose a JSON file for your saved views."
	var absolute := ProjectSettings.globalize_path(destination).simplify_path()
	for suffix in ["", ".bak", ".tmp", ".damaged"]:
		if absolute == ProjectSettings.globalize_path(path + suffix).simplify_path():
			return "Choose a file outside the active saved-view library."
	var temporary := destination + "." + Crypto.new().generate_random_bytes(16).hex_encode() + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "Could not open the export file."
	file.store_string(JSON.stringify({"schema_version": 1, "views": entries}, "\t", true, true))
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(temporary, destination)
	if FileAccess.file_exists(temporary):
		DirAccess.remove_absolute(temporary)
	return "" if error == OK else "Could not finish exporting saved views."


static func same_snapshot(a: Variant, b: Variant) -> bool:
	if (a is int or a is float) and (b is int or b is float):
		return absf(float(a) - float(b)) <= 1e-12
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for key in a:
			if not b.has(key) or not same_snapshot(a[key], b[key]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for index in a.size():
			if not same_snapshot(a[index], b[index]):
				return false
		return true
	return a == b


func preview_import(source: String, validate_state: Callable) -> Dictionary:
	if not read_error.is_empty():
		return {"error": read_error}
	var incoming := read_file(source)
	if not incoming.error.is_empty():
		return incoming
	var next := entries.duplicate(true)
	var lines: Array[String] = []
	var imported := 0
	var skipped := 0
	for entry in incoming.entries:
		var error: String = validate_state.call(entry.state)
		if not error.is_empty():
			lines.append("Skip “%s”: %s" % [entry.name, error])
			skipped += 1
			continue
		var identical := false
		for existing in entries:
			if existing.id == entry.id and same_snapshot(existing.state, entry.state) and existing.get("notes", "") == entry.get("notes", ""):
				identical = true
		if identical:
			lines.append("Already present: “%s”" % entry.name)
			skipped += 1
			continue
		var copy: Dictionary = entry.duplicate(true)
		var names := {}
		var ids := {}
		for existing in next:
			names[existing.name.to_lower()] = true
			ids[existing.id] = true
		var number := 2
		while names.has(copy.name.to_lower()):
			var suffix := " (%d)" % number
			copy.name = str(entry.name).left(80 - suffix.length()) + suffix
			number += 1
		while ids.has(copy.id):
			copy.id = Crypto.new().generate_random_bytes(16).hex_encode()
		next.append(copy)
		lines.append("Import “%s”%s" % [copy.name, " (renamed to keep both views)" if copy.name != entry.name else ""])
		imported += 1
	if next.size() > MAX_VIEWS:
		return {"error": "This import would exceed 200 views. Delete some views or use a smaller export."}
	return {"error": "", "entries": next, "imported": imported, "skipped": skipped,
		"summary": "\n".join(lines), "library_hash": loaded_hash}


func apply_import(plan: Dictionary, validate_state: Callable) -> String:
	if not read_error.is_empty():
		return read_error
	if plan.get("library_hash") != loaded_hash or not plan.get("entries") is Array or plan.get("imported", 0) < 1:
		return "Open the import preview again before importing."
	# Recheck every added snapshot before the single atomic library write.
	var next: Array[Dictionary] = []
	for entry in plan.entries:
		if next.size() >= entries.size():
			var error: String = validate_state.call(entry.state)
			if not error.is_empty():
				return error
		next.append(entry.duplicate(true))
	return persist(next)
