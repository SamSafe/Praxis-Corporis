extends SceneTree

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
	await process_frame
	while viewer.loading:
		await process_frame
	check(viewer.body_choice.item_count == 3, "Prepared separate bone study appears alongside both HRA references")
	await viewer.switch_body("bodyparts-male-bones-study")
	check(viewer.model.meshes.size() == 203 and viewer.model.body.get("study", false), "The bone study remains a distinct source reference")
	check(viewer.peel_button.disabled and viewer.chest_button.disabled, "Study reference does not offer absent skin/heart controls")
	check(viewer.orbit.target.is_equal_approx(viewer.model.bounds_for("anatomy.body").get_center()), "Whole body frames the actual skeleton when no skin mesh exists")
	var femur := "source.bodyparts3d-v4-male.FJ3365"
	viewer.select_structure(femur)
	check(viewer.heading.text == "Right femur", "Imported source bone names are selectable")
	var original: AABB = viewer.model.bounds_for(femur)
	viewer.model.checkpoint()
	viewer.model.offset_selection(Vector3(0.12, 0.03, 0))
	viewer.inspect_alone()
	var changes: Dictionary = viewer.model.export_state()
	viewer.save_path = "user://study_reference_test.json"
	viewer.save_view()
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(viewer.save_path))
	check(saved.reference_hash == viewer.model.body.sha256, "Study saved views are bound to their derived source geometry")
	await viewer.switch_body("female")
	await viewer.load_view()
	check(viewer.model.body.id == "bodyparts-male-bones-study" and viewer.model.export_state() == changes and viewer.model.isolated_id == femur,
		"Loading an isolated bone study restores its reference, edits and temporary view")
	viewer.return_to_context()
	check(viewer.model.isolated_id.is_empty() and viewer.model.export_state() == changes, "Bone inspection return preserves displacement")
	var browser: Window = viewer.show_coverage()
	check(browser != null and browser.notes.reference_ids == ["bodyparts-male-bones-study"], "Study coverage is distinct from the HRA comparison")
	browser.show_system(0)
	check("203" in browser.information.text and "No registration" in browser.notes.notice, "Study coverage states measured counts and alignment limits")
	browser.queue_free()
	var before: Dictionary = viewer.current_view()
	saved.reference_hash = "wrong-source-version"
	var file := FileAccess.open(viewer.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(saved))
	file.close()
	await viewer.load_view()
	check(viewer.current_view() == before, "A mismatched source version is rejected before changing the study view")
	viewer.model.restore(femur)
	check(viewer.model.bounds_for(femur).is_equal_approx(original), "Source bone restoration recovers exact baseline bounds")
	DirAccess.remove_absolute(viewer.save_path)
	viewer.queue_free()
	await process_frame
	print("Study reference failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
