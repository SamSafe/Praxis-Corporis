@tool
extends EditorPlugin

var anatomy_export: EditorExportPlugin


class AnatomyExport extends EditorExportPlugin:
	const ContentBundle = preload("res://scripts/content_bundle.gd")
	func _get_name() -> String:
		return "PraxisPrivateAnatomy"

	func _export_begin(features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
		if not features.has("macos"):
			return
		var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/source_manifest.json"))
		manifest.files.append_array(ContentBundle.supplemental_files())
		for record in manifest.files:
			var source := "res://" + str(record.local_path)
			if not FileAccess.file_exists(source) or FileAccess.get_sha256(source) != record.sha256:
				push_error("Pinned anatomy unavailable during Mac export: " + source)
				return
			add_file(source, FileAccess.get_file_as_bytes(source), false)
			if record.has("body_id"):
				var prepared := ContentBundle.prepared_scene_path(record.body_id, record.sha256)
				if not FileAccess.file_exists(prepared):
					push_error("Prepared anatomy unavailable during Mac export: " + prepared)
					return
				add_file(prepared, FileAccess.get_file_as_bytes(prepared), false)


func _enter_tree() -> void:
	anatomy_export = AnatomyExport.new()
	add_export_plugin(anatomy_export)


func _exit_tree() -> void:
	remove_export_plugin(anatomy_export)
