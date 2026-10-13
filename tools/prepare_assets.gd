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
		# Migrate a pinned local cache without repeating the expensive raw GLB import.
		var cache_error := migrate_geometry_cache(body, model)
		if not cache_error.is_empty():
			push_error(cache_error)
			model.free()
			quit(1)
			return
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


func migrate_geometry_cache(record: Dictionary, model: Node3D) -> String:
	var target := ContentBundle.prepared_scene_path(record.id, record.sha256)
	var legacy := "res://assets/prepared/%s-%s.scn" % [record.id, str(record.sha256).left(12)]
	if FileAccess.file_exists(target) or not FileAccess.file_exists(legacy):
		return ""
	if FileAccess.get_sha256("res://" + str(record.asset_path)) != record.sha256:
		return "Pinned source differs while preparing geometry: " + str(record.id)
	var packed := ResourceLoader.load(legacy, "PackedScene") as PackedScene
	if packed == null:
		return "Could not read the prior local cache: " + legacy
	var instance := packed.instantiate()
	var scene := instance as Node3D
	if scene == null:
		instance.free()
		return "The prior cache is not a 3D scene."
	if scene.get_meta("source_sha256", "") != record.sha256 or scene.get_meta("engine", "") != Engine.get_version_info().string:
		scene.free()
		return "" # A fresh source import will create the current cache.
	var mapping := {}
	model.index_cached_nodes(scene, mapping)
	var error: String = model.validate_scene(record, mapping, scene)
	if not error.is_empty():
		scene.free()
		return error
	for node in mapping.values():
		if node is MeshInstance3D:
			var collider: Node = node.get_node_or_null("InspectionCollider")
			if collider != null:
				collider.free()
	scene.set_meta("prepared_geometry_version", ContentBundle.PREPARED_GEOMETRY_VERSION)
	var geometry := PackedScene.new()
	var save_error := geometry.pack(scene)
	if save_error == OK:
		save_error = ResourceSaver.save(geometry, target)
	scene.free()
	if save_error != OK:
		return "Could not prepare geometry-only cache (Godot error %d)." % save_error
	print("Prepared geometry-only cache: ", record.id)
	return ""
