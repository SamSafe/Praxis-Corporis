extends SceneTree
## Precision regression: tiny source triangles must remain pickable in metre coordinates.

const Model = preload("res://scripts/anatomy_model.gd")
const Orbit = preload("res://scripts/orbit_camera.gd")
const Labels = preload("res://scripts/anatomy_labels.gd")
const Content = preload("res://scripts/content_bundle.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var world := SubViewport.new()
	world.size = Vector2i(800, 650)
	world.own_world_3d = true
	root.add_child(world)
	var model := Model.new()
	world.add_child(model)
	var orbit := Orbit.new()
	world.add_child(orbit)
	var labels := Labels.new()
	labels.model = model
	labels.camera = orbit.camera
	world.add_child(labels)
	labels.size = Vector2(world.size)
	for reference in Content.catalogue().bodies:
		if reference.get("study_kind") != "hra-spinal":
			continue
		check((await model.load_body(reference)).is_empty(), "Load normalized picking resources")
		var maximum_error := 0.0
		for index in model.meshes:
			var holder: CollisionShape3D = model.colliders[index].get_child(0)
			var faces: PackedVector3Array = model.meshes[index].mesh.get_faces()
			var recovered: PackedVector3Array = holder.transform * holder.shape.get_faces()
			check(recovered.size() == faces.size(), "Picking retains every source triangle")
			for vertex in range(0, faces.size(), 97):
				maximum_error = maxf(maximum_error, recovered[vertex].distance_to(faces[vertex]))
		check(maximum_error <= 0.0000001, "Inverse picking normalization preserves source faces within 0.1 micrometre")
		for id in [reference.root_id, reference.qa_leaf_id]:
			model.select(id)
			model.set_isolation(id)
			orbit.focus(model.bounds_for(id))
			await physics_frame
			await physics_frame
			var hits := 0
			var wrong_hits := 0
			var allowed := {}
			for node_index in model.structures[id].mesh_nodes:
				allowed[int(node_index)] = true
			for y in range(50, 650, 50):
				for x in range(50, 800, 50):
					var hit := model.ray_hit(orbit.camera, Vector2(x, y))
					if not hit.is_empty():
						wrong_hits += int(not allowed.has(int(hit.collider.get_meta("mesh_index"))))
						hits += 1
			check(hits > 0, "Small source surfaces accept actual physics rays")
			check(wrong_hits == 0, "Ray hits belong to the selected source geometry")
			labels.update_labels()
			check(labels.visible_ids.has(id), "Source surfaces have a first-hit label anchor")
		print("PASS normalized spinal picking: ", reference.id, " · maximum sampled source-face error ", maximum_error, " m")
	world.queue_free()
	await process_frame
	print("Spinal picking failures: ", failures)
	quit(0 if failures == 0 else 1)
