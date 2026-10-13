extends SceneTree
## Compare migrated caches with prior source geometry and every runtime picking shape.

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var model := AnatomyModel.new()
	root.add_child(model)
	for record in ContentBundle.catalogue().bodies:
		var legacy_path := "res://assets/prepared/%s-%s.scn" % [record.id, str(record.sha256).left(12)]
		var legacy_resource := load(legacy_path) as PackedScene
		var geometry_resource := load(ContentBundle.prepared_scene_path(record.id, record.sha256)) as PackedScene
		check(legacy_resource != null and geometry_resource != null, "Both cache generations exist for comparison")
		if legacy_resource == null or geometry_resource == null:
			continue
		var legacy := legacy_resource.instantiate() as Node3D
		var geometry := geometry_resource.instantiate() as Node3D
		var before := {}
		var after := {}
		model.index_cached_nodes(legacy, before)
		model.index_cached_nodes(geometry, after)
		check(before.size() == after.size(), "Migration preserves all indexed source nodes")
		for index in before:
			check(after.has(index), "Migration preserves source node identity")
			if not after.has(index):
				continue
			var original: Node3D = before[index]
			var migrated: Node3D = after[index]
			check(original.name == migrated.name and original.transform == migrated.transform,
				"Source names and transforms remain exact")
			check(original.get_parent().name == migrated.get_parent().name, "Source hierarchy remains exact")
			if original is MeshInstance3D:
				var old_mesh := original as MeshInstance3D
				var new_mesh := migrated as MeshInstance3D
				check(new_mesh != null and new_mesh.get_node_or_null("InspectionCollider") == null,
					"Geometry cache excludes runtime picking nodes")
				check(old_mesh.mesh.get_surface_count() == new_mesh.mesh.get_surface_count(), "Surface count stays exact")
				for surface in old_mesh.mesh.get_surface_count():
					check(old_mesh.mesh.surface_get_arrays(surface) == new_mesh.mesh.surface_get_arrays(surface),
						"Vertices, normals, indices and other surface arrays remain exact")
					var old_material := old_mesh.mesh.surface_get_material(surface) as StandardMaterial3D
					var new_material := new_mesh.mesh.surface_get_material(surface) as StandardMaterial3D
					check((old_material == null and new_material == null) or (old_material != null and new_material != null
						and old_material.albedo_color == new_material.albedo_color and old_material.roughness == new_material.roughness
						and old_material.metallic == new_material.metallic and old_material.cull_mode == new_material.cull_mode),
						"Source material appearance stays exact")
		var error: String = await model.load_body(record)
		check(error.is_empty(), "Runtime loads the migrated source: " + error)
		if error.is_empty():
			for index in model.meshes:
				var mesh: MeshInstance3D = model.meshes[index]
				var old_mesh: MeshInstance3D = before[index]
				var shape := model.colliders[index].get_child(0) as CollisionShape3D
				var old_shape := old_mesh.get_node("InspectionCollider").get_child(0) as CollisionShape3D
				check(shape.shape is ConcavePolygonShape3D and shape.shape.get_faces() == old_shape.shape.get_faces(),
					"Runtime picking faces match the prior cache exactly")
			# Exercise the fresh-import saving path as well as migration from a prior cache.
			model.assign_cache_owners(model.source_scene)
			var repacked := PackedScene.new()
			check(repacked.pack(model.source_scene) == OK, "Runtime scene can be packed as geometry only")
			var saved_scene := repacked.instantiate() as Node3D
			var saved_mapping := {}
			model.index_cached_nodes(saved_scene, saved_mapping)
			for index in model.meshes:
				check(saved_mapping[index].get_node_or_null("InspectionCollider") == null,
					"Fresh-import caches exclude every runtime picking shape")
			saved_scene.free()
			print("PASS exact migrated geometry and picking: ", record.id, " / ", model.meshes.size(), " meshes")
		legacy.free()
		geometry.free()
	model.free()
	print("Prepared geometry failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
