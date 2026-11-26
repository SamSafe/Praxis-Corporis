extends SceneTree
## Selecting a structure that lies inside other anatomy says what covers it and how to
## reveal it; a structure in plain view, an isolated one or a cut-away view gets no hint.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	if viewer.model.body.id != "female":
		await viewer.switch_body("female")
	await process_frame
	var caudate: String = viewer.study_content.structure_id("anatomy.basal-ganglia", viewer.model.structures)
	viewer.select_structure(caudate)
	await process_frame
	check("is behind" in viewer.status.text and "Inspect alone" in viewer.status.text, "A deep brain nucleus says what covers it: " + viewer.status.text)
	viewer.status.text = ""
	viewer.select_structure("anatomy.skin")
	await process_frame
	check(not "is behind" in viewer.status.text, "The skin is in plain view")
	# Isolating the nucleus shows it, so the hint goes.
	viewer.select_structure(caudate)
	viewer.inspect_alone()
	await process_frame
	viewer.status.text = ""
	viewer.note_covered_selection()
	check(not "is behind" in viewer.status.text, "No hint while the structure is inspected alone")
	viewer.end_isolation()
	# The hint does not change the view or anatomy state.
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	viewer.note_covered_selection()
	check(viewer.model.export_state() == anatomy, "The hint changes no anatomy state")
	print("Covered selection failures: ", failures)
	quit(0 if failures == 0 else 1)
