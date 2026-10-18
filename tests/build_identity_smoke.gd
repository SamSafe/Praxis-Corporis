extends SceneTree

const BuildIdentity = preload("res://scripts/build_identity.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var data := {"schema_version": 1, "channel": "private", "build_id": "a".repeat(32),
		"application_version": "0.1.0", "source_revision": "b".repeat(40),
		"source_snapshot_sha256": "c".repeat(64), "engine": "4.7.2.stable.official.ed1daf0bf", "content_pack": "fixture"}
	var path := "user://build-identity-" + Crypto.new().generate_random_bytes(8).hex_encode() + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var restored := BuildIdentity.read("fixture", path)
	var same := restored.size() == data.size()
	for key in data:
		same = same and restored.get(key) == data[key]
	check(same, "The generated identity retains every recorded value through JSON")
	check(BuildIdentity.read("other", path).is_empty(), "An identity cannot describe another content pack")
	for damage in [null, {}, {"schema_version": 1}, "invalid"]:
		check(not BuildIdentity.valid(damage), "Incomplete or non-record identities are rejected")
	for key in ["build_id", "source_revision", "source_snapshot_sha256", "engine", "application_version"]:
		var invalid: Dictionary = data.duplicate()
		invalid[key] = "invalid\nvalue"
		check(not BuildIdentity.valid(invalid), "Malformed identity field rejected: " + key)
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("not JSON")
	file.close()
	check(BuildIdentity.read("fixture", path).is_empty(), "Corrupt identity becomes unavailable without a fabricated version")
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(" ".repeat(BuildIdentity.MAX_BYTES + 1))
	file.close()
	check(BuildIdentity.read("fixture", path).is_empty(), "Identity input has a byte bound")
	DirAccess.remove_absolute(path)
	check(BuildIdentity.read("fixture", path).is_empty(), "Missing identity is explicitly unavailable")
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var dialog: Window = viewer.show_sources()
	await process_frame
	check("Development checkout" in dialog.message and "build identity unavailable" in dialog.message and "Content pack: " + viewer.pack.id in dialog.message,
		"The source checkout identifies itself without claiming an exported build ID")
	check(viewer.export_view_state() == before, "Reading build information preserves anatomy")
	dialog.queue_free()
	viewer.queue_free()
	await process_frame
	print("Build identity failures: ", failures)
	quit(0 if failures == 0 else 1)
