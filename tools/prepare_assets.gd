extends SceneTree
## Prepare source geometry once; normal launches reuse the local compiled scenes.

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")


func _initialize() -> void:
	call_deferred("prepare")


func prepare() -> void:
	var catalogue := ContentBundle.catalogue()
	var model := AnatomyModel.new()
	root.add_child(model)
	for body in catalogue.bodies:
		var error: String = await model.load_body(body)
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
