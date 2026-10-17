extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")


func _initialize() -> void:
	var prefix := "user://draft-export-limit-" + Crypto.new().generate_random_bytes(16).hex_encode()
	var library := SavedViews.new()
	library.path = prefix + ".json"
	var id := "0123456789abcdef0123456789abcdef"
	library.entries.append({"id": id, "name": "Large valid snapshot", "created_unix": 1,
		"state": {"opaque": "x".repeat(SavedViews.MAX_BYTES - 20000)}, "notes": "Saved note"})
	var base := JSON.stringify({"schema_version": 1, "views": library.entries}, "\t", true, true)
	var note := "🫀".repeat(SavedViews.MAX_NOTE_CHARACTERS)
	var destination := prefix + "-export.json"
	var file := FileAccess.open(destination, FileAccess.WRITE)
	file.store_string("Keep this existing export")
	file.close()
	var original := FileAccess.get_file_as_bytes(destination)
	var error := library.export_library(destination, {id: note})
	var valid := base.to_utf8_buffer().size() <= SavedViews.MAX_BYTES and library.notes_format(note).is_empty()
	valid = valid and "size limit" in error and FileAccess.get_file_as_bytes(destination) == original
	valid = valid and library.entries[0].notes == "Saved note" and not FileAccess.file_exists(library.path)
	DirAccess.remove_absolute(destination)
	print("Draft export size-limit failures: ", 0 if valid else 1)
	quit(0 if valid else 1)
