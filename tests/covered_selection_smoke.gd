extends SceneTree
## Selecting a structure that lies inside other anatomy brings it into sight: the camera
## turns to a direction that shows it, or, when it is enclosed, the parts in front are
## drawn faded while it stays selected. Display only. A structure in plain view keeps the
## camera where it is; with the reveal off the status line says what covers it.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func in_sight(viewer, id: String) -> bool:
	var eye: Vector3 = viewer.orbit.to_global(viewer.orbit.target + viewer.orbit_direction(viewer.orbit.yaw, viewer.orbit.pitch) * maxf(viewer.orbit.distance, 2.0))
	return viewer.model.covering(id, eye).is_empty()


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
	viewer.whole_body()
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	var undo: int = viewer.model.undo_stack.size()
	var started := Time.get_ticks_usec()
	viewer.select_structure(caudate)
	var cost := (Time.get_ticks_usec() - started) / 1000.0
	await process_frame
	check(in_sight(viewer, caudate), "A deep brain nucleus is brought into sight: " + viewer.status.text)
	check("Camera turned" in viewer.status.text or "Faded " in viewer.status.text, "The status line says how it was shown: " + viewer.status.text)
	check(viewer.model.export_state() == anatomy and viewer.model.undo_stack.size() == undo, "Bringing it into sight changes no stored anatomy state or undo history")
	check(cost < 250.0, "Choosing the view is quick: %.1f ms" % cost)
	var faded: bool = viewer.model.view_reveal_id == caudate
	if faded:
		var index: int = int(viewer.model.view_reveal.keys()[0])
		check(viewer.model.effective_visibility(index) == "faded", "Parts in front are drawn faded")
		check(viewer.model.states[index].visibility == "visible", "Their stored visibility is unchanged")

	# Another selection drops the extra fading; Back restores it with the view.
	viewer.select_structure("anatomy.skin")
	await process_frame
	check(viewer.model.view_reveal.is_empty(), "A new selection ends the extra fading")
	check(not "is behind" in viewer.status.text, "The skin is in plain view")
	viewer.navigate_history(true)
	await process_frame
	check(viewer.model.selected_id == caudate and in_sight(viewer, caudate), "Back restores the deep selection in sight")

	# A structure already in sight keeps the camera where it is.
	viewer.whole_body()
	var yaw: float = viewer.orbit.yaw
	var pitch: float = viewer.orbit.pitch
	viewer.select_structure("anatomy.lungs")
	check(viewer.orbit.yaw == yaw and viewer.orbit.pitch == pitch, "A structure in sight does not turn the camera")
	check(viewer.model.view_reveal.is_empty(), "Nothing extra is faded for a structure in sight")
	# The heart lies partly behind breast tissue, thymus and lung edges from the front:
	# those are faded and the front view is kept.
	viewer.whole_body()
	viewer.select_structure("anatomy.heart")
	check(in_sight(viewer, "anatomy.heart"), "The heart is brought into sight")
	check(viewer.orbit.yaw == yaw and viewer.orbit.pitch == pitch, "The heart keeps the front view: " + viewer.status.text)

	# With the reveal off, the camera stays and the status line explains.
	viewer.whole_body()
	viewer.model.reveal_selection = false
	viewer.model.refresh_appearance()
	yaw = viewer.orbit.yaw
	viewer.select_structure(caudate)
	await process_frame
	check(viewer.orbit.yaw == yaw and viewer.model.view_reveal.is_empty(), "With the reveal off the camera stays put")
	check("is behind" in viewer.status.text and "Inspect alone" in viewer.status.text, "and the status line says what covers it: " + viewer.status.text)
	viewer.model.reveal_selection = true
	viewer.model.refresh_appearance()

	# Isolating the nucleus shows it, so the hint goes.
	viewer.inspect_alone()
	await process_frame
	viewer.status.text = ""
	viewer.note_covered_selection()
	check(not "is behind" in viewer.status.text, "No hint while the structure is inspected alone")
	viewer.end_isolation()

	# A prepared cut shows the interior itself, so it adds no extra fading.
	var cuts: Array = viewer.available_cuts()
	if not cuts.is_empty():
		viewer.open_prepared_cut(int(cuts[0]))
		check(viewer.model.view_reveal.is_empty(), "A prepared cut adds no extra fading")
	print("Covered selection: caudate view chosen in %.1f ms, %s" % [cost, "faded parts in front" if faded else "turned"])
	print("Covered selection failures: ", failures)
	quit(0 if failures == 0 else 1)
