extends SceneTree
## Conditions are found by title in the anatomy search: results follow the supplied
## records, only conditions offered on the current body are listed, and choosing one
## opens its draft text without changing anatomy until Inspect is chosen.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func query(viewer, text: String) -> void:
	viewer.search.text = text
	viewer.rebuild_tree()


func condition_rows(viewer) -> Array:
	var rows := []
	for index in viewer.search_results.item_count:
		var target := str(viewer.search_results.get_item_metadata(index))
		if target.begins_with(viewer.CONDITION_PREFIX):
			rows.append(target.trim_prefix(viewer.CONDITION_PREFIX))
	return rows


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	if viewer.model.body.id != "female":
		await viewer.switch_body("female")
	var content = viewer.study_content
	# A condition title the catalogue does not contain is still found.
	query(viewer, "aortic stenosis")
	check(condition_rows(viewer) == ["condition.aortic-stenosis"], "Search lists aortic stenosis as a condition")
	var last: int = viewer.search_results.item_count - 1
	check(last >= 0 and "Condition · " in viewer.search_results.get_item_text(last), "The row says it is a condition and names its reference anatomy")
	check(viewer.search_total == viewer.search_results.item_count, "The summary counts condition results")
	# Words match in any order and case.
	query(viewer, "STENOSIS aortic")
	check(condition_rows(viewer) == ["condition.aortic-stenosis"], "Words match in any order and case")
	# Catalogue records still come first.
	query(viewer, "heart")
	check(viewer.search_results.get_item_metadata(0) == "anatomy.heart", "Supplied records rank ahead of conditions")
	var heart_conditions: Array = condition_rows(viewer)
	check(not heart_conditions.is_empty(), "Conditions with 'heart' in their title are listed")
	for id in heart_conditions:
		check(content.condition_available(id, viewer.model.structures), "Listed condition is offered on this body: " + id)
	# Only conditions offered on the current body appear.
	query(viewer, "prostate")
	check(condition_rows(viewer).is_empty(), "Prostate conditions are not offered on the female body")
	query(viewer, "ovarian cyst")
	check(condition_rows(viewer) == ["condition.ovarian-cysts"], "Ovarian cysts are offered on the female body")
	# Choosing a result opens the condition text and changes no anatomy.
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	var selected_before: String = viewer.model.selected_id
	query(viewer, "aortic stenosis")
	viewer.on_search_selected(viewer.search_results.item_count - 1)
	await process_frame
	var dialog: Window = null
	for child in viewer.get_children():
		if child is AcceptDialog and "Aortic stenosis" in child.title:
			dialog = child
	check(dialog != null and "REFERENCE ANATOMY ONLY" in dialog.message and "nhlbi.nih.gov" in dialog.message, "Choosing it opens the draft condition text with sources")
	check(viewer.model.selected_id == selected_before and viewer.model.export_state() == anatomy, "Opening the condition changes no anatomy state")
	if dialog != null:
		dialog.custom_action.emit("reference")
		await process_frame
	var valve: String = content.structure_id("anatomy.heart.valve.aortic", viewer.model.structures)
	check(not valve.is_empty() and viewer.model.isolated_id == valve, "Inspect reference anatomy isolates the aortic valve")
	# The male body lists its own conditions.
	await viewer.switch_body("male")
	query(viewer, "prostate")
	var prostate: Array = condition_rows(viewer)
	check(not prostate.is_empty(), "The male body lists its prostate conditions")
	for id in prostate:
		check(content.condition_available(id, viewer.model.structures), "Listed male condition is offered: " + id)
	query(viewer, "")
	check(viewer.tree.visible and not viewer.search_results.visible, "Clearing search restores the hierarchy")
	print("Condition search failures: ", failures)
	quit(0 if failures == 0 else 1)
