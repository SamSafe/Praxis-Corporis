extends Node3D
## One physical mesh state per source node, shared by all ancestor selections.

signal state_changed
signal load_progress(stage: String, fraction: float)

const SourceIndexExtension = preload("res://scripts/source_index_extension.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
const PreparedSelection = preload("res://scripts/prepared_selection.gd")

var body: Dictionary = {}
var structures: Dictionary = {}
var meshes: Dictionary = {}
var baseline: Dictionary = {}
var baseline_world: Dictionary = {}
var states: Dictionary = {}
var materials: Dictionary = {}
var colliders: Dictionary = {}
var selected_id := ""
var isolated_id := ""
var isolated_meshes: Dictionary = {}
var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []
var original_ghosts: Dictionary = {}
var show_original_positions := true
var ghost_material: StandardMaterial3D
var source_scene: Node3D
var load_seconds := 0.0
var loading := false
var load_wait_frames := 0
var resource_operation_intervals_ms: Dictionary = {}
var prepared_selection_batches := 0
var preparing_cache := false # Explicit offline preparation; ordinary launches require compiled picking shapes.
var hash_worker: Thread
var staged_scene: Node3D


func _exit_tree() -> void:
	# A worker only reads a file. Join before releasing its owning object.
	if hash_worker != null and hash_worker.is_started():
		hash_worker.wait_to_finish()
	if is_instance_valid(staged_scene):
		staged_scene.free()
	staged_scene = null


static func source_hash(path: String) -> String:
	return FileAccess.get_sha256(path)


func load_body(record: Dictionary) -> String:
	if loading:
		return "A reference is already loading."
	loading = true
	var error: String = await prepare_body(record)
	loading = false
	return error


func prepare_body(record: Dictionary) -> String:
	var started := Time.get_ticks_msec()
	resource_operation_intervals_ms.clear()
	prepared_selection_batches = 0
	var wait_frames := 0
	var path := "res://" + str(record.asset_path)
	if not FileAccess.file_exists(path):
		if OS.has_feature("template"):
			return "Anatomy is missing from this build. Re-extract the application together with anatomy.pck."
		return "Anatomy files are missing. Run python3 tools/fetch_assets.py, then reopen the viewer."
	load_progress.emit("Checking source file", -1.0)
	hash_worker = Thread.new()
	if hash_worker.start(source_hash.bind(path)) != OK:
		hash_worker = null
		return "Could not start source verification. Try loading the reference again."
	while hash_worker.is_alive():
		await get_tree().process_frame
		wait_frames += 1
	var actual_hash: String = hash_worker.wait_to_finish()
	hash_worker = null
	if actual_hash != str(record.sha256):
		if OS.has_feature("template"):
			return "Anatomy differs from the expected reference. Re-extract the complete private build."
		return "The anatomy file differs from the pinned sample. Run the asset verification tool."
	print("Loading ", record.id, " reference")
	var cache_path := ContentBundle.prepared_scene_path(record.id, record.sha256)
	var next_scene: Node3D
	var node_map := {}
	var from_cache := false
	if FileAccess.file_exists(cache_path):
		load_progress.emit("Loading anatomy", 0.0)
		var operation_started := Time.get_ticks_usec()
		var request_error := ResourceLoader.load_threaded_request(cache_path, "PackedScene", false)
		record_resource_operation("request", operation_started)
		if request_error != OK:
			return "Could not start reading prepared anatomy (Godot error %d)." % request_error
		var progress := []
		operation_started = Time.get_ticks_usec()
		var resource_status := ResourceLoader.load_threaded_get_status(cache_path, progress)
		record_resource_operation("status", operation_started)
		while resource_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			load_progress.emit("Loading anatomy", float(progress[0]) if not progress.is_empty() else 0.0)
			await get_tree().process_frame
			wait_frames += 1
			operation_started = Time.get_ticks_usec()
			resource_status = ResourceLoader.load_threaded_get_status(cache_path, progress)
			record_resource_operation("status", operation_started)
		if resource_status != ResourceLoader.THREAD_LOAD_LOADED:
			return "Prepared anatomy could not be read. Re-prepare the source or re-extract the complete private build."
		# This call is nonblocking only after THREAD_LOAD_LOADED.
		operation_started = Time.get_ticks_usec()
		var cached := ResourceLoader.load_threaded_get(cache_path) as PackedScene
		record_resource_operation("collect", operation_started)
		load_progress.emit("Preparing view", -1.0)
		await get_tree().process_frame
		wait_frames += 1
		if cached:
			operation_started = Time.get_ticks_usec()
			var instance := cached.instantiate()
			record_resource_operation("instantiate", operation_started)
			next_scene = instance as Node3D
			if next_scene == null:
				instance.free()
			elif next_scene.get_meta("source_sha256", "") == record.sha256 and next_scene.get_meta("engine", "") == Engine.get_version_info().string and next_scene.get_meta("prepared_geometry_version", 0) == ContentBundle.PREPARED_GEOMETRY_VERSION:
				staged_scene = next_scene
				operation_started = Time.get_ticks_usec()
				index_cached_nodes(next_scene, node_map)
				record_resource_operation("index", operation_started)
				from_cache = true
			else:
				next_scene.free()
				next_scene = null
	if not from_cache:
		if OS.has_feature("template"):
			return "Prepared anatomy does not match this application version. Re-extract the complete private build."
		# The first development import remains an offline preparation step.
		load_progress.emit("Preparing source geometry — first import may take several minutes", -1.0)
		await get_tree().process_frame
		wait_frames += 1
		var extension := SourceIndexExtension.new()
		GLTFDocument.register_gltf_document_extension(extension, true)
		var document := GLTFDocument.new()
		var gltf := GLTFState.new()
		gltf.handle_binary_image_mode = GLTFState.HANDLE_BINARY_IMAGE_MODE_EMBED_AS_UNCOMPRESSED
		var error := document.append_from_file(path, gltf)
		if error != OK:
			GLTFDocument.unregister_gltf_document_extension(extension)
			return "Could not read anatomy file (Godot error %d)." % error
		next_scene = document.generate_scene(gltf) as Node3D
		GLTFDocument.unregister_gltf_document_extension(extension)
		if next_scene:
			staged_scene = next_scene
			index_cached_nodes(next_scene, node_map)
	if next_scene == null:
		return "The anatomy file did not produce a 3D scene."
	load_progress.emit("Checking anatomy", -1.0)
	var mapping_error := validate_scene(record, node_map, next_scene)
	if not mapping_error.is_empty():
		next_scene.free()
		staged_scene = null
		return mapping_error
	var next_structures := {}
	for concept in record.structures:
		next_structures[str(concept.id)] = concept
	var root_record: Dictionary = next_structures[str(record.root_id)]
	var anatomy_root: Node = node_map[int(root_record.source_node)]
	# Sampling-site roots are removed only from the staged scene.
	for child in next_scene.get_children():
		if child != anatomy_root:
			child.free()
	var next_materials := {}
	var next_colliders := {}
	var next_shapes := {}
	if not preparing_cache:
		var selection: Dictionary = await load_prepared_selection(record, root_record)
		if selection.has("error"):
			next_scene.free()
			staged_scene = null
			return selection.error
		next_shapes = selection.shapes
		wait_frames += selection.yield_frames
	load_progress.emit("Preparing selection", 0.0)
	var selection_batch_started := Time.get_ticks_usec()
	for index in root_record.mesh_nodes:
		var mesh: MeshInstance3D = node_map[int(index)]
		var overrides: Array[StandardMaterial3D] = []
		for surface in mesh.mesh.get_surface_count():
			var source_material := mesh.get_active_material(surface) as StandardMaterial3D
			var material := source_material.duplicate() as StandardMaterial3D if source_material else StandardMaterial3D.new()
			material.roughness = maxf(material.roughness, 0.6)
			overrides.append(material)
		next_materials[int(index)] = overrides
		var collider := mesh.get_node_or_null("InspectionCollider") as StaticBody3D
		if collider == null:
			collider = StaticBody3D.new()
			collider.name = "InspectionCollider"
			collider.collision_layer = 1
			collider.collision_mask = 0
			collider.set_meta("mesh_index", int(index))
			var shape := CollisionShape3D.new()
			shape.shape = mesh.mesh.create_trimesh_shape() if preparing_cache else next_shapes[int(index)]
			collider.add_child(shape)
			mesh.add_child(collider)
		next_colliders[int(index)] = collider
		# Bound work between yields; one mesh remains an indivisible geometry operation.
		if Time.get_ticks_usec() - selection_batch_started >= 8000 or next_materials.size() % 40 == 0:
			load_progress.emit("Preparing selection", float(next_materials.size()) / root_record.mesh_nodes.size())
			await get_tree().process_frame
			wait_frames += 1
			selection_batch_started = Time.get_ticks_usec()
	# No fallible mapping or preparation step remains before replacing the old scene.
	load_progress.emit("Opening reference", -1.0)
	clear_body()
	body = record
	source_scene = next_scene
	staged_scene = null
	add_child(source_scene)
	structures = next_structures
	materials = next_materials
	colliders = next_colliders
	for index in root_record.mesh_nodes:
		var mesh: MeshInstance3D = node_map[int(index)]
		meshes[int(index)] = mesh
		baseline[int(index)] = mesh.transform
		baseline_world[int(index)] = mesh.global_transform
		states[int(index)] = {"visibility": "visible", "offset": Vector3.ZERO}
	if not from_cache:
		source_scene.set_meta("source_sha256", record.sha256)
		source_scene.set_meta("engine", Engine.get_version_info().string)
		source_scene.set_meta("prepared_geometry_version", ContentBundle.PREPARED_GEOMETRY_VERSION)
		assign_cache_owners(source_scene)
		var packed := PackedScene.new()
		if packed.pack(source_scene) == OK:
			var cache_error := ResourceSaver.save(packed, cache_path)
			if cache_error != OK:
				push_warning("Could not save the local geometry cache; next load will import again.")
	load_seconds = (Time.get_ticks_msec() - started) / 1000.0
	load_wait_frames = wait_frames
	print("Prepared %d meshes in %.2fs; %d frames while loading" % [meshes.size(), load_seconds, wait_frames])
	state_changed.emit()
	return ""


func record_resource_operation(operation: String, started_usec: int) -> void:
	# Measures time inside each call, including synchronization; not isolated CPU/GPU cost.
	if not resource_operation_intervals_ms.has(operation):
		resource_operation_intervals_ms[operation] = []
	resource_operation_intervals_ms[operation].append((Time.get_ticks_usec() - started_usec) / 1000.0)


func load_prepared_selection(record: Dictionary, root_record: Dictionary) -> Dictionary:
	var count := ContentBundle.selection_batch_count(record.id, record.sha256)
	if count == 0 or count > root_record.mesh_nodes.size():
		return {"error": "Prepared picking shapes are missing or incompatible. Re-extract the complete private build or run the source preparation tool."}
	var expected := {}
	for index in root_record.mesh_nodes:
		expected[int(index)] = true
	var shapes := {}
	var yield_frames := 0
	for batch_index in count:
		load_progress.emit("Loading selection", float(batch_index) / count)
		var path := ContentBundle.selection_batch_path(record.id, record.sha256, batch_index)
		if not FileAccess.file_exists(path):
			return {"error": "Prepared picking shapes are missing. Re-extract the complete private build or run the source preparation tool."}
		var started := Time.get_ticks_usec()
		var error := ResourceLoader.load_threaded_request(path, "Resource", false)
		record_resource_operation("request", started)
		if error != OK:
			return {"error": "Could not read prepared picking shapes. Re-extract the complete private build or run the source preparation tool."}
		var status := ResourceLoader.THREAD_LOAD_IN_PROGRESS
		while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Yield before each poll so queued shape initialization is spread across groups.
			await get_tree().process_frame
			yield_frames += 1
			started = Time.get_ticks_usec()
			status = ResourceLoader.load_threaded_get_status(path)
			record_resource_operation("status", started)
		if status != ResourceLoader.THREAD_LOAD_LOADED:
			return {"error": "Prepared picking shapes could not be read. Re-extract the complete private build or run the source preparation tool."}
		started = Time.get_ticks_usec()
		var batch := ResourceLoader.load_threaded_get(path) as PreparedSelection
		record_resource_operation("collect", started)
		if batch == null or batch.source_sha256 != record.sha256 or batch.engine != Engine.get_version_info().string or batch.mesh_nodes.is_empty() or batch.mesh_nodes.size() != batch.shapes.size():
			return {"error": "Prepared picking shapes do not match the source reference."}
		for i in batch.mesh_nodes.size():
			var index: int = batch.mesh_nodes[i]
			if not expected.has(index) or shapes.has(index) or not batch.shapes[i] is ConcavePolygonShape3D:
				return {"error": "Prepared picking shapes do not match the source mesh catalogue."}
			shapes[index] = batch.shapes[i]
		prepared_selection_batches += 1
	if shapes.size() != expected.size():
		return {"error": "Prepared picking shapes omit source meshes."}
	return {"shapes": shapes, "yield_frames": yield_frames}


func validate_scene(record: Dictionary, mapping: Dictionary, scene: Node3D) -> String:
	var root_record := {}
	for concept in record.structures:
		if not mapping.has(int(concept.source_node)):
			return "The catalogue does not match imported node %d (%s)." % [concept.source_node, concept.source_name]
		if concept.id == record.root_id:
			root_record = concept
	if root_record.is_empty():
		return "The catalogue does not declare its anatomy root."
	var anatomy_root: Node = mapping[int(root_record.source_node)]
	if anatomy_root.get_parent() != scene:
		return "The declared anatomy root is outside the expected source hierarchy."
	for concept in record.structures:
		var source_node: Node = mapping[int(concept.source_node)]
		if source_node != anatomy_root and not anatomy_root.is_ancestor_of(source_node):
			return "A catalogue structure is outside the anatomy root."
		for index in concept.mesh_nodes:
			var mesh := mapping.get(int(index)) as MeshInstance3D
			if mesh == null or mesh.mesh == null or not root_record.mesh_nodes.has(index):
				return "A declared mesh is missing from the imported anatomy."
			if mesh != anatomy_root and not anatomy_root.is_ancestor_of(mesh):
				return "A declared mesh is outside the anatomy root."
	return ""


func index_cached_nodes(node: Node, mapping: Dictionary) -> void:
	if node.has_meta("source_index"):
		mapping[int(node.get_meta("source_index"))] = node
	for child in node.get_children():
		index_cached_nodes(child, mapping)


func assign_cache_owners(node: Node) -> void:
	for child in node.get_children():
		if child.name == "InspectionCollider":
			# Runtime picking shapes are rebuilt in batches instead of loaded as one resource burst.
			child.owner = null
			for shape in child.get_children():
				shape.owner = null
		else:
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
	isolated_id = ""
	isolated_meshes.clear()
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


func set_isolation(id: String) -> bool:
	if not id.is_empty() and (not structures.has(id) or structures[id].mesh_nodes.is_empty()):
		return false
	isolated_id = id
	isolated_meshes.clear()
	if not id.is_empty():
		for index in structures[id].mesh_nodes:
			isolated_meshes[int(index)] = true
	refresh_appearance()
	state_changed.emit()
	return true


func effective_visibility(index: int) -> String:
	# A temporary view mask reveals a supplied selection without editing inspection
	# states. Baseline geometry, saved displacements and undo history are untouched.
	if not isolated_id.is_empty():
		return "visible" if isolated_meshes.has(index) else "hidden"
	return states[index].visibility


func refresh_appearance() -> void:
	var highlighted := {}
	if structures.has(selected_id):
		for index in structures[selected_id].mesh_nodes:
			highlighted[int(index)] = true
	for index in meshes:
		var mesh: MeshInstance3D = meshes[index]
		var visibility := effective_visibility(index)
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
	var show: bool = show_original_positions and states[index].offset != Vector3.ZERO and effective_visibility(index) != "hidden"
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
