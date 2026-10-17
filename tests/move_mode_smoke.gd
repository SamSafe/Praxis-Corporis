extends SceneTree

const Verification = preload("res://scripts/study_verification.gd")
var failures := 0


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	for reference in viewer.pack.bodies:
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		var leaf: String = reference.get("qa_leaf_id", "anatomy.heart.valve.mitral")
		if reference.id == "bodyparts-male-bones-study":
			leaf = "source.bodyparts3d-v4-male.FJ3365"
		viewer.select_structure(leaf)
		viewer.inspect_alone()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.01, 0.02, 0))
		if not await Verification.verify_move_mode_boundary(viewer):
			failures += 1
	viewer.queue_free()
	await process_frame
	print("Move mode failures: ", failures)
	quit(0 if failures == 0 else 1)
