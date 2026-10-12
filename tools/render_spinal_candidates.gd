extends SceneTree
## Developer source-frame inspection; does not alter the viewer catalogue or sources.

var candidate_folder := ""


func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--candidates="):
			candidate_folder = argument.trim_prefix("--candidates=")
	call_deferred("run")


func collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)
	if node is CollisionObject3D:
		node.collision_layer = 0
	for child in node.get_children():
		collect_meshes(child, result)


func world_bounds(meshes: Array[MeshInstance3D]) -> AABB:
	var bounds := AABB()
	for index in meshes.size():
		var box: AABB = meshes[index].global_transform * meshes[index].get_aabb()
		bounds = box if index == 0 else bounds.merge(box)
	return bounds


func tint(meshes: Array[MeshInstance3D], color: Color) -> void:
	for mesh in meshes:
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.8
		if color.a < 1:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh.material_override = material


func run() -> void:
	if candidate_folder.is_empty() or DisplayServer.get_name() == "headless":
		push_error("Specify --candidates=/folder and use a desktop display")
		quit(1)
		return
	var inventory: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/audit/hra-spinal-candidates.json"))
	var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	var output := {"engine": Engine.get_version_info().string, "inspection": "Source coordinates preserved; display colours/skin opacity modified. Registration and medical review pending.", "references": []}
	for sex in ["female", "male"]:
		var world := Node3D.new()
		root.add_child(world)
		var skin: MeshInstance3D
		var body: Dictionary
		for reference in pack.bodies:
			if reference.id == sex:
				body = reference
		var cache_path := "res://assets/prepared/%s-%s.scn" % [sex, str(body.sha256).left(12)]
		var packed := load(cache_path) as PackedScene
		if packed == null or FileAccess.get_sha256("res://" + str(body.asset_path)) != body.sha256:
			push_error("Prepare/verify the pinned HRA reference before source-frame inspection")
			quit(1)
			return
		var context := packed.instantiate() as Node3D
		world.add_child(context)
		var context_meshes: Array[MeshInstance3D] = []
		collect_meshes(context, context_meshes)
		for mesh in context_meshes:
			mesh.visible = mesh.name.to_lower().ends_with("_skin")
			if mesh.visible:
				skin = mesh
		if skin == null:
			push_error("Source skin is unavailable")
			quit(1)
			return
		tint([skin], Color(0.5, 0.65, 0.75, 0.09))
		var candidate_meshes: Array[MeshInstance3D] = []
		var records: Array[Dictionary] = []
		for record in inventory.records:
			if not str(record.root_name).begins_with("VH_F_" if sex == "female" else "VH_M_"):
				continue
			var path := candidate_folder.path_join(str(record.source_path).get_file())
			if FileAccess.get_sha256(path) != record.sha256:
				push_error("Candidate geometry differs from the audited source")
				quit(1)
				return
			var document := GLTFDocument.new()
			var state := GLTFState.new()
			if document.append_from_file(path, state) != OK:
				quit(1)
				return
			var scene := document.generate_scene(state)
			world.add_child(scene)
			var meshes: Array[MeshInstance3D] = []
			collect_meshes(scene, meshes)
			var bounds := world_bounds(meshes)
			var low: Array = record.declared_position_bounds.min
			var high: Array = record.declared_position_bounds.max
			var expected := AABB(Vector3(low[0], low[1], low[2]), Vector3(high[0] - low[0], high[1] - low[1], high[2] - low[2]))
			var triangles := 0
			for mesh in meshes:
				for surface in mesh.mesh.get_surface_count():
					var indices: int = mesh.mesh.surface_get_array_index_len(surface)
					triangles += int((indices if indices else mesh.mesh.surface_get_array_len(surface)) / 3)
			if meshes.size() != record.anatomy_mesh_nodes or triangles != record.anatomy_triangles or not bounds.is_equal_approx(expected):
				push_error("Rendered source geometry disagrees with the declared inventory")
				quit(1)
				return
			tint(meshes, Color("e6ddbb") if "vertebrae" in record.root_name else Color("d97562"))
			for mesh in meshes:
				if mesh.name == "VH_F_lumbar_vertebra_6":
					tint([mesh], Color("f6ba59"))
			candidate_meshes.append_array(meshes)
			records.append({"root": record.root_name, "sha256": record.sha256, "meshes": meshes.size(), "triangles": triangles,
				"engine_bounds_min": [bounds.position.x, bounds.position.y, bounds.position.z],
				"engine_bounds_max": [bounds.end.x, bounds.end.y, bounds.end.z]})
		var environment := WorldEnvironment.new()
		environment.environment = Environment.new()
		environment.environment.background_mode = Environment.BG_COLOR
		environment.environment.background_color = Color("0b1522")
		environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color = Color.WHITE
		environment.environment.ambient_light_energy = 0.65
		world.add_child(environment)
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-20, 145, 0)
		world.add_child(light)
		var camera := Camera3D.new()
		camera.fov = 38
		camera.near = 0.002
		world.add_child(camera)
		var bounds := world_bounds(candidate_meshes)
		camera.position = bounds.get_center() + Vector3(0, 0, -bounds.size.length() * 1.8)
		camera.look_at(bounds.get_center(), Vector3.UP)
		var caption := Label.new()
		caption.position = Vector2(24, 20)
		caption.add_theme_font_size_override("font_size", 20)
		caption.text = "HRA %s v1.2 spinal candidates in v1.1 source coordinates\nSupplied positions unchanged · cream vertebrae / coral cord · faint skin context\nRegistration and qualified anatomy review pending" % sex
		if sex == "female":
			caption.text += "\nGold: source node lumbar_vertebra_6 lacks label/ontology; interpretation unresolved"
		root.add_child(caption)
		var credit := Label.new()
		credit.position = Vector2(24, 820)
		credit.add_theme_font_size_override("font_size", 15)
		credit.text = "HuBMAP / Human Reference Atlas · CC BY 4.0 · inspection colours/skin transparency modified\nhttps://github.com/hubmapconsortium/ccf-3d-reference-object-library\nhttps://creativecommons.org/licenses/by/4.0/"
		root.add_child(credit)
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var name := "hra-%s-spinal-candidates.png" % sex
		if image.save_png("/tmp/medicine-viewer-feasibility/" + name) != OK:
			quit(1)
			return
		output.references.append({"sex": sex, "context_hash": body.sha256, "candidates": records, "capture": name})
		print("PASS source-frame candidate rendering: ", sex)
		caption.queue_free()
		credit.queue_free()
		world.queue_free()
		await process_frame
	var file := FileAccess.open("/tmp/medicine-viewer-feasibility/spinal-candidates-engine.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "\t", true, true))
	file.close()
	quit()
