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
	for id in ["female", "male"]:
		if viewer.model.body.id != id:
			await viewer.switch_body(id)
		viewer.select_structure("anatomy.heart.valve.mitral")
		viewer.inspect_alone()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.01, 0, 0))
		if not await Verification.verify_study_navigation(viewer):
			failures += 1
	viewer.queue_free()
	await process_frame
	print("Study navigation failures: ", failures)
	quit(0 if failures == 0 else 1)
