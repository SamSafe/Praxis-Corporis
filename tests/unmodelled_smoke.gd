extends SceneTree
## Structures no open source models (scrotum, vulva, adenoids, lingual tonsils, and the
## parotid glands on the complete body): found by name, read as text with sources and conditions, and located only
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
	# Search finds an unmodelled structure by name, after any supplied records and
	# before conditions whose titles match.
	viewer.search.text = "vulva"
	viewer.rebuild_tree()
	var last := -1
	for index in viewer.search_results.item_count:
		if str(viewer.search_results.get_item_metadata(index)).begins_with(viewer.UNMODELLED_PREFIX):
			last = index
	check(last >= 0 and not str(viewer.search_results.get_item_metadata(last - 1 if last > 0 else 0)).begins_with(viewer.CONDITION_PREFIX), "Conditions follow the text-only card")
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
	# The parotid glands are modelled on this body (traced from the Visible Human CT).
	var parotid_id: String = content.structure_id("anatomy.parotid-glands", viewer.model.structures)
	check(not parotid_id.is_empty() and not content.unmodelled("anatomy.parotid-glands", viewer.model.structures), "The female body models the parotid glands")
	check(viewer.model.structures[parotid_id].mesh_nodes.size() == 2, "Both glands have geometry")
	check(content.find_unmodelled("parotid", viewer.model.structures).is_empty(), "Search finds the real glands, not a text-only entry")
	check(content.condition_focus("condition.mumps", viewer.model.structures) == parotid_id, "Mumps locates the modelled glands")
	var mumps: Window = viewer.show_condition("condition.mumps")
	check(mumps != null and "REFERENCE ANATOMY ONLY" in mumps.message and button(mumps, "Inspect reference anatomy") != null, "Mumps reads as an ordinary located condition here")
	if mumps != null:
		mumps.hide()
		mumps.queue_free()
	# Nothing nearby on this body: text only, no locate action.
	check(content.stand_in("anatomy.scrotum", viewer.model.structures).is_empty(), "The female body has no scrotum neighbour")
	var hydrocele: Window = viewer.show_condition("condition.hydrocele")
	check(hydrocele != null and "NO 3D MODEL" in hydrocele.message and button(hydrocele, "Inspect reference anatomy") == null, "Hydrocele reads as text only on the female body")
	if hydrocele != null:
		hydrocele.hide()
		hydrocele.queue_free()
	var scrotum: Window = viewer.show_unmodelled_card("anatomy.scrotum")
	check(scrotum != null and button(scrotum, "Locate nearby anatomy") == null and "no nearby supplied anatomy" in scrotum.message, "The scrotum card says nothing nearby is supplied here")
	if scrotum != null:
		scrotum.hide()
		scrotum.queue_free()
	# No other unmodelled card resolves to geometry.
	for id in ["anatomy.scrotum", "anatomy.vulva", "anatomy.adenoids", "anatomy.lingual-tonsils"]:
		check(content.unmodelled(id, viewer.model.structures) and content.structure_id(id, viewer.model.structures).is_empty(), "No geometry for " + id)
	# The complete body locates the parotid glands through its salivary glands.
	if "bodyparts-male-complete" in viewer.pack.bodies.map(func(b): return b.id):
		await viewer.switch_body("bodyparts-male-complete")
		var near: String = content.stand_in("anatomy.parotid-glands", viewer.model.structures)
		check(near == content.structure_id("anatomy.salivary-glands", viewer.model.structures) and not near.is_empty(), "Complete body: parotid glands sit near the salivary glands")
		check(content.unmodelled("anatomy.parotid-glands", viewer.model.structures) and content.find_unmodelled("parotid", viewer.model.structures) == ["anatomy.parotid-glands"], "Complete body: the parotid glands stay text-only")
		check(content.stand_in("anatomy.scrotum", viewer.model.structures) == content.structure_id("anatomy.testes", viewer.model.structures), "Complete body: scrotum sits near the testes")
		check(content.condition_available("condition.testicular-torsion", viewer.model.structures), "Testicular torsion is offered where the testes are supplied")
	print("Unmodelled structure failures: ", failures)
	quit(0 if failures == 0 else 1)
