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
	var catalogue_hashes := {}
	for body in ContentBundle.catalogue().bodies:
		catalogue_hashes[str(body.id)] = str(body.sha256)
	var packer := PCKPacker.new()
	if packer.pck_start(output) != OK:
		push_error("Could not create anatomy package")
		quit(1)
		return
	for source_record in manifest.files:
		# A supplemented body (United v1.1 plus later HRA organs) ships its derived file;
		# the catalogue, prepared scenes and runtime checks all use that file's hash.
		var record: Dictionary = source_record.duplicate()
		if record.has("supplemented_path"):
			record.local_path = record.supplemented_path
			record.sha256 = record.supplemented_sha256
		if record.has("body_id") and catalogue_hashes.get(str(record.body_id), record.sha256) != record.sha256:
			push_error("Packaged body differs from the catalogue the app loads: " + str(record.body_id))
			quit(1)
			return
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
			var prepared := ContentBundle.prepared_files(record.body_id, record.sha256)
			if prepared.is_empty():
				push_error("Prepared picking groups missing; run tools/prepare_assets.gd first.")
				quit(1)
				return
			for file in prepared:
				if not FileAccess.file_exists(file) or packer.add_file(file, file) != OK:
					push_error("Prepared anatomy missing; run tools/prepare_assets.gd first: " + file)
					quit(1)
					return
	if packer.flush() != OK:
		push_error("Could not finish anatomy package")
		quit(1)
		return
	print("Anatomy package complete: ", output)
	quit()
