extends Node3D
## One physical mesh state per source node, shared by all ancestor selections.

signal state_changed

const SourceIndexExtension = preload("res://scripts/source_index_extension.gd")

var body: Dictionary = {}
var structures: Dictionary = {}
var meshes: Dictionary = {}
var baseline: Dictionary = {}
var baseline_world: Dictionary = {}
var states: Dictionary = {}
var materials: Dictionary = {}
var colliders: Dictionary = {}
var selected_id := ""
var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []
var original_ghosts: Dictionary = {}
var show_original_positions := true
var ghost_material: StandardMaterial3D
var source_scene: Node3D
var load_seconds := 0.0


func load_body(record: Dictionary) -> String:
	var path := "res://" + str(record.asset_path)
	if not FileAccess.file_exists(path):
		if OS.has_feature("template"):
			return "Anatomy is missing from this build. Re-extract the application together with anatomy.pck."
		return "Anatomy files are missing. Run python3 tools/fetch_assets.py, then reopen the viewer."
	if FileAccess.get_sha256(path) != str(record.sha256):
		return "The anatomy file differs from the pinned sample. Run the asset verification tool."
	var started := Time.get_ticks_msec()
	print("Importing ", record.id, " reference")
	var cache_path := "res://assets/prepared/%s-%s.scn" % [record.id, str(record.sha256).left(12)]
	var next_scene: Node3D
	var node_map := {}
	var from_cache := false
	if FileAccess.file_exists(cache_path):
		var cached := ResourceLoader.load(cache_path, "PackedScene") as PackedScene
		if cached:
			next_scene = cached.instantiate() as Node3D
			if next_scene.get_meta("source_sha256", "") == record.sha256 and next_scene.get_meta("engine", "") == Engine.get_version_info().string:
				index_cached_nodes(next_scene, node_map)
				from_cache = true
			else:
				next_scene.free()
				next_scene = null
	if not from_cache:
		if OS.has_feature("template"):
			return "Prepared anatomy does not match this application version. Re-extract the complete private build."
		var extension := SourceIndexExtension.new()
		GLTFDocument.register_gltf_document_extension(extension, true)
		var document := GLTFDocument.new()
		var gltf := GLTFState.new()
		gltf.handle_binary_image_mode = GLTFState.HANDLE_BINARY_IMAGE_MODE_EMBED_AS_UNCOMPRESSED
		var error := document.append_from_file(path, gltf)
		if error != OK:
			GLTFDocument.unregister_gltf_document_extension(extension)
			return "Could not read anatomy file (Godot error %d)." % error
		print("glTF parsed after %.2fs" % ((Time.get_ticks_msec() - started) / 1000.0))
		next_scene = document.generate_scene(gltf) as Node3D
		GLTFDocument.unregister_gltf_document_extension(extension)
		if next_scene:
			index_cached_nodes(next_scene, node_map)
	print("glTF scene generated after %.2fs" % ((Time.get_ticks_msec() - started) / 1000.0))
	if next_scene == null:
		return "The anatomy file did not produce a 3D scene."
	# Validate mappings before replacing the current body.
	for concept in record.structures:
		if not node_map.has(int(concept.source_node)):
			next_scene.free()
			return "The catalogue does not match imported node %d (%s)." % [concept.source_node, concept.source_name]
	clear_body()
	body = record
	source_scene = next_scene
	add_child(source_scene)
	# Only the anatomy root is retained. Sampling-site roots are never rendered/picked.
	var anatomy_root_index := 0
	for concept in record.structures:
		structures[str(concept.id)] = concept
		if concept.id == record.root_id:
			anatomy_root_index = int(concept.source_node)
	var anatomy_root: Node = node_map[anatomy_root_index]
	for child in source_scene.get_children():
		if child != anatomy_root:
			child.free()
	for index in structures[str(record.root_id)].mesh_nodes:
		var mesh := node_map[int(index)] as MeshInstance3D
		if mesh == null:
			clear_body()
			return "A declared mesh is missing from the imported scene."
		meshes[int(index)] = mesh
		baseline[int(index)] = mesh.transform
		baseline_world[int(index)] = mesh.global_transform
		states[int(index)] = {"visibility": "visible", "offset": Vector3.ZERO}
		var overrides: Array[StandardMaterial3D] = []
		for surface in mesh.mesh.get_surface_count():
			var source_material := mesh.get_active_material(surface) as StandardMaterial3D
			var material := source_material.duplicate() as StandardMaterial3D if source_material else StandardMaterial3D.new()
			material.roughness = maxf(material.roughness, 0.6)
			overrides.append(material)
		materials[int(index)] = overrides
		var collider := mesh.get_node_or_null("InspectionCollider") as StaticBody3D
		if collider == null:
			collider = StaticBody3D.new()
			collider.name = "InspectionCollider"
			collider.collision_layer = 1
			collider.collision_mask = 0
			collider.set_meta("mesh_index", int(index))
			var shape := CollisionShape3D.new()
			shape.shape = mesh.mesh.create_trimesh_shape()
			collider.add_child(shape)
			mesh.add_child(collider)
		colliders[int(index)] = collider
		if meshes.size() % 200 == 0:
			print("Prepared %d mesh nodes after %.2fs" % [meshes.size(), (Time.get_ticks_msec() - started) / 1000.0])
	if not from_cache:
		source_scene.set_meta("source_sha256", record.sha256)
		source_scene.set_meta("engine", Engine.get_version_info().string)
		assign_cache_owners(source_scene)
		var packed := PackedScene.new()
		if packed.pack(source_scene) == OK:
			var cache_error := ResourceSaver.save(packed, cache_path)
			if cache_error != OK:
				push_warning("Could not save the local geometry cache; next load will import again.")
	load_seconds = (Time.get_ticks_msec() - started) / 1000.0
	state_changed.emit()
	return ""


func index_cached_nodes(node: Node, mapping: Dictionary) -> void:
	if node.has_meta("source_index"):
		mapping[int(node.get_meta("source_index"))] = node
	for child in node.get_children():
		index_cached_nodes(child, mapping)


func assign_cache_owners(node: Node) -> void:
	for child in node.get_children():
		child.owner = source_scene
		assign_cache_owners(child)


func clear_body() -> void:
	if is_instance_valid(source_scene):
		remove_child(source_scene)
		source_scene.free()
	source_scene = null
	structures.clear()
	meshes.clear()
	baseline.clear()
	baseline_world.clear()
	states.clear()
	materials.clear()
	colliders.clear()
	undo_stack.clear()
	redo_stack.clear()
	for ghost in original_ghosts.values():
		ghost.free()
	original_ghosts.clear()
	selected_id = ""
	body = {}


func bounds_for(id: String) -> AABB:
	var bounds := AABB()
	var first := true
	if not structures.has(id):
		return bounds
	for index in structures[id].mesh_nodes:
		var mesh: MeshInstance3D = meshes[int(index)]
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds


func select(id: String) -> void:
	selected_id = id if structures.has(id) else ""
	refresh_appearance()
	state_changed.emit()


func refresh_appearance() -> void:
	var highlighted := {}
	if structures.has(selected_id):
		for index in structures[selected_id].mesh_nodes:
			highlighted[int(index)] = true
	for index in meshes:
		var mesh: MeshInstance3D = meshes[index]
		var visibility: String = states[index].visibility
		mesh.visible = visibility != "hidden"
		# Faded anatomy is intentionally click-through, to reach structures behind it.
		colliders[index].collision_layer = 1 if visibility == "visible" else 0
		mesh.transform = baseline[index]
		mesh.position += states[index].offset
		var is_highlighted := highlighted.has(index)
		for surface in mesh.mesh.get_surface_count():
			var material: StandardMaterial3D = materials[index][surface]
			var original := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
			material.albedo_color = original.albedo_color if original else Color(0.7, 0.65, 0.6)
			if structures.has("anatomy.skin") and index == int(structures["anatomy.skin"].source_node):
				material.albedo_color = Color("b8a493")
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if visibility == "faded" else BaseMaterial3D.TRANSPARENCY_DISABLED
			material.albedo_color.a = 0.14 if visibility == "faded" else 1.0
			material.emission_enabled = is_highlighted
			if is_highlighted:
				material.albedo_color = Color(0.97, 0.63, 0.29, material.albedo_color.a)
				material.emission = Color(0.18, 0.075, 0.015)
			mesh.set_surface_override_material(surface, material)
		refresh_original_ghost(index)


func refresh_original_ghost(index: int) -> void:
	var show: bool = show_original_positions and states[index].offset != Vector3.ZERO and states[index].visibility != "hidden"
	if show and not original_ghosts.has(index):
		if ghost_material == null:
			ghost_material = StandardMaterial3D.new()
			ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ghost_material.albedo_color = Color(0.24, 0.76, 0.84, 0.18)
		var ghost := MeshInstance3D.new()
		ghost.name = "OriginalPosition_%d" % index
		ghost.mesh = meshes[index].mesh
		ghost.material_override = ghost_material
		ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# No collision or source index: an inspection overlay is never anatomy to pick.
		add_child(ghost)
		ghost.global_transform = baseline_world[index]
		original_ghosts[index] = ghost
	if original_ghosts.has(index):
		original_ghosts[index].visible = show


func checkpoint() -> void:
	redo_stack.clear()
	undo_stack.append(states.duplicate(true))
	if undo_stack.size() > 40:
		undo_stack.pop_front()


func set_visibility(id: String, visibility: String) -> void:
	if not structures.has(id) or visibility not in ["visible", "hidden", "faded"]:
		return
	checkpoint()
	for index in structures[id].mesh_nodes:
		states[int(index)].visibility = visibility
	refresh_appearance()
	state_changed.emit()


func offset_selection(delta: Vector3) -> void:
	if not structures.has(selected_id):
		return
	for index in structures[selected_id].mesh_nodes:
		states[int(index)].offset = (states[int(index)].offset + delta).clamp(Vector3.ONE * -10.0, Vector3.ONE * 10.0)
	refresh_appearance()
	state_changed.emit()


func restore(id: String = "anatomy.body") -> void:
	if not structures.has(id):
		return
	checkpoint()
	for index in structures[id].mesh_nodes:
		states[int(index)] = {"visibility": "visible", "offset": Vector3.ZERO}
	refresh_appearance()
	state_changed.emit()


func undo() -> void:
	if undo_stack.is_empty():
		return
	redo_stack.append(states.duplicate(true))
	states = undo_stack.pop_back()
	refresh_appearance()
	state_changed.emit()


func redo() -> void:
	if redo_stack.is_empty():
		return
	undo_stack.append(states.duplicate(true))
	states = redo_stack.pop_back()
	refresh_appearance()
	state_changed.emit()


func pick(camera: Camera3D, position: Vector2) -> String:
	var hit := ray_hit(camera, position)
	if hit.is_empty():
		return ""
	var index: int = hit.collider.get_meta("mesh_index")
	for id in structures:
		if int(structures[id].source_node) == index:
			return id
	return ""


func ray_hit(camera: Camera3D, position: Vector2) -> Dictionary:
	var origin := camera.project_ray_origin(position)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + camera.project_ray_normal(position) * 30.0, 1)
	return get_world_3d().direct_space_state.intersect_ray(query)


func export_state() -> Dictionary:
	var changes := {}
	for id in structures:
		var index := int(structures[id].source_node)
		if not states.has(index):
			continue
		var state: Dictionary = states[index]
		var offset: Vector3 = state.offset
		if state.visibility != "visible" or offset != Vector3.ZERO:
			changes[id] = {"visibility": state.visibility, "offset": [offset.x, offset.y, offset.z]}
	return changes


func apply_saved_state(changes: Dictionary) -> String:
	# Validate every change first; a malformed file must not partly alter the body.
	var validation := validate_saved_changes(changes, body)
	if not validation.is_empty():
		return validation
	var next := states.duplicate(true)
	for index in next:
		next[index] = {"visibility": "visible", "offset": Vector3.ZERO}
	for id in changes:
		var index := int(structures[id].source_node)
		var change: Dictionary = changes[id]
		var offset: Array = change.offset
		next[index] = {"visibility": change.visibility, "offset": Vector3(float(offset[0]), float(offset[1]), float(offset[2]))}
	checkpoint()
	states = next
	refresh_appearance()
	state_changed.emit()
	return ""


func validate_saved_changes(changes: Dictionary, reference: Dictionary) -> String:
	var available := {}
	for structure in reference.structures:
		available[str(structure.id)] = structure
	for id in changes:
		if not available.has(id):
			return "Saved view refers to anatomy missing from this sample pack."
		var structure: Dictionary = available[id]
		if not structure.mesh_nodes.has(structure.source_node) or not changes[id] is Dictionary:
			return "Saved view contains an invalid mesh state."
		var change: Dictionary = changes[id]
		var offset = change.get("offset")
		if change.get("visibility") not in ["visible", "hidden", "faded"] or not offset is Array or offset.size() != 3:
			return "Saved view contains an invalid visibility or displacement."
		for coordinate in offset:
			if not (coordinate is float or coordinate is int) or not is_finite(float(coordinate)) or absf(float(coordinate)) > 10.0:
				return "Saved displacement is outside the supported inspection range."
	return ""
