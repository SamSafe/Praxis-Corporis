extends SceneTree
## Real-body UI state, occlusion and navigation checks, without a desktop display.

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
		push_error("No prepared anatomy available")
		quit(1)
		return
	viewer.save_path = "user://exploration_test_view.json"
	for body in ["female", "male"]:
		if viewer.model.body.id != body:
			await viewer.switch_body(body)
		check(viewer.back_views.is_empty() and viewer.forward_views.is_empty(), "Body switching clears view history")
		viewer.whole_body(false)
		var whole: Dictionary = viewer.current_view()
		viewer.chest_view()
		var chest: Dictionary = viewer.current_view()
		check(viewer.back_views.size() == 1, "Show chest creates one navigation step")
		viewer.orbit.yaw += 0.24
		viewer.orbit.update_camera()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.08, 0.02, 0))
		var inspection: Dictionary = viewer.model.export_state()
		var undo_count: int = viewer.model.undo_stack.size()
		var orbited: Dictionary = viewer.current_view()
		viewer.select_structure("anatomy.heart.ventricle.left")
		check(viewer.anatomy_labels.context_id == "anatomy.heart", "Selecting a component retains its organ label set")
		var component: Dictionary = viewer.current_view()
		viewer.navigate_history(true)
		check(viewer.current_view() == orbited, "Back restores the camera as left after manual orbit")
		check(viewer.model.export_state() == inspection and viewer.model.undo_stack.size() == undo_count,
			"Navigation preserves inspection visibility, offsets and undo history")
		viewer.navigate_history(false)
		check(viewer.current_view() == component, "Forward restores the component view")
		viewer.navigate_history(true)
		viewer.select_structure("anatomy.heart.atrium.left")
		check(viewer.forward_views.is_empty(), "New navigation discards stale forward views")
		viewer.navigate_history(true)
		viewer.navigate_history(true)
		check(viewer.current_view() == whole, "Back can return to the initial whole-body camera")
		check(viewer.model.export_state() == inspection, "Whole-body history preserves current revealed and moved anatomy")
		viewer.navigate_history(false)
		check(viewer.model.selected_id == chest.selection, "Forward can return to the chest selection")

		viewer.model.restore()
		viewer.model.set_visibility("anatomy.body", "hidden")
		viewer.model.set_visibility("anatomy.heart", "visible")
		viewer.select_structure("anatomy.heart")
		viewer.local_labels_button.button_pressed = true
		viewer.label_density.value = 4
		await physics_frame
		await physics_frame
		var labels: Control = viewer.anatomy_labels
		labels.update_labels()
		check(labels.local_ids().size() == 14, "Local heart labels use all 14 supplied physical components")
		check(labels.visible_ids.size() > 1 and labels.visible_ids.size() <= 4, "Exposed heart labels respect the configured density")
		check(labels.rays_left >= 0, "Label searches stay within their ray-query budget")
		var rectangles: Array[Rect2] = []
		for id in labels.visible_ids:
			var hit: Dictionary = viewer.model.ray_hit(viewer.orbit.camera, labels.viewport_point(labels.anchors[id]))
			check(not hit.is_empty() and viewer.model.structures[id].mesh_nodes.has(float(hit.collider.get_meta("mesh_index"))),
				"Each label points to its own first-hit anatomy surface")
			var button: Button = labels.buttons[id]
			var rectangle := Rect2(button.position, button.size)
			check(Rect2(Vector2.ZERO, labels.size).encloses(rectangle), "Labels remain in the viewer")
			for other in rectangles:
				check(not rectangle.intersects(other), "Labels do not overlap")
			rectangles.append(rectangle)
		print("PASS real heart labels: ", body, " · ", labels.visible_ids)
		var leaf := ""
		for id in labels.visible_ids:
			if id != "anatomy.heart":
				leaf = id
				break
		if not leaf.is_empty():
			labels.buttons[leaf].pressed.emit()
			check(viewer.model.selected_id == leaf and viewer.tree.get_selected().get_metadata(0) == leaf,
				"Label selection synchronizes the anatomy tree and model")
			viewer.labels_button.button_pressed = false
			viewer.label_density.value = 1
			await physics_frame
			await physics_frame
			labels.update_labels()
			check(labels.visible_ids == [leaf], "The selected local part receives priority at the lowest density")
			viewer.labels_button.button_pressed = true
			viewer.label_density.value = 4
		viewer.save_view()
		var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(viewer.save_path))
		viewer.local_labels_button.button_pressed = false
		viewer.label_density.value = 12
		viewer.whole_body()
		await viewer.load_view()
		check(viewer.local_labels_button.button_pressed and viewer.label_density.value == 4 and labels.context_id == "anatomy.heart",
			"Saved views restore local label settings and the parent organ context")
		var before: Dictionary = viewer.current_view()
		saved.label_density = 1.5
		var file := FileAccess.open(viewer.save_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(saved))
		file.close()
		await viewer.load_view()
		check(viewer.current_view() == before, "Malformed label settings are rejected before altering the view")
		saved.label_density = 4
		saved.label_context = "anatomy.lungs"
		file = FileAccess.open(viewer.save_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(saved))
		file.close()
		await viewer.load_view()
		check(viewer.current_view() == before, "An unrelated saved organ label set is rejected atomically")
		# Old schema-1 saves remain loadable without the new optional fields.
		for key in ["label_density", "local_labels", "label_context"]:
			saved.erase(key)
		file = FileAccess.open(viewer.save_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(saved))
		file.close()
		await viewer.load_view()
		check(not viewer.local_labels_button.button_pressed and viewer.label_density.value == 8,
			"Earlier saved views retain compatible label defaults")

		viewer.select_structure("anatomy.heart")
		viewer.local_labels_button.button_pressed = true
		viewer.model.set_visibility("anatomy.skin", "visible")
		viewer.orbit.focus(viewer.model.bounds_for("anatomy.skin"))
		await physics_frame
		await physics_frame
		# With the selection reveal off, opaque skin must still hide the heart's labels.
		viewer.model.reveal_selection = false
		viewer.model.refresh_appearance()
		await physics_frame
		await physics_frame
		labels.update_labels()
		check(labels.visible_ids.is_empty(), "Opaque skin prevents misleading heart surface labels")
		viewer.model.reveal_selection = true
		viewer.model.refresh_appearance()
		await physics_frame
		await physics_frame
		labels.update_labels()
		check(not labels.visible_ids.is_empty(), "Revealing the selected heart lets its surface labels show")
		viewer.model.set_visibility("anatomy.body", "hidden")
		viewer.model.set_visibility("anatomy.heart", "faded")
		viewer.focus_selection()
		await physics_frame
		await physics_frame
		labels.update_labels()
		check(labels.visible_ids.is_empty(), "Hidden and faded click-through geometry has no surface labels")
		viewer.whole_body()
		check(labels.context_id.is_empty(), "Whole-body navigation clears the previous local label set")
		print("PASS exploration workflow: ", body)
	DirAccess.remove_absolute(viewer.save_path)
	viewer.queue_free()
	await process_frame
	print("Exploration failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
