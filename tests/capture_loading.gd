extends SceneTree
## Render a real replacement while the prior heart inspection remains in view.


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	viewer.chest_view()
	viewer.inspect_alone()
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.02, 0, 0))
	var before: Dictionary = viewer.current_view()
	var edits: Dictionary = viewer.model.export_state()
	await physics_frame
	await physics_frame
	await RenderingServer.frame_post_draw
	viewer.switch_body("male")
	while viewer.loading and not viewer.loading_stage.text.begins_with("Loading anatomy"):
		await process_frame
	if not viewer.loading:
		push_error("Load finished before the real progress view could be captured")
		quit(1)
		return
	await RenderingServer.frame_post_draw
	var preserved: bool = viewer.current_view() == before and viewer.model.export_state() == edits
	var image := root.get_texture().get_image()
	var error := image.save_png("res://docs/prototype/loading-reference.png")
	while viewer.loading:
		await process_frame
	if not preserved or error != OK or viewer.model.body.get("id") != "male":
		push_error("Loading capture or preserved source view check failed")
		quit(1)
		return
	print("PASS rendered loading step with prior inspection preserved")
	viewer.queue_free()
	await process_frame
	quit()
