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
	if viewer.model.body.is_empty():
		push_error("Prepared anatomy is unavailable")
		quit(1)
		return
	for body in ["female", "male"]:
		if viewer.model.body.id != body:
			await viewer.switch_body(body)
		var browser: Window = viewer.show_coverage()
		check(browser != null, "Matching coverage notes open for both bodies")
		if browser == null:
			continue
		check(browser.visible, "The coverage window actually opens")
		for index in range(viewer.coverage_notes.systems.size()):
			browser.show_system(index)
			var entry: Dictionary = viewer.coverage_notes.systems[index]
			check(entry.supplied.female in browser.information.text and entry.supplied.male in browser.information.text,
				"Coverage displays both bodies' actual source notes")
			check(entry.gaps in browser.information.text, "Coverage never omits recorded gaps")
			check(browser.explore_button.disabled == entry.roots[body].is_empty(), "Unestablished groups cannot be offered as present anatomy")
		browser.show_system(1)
		browser.explore_current()
		await process_frame
		check(viewer.model.selected_id == "anatomy.system.skeletal", "Explore supplied group selects the active reference's geometry")
		check(viewer.model.isolated_id.is_empty(), "Reading coverage does not start a temporary inspection")
		print("PASS coverage browser: ", body)
	viewer.queue_free()
	await process_frame
	print("Coverage failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
