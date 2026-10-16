extends SceneTree

const ReferenceState = preload("res://scripts/reference_state.gd")
const ContentBundle = preload("res://scripts/content_bundle.gd")
var failures := 0
var directory := "user://reference-test-" + Crypto.new().generate_random_bytes(8).hex_encode()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var pack := ContentBundle.catalogue()
	var state := ReferenceState.new()
	state.path = directory + "/reference.json"
	check(state.choice(pack).id == "female", "Disabled startup uses the established default")
	state.enabled = true
	check(state.choice(pack).id == "female" and state.save().is_empty() and not FileAccess.file_exists(state.path), "No completed reference means no new startup file")
	for body in pack.bodies:
		state.remember(body)
		check(state.current.body_id == body.id and state.save().is_empty(), "A completed supplied reference can be remembered")
		var reopened := ReferenceState.new()
		reopened.path = state.path
		reopened.enabled = true
		var choice := reopened.choice(pack)
		check(choice.id == body.id and choice.message.is_empty() and reopened.current.is_empty(), "Each supplied reference reopens by its exact source identity without pretending it has loaded")
	var known := state.current.duplicate()
	state.remember({"id": "broken", "sha256": "not-a-fingerprint"})
	check(state.current == known, "Incomplete reference data cannot replace the last completed reference")
	for invalid in ["{", "[]", '{"schema_version":1,"body_id":"male"}', '{"schema_version":true,"body_id":"male","source_sha256":"' + "a".repeat(64) + '"}']:
		write(state.path, invalid)
		var choice := state.choice(pack)
		check(choice.id == "female" and not choice.message.is_empty() and FileAccess.get_file_as_string(state.path) == invalid, "Malformed startup records fall back quietly without rewriting their input")
	var record: Dictionary = state.current.duplicate()
	record.body_id = "not-installed"
	write(state.path, JSON.stringify(record))
	check(state.choice(pack).id == "female" and "unavailable" in state.choice(pack).message, "A removed reference falls back to the default")
	record = state.current.duplicate()
	record.source_sha256 = "0".repeat(64)
	write(state.path, JSON.stringify(record))
	check(state.choice(pack).id == "female" and "changed" in state.choice(pack).message, "A changed source fingerprint cannot silently reopen another version")
	var bytes := FileAccess.get_file_as_bytes(state.path)
	state.enabled = false
	check(state.choice(pack).id == "female" and state.save().is_empty() and FileAccess.get_file_as_bytes(state.path) == bytes, "Scripted QA ignores and preserves a seeded startup file")
	state.enabled = true
	state.path += "/missing/file.json"
	check(not state.save().is_empty() and state.current == known, "A failed write retains the completed in-memory choice")
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Reference state failures: ", failures)
	quit(0 if failures == 0 else 1)
