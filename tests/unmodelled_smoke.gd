extends SceneTree
## Structures no open source models (parotid glands, scrotum, vulva, adenoids, lingual
## tonsils): found by name, read as text with sources and conditions, and located only
## through nearby supplied anatomy. No geometry is invented for them.

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func link_texts(container: Control) -> Array:
	return container.get_children().filter(func(c): return c is LinkButton).map(func(c): return c.text)


func button(dialog: Window, text: String) -> Button:
	for child in dialog.find_children("*", "Button", true, false):
		if child is Button and child.text == text:
			return child
	return null


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	while viewer.loading:
		await process_frame
	if viewer.model.body.id != "female":
		await viewer.switch_body("female")
	var content = viewer.study_content
	var anatomy: Dictionary = viewer.model.export_state().duplicate(true)
	# Search finds an unmodelled structure by name, after any supplied records.
	viewer.search.text = "vulva"
	viewer.rebuild_tree()
	var last: int = viewer.search_results.item_count - 1
	check(last >= 0 and str(viewer.search_results.get_item_metadata(last)) == viewer.UNMODELLED_PREFIX + "anatomy.vulva", "Search lists the vulva card")
	check(last >= 0 and "No 3D model" in viewer.search_results.get_item_text(last) and "Vagina" in viewer.search_results.get_item_text(last), "The result says it has no model and names the nearby part")
	var selected_before: String = viewer.model.selected_id
	viewer.on_search_selected(last)
	await process_frame
	var dialog: Window = null
	for child in viewer.get_children():
		if child is AcceptDialog and "Vulva" in child.title:
			dialog = child
	check(dialog != null and "No 3D model" in dialog.message and "nci-def-vulva" not in dialog.message and "cancer.gov" in dialog.message, "Choosing it opens the study card with sources")
	check(viewer.model.selected_id == selected_before and viewer.model.export_state() == anatomy, "Opening the card changes no anatomy state")
	check(dialog != null and button(dialog, "Locate nearby anatomy") != null and button(dialog, "Vulvar cancer") != null, "The card offers locate and its conditions")
	if dialog != null:
		dialog.custom_action.emit("locate")
		await process_frame
	var vagina: String = content.structure_id("anatomy.vagina", viewer.model.structures)
	check(not vagina.is_empty() and viewer.model.selected_id == vagina, "Locate selects the vagina, the nearest supplied structure")
	check(viewer.model.export_state().get("states", anatomy.get("states")) == anatomy.get("states"), "Locating changes no visibility or position state")
	viewer.search.text = ""
	viewer.rebuild_tree()
	# The supplied neighbour's panel lists the unmodelled card and its conditions.
	viewer.refresh_study_content()
	check("Vulva · no 3D model" in link_texts(viewer.study_links), "The vagina's panel links the vulva card")
	var conditions: Array = link_texts(viewer.condition_links)
	for title in ["Vulvar cancer", "Vulvodynia", "Bartholin cyst or abscess"]:
		check(title in conditions, "The vagina's panel offers " + title)
	var condition: Window = viewer.show_condition("condition.vulvodynia")
	check(condition != null and "NO 3D MODEL" in condition.message and button(condition, "Inspect reference anatomy") != null, "Condition text says no model and still locates nearby anatomy")
	if condition != null:
		condition.hide()
		condition.queue_free()
	check(content.condition_focus("condition.vulvodynia", viewer.model.structures) == vagina, "The condition's focus is the stand-in structure")
	# Nothing nearby on this body: text only, no locate action.
	check(content.stand_in("anatomy.parotid-glands", viewer.model.structures).is_empty(), "The female body has no parotid neighbour")
	var mumps: Window = viewer.show_condition("condition.mumps")
	check(mumps != null and button(mumps, "Inspect reference anatomy") == null, "Mumps reads as text only on the female body")
	if mumps != null:
		mumps.hide()
		mumps.queue_free()
	var parotid: Window = viewer.show_unmodelled_card("anatomy.parotid-glands")
	check(parotid != null and button(parotid, "Locate nearby anatomy") == null and "no nearby supplied anatomy" in parotid.message, "The parotid card says nothing nearby is supplied here")
	if parotid != null:
		parotid.hide()
		parotid.queue_free()
	# No unmodelled card ever resolves to geometry.
	for id in ["anatomy.parotid-glands", "anatomy.scrotum", "anatomy.vulva", "anatomy.adenoids", "anatomy.lingual-tonsils"]:
		check(content.unmodelled(id) and content.structure_id(id, viewer.model.structures).is_empty(), "No geometry for " + id)
	# The complete body locates the parotid glands through its salivary glands.
	if "bodyparts-male-complete" in viewer.pack.bodies.map(func(b): return b.id):
		await viewer.switch_body("bodyparts-male-complete")
		var near: String = content.stand_in("anatomy.parotid-glands", viewer.model.structures)
		check(near == content.structure_id("anatomy.salivary-glands", viewer.model.structures) and not near.is_empty(), "Complete body: parotid glands sit near the salivary glands")
		check(content.stand_in("anatomy.scrotum", viewer.model.structures) == content.structure_id("anatomy.testes", viewer.model.structures), "Complete body: scrotum sits near the testes")
		check(content.condition_available("condition.testicular-torsion", viewer.model.structures), "Testicular torsion is offered where the testes are supplied")
	print("Unmodelled structure failures: ", failures)
	quit(0 if failures == 0 else 1)
