extends RefCounted
## Explicit developer-only sampling; no background telemetry or session access.

const ContentBundle = preload("res://scripts/content_bundle.gd")
const CHEST_SCENE := "chest orbit with faded lungs and local labels"
const CHEST_REFERENCES := ["female", "male", "bodyparts-male-complete"]
const DEFAULTS := {"seconds": 5.0, "warmup_seconds": 1.0, "repetitions": 1, "window_pixels": [1440, 900], "scene_view": "workspace", "render_fraction": 1.0}


var planned_samples := 0


func configuration(arguments: PackedStringArray) -> Dictionary:
	var config := DEFAULTS.duplicate(true)
	var seen := {}
	for argument in arguments:
		if not argument.begins_with("--profile-") or argument == "--profile-rendered-bundle":
			continue
		var pair := argument.split("=", true, 1)
		if pair.size() != 2 or seen.has(pair[0]):
			return {"error": "Profile options require one unique --profile-option=value argument."}
		seen[pair[0]] = true
		match pair[0]:
			"--profile-view":
				if pair[1] not in ["workspace", "expanded"]:
					return {"error": "Profile view must be workspace or expanded."}
				config.scene_view = pair[1]
			"--profile-resolution":
				if pair[1] not in ["native", "75", "50"]:
					return {"error": "Profile resolution must be native, 75 or 50."}
				config.render_fraction = {"native": 1.0, "75": 0.75, "50": 0.5}[pair[1]]
			"--profile-seconds", "--profile-warmup":
				if not pair[1].is_valid_float():
					return {"error": "Profile duration must be a finite number."}
				var value := pair[1].to_float()
				var minimum := 1.0 if pair[0] == "--profile-seconds" else 0.25
				var maximum := 120.0 if pair[0] == "--profile-seconds" else 10.0
				if not is_finite(value) or value < minimum or value > maximum:
					return {"error": "Profile duration is outside its supported range."}
				config["seconds" if pair[0] == "--profile-seconds" else "warmup_seconds"] = value
			"--profile-repetitions":
				if not pair[1].is_valid_int() or pair[1].to_int() < 1 or pair[1].to_int() > 3:
					return {"error": "Profile repetitions must be an integer from 1 to 3."}
				config.repetitions = pair[1].to_int()
			"--profile-window":
				var dimensions := pair[1].split("x")
				if dimensions.size() != 2 or not dimensions[0].is_valid_int() or not dimensions[1].is_valid_int():
					return {"error": "Profile window must be WIDTHxHEIGHT in pixels."}
				var width := dimensions[0].to_int()
				var height := dimensions[1].to_int()
				if width < 1100 or width > 3840 or height < 720 or height > 2160:
					return {"error": "Profile window must be between 1100x720 and 3840x2160."}
				config.window_pixels = [width, height]
			_:
				return {"error": "Unknown profile option: " + str(pair[0])}
	return config


func percentile(sorted: Array[float], fraction: float) -> float:
	return sorted[clampi(int(ceil(sorted.size() * fraction)) - 1, 0, sorted.size() - 1)]


func sample(viewer: Control, name: String, config: Dictionary, repetition: int) -> Dictionary:
	var warmup_end := Time.get_ticks_usec() + int(config.warmup_seconds * 1000000)
	while Time.get_ticks_usec() < warmup_end:
		await RenderingServer.frame_post_draw
	var expected := Vector2i(config.window_pixels[0], config.window_pixels[1])
	if viewer.get_window().size != expected:
		return {"error": "Profile window changed before sampling: " + name}
	var initial_viewport: Vector2i = viewer.viewport.size
	var initial_display: Vector2i = viewer.scene_container.displayed_pixels
	var expected_view: String = config.get("scene_view", "workspace")
	var expected_fraction: float = config.get("render_fraction", 1.0)
	if viewer.scene_expanded != (expected_view == "expanded") or viewer.scene_container.resolution_fraction != expected_fraction:
		return {"error": "Scene view or resolution differs from the requested profile."}
	if expected_view == "expanded" and initial_display != expected:
		return {"error": "Expanded scene does not cover the requested window pixels."}
	var samples: Array[float] = []
	var draw_calls: Array[int] = []
	var started := Time.get_ticks_usec()
	var previous := started
	var all_focused := viewer.get_window().has_focus()
	while (Time.get_ticks_usec() - started) / 1000000.0 < config.seconds:
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		var interval := (now - previous) / 1000.0
		previous = now
		samples.append(interval)
		if viewer.get_window().size != expected or viewer.viewport.size != initial_viewport or viewer.scene_container.displayed_pixels != initial_display or viewer.scene_expanded != (expected_view == "expanded") or viewer.scene_container.resolution_fraction != expected_fraction:
			return {"error": "Window or 3D viewport changed during sampling: " + name,
				"reference": viewer.model.body.id, "repetition": repetition,
				"observed_window_pixels": [viewer.get_window().size.x, viewer.get_window().size.y],
				"observed_viewport_pixels": [viewer.viewport.size.x, viewer.viewport.size.y],
				"raw_frame_intervals_ms": samples}
		all_focused = all_focused and viewer.get_window().has_focus()
		draw_calls.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
		viewer.orbit.yaw += interval / 1000.0 * 0.5
		viewer.orbit.update_camera()
	var elapsed := (previous - started) / 1000000.0
	var ordered := samples.duplicate()
	ordered.sort()
	var slow_frames := 0
	var stalled_frames := 0
	for value in samples:
		slow_frames += int(value > 1000.0 / 30.0)
		stalled_frames += int(value > 100.0)
	var visible_meshes := 0
	for mesh in viewer.model.meshes.values():
		visible_meshes += int(mesh.visible)
	var call_sum := 0
	for count in draw_calls:
		call_sum += count
	var result := {"reference": viewer.model.body.id, "reference_hash": viewer.model.body.sha256,
		"scene": name, "repetition": repetition, "window_pixels": [viewer.get_window().size.x, viewer.get_window().size.y],
		"scene_viewport_pixels": [viewer.viewport.size.x, viewer.viewport.size.y],
		"scene_display_pixels": [initial_display.x, initial_display.y],
		"scene_view": expected_view, "render_fraction": expected_fraction,
		"scene_resolution_limited": viewer.scene_container.resolution_limited,
		"window_mode": viewer.get_window().mode,
		"visible_source_meshes": visible_meshes, "isolation": viewer.model.isolated_id,
		"local_labels": viewer.local_labels_button.button_pressed,
		"label_density": int(viewer.label_density.value), "warmup_seconds": config.warmup_seconds,
		"requested_seconds": config.seconds, "window_focused_throughout_sample": all_focused,
		"msaa_3d": viewer.viewport.msaa_3d, "vsync_mode": DisplayServer.window_get_vsync_mode(),
		"elapsed_seconds": elapsed, "frames": samples.size(), "average_frame_cadence_fps": samples.size() / elapsed,
		"frame_interval_ms": {"median": percentile(ordered, 0.5), "p95": percentile(ordered, 0.95),
			"p99": percentile(ordered, 0.99), "maximum": ordered[-1]},
		"frames_over_33_33_ms": slow_frames, "frames_over_100_ms": stalled_frames,
		"average_global_draw_calls": float(call_sum) / samples.size(),
		"raw_frame_intervals_ms": samples}
	print("PROFILE ", repetition, " / ", viewer.model.body.id, " / ", name, ": %.1f frame-cadence FPS · p95 %.2f ms" % [result.average_frame_cadence_fps, result.frame_interval_ms.p95])
	return result


func append_sample(report: Dictionary, viewer: Control, name: String, config: Dictionary, repetition: int) -> bool:
	var result := await sample(viewer, name, config, repetition)
	if result.has("error"):
		report.error = result.error
		report.interrupted_scene = result
		return false
	report.scenes.append(result)
	if "--profile-rendered-bundle" in OS.get_cmdline_user_args():
		var progress := {"completed_samples": report.scenes.size(), "planned_samples": planned_samples,
			"reference": result.reference, "scene": result.scene, "repetition": repetition,
			"last_sample_seconds": result.elapsed_seconds, "viewport_pixels": result.scene_viewport_pixels,
			"last_sample_focused": result.window_focused_throughout_sample}
		var file := FileAccess.open("user://render-profile-progress.json.tmp", FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(progress, "\t", true, true))
			file.close()
			DirAccess.rename_absolute("user://render-profile-progress.json.tmp", "user://render-profile-progress.json")
	return true


func record_load_interval(trace: Dictionary) -> void:
	var now := Time.get_ticks_usec()
	if now > trace.previous_usec:
		trace.intervals.append((now - trace.previous_usec) / 1000.0)
	trace.previous_usec = now


func record_load_stage(stage: String, _fraction: float, trace: Dictionary) -> void:
	if trace.stages[-1].stage != stage:
		trace.stages.append({"stage": stage, "at_seconds": (Time.get_ticks_usec() - trace.started_usec) / 1000000.0})


func measure_load(viewer: Control, reference: Dictionary, repetition: int) -> Dictionary:
	var started := Time.get_ticks_usec()
	var trace := {"started_usec": started, "previous_usec": started, "intervals": [],
		"stages": [{"stage": "Reference request", "at_seconds": 0.0}]}
	var frame_listener := record_load_interval.bind(trace)
	var stage_listener := record_load_stage.bind(trace)
	viewer.get_tree().process_frame.connect(frame_listener)
	viewer.model.load_progress.connect(stage_listener)
	await viewer.switch_body(reference.id)
	viewer.get_tree().process_frame.disconnect(frame_listener)
	viewer.model.load_progress.disconnect(stage_listener)
	record_load_interval(trace) # Closing boundary: includes the work after the last process callback.
	var finished: int = trace.previous_usec
	if viewer.model.body.get("id") != reference.id:
		return {"error": "Could not load reference for profiling: " + str(reference.id)}
	var wall := (finished - started) / 1000000.0
	trace.stages.append({"stage": "Reference ready", "at_seconds": wall})
	await RenderingServer.frame_post_draw
	var first_post_draw_ms := (Time.get_ticks_usec() - finished) / 1000.0
	var slow := 0
	var stalled := 0
	var largest := 0.0
	for interval in trace.intervals:
		largest = maxf(largest, interval)
		slow += int(interval > 1000.0 / 30.0)
		stalled += int(interval > 100.0)
	var result := {"reference": reference.id, "reference_hash": reference.sha256, "repetition": repetition,
		"wall_seconds": wall, "verified_prepared_scene_seconds": viewer.model.load_seconds,
		"resource_operation_intervals_ms": viewer.model.resource_operation_intervals_ms.duplicate(true),
		"prepared_selection_batches": viewer.model.prepared_selection_batches,
		"ui_process_frames_during_load": viewer.load_frame_count, "loader_yield_frames": viewer.model.load_wait_frames,
		"raw_process_intervals_ms": trace.intervals, "interval_count": trace.intervals.size(),
		"maximum_process_gap_ms": largest, "intervals_over_33_33_ms": slow, "intervals_over_100_ms": stalled,
		"stage_events": trace.stages, "first_post_draw_after_load_ms": first_post_draw_ms}
	print("PROFILE LOAD ", repetition, " / ", reference.id, ": %.2f s · largest process gap %.2f ms" % [wall, largest])
	return result


func run(viewer: Control) -> Dictionary:
	var config := configuration(OS.get_cmdline_user_args())
	if config.has("error"):
		return config
	if DisplayServer.get_name() == "headless":
		return {"error": "Rendering profile needs a desktop display; headless timing is not rendering evidence."}
	var boundary_error := ContentBundle.verify_export_boundary()
	if not boundary_error.is_empty():
		return {"error": boundary_error}
	var window := viewer.get_window()
	var expected := Vector2i(config.window_pixels[0], config.window_pixels[1])
	# Explicit developer mode fixes only its own window; ordinary launches keep resize controls.
	window.wrap_controls = false
	window.mode = Window.MODE_WINDOWED
	window.min_size = expected
	window.max_size = expected
	window.unresizable = true
	window.size = expected
	await viewer.get_tree().process_frame
	await viewer.get_tree().process_frame
	if viewer.get_window().size != Vector2i(config.window_pixels[0], config.window_pixels[1]):
		return {"error": "The desktop did not provide the requested profile window dimensions."}
	viewer.set_scene_resolution(config.render_fraction)
	var report := {"schema_version": 3, "engine": Engine.get_version_info().string,
		"engine_commit": Engine.get_version_info().hash, "configuration": config,
		"platform": OS.get_name(), "cpu": OS.get_processor_name(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"graphics_api": RenderingServer.get_video_adapter_api_version(),
		"gpu": RenderingServer.get_video_adapter_name(), "vendor": RenderingServer.get_video_adapter_vendor(),
		"vsync_mode": DisplayServer.window_get_vsync_mode(), "pack_id": viewer.pack.id,
		"engine_max_fps": Engine.max_fps, "engine_time_scale": Engine.time_scale,
		"method": "Configured stationary warmup and orbit at 0.5 rad/s; intervals between frame_post_draw callbacks, nearest-rank percentiles.",
		"load_method": "Process callbacks during switch_body, including start/end partial intervals; stage transition timestamps. Post-draw delay starts after switch_body completes, not process startup.",
		"limits": ["Single-process repeated observations with uncontrolled OS cache, power state and background load.",
			"Frame callback cadence includes VSync/CPU scheduling; it is not a GPU timestamp or presentation-latency measurement.",
			"Load intervals include partial boundary intervals; stage timings include scheduling and do not isolate CPU execution cost.",
			"No condition content, human-input acceptance, representative-laptop or minimum-hardware claim."],
		"measurement_plan": [], "loads": [], "scenes": []}
	var planned := {}
	for reference in viewer.pack.bodies:
		var scenes := ["whole-body orbit", "isolated supplied-part orbit"]
		# References that supply the heart also get the chest workload.
		if reference.id in CHEST_REFERENCES:
			scenes.insert(1, CHEST_SCENE)
		planned[reference.id] = scenes
		report.measurement_plan.append({"reference": reference.id, "reference_hash": reference.sha256, "scenes": scenes})
	planned_samples = 0
	for scenes in planned.values():
		planned_samples += scenes.size() * config.repetitions
	for repetition in range(1, config.repetitions + 1):
		for reference in viewer.pack.bodies:
			var load_result := await measure_load(viewer, reference, repetition)
			if load_result.has("error"):
				return load_result
			report.loads.append(load_result)
			viewer.set_scene_expanded(config.scene_view == "expanded")
			await viewer.get_tree().process_frame
			await viewer.get_tree().process_frame
			viewer.orbit.input_enabled = false
			viewer.local_labels_button.button_pressed = false
			viewer.labels_button.button_pressed = true
			viewer.label_density.value = 8
			viewer.whole_body(false)
			if not await append_sample(report, viewer, "whole-body orbit", config, repetition):
				return report
			if CHEST_SCENE in planned[reference.id]:
				if not viewer.model.structures.has("anatomy.heart"):
					return {"error": "The chest profiling workload needs the heart: " + str(reference.id)}
				viewer.chest_view()
				viewer.local_labels_button.button_pressed = true
				if not await append_sample(report, viewer, CHEST_SCENE, config, repetition):
					return report
				viewer.select_structure("anatomy.heart.valve.mitral")
			else:
				viewer.select_structure(str(reference.get("qa_leaf_id", "source.bodyparts3d-v4-male.FJ3365")))
			viewer.inspect_alone()
			if viewer.model.selected_id.is_empty() or viewer.model.isolated_id != viewer.model.selected_id:
				return {"error": "The supplied-part profiling workload did not isolate its mapped source mesh: " + str(reference.id)}
			if not await append_sample(report, viewer, "isolated supplied-part orbit", config, repetition):
				return report
	return report
