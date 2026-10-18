extends SceneTree

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	root.size = Vector2i(1440, 900)
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	# Keep search, list and page controls reachable at the smallest workspace,
	# including the largest supported text size.
	root.size = Vector2i(1100, 720)
	for scale in [1.0, 1.3]:
		var settings: Dictionary = viewer.preference_state()
		settings.text_scale = scale
		viewer.apply_preferences(settings)
		viewer.list_view_button.button_pressed = true
		for frame in 4:
			await process_frame
		var bounds := Rect2(Vector2.ZERO, Vector2(root.size))
		for control in [viewer.search, viewer.list_view_button, viewer.search_results, viewer.browse_previous, viewer.browse_next]:
			check(bounds.encloses(control.get_global_rect()) and control.size.y > 0, "List controls fit the compact workspace at text scale " + str(scale))
	viewer.list_view_button.button_pressed = false
	var defaults: Dictionary = viewer.preference_state()
	defaults.text_scale = 1.0
	viewer.apply_preferences(defaults)
	root.size = Vector2i(1440, 900)
	for reference in viewer.pack.bodies:
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		var before: Dictionary = viewer.export_view_state().duplicate(true)
		var undo: Array = viewer.model.undo_stack.duplicate(true)
		var redo: Array = viewer.model.redo_stack.duplicate(true)
		var back: Array = viewer.back_views.duplicate(true)
		var forward: Array = viewer.forward_views.duplicate(true)
		viewer.list_view_button.button_pressed = true
		var seen := {}
		var ordered := []
		while true:
			check(not viewer.tree.visible and viewer.search_results.visible and viewer.browse_pager.visible, "List mode exposes records and paging")
			check(viewer.search_results.item_count <= 100 and viewer.search_total == viewer.model.structures.size(), "Each page is bounded and reports the complete catalogue")
			for index in viewer.search_results.item_count:
				var id: String = viewer.search_results.get_item_metadata(index)
				check(not seen.has(id) and viewer.model.structures.has(id), "Pages retain distinct real catalogue IDs")
				seen[id] = true
				ordered.append(id)
			check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward,
				"Browsing does not select, move anatomy or change camera/histories")
			if viewer.browse_next.disabled:
				break
			viewer.browse_records(1)
		check(seen.size() == viewer.model.structures.size(), "Every catalogue record is reachable exactly once")
		var last_page: int = viewer.browse_page
		viewer.browse_records(1)
		check(viewer.browse_page == last_page, "Next stops at the last page")
		viewer.browse_records(-1000)
		check(viewer.browse_page == 0 and viewer.browse_previous.disabled, "Previous stops at the first page")
		var expected: String = reference.get("qa_leaf_id", "anatomy.heart.valve.mitral")
		if reference.id == "bodyparts-male-bones-study":
			expected = "source.bodyparts3d-v4-male.FJ3365"
		viewer.search.set_accessible_value(expected)
		check(viewer.search_total >= 1 and not viewer.browse_pager.visible and viewer.search_results.get_item_metadata(0) == expected,
			"Accessible search updates the normal source results while list mode is selected")
		viewer.activate_first_search_result()
		check(viewer.model.selected_id == expected and viewer.model.export_state() == before.changes, "A listed source result selects its actual anatomy without editing it")
		viewer.search.set_accessible_value("")
		check(viewer.browse_pager.visible and viewer.search_results.item_count == mini(100, seen.size()), "Clearing search restores the chosen list mode")
		viewer.list_view_button.button_pressed = false
		check(viewer.tree.visible and not viewer.search_results.visible and not viewer.browse_pager.visible, "Unchecking list mode restores the hierarchy")
		check(await viewer.restore_view_state(before), "Restore the test's original scene")
		viewer.model.undo_stack = undo
		viewer.model.redo_stack = redo
		viewer.back_views = back
		viewer.forward_views = forward
		viewer.refresh_details()
		print("PASS complete anatomy list: ", reference.id, " · ", ordered.size(), " records")
	viewer.queue_free()
	await process_frame
	print("Anatomy list failures: ", failures)
	quit(0 if failures == 0 else 1)
