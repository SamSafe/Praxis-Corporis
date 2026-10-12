extends SceneTree

const RenderProfile = preload("res://scripts/render_profile.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	await viewer.switch_body("bodyparts-male-bones-study")
	viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
	viewer.inspect_alone()
	root.size = Vector2i(1100, 720)
	await process_frame
	await RenderingServer.frame_post_draw
	var before: Dictionary = viewer.model.export_state()
	var profiler := RenderProfile.new()
	var config := {"seconds": 1.0, "warmup_seconds": 0.25, "repetitions": 1, "window_pixels": [1100, 720]}
	var report := {"scenes": []}
	create_timer(0.6).timeout.connect(func(): root.size = Vector2i(1120, 720))
	var completed: bool = await profiler.append_sample(report, viewer, "dimension-change fixture", config, 1)
	check(not completed and report.has("error") and report.scenes.is_empty(), "A resized scene cannot be appended as a completed measurement")
	check(report.has("interrupted_scene") and report.interrupted_scene.has("raw_frame_intervals_ms"), "The interrupted sample retains its raw diagnostic intervals")
	check(viewer.model.export_state() == before, "Sampling/rejection leaves source anatomy unchanged")
	viewer.queue_free()
	await process_frame
	print("Rendered profile rejection failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
