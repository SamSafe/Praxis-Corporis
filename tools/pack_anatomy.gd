extends SceneTree
const ContentBundle = preload("res://scripts/content_bundle.gd")
## Write only the pinned source data and prepared geometry into the content package.


func _initialize() -> void:
	var output := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output = argument.trim_prefix("--output=")
	if output.is_empty():
		push_error("Specify -- --output=/absolute/path/anatomy.pck")
		quit(1)
		return
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/source_manifest.json"))
	manifest.files.append_array(ContentBundle.supplemental_files())
	var packer := PCKPacker.new()
	if packer.pck_start(output) != OK:
		push_error("Could not create anatomy package")
		quit(1)
		return
	for record in manifest.files:
		var path := "res://" + str(record.local_path)
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != record.sha256:
			push_error("Pinned source missing or modified: " + path)
			quit(1)
			return
		if packer.add_file(path, path) != OK:
			push_error("Could not pack " + path)
			quit(1)
			return
		if record.has("body_id"):
			var prepared := ContentBundle.prepared_scene_path(record.body_id, record.sha256)
			if not FileAccess.file_exists(prepared) or packer.add_file(prepared, prepared) != OK:
				push_error("Prepared geometry missing; run tools/prepare_assets.gd first: " + prepared)
				quit(1)
				return
	if packer.flush() != OK:
		push_error("Could not finish anatomy package")
		quit(1)
		return
	print("Anatomy package complete: ", output)
	quit()
