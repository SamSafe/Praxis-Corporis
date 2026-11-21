extends SceneTree
## Optional rendered look check: saves whole-body, chest and heart views for visual review.
## Requires a desktop display. Usage: godot --path . --script tests/capture_look.gd -- <output-dir> [female|male]

var output := "/tmp/praxis-look"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		output = args[0]
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("capture", args[1] if args.size() > 1 else "female")


func save_image(name: String) -> void:
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	var path := output.path_join(name + ".png")
	if root.get_texture().get_image().save_png(path) != OK:
		push_error("Screenshot failed: " + path)
	print("Screenshot: ", path)


func capture(body: String) -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	if body != viewer.model.body.get("id", ""):
		viewer.switch_body(body)
		await process_frame
		while viewer.loading:
			await process_frame
	if viewer.model.body.is_empty():
		push_error("Could not load reference")
		quit(1)
		return
	viewer.whole_body()
	await save_image(body + "-1-whole")
	viewer.chest_view()
	await save_image(body + "-2-chest")
	viewer.inspect_alone("anatomy.heart")
	await save_image(body + "-3-heart")
	viewer.whole_body()
	viewer.inspect_alone(viewer.study_content.structure_id("anatomy.brain", viewer.model.structures))
	await save_image(body + "-4-brain")
	viewer.whole_body()
	viewer.inspect_alone(viewer.study_content.structure_id("anatomy.knee", viewer.model.structures))
	await save_image(body + "-5-knee")
	viewer.whole_body()
	viewer.inspect_alone(viewer.study_content.structure_id("anatomy.eyes", viewer.model.structures))
	await save_image(body + "-6-eyes")
	viewer.whole_body()
	viewer.peel_skin()
	await save_image(body + "-7-peeled")
	quit(0)
