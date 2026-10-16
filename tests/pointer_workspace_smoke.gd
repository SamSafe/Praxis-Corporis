extends SceneTree

const Verification = preload("res://scripts/study_verification.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	for reference in viewer.pack.bodies:
		await viewer.switch_body(reference.id)
		var id: String = reference.get("qa_leaf_id", "anatomy.heart.valve.mitral")
		if reference.id == "bodyparts-male-bones-study":
			id = "source.bodyparts3d-v4-male.FJ3365"
		viewer.select_structure(id)
		viewer.inspect_alone()
		if not await Verification.verify_pointer_interruption(viewer):
			quit(1)
			return
	viewer.queue_free()
	await process_frame
	print("Pointer workspace failures: 0")
	quit()
