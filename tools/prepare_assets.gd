extends SceneTree
## Prepare source geometry once; normal launches reuse the local compiled scenes.

const AnatomyModel = preload("res://scripts/anatomy_model.gd")


func _initialize() -> void:
	call_deferred("prepare")


func prepare() -> void:
	var catalogue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	var model := AnatomyModel.new()
	root.add_child(model)
	for body in catalogue.bodies:
		var error: String = model.load_body(body)
		if not error.is_empty():
			push_error(error)
			model.free()
			quit(1)
			return
		print("Prepared ", body.id, ": ", model.meshes.size(), " meshes in %.2fs" % model.load_seconds)
		await process_frame
	model.clear_body()
	model.free()
	quit()
