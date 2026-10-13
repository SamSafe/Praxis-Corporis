extends SceneTree
## Reject incompatible or incomplete picking groups without replacing the real body.

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
const PreparedSelection = preload("res://scripts/prepared_selection.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var record: Dictionary = ContentBundle.catalogue().bodies[0]
	var model := AnatomyModel.new()
	root.add_child(model)
	var initial: String = await model.load_body(record)
	check(initial.is_empty(), "The real reference loads before fault injection")
	if not initial.is_empty():
		model.free()
		quit(1)
		return
	model.select("anatomy.heart.valve.mitral")
	model.checkpoint()
	model.offset_selection(Vector3(0.02, 0.01, 0.0))
	model.set_visibility(model.selected_id, "faded")
	var original_scene := model.source_scene
	var original_states := model.states.duplicate(true)
	var original_undo := model.undo_stack.duplicate(true)
	var original_selected := model.selected_id
	var source_batch := load(ContentBundle.selection_batch_path(record.id, record.sha256, 0)) as PreparedSelection
	for fault in ["missing_manifest", "missing_batch", "wrong_engine", "wrong_source", "unknown_node", "duplicate_node", "missing_meshes"]:
		var broken := record.duplicate(true)
		broken.id = "qa-selection-%d-%s" % [Time.get_ticks_usec(), fault]
		var geometry := ContentBundle.prepared_scene_path(broken.id, broken.sha256)
		var manifest_path := ContentBundle.selection_manifest_path(broken.id, broken.sha256)
		var batch_path := ContentBundle.selection_batch_path(broken.id, broken.sha256, 0)
		check(DirAccess.copy_absolute(ContentBundle.prepared_scene_path(record.id, record.sha256), geometry) == OK,
			"Create an independent geometry fixture")
		if fault != "missing_manifest":
			var manifest := {"schema_version": 1, "reference_id": broken.id, "source_sha256": record.sha256,
				"engine": "wrong-engine" if fault == "wrong_engine" else Engine.get_version_info().string, "batch_count": 1}
			var file := FileAccess.open(manifest_path, FileAccess.WRITE)
			file.store_string(JSON.stringify(manifest))
			file.close()
			var batch := PreparedSelection.new()
			batch.source_sha256 = "0".repeat(64) if fault == "wrong_source" else record.sha256
			batch.engine = Engine.get_version_info().string
			batch.mesh_nodes = PackedInt32Array([source_batch.mesh_nodes[0]])
			batch.shapes.append(source_batch.shapes[0])
			if fault == "unknown_node":
				batch.mesh_nodes[0] = -777
			elif fault == "duplicate_node":
				batch.mesh_nodes.append(batch.mesh_nodes[0])
				batch.shapes.append(batch.shapes[0])
			check(ResourceSaver.save(batch, batch_path) == OK, "Create an independent picking fixture")
			if fault == "missing_batch":
				check(DirAccess.remove_absolute(batch_path) == OK, "Remove only the independent picking fixture")
		var error: String = await model.load_body(broken)
		check(not error.is_empty(), fault + ": incompatible/incomplete picking groups are rejected")
		check(model.source_scene == original_scene and model.body.id == record.id and model.states == original_states
			and model.undo_stack == original_undo and model.selected_id == original_selected,
			fault + ": exact current geometry and inspection state survive rejection")
		check(model.staged_scene == null and model.hash_worker == null and not model.loading,
			fault + ": staging and source verification are released")
		for path in [geometry, manifest_path, batch_path]:
			if FileAccess.file_exists(path):
				check(DirAccess.remove_absolute(path) == OK, "Remove only the independent test fixture")
	model.free()
	print("Prepared selection rejection failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
