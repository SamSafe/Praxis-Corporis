extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const Browser = preload("res://scripts/saved_views_browser.gd")
var failures := 0
var directory := "user://view-context-" + Crypto.new().generate_random_bytes(8).hex_encode()
var catalogue := {"id": "context-test", "bodies": []}


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _initialize() -> void:
	call_deferred("run")


func state(body: String, hash: String) -> Dictionary:
	return {"pack_id": catalogue.id, "body": body, "reference_hash": hash, "selection": "part"}


func validate(snapshot: Dictionary) -> String:
	if snapshot.get("pack_id") != catalogue.id:
		return "Different content pack."
	for body in catalogue.bodies:
		if body.id == snapshot.get("body"):
			if snapshot.get("reference_hash", body.sha256) != body.sha256 or (body.get("study", false) and not snapshot.has("reference_hash")):
				return "Different source geometry."
			return ""
	return "Reference unavailable."


func filter(browser: Window, query: String) -> void:
	browser.filter_input.text = query
	browser.filter_input.text_changed.emit(query)


func scope(browser: Window, active: bool) -> void:
	browser.reference_only.button_pressed = active


func choose(browser: Window, id: String) -> void:
	for index in browser.view_list.item_count:
		if browser.view_list.get_item_metadata(index) == id:
			browser.view_list.select(index)
			browser.select_entry(index)
			return
	check(false, "Expected view is visible: " + id)


func run() -> void:
	catalogue.bodies = [
		{"id": "female", "label": "Female HRA", "short_label": "Female HRA", "sha256": "a".repeat(64), "structures": [{"id": "part", "label": "Mitral valve", "source_name": "VH_F_mitral_valve", "ontology": "UBERON:0002135"}]},
		{"id": "male", "label": "Male HRA", "short_label": "Male HRA", "sha256": "b".repeat(64), "structures": [{"id": "part", "label": "Mitral valve", "source_name": "VH_M_mitral_valve", "ontology": "UBERON:0002135"}]},
		{"id": "bones", "label": "Separate bone study", "short_label": "Bone study", "sha256": "d".repeat(64), "study": true, "structures": [{"id": "part", "label": "Right femur", "source_name": "FJ3365", "ontology": "FMA:24474"}]},
	]
	var snapshots := [state("female", "a".repeat(64)), state("male", "b".repeat(64)), state("bones", "d".repeat(64)), state("female", "c".repeat(64)), state("female", "a".repeat(64)), state("retired-study", "e".repeat(64)), state("bones", "d".repeat(64)), state("female", "a".repeat(64))]
	snapshots[4].erase("reference_hash") # Supported legacy HRA view.
	snapshots[5].selection = "archive.part"
	snapshots[6].erase("reference_hash") # Studies require a source fingerprint.
	snapshots[7].pack_id = "older-pack"
	DirAccess.make_dir_recursive_absolute(directory)
	var library := SavedViews.new()
	library.path = directory + "/views.json"
	library.load_library()
	var ids := []
	for index in snapshots.size():
		check(library.add_view("Review %d" % index, snapshots[index]).is_empty(), "Fixture saves")
		ids.append(library.entries[0].id)
	library.set_notes(ids[0], "courseword λ 🫀")
	var browser := Browser.new()
	browser.library = library
	browser.pack = catalogue
	browser.current_state = snapshots[0].duplicate(true)
	browser.validate_state = validate
	root.add_child(browser)
	browser.popup_centered(Vector2i(820, 660))
	await process_frame
	var restored := [0]
	browser.restore_requested.connect(func(_snapshot: Dictionary, _name: String): restored[0] += 1)
	var bytes_before := FileAccess.get_file_as_bytes(library.path)
	var entries_before := library.entries.duplicate(true)
	check(browser.view_list.item_count == 8 and not browser.reference_only.button_pressed and "Female HRA" in browser.reference_only.tooltip_text,
		"The library starts with all views and identifies the current reference")
	filter(browser, "UBERON0002135")
	check(browser.view_list.item_count == 3, "Ontology search resolves both bodies and supported legacy HRA, without borrowing labels for changed sources or packs")
	filter(browser, "VH_F_mitral_valve")
	check(browser.view_list.item_count == 2, "Source names stay bound to their own reference")
	filter(browser, "female courseword")
	check(browser.view_list.item_count == 1 and browser.view_list.get_item_metadata(0) == ids[0], "Words combine current reference metadata and Unicode study notes")
	browser.focus_first_match()
	check("Female HRA · Mitral valve" in browser.view_list.get_item_tooltip(0) and "Female HRA · Mitral valve" in browser.information.text,
		"List tooltips and selected details show the same reference and anatomy context")
	filter(browser, "FMA24474")
	check(browser.view_list.item_count == 1 and browser.view_list.get_item_metadata(0) == ids[2], "A study without its required fingerprint cannot borrow current anatomy metadata")
	filter(browser, "retired-study archive.part")
	check(browser.view_list.item_count == 1, "Unavailable views remain discoverable by recorded IDs")
	browser.focus_first_match()
	check(browser.restore_button.disabled and browser.notes_input.editable and "Reference unavailable" in browser.information.text, "Unavailable views keep their notes but cannot restore")
	filter(browser, "")
	choose(browser, ids[3])
	check(browser.restore_button.disabled and "Female HRA" not in browser.information.text and "Different source geometry" in browser.information.text,
		"A stale reference shows recorded IDs and its compatibility error")
	choose(browser, ids[0])
	browser.notes_input.text = "An unfinished context draft"
	browser.on_notes_changed()
	browser.delete_selected()
	scope(browser, true)
	check(browser.view_list.item_count == 4 and browser.selected_entry().get("id") == ids[0], "This reference uses exact body identity and retains selection")
	check(browser.delete_pending.is_empty() and browser.delete_button.text == "Delete" and browser.message.text.is_empty() and library.entries.size() == 8,
		"Changing reference scope cancels pending deletion and clears only its obsolete prompt")
	filter(browser, "FMA24474")
	check(browser.view_list.item_count == 0 and browser.draft_notes.get(ids[0]) == "An unfinished context draft", "Scope and query combine without losing a filtered-out draft")
	filter(browser, "")
	choose(browser, ids[0])
	browser.notes_input.set_caret_column(7)
	browser.name_input.text = "A name still being typed"
	scope(browser, false)
	check(browser.view_list.item_count == 8 and browser.notes_input.text == "An unfinished context draft" and browser.notes_input.get_caret_column() == 7 and browser.name_input.text == "A name still being typed",
		"Removing scope preserves the note, cursor and unfinished name")
	check(FileAccess.get_file_as_bytes(library.path) == bytes_before and library.entries == entries_before and browser.current_state == snapshots[0] and restored[0] == 0,
		"Searching and scoping never write snapshots, notes or current anatomy")
	choose(browser, ids[1])
	browser.delete_selected()
	browser.delete_selected()
	scope(browser, true)
	filter(browser, "mitral")
	browser.undo_delete()
	check(not browser.reference_only.button_pressed and browser.filter_input.text == "mitral" and browser.selected_entry().get("id") == ids[1] and browser.view_list.item_count == 3,
		"Undo reveals another reference by removing scope while retaining a matching anatomy query")
	check(browser.draft_notes.get(ids[0]) == "An unfinished context draft" and restored[0] == 0, "Undo across scope retains other drafts and never restores anatomy")
	browser.request_close()
	check(browser.unsaved_dialog.visible, "A draft hidden by context search still protects close")
	browser.queue_free()
	await process_frame
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)
	print("Saved-view context failures: ", failures)
	quit(0 if failures == 0 else 1)
