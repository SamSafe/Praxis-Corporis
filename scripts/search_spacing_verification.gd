extends RefCounted
## Disposable search fixtures; no clipboard access or persistent user changes.

const Search = preload("res://scripts/anatomy_search.gd")
const Browser = preload("res://scripts/saved_views_browser.gd")
const SavedViews = preload("res://scripts/saved_views.gd")
const StudyVerification = preload("res://scripts/study_verification.gd")
const WHITE_SPACE := [0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x0020, 0x0085,
	0x00A0, 0x1680, 0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006,
	0x2007, 0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000]


static func check(condition: bool, context: String) -> bool:
	if not condition:
		push_error("Search spacing: " + context)
	return condition


static func run(viewer: Control) -> bool:
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	var undo: Array = viewer.model.undo_stack.duplicate(true)
	var redo: Array = viewer.model.redo_stack.duplicate(true)
	var back: Array = viewer.back_views.duplicate(true)
	var forward: Array = viewer.forward_views.duplicate(true)
	var source_records: Dictionary = viewer.model.structures.duplicate(true)
	var original_query: String = viewer.search.text
	var query := ""
	for record in source_records.values():
		if not record.get("mesh_nodes", []).is_empty() and " " in str(record.label):
			query = str(record.label)
			break
	var baseline: Dictionary = viewer.search_index.find(query)
	var valid := check(not query.is_empty() and baseline.total > 0, "multiword source fixture")
	var library := SavedViews.new()
	library.path = "user://search-spacing-" + Crypto.new().generate_random_bytes(16).hex_encode() + ".json"
	valid = library.load_library().is_empty() and valid
	valid = library.add_view("Left\u00a0review", before).is_empty() and valid
	if not StudyVerification.has_fixture_entries(library, 1, "search-spacing"):
		return false
	var first: String = library.entries[0].id
	valid = library.set_notes(first, "Saved\u202fnote\nCafé 🫀").is_empty() and valid
	valid = library.add_view("Other view", before).is_empty() and valid
	if not StudyVerification.has_fixture_entries(library, 2, "search-spacing"):
		return false
	var bytes_before := FileAccess.get_file_as_bytes(library.path)
	var browser := Browser.new()
	browser.library = library
	browser.pack = viewer.pack
	browser.current_state = before
	browser.validate_state = viewer.validate_view_state
	viewer.add_child(browser)
	# Opening the browser reloads JSON numbers; compare subsequent filtering with
	# that loaded representation rather than the pre-serialization dictionaries.
	var entries_before: Array = library.entries.duplicate(true)
	valid = check(library.entries[1].name == "Left\u00a0review" and library.entries[1].notes == "Saved\u202fnote\nCafé 🫀", "stored Unicode text") and valid
	browser.draft_notes[first] = "Draft\u2003token"
	var drafts: Dictionary = browser.draft_notes.duplicate(true)
	for code in WHITE_SPACE:
		var space := String.chr(code)
		valid = check(Search.normalize_spaces(space + "left" + space + space + "atrium" + space) == "left atrium", "normalization U+%04X" % code) and valid
		valid = check(Search.normalize_spaces(space).is_empty(), "blank normalization U+%04X" % code) and valid
		valid = check(viewer.search_index.find(space + query.replace(" ", space + space) + space) == baseline, "ordered source matches U+%04X" % code) and valid
		for phrase in ["left review", "saved note", "draft token"]:
			browser.filter_input.text = phrase.replace(" ", space)
			browser.apply_filter(browser.filter_input.text)
			valid = check(browser.view_list.item_count == 1 and browser.view_list.get_item_metadata(0) == first, "library match U+%04X" % code) and valid
		browser.filter_input.text = space
		browser.apply_filter(space)
		valid = check(browser.view_list.item_count == 2, "blank library filter U+%04X" % code) and valid
	# These format characters are not Unicode White_Space; retain them verbatim.
	for code in [0x180E, 0x200B, 0x200C, 0x200D, 0x2060, 0xFEFF]:
		var text := "left" + String.chr(code) + "atrium"
		valid = check(Search.normalize_spaces(text) == text and Browser.search_text(text) == text, "format character retention U+%04X" % code) and valid
	valid = check(Search.words("left_atrium") == "left atrium" and Browser.search_text("left_atrium") == "left_atrium", "underscore behavior") and valid
	# The visible list follows the catalogue ranking, then any text-only cards and
	# conditions whose titles match; ordinary spaces give the expected list.
	viewer.search.text = query
	viewer.rebuild_tree()
	var expected_total: int = viewer.search_total
	var expected_ids: Array = []
	for index in viewer.search_results.item_count:
		expected_ids.append(viewer.search_results.get_item_metadata(index))
	valid = check(expected_total >= baseline.total and expected_ids.slice(0, baseline.results.size()) == baseline.results.map(func(r): return r.id), "catalogue results lead the visible list") and valid
	for code in [0x00A0, 0x202F, 0x2003, 0x3000]:
		var space := String.chr(code)
		viewer.search.text = query.replace(" ", space)
		viewer.rebuild_tree()
		valid = check(viewer.search_total == expected_total and viewer.search_results.item_count == expected_ids.size(), "visible anatomy results U+%04X" % code) and valid
		for index in expected_ids.size():
			valid = check(viewer.search_results.get_item_metadata(index) == expected_ids[index], "visible anatomy identity U+%04X" % code) and valid
		viewer.search.text = space + space
		viewer.rebuild_tree()
		viewer.activate_first_search_result()
		valid = check(viewer.tree.visible and not viewer.search_results.visible and not viewer.search_summary.visible and viewer.search_total == 0, "blank anatomy filter U+%04X" % code) and valid
	valid = check(library.entries == entries_before and FileAccess.get_file_as_bytes(library.path) == bytes_before and browser.draft_notes == drafts, "library bytes and drafts") and valid
	valid = check(viewer.model.structures == source_records and viewer.export_view_state() == before, "source records and scene") and valid
	valid = check(viewer.model.undo_stack == undo and viewer.model.redo_stack == redo and viewer.back_views == back and viewer.forward_views == forward, "scene histories") and valid
	viewer.search.text = original_query
	viewer.rebuild_tree()
	browser.queue_free()
	await viewer.get_tree().process_frame
	for suffix in ["", ".bak"]:
		var path: String = library.path + suffix
		if FileAccess.file_exists(path):
			valid = DirAccess.remove_absolute(path) == OK and valid
	if valid:
		print("PASS bundled search spacing: ", viewer.model.body.id, " · 25 Unicode spaces")
	else:
		push_error("Search spacing changed matching, source records, drafts or viewer state: " + str(viewer.model.body.id))
	return valid
