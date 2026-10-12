extends SceneTree

const AnatomySearch = preload("res://scripts/anatomy_search.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func query(viewer, text: String) -> void:
	viewer.search.text = text
	viewer.rebuild_tree()


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	for body in ["female", "male"]:
		if viewer.model.body.id != body:
			await viewer.switch_body(body)
		viewer.chest_view()
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.04, 0.01, 0))
		var before: Dictionary = viewer.export_view_state()
		var undo: Array = viewer.model.undo_stack.duplicate(true)
		var history: Array = viewer.back_views.duplicate(true)
		query(viewer, "heart")
		check(str(viewer.model.body.label) in viewer.search_summary.text, "Results identify the active HRA reference")
		check(viewer.search_results.get_item_metadata(0) == "anatomy.heart", "Exact label precedes related heart records")
		check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.back_views == history,
			"Filtering preserves camera, inspection edits and both histories")
		query(viewer, "  uBeRoN 0002135  ")
		check(viewer.search_total == 1 and viewer.search_results.get_item_metadata(0) == "anatomy.heart.valve.mitral", "Ontology separator/case variations resolve the actual supplied valve")
		check("VH_" in viewer.search_results.get_item_text(0) and "UBERON:0002135" in viewer.search_results.get_item_tooltip(0), "Rows and tooltips retain source identity")
		query(viewer, "ventricle left")
		check(viewer.search_items.has("anatomy.heart.ventricle.left"), "Multiword name search accepts a different word order")
		query(viewer, "anatomy.heart.valve.mitral")
		check(viewer.search_total == 1, "Catalogue identifiers find their exact structure")
		viewer.activate_first_search_result()
		check(viewer.model.selected_id == "anatomy.heart.valve.mitral" and viewer.search_results.has_focus(), "Enter-selection focuses the real structure and offers list keyboard navigation")
		check(viewer.model.export_state() == before.changes and viewer.model.undo_stack == undo, "Search selection preserves existing body edits")
		var copied: String = viewer.source_record_text()
		check("Source name: VH_" in copied and "UBERON:0002135" in copied and viewer.model.body.sha256 in copied and "Anatomical review: pending" in copied,
			"Copyable source record names its reference, exact identity, fingerprint and review status")
		check("Source name: VH_" in viewer.detail.text and "Catalogue ID: anatomy.heart.valve.mitral" in viewer.detail.text, "Details expose the source name rather than repeating only the display label")
		# Repeated source labels stay separate: do not infer new anatomy or collapse IDs.
		query(viewer, "dura mater")
		var dura_ids := {}
		var source_names := {}
		for index in viewer.search_results.item_count:
			var id: String = viewer.search_results.get_item_metadata(index)
			dura_ids[id] = true
			source_names[viewer.model.structures[id].source_name] = true
		check(dura_ids.size() >= 2 and source_names.size() == dura_ids.size(), "Repeated labels retain distinct original source records")
		query(viewer, "a")
		check(viewer.search_total > 100 and viewer.search_results.item_count == 100 and str(viewer.search_total) in viewer.search_summary.text,
			"Capped lists report the full match count")
		var first_order := []
		for index in viewer.search_results.item_count:
			first_order.append(viewer.search_results.get_item_metadata(index))
		viewer.rebuild_tree()
		for index in viewer.search_results.item_count:
			check(first_order[index] == viewer.search_results.get_item_metadata(index), "Ranked ordering stays stable")
		before = viewer.export_view_state()
		query(viewer, "unavailable-source-identifier")
		viewer.activate_first_search_result()
		check(viewer.search_total == 0 and "No matches" in viewer.search_summary.text and viewer.export_view_state() == before, "An empty result is explicit and Enter never changes the current view")
		query(viewer, "")
		check(viewer.tree.visible and not viewer.search_results.visible and not viewer.search_summary.visible and viewer.tree_items.has("anatomy.heart"), "Clearing search restores the full hierarchy")
		viewer.navigate_history(true)
		check(viewer.model.export_state() == before.changes, "Search navigation history preserves anatomy edits")
		print("PASS real-source search: ", body)
	query(viewer, "FMA24474")
	await viewer.switch_body("bodyparts-male-bones-study")
	check(viewer.search_total == 1 and viewer.search_results.get_item_metadata(0) == "source.bodyparts3d-v4-male.FJ3365", "Switching reference rebuilds the index for the current query")
	viewer.activate_first_search_result()
	check(viewer.model.selected_id == "source.bodyparts3d-v4-male.FJ3365" and viewer.heading.text == "Right femur", "A source ontology search selects the supplied bone")
	var source_text: String = viewer.source_record_text()
	check("FJ3365" in source_text and "FMA24474" in source_text and "BodyParts3D" in source_text and viewer.model.body.sha256 in source_text, "The study record uses its own source fingerprint")
	query(viewer, "FMA52749")
	check(viewer.search_total == 2, "One ontology identity can resolve multiple supplied files without merging geometry")
	query(viewer, "FJ3365")
	check(viewer.search_total == 1, "An original source file identifier resolves the exact bone")
	query(viewer, "right\t  femur")
	check(viewer.search_results.get_item_metadata(0) == "source.bodyparts3d-v4-male.FJ3365", "Whitespace normalization keeps the intended words")
	viewer.on_search_selected(0)
	viewer.inspect_alone()
	var isolated: Dictionary = viewer.model.export_state()
	query(viewer, "left femur")
	viewer.on_search_selected(0)
	check(not viewer.model.isolated_id.is_empty() and viewer.model.selected_id == viewer.model.isolated_id and viewer.model.export_state() == isolated, "Search selection inside isolation preserves the temporary inspection workflow")
	viewer.return_to_context()
	query(viewer, "FJ3365")
	var old_index: RefCounted = viewer.search_index
	var old_results: Dictionary = viewer.search_items.duplicate(true)
	var before: Dictionary = viewer.export_view_state()
	var original: Array = viewer.pack.bodies
	viewer.pack.bodies = original.duplicate(true)
	viewer.pack.bodies[0].asset_path = "assets/search-missing-test.glb"
	await viewer.switch_body("female")
	viewer.pack.bodies = original
	check(viewer.export_view_state() == before and viewer.search_items == old_results and viewer.search_index == old_index,
		"A failed replacement keeps the existing search catalogue and visible results")
	viewer.queue_free()
	await process_frame
	print("Search failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
