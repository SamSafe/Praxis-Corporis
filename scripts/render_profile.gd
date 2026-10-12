extends RefCounted
## Explicit developer-only sampling; no background telemetry or session access.

const SAMPLE_SECONDS := 5.0
const WARMUP_SECONDS := 1.0


func percentile(sorted: Array[float], fraction: float) -> float:
	return sorted[clampi(int(ceil(sorted.size() * fraction)) - 1, 0, sorted.size() - 1)]


func sample(viewer: Control, name: String) -> Dictionary:
	var warmup_end := Time.get_ticks_usec() + int(WARMUP_SECONDS * 1000000)
	while Time.get_ticks_usec() < warmup_end:
		await RenderingServer.frame_post_draw
	var samples: Array[float] = []
	var draw_calls: Array[int] = []
	var started := Time.get_ticks_usec()
	var previous := started
	while (Time.get_ticks_usec() - started) / 1000000.0 < SAMPLE_SECONDS:
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		var interval := (now - previous) / 1000.0
		previous = now
		samples.append(interval)
		draw_calls.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
		viewer.orbit.yaw += interval / 1000.0 * 0.5
		viewer.orbit.update_camera()
	var elapsed := (previous - started) / 1000000.0
	var ordered := samples.duplicate()
	ordered.sort()
	var slow_frames := 0
	for value in samples:
		slow_frames += int(value > 1000.0 / 30.0)
	var visible_meshes := 0
	for mesh in viewer.model.meshes.values():
		visible_meshes += int(mesh.visible)
	var call_sum := 0
	for count in draw_calls:
		call_sum += count
	var result := {"reference": viewer.model.body.id, "reference_hash": viewer.model.body.sha256,
		"scene": name, "window_pixels": [viewer.get_window().size.x, viewer.get_window().size.y],
		"scene_viewport_pixels": [viewer.viewport.size.x, viewer.viewport.size.y],
		"visible_source_meshes": visible_meshes, "isolation": viewer.model.isolated_id,
		"local_labels": viewer.local_labels_button.button_pressed,
		"label_density": int(viewer.label_density.value), "warmup_seconds": WARMUP_SECONDS,
		"elapsed_seconds": elapsed, "frames": samples.size(), "average_frame_cadence_fps": samples.size() / elapsed,
		"frame_interval_ms": {"median": percentile(ordered, 0.5), "p95": percentile(ordered, 0.95),
			"p99": percentile(ordered, 0.99), "maximum": ordered[-1]},
		"frames_over_33_33_ms": slow_frames, "average_global_draw_calls": float(call_sum) / samples.size(),
		"raw_frame_intervals_ms": samples}
	print("PROFILE ", viewer.model.body.id, " / ", name, ": %.1f frame-cadence FPS · p95 %.2f ms" % [result.average_frame_cadence_fps, result.frame_interval_ms.p95])
	return result


func run(viewer: Control) -> Dictionary:
	if DisplayServer.get_name() == "headless":
		return {"error": "Rendering profile needs a desktop display; headless timing is not rendering evidence."}
	var report := {"schema_version": 1, "engine": Engine.get_version_info().string,
		"platform": OS.get_name(), "cpu": OS.get_processor_name(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"graphics_api": RenderingServer.get_video_adapter_api_version(),
		"gpu": RenderingServer.get_video_adapter_name(), "vendor": RenderingServer.get_video_adapter_vendor(),
		"vsync_mode": DisplayServer.window_get_vsync_mode(), "pack_id": viewer.pack.id,
		"method": "One-second stationary warmup, five-second scripted orbit at 0.5 rad/s per scene; intervals between frame_post_draw callbacks.",
		"limits": ["Short single-process observations with uncontrolled OS cache, power state and background load.",
			"Frame callback cadence includes VSync/CPU scheduling; it is not a GPU timestamp or presentation-latency measurement.",
			"No condition content, human-input acceptance, representative-laptop or minimum-hardware claim."],
		"loads": [], "scenes": []}
	for reference in viewer.pack.bodies:
		var load_started := Time.get_ticks_usec()
		await viewer.switch_body(reference.id)
		if viewer.model.body.get("id") != reference.id:
			return {"error": "Could not load reference for profiling: " + str(reference.id)}
		report.loads.append({"reference": reference.id, "reference_hash": reference.sha256,
			"wall_seconds": (Time.get_ticks_usec() - load_started) / 1000000.0,
			"prepared_scene_seconds": viewer.model.load_seconds})
		viewer.local_labels_button.button_pressed = false
		viewer.labels_button.button_pressed = true
		viewer.whole_body(false)
		report.scenes.append(await sample(viewer, "whole-body orbit"))
		if viewer.model.structures.has("anatomy.heart"):
			viewer.chest_view()
			viewer.local_labels_button.button_pressed = true
			viewer.label_density.value = 8
			report.scenes.append(await sample(viewer, "chest orbit with faded lungs and local labels"))
			viewer.select_structure("anatomy.heart.valve.mitral")
		else:
			viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
		viewer.inspect_alone()
		report.scenes.append(await sample(viewer, "isolated supplied-part orbit"))
	return report
