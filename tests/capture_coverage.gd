extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	root.size = Vector2i(1100, 720)
	await process_frame
	var coverage: Window = viewer.show_coverage()
	if coverage == null:
		push_error("Coverage unavailable")
		quit(1)
		return
	coverage.system_list.select(1)
	coverage.show_system(1)
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/coverage-skeleton.png")
	coverage.queue_free()
	viewer.queue_free()
	await process_frame
	print("PASS rendered coverage capture" if result == OK else "Coverage capture failed")
	quit(0 if result == OK else 1)
