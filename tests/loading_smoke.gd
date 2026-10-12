extends SceneTree
## Real prepared scenes, failed replacements, and input during asynchronous loads.

var failures: Array[String] = []
var heartbeat := 0
var observed_stages: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func watch_load(viewer, id: String, inject_input: bool = false) -> void:
	heartbeat = 0
	viewer.switch_body(id)
	check(viewer.loading and viewer.loading_row.visible and not viewer.orbit.input_enabled,
		"The replacement displays progress and suspends camera input immediately")
	var injected := false
	while viewer.loading:
		heartbeat += 1
		if inject_input and viewer.model.loading and not injected:
			injected = true
			var overlap: String = await viewer.model.load_body(viewer.pack.bodies[0])
			check(not overlap.is_empty(), "A concurrent model replacement is rejected")
			var key := InputEventKey.new()
			key.pressed = true
			key.keycode = KEY_Z
			key.ctrl_pressed = true
			root.push_input(key)
			key = InputEventKey.new()
			key.pressed = true
			key.keycode = KEY_ESCAPE
			root.push_input(key)
			var wheel := InputEventMouseButton.new()
			wheel.button_index = MOUSE_BUTTON_WHEEL_UP
			wheel.pressed = true
			wheel.position = Vector2(viewer.viewport.size) / 2.0
			viewer.viewport.push_input(wheel, true)
			viewer.restore_selected()
			viewer.focus_selection()
			viewer.tree_items["anatomy.lungs"].select(0)
			viewer.on_tree_selected()
			check(viewer.tree.get_selected().get_metadata(0) == viewer.model.selected_id,
				"A paused tree selection stays aligned with the retained body")
			viewer.parts_items["anatomy.heart.valve.aortic"].select(0)
			viewer.on_part_selected()
			check(viewer.parts_tree.get_selected().get_metadata(0) == viewer.model.selected_id,
				"A paused part selection stays aligned with the retained body")
		await process_frame
	check(not viewer.model.loading and not viewer.loading_row.visible and viewer.orbit.input_enabled,
		"Loading controls return to normal after success or failure")
	check(not viewer.labels_button.disabled and viewer.label_density.editable,
		"Label controls become editable after loading")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	check(viewer.model.body.get("id") == "female" and viewer.model.load_wait_frames > 2,
		"Initial real anatomy loading yields process frames")
	viewer.model.load_progress.connect(func(stage: String, fraction: float):
		if not observed_stages.has(stage):
			observed_stages.append(stage)
		check(fraction == -1.0 or (fraction >= 0.0 and fraction <= 1.0), "Step progress stays within its declared range"))
	viewer.chest_view()
	viewer.select_structure("anatomy.heart.valve.mitral")
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.03, 0.01, 0))
	viewer.model.set_visibility("anatomy.heart.valve.mitral", "faded")
	viewer.model.undo()
	viewer.inspect_alone()
	viewer.move_button.button_pressed = true
	viewer.orbit.move_mode = true
	viewer.scene_container.grab_focus()
	var before: Dictionary = viewer.export_view_state()
	var history: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var old_scene: Node3D = viewer.model.source_scene
	var original_references: Array = viewer.pack.bodies.duplicate(true)
	for fault in ["missing_file", "changed_hash", "missing_root", "declared_nonmesh"]:
		viewer.pack.bodies = original_references.duplicate(true)
		var broken: Dictionary = viewer.pack.bodies[1]
		match fault:
			"missing_file":
				broken.asset_path = "assets/missing-loading-test.glb"
			"changed_hash":
				broken.sha256 = "0".repeat(64)
			"missing_root":
				broken.root_id = "missing.root"
			"declared_nonmesh":
				for concept in broken.structures:
					if concept.id == broken.root_id:
						# This node exists, but is a group: previously caught after clear_body.
						concept.mesh_nodes.append(concept.source_node)
		await watch_load(viewer, "male", fault != "missing_file")
		check(viewer.export_view_state() == before and viewer.model.source_scene == old_scene,
			fault + ": failed replacement preserves exact current scene, edits, camera, labels and isolation")
		check(viewer.back_views == history and viewer.forward_views == forward and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo,
			fault + ": failed replacement preserves both navigation and inspection history")
		check(viewer.orbit.move_mode and viewer.move_button.button_pressed,
			fault + ": rejected input does not exit the prior Move mode")
		check(viewer.body_choice.get_item_metadata(viewer.body_choice.selected) == "female" and not viewer.body_choice.disabled,
			fault + ": selector returns to the retained reference")
		check(viewer.model.staged_scene == null and viewer.model.hash_worker == null,
			fault + ": failed replacement releases staging and verification worker")
	viewer.pack.bodies = original_references
	for id in ["male", "bodyparts-male-bones-study", "female"]:
		await watch_load(viewer, id)
		check(heartbeat > 2 and viewer.model.load_wait_frames > 2,
			id + ": real replacement allows UI frame processing while loading")
		check(viewer.model.body.id == id and viewer.model.meshes.size() == (203 if id == "bodyparts-male-bones-study" else (788 if id == "male" else 801)),
			id + ": asynchronous loading retains all audited geometry")
		check(not viewer.orbit.move_mode and viewer.model.undo_stack.is_empty(),
			id + ": a successful reference switch starts its own inspection history")
		print("PASS responsive load: %s; watcher frames %d; loader yields %d" % [id, heartbeat, viewer.model.load_wait_frames])
	for stage in ["Checking source file", "Loading anatomy", "Preparing view", "Checking anatomy", "Preparing selection", "Opening reference"]:
		check(observed_stages.has(stage), "Progress reports the actual loading step: " + stage)
	# Free a live verifier before it completes: its reader is joined without touching anatomy.
	var model = load("res://scripts/anatomy_model.gd").new()
	root.add_child(model)
	model.load_body(original_references[0])
	check(model.hash_worker != null, "Shutdown test starts the real source reader")
	model.free()
	viewer.queue_free()
	await process_frame
	print("Responsive loading failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
