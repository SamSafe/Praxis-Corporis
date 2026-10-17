extends SceneTree

const Verification = preload("res://scripts/scene_render_verification.gd")


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
		if not await Verification.run(viewer, "--render-scene-check" in OS.get_cmdline_user_args()):
			failures += 1
	viewer.queue_free()
	await process_frame
	print("Scene render failures: ", failures)
	quit(0 if failures == 0 else 1)
