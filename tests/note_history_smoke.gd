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
	var failures := 0
	for reference in viewer.pack.bodies:
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		if not await Verification.verify_note_history(viewer):
			failures += 1
	viewer.queue_free()
	await process_frame
	print("Note history failures: ", failures)
	quit(0 if failures == 0 else 1)
