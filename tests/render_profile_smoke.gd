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
	var profiler := RenderProfile.new()
	var config: Dictionary = profiler.configuration(PackedStringArray(["--profile-rendered-bundle", "--profile-seconds=60", "--profile-warmup=2", "--profile-repetitions=3", "--profile-window=1920x1080"]))
	check(config == {"seconds": 60.0, "warmup_seconds": 2.0, "repetitions": 3, "window_pixels": [1920, 1080], "scene_view": "workspace", "render_fraction": 1.0}, "Sustained configuration preserves exact values")
	var expanded: Dictionary = profiler.configuration(PackedStringArray(["--profile-view=expanded", "--profile-resolution=75"]))
	check(expanded.scene_view == "expanded" and expanded.render_fraction == 0.75, "Explicit full-window/resolution choices are preserved")
	for invalid in ["--profile-view=wrong", "--profile-resolution=100", "--profile-resolution=0"]:
		check(profiler.configuration(PackedStringArray([invalid])).has("error"), "Invalid display option is rejected")
	check(profiler.configuration(PackedStringArray()) == profiler.DEFAULTS, "Ordinary diagnostic defaults remain explicit")
	for invalid in ["--profile-seconds=0", "--profile-seconds=121", "--profile-seconds=NaN", "--profile-seconds=inf", "--profile-warmup=0", "--profile-warmup=11", "--profile-repetitions=1.5", "--profile-repetitions=4", "--profile-window=1099x720", "--profile-window=1920x719", "--profile-window=3841x2160", "--profile-window=1920x1080x1", "--profile-window=wrong", "--profile-seconds", "--profile-unknown=1"]:
		check(profiler.configuration(PackedStringArray([invalid])).has("error"), "Invalid configuration is rejected: " + invalid)
	check(profiler.configuration(PackedStringArray(["--profile-seconds=60", "--profile-seconds=5"])).has("error"), "Repeated options cannot silently change the measurement")
	var default_again: Dictionary = profiler.configuration(PackedStringArray())
	config.window_pixels[0] = 1234
	check(default_again.window_pixels == [1440, 900], "Configuration mutation does not change defaults")
	var control := Control.new()
	var result: Dictionary = await profiler.run(control)
	control.free()
	check(result.has("error") and "desktop display" in result.error, "Headless execution cannot produce rendering evidence")
	print("Render profile configuration failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
