extends SceneTree

var failures := 0
var directory := "user://startup-check-" + Crypto.new().generate_random_bytes(8).hex_encode()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func write_choice(path: String, body: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 1, "body_id": body.id, "source_sha256": body.sha256}))
	file.close()


func ready(viewer) -> void:
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var viewer = load("res://scenes/main.tscn").instantiate()
	viewer.reference_state.path = directory + "/reference.json"
	root.add_child(viewer)
	# Only this disposable reference file is enabled before deferred startup.
	viewer.reference_state.enabled = true
	var male: Dictionary
	for body in viewer.pack.bodies:
		if body.id == "male":
			male = body
	write_choice(viewer.reference_state.path, male)
	await ready(viewer)
	check(viewer.model.body.id == "male" and viewer.reference_state.current.body_id == "male", "Startup opens the remembered real reference and records only its completed load")
	check(root.title == "Praxis Corporis · " + male.label, "The window title identifies the loaded HRA reference")
	check(viewer.reference_state.save().is_empty(), "A completed startup can be persisted on accepted shutdown")
	var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(viewer.reference_state.path))
	check(record.size() == 3 and record.body_id == "male" and record.source_sha256 == male.sha256, "Startup persistence contains only reference identity and source fingerprint")
	var before: Dictionary = viewer.export_view_state()
	var original: Dictionary = viewer.pack
	viewer.pack = original.duplicate(true)
	for body in viewer.pack.bodies:
		if body.id == "female":
			body.asset_path = "assets/missing-startup-test.glb"
	await viewer.switch_body("female")
	check(viewer.model.body.id == "male" and viewer.reference_state.current.body_id == "male" and viewer.export_view_state() == before,
		"A failed later switch preserves the last successful reference and exploration")
	viewer.pack = original
	await viewer.switch_body("hra-v1-2-female-cord-study")
	check(viewer.reference_state.current.body_id == "hra-v1-2-female-cord-study" and "Female cord" in root.title, "Separate source studies update startup identity and the window title")
	viewer.queue_free()
	await process_frame
	viewer = load("res://scenes/main.tscn").instantiate()
	viewer.reference_state.path = directory + "/reference.json"
	root.add_child(viewer)
	viewer.reference_state.enabled = true
	write_choice(viewer.reference_state.path, male)
	var seeded := FileAccess.get_file_as_bytes(viewer.reference_state.path)
	viewer.pack = viewer.pack.duplicate(true)
	for body in viewer.pack.bodies:
		if body.id == "male":
			body.asset_path = "assets/missing-startup-test.glb"
	await ready(viewer)
	check(viewer.model.body.id == "female" and viewer.reference_state.current.body_id == "female" and "could not be opened" in viewer.status.text,
		"An unavailable remembered asset falls back to the actual female reference during first startup")
	check(FileAccess.get_file_as_bytes(viewer.reference_state.path) == seeded, "Fallback loading alone does not rewrite the startup file")
	check(viewer.reference_state.save().is_empty(), "Accepted shutdown can save the successfully loaded fallback")
	viewer.queue_free()
	await process_frame
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Reference startup failures: ", failures)
	quit(0 if failures == 0 else 1)
