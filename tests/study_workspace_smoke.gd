extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const ViewCapture = preload("res://scripts/view_capture.gd")
var failures := 0
var rendered := false
var viewer


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func capture(name: String) -> void:
	if not rendered:
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("/tmp/medicine-improvements/" + name + ".png") == OK, "Capture " + name)


func _initialize() -> void:
	rendered = DisplayServer.get_name() != "headless"
	call_deferred("run")


func run() -> void:
	viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	for reference in ["female", "male"]:
		if viewer.model.body.id != reference:
			await viewer.switch_body(reference)
		for id in viewer.study_content.data.cards:
			check(viewer.model.structures.has(id), "Study card maps to actual geometry: " + id)
			for related in viewer.study_content.card(id).related:
				check(viewer.model.structures.has(related), "Study relationship maps to this reference")
		viewer.select_structure("anatomy.heart")
		check("Pumps blood" in viewer.study_summary.text and viewer.study_links.get_child_count() == 5, "Heart card shows authored text, relationships and primary sources")
		viewer.study_links.get_child(0).pressed.emit()
		check(viewer.model.selected_id == "anatomy.heart.chambers", "Related-structure links can rebuild their own controls safely")
		viewer.select_structure("anatomy.heart")
		viewer.model.checkpoint()
		viewer.model.offset_selection(Vector3(0.02, 0.01, 0))
		viewer.local_labels_button.button_pressed = false
		viewer.original_positions_button.button_pressed = false
		var before: Dictionary = viewer.export_view_state().duplicate(true)
		var undo: Array = viewer.model.undo_stack.duplicate(true)
		var back: Array = viewer.back_views.duplicate(true)
		viewer.start_guided_chest()
		check(viewer.guided_chest.active and viewer.guided_chest.visible, "Guide starts with visible controls")
		viewer.apply_chest_step(2)
		check(viewer.validate_view_state(viewer.export_view_state()).is_empty(), "Separated teaching views remain valid portable snapshots")
		check(not viewer.model.export_state().is_empty() and viewer.model.bounds_for("anatomy.heart").size.length() > 0.2, "Teaching layout separates actual chamber geometry")
		await capture("guided-chambers-" + reference)
		viewer.set_scene_expanded(true)
		check(viewer.guided_chest.get_parent() == viewer.expanded_scene and viewer.guided_chest.is_visible_in_tree(), "Guide remains available in expanded anatomy")
		await capture("guided-expanded-" + reference)
		viewer.set_scene_expanded(false)
		for index in [3, 4, 5, 1]:
			viewer.apply_chest_step(index)
			check(viewer.validate_view_state(viewer.export_view_state()).is_empty(), "Every guide step can be saved and restored")
		await viewer.finish_guided_chest()
		check(viewer.export_view_state() == before and viewer.model.undo_stack == undo and viewer.back_views == back, "Finishing restores original camera, edits, labels and histories exactly")
		await capture("study-card-" + reference)
		viewer.start_guided_chest()
		check(await viewer.restore_view_state(before) and not viewer.guided_chest.active and viewer.export_view_state() == before, "Restoring a saved view ends the teaching workspace cleanly")
	var snapshot: Dictionary = viewer.export_view_state().duplicate(true)
	var preference_path := "user://workspace-preferences-" + Crypto.new().generate_random_bytes(8).hex_encode() + ".json"
	viewer.preferences.path = preference_path
	viewer.preferences_active = true
	viewer.on_panel_action(0)
	viewer.set_scene_resolution(0.75)
	check(viewer.preferences.load_settings().is_empty() and not viewer.preferences.values.explorer and viewer.preferences.values.resolution == 0.75, "Workspace preference controls persist panel and resolution changes")
	viewer.on_panel_action(0)
	viewer.set_scene_resolution(1.0)
	viewer.preferences_active = false
	DirAccess.remove_absolute(preference_path)
	var settings: Dictionary = viewer.preference_state()
	settings.text_scale = 1.3
	viewer.apply_preferences(settings)
	root.size = Vector2i(1100, 720)
	await process_frame
	await process_frame
	check(viewer.export_view_state() == snapshot and viewer.heading.get_theme_font_size("font_size") == 30, "Text scaling preserves the exploration and scales explicit headings")
	for control in [viewer.body_choice, viewer.guide_button, viewer.panels_menu]:
		check(control.get_global_rect().end.x <= viewer.size.x + 1, "Compact header keeps controls inside the window")
	await capture("large-text-compact")
	viewer.apply_preferences(viewer.ViewerPreferences.DEFAULTS)
	root.size = Vector2i(1440, 900)
	for reference in viewer.pack.bodies:
		if reference.get("study_kind") != "hra-spinal":
			continue
		await viewer.switch_body(reference.id)
		check(viewer.model.body.id == reference.id and viewer.model.meshes.size() > 20, "Source study loads its exact mapped meshes")
		check(viewer.guide_button.disabled and viewer.peel_button.disabled, "Source studies disable absent chest and skin actions")
		viewer.select_structure(reference.qa_leaf_id)
		viewer.inspect_alone()
		check(viewer.validate_view_state(viewer.export_view_state()).is_empty(), "Spinal isolation remains compatible with saves")
		viewer.return_to_context()
		check(viewer.model.isolated_id.is_empty(), "Spinal inspection returns to its own source context")
		var coverage: Window = viewer.show_coverage()
		check(coverage.notes.reference_ids == [reference.id], "Source study has its own coverage record")
		coverage.queue_free()
		var credits := ViewCapture.credits(reference, "")
		check("v1.2" in credits and "BodyParts3D" not in credits and reference.source_url in credits, "Spinal exports retain the correct source and licence")
		for structure in reference.structures:
			if structure.get("metadata_gap") and structure.source_name == "VH_F_lumbar_vertebra_6":
				viewer.select_structure(structure.id)
				check("Unlabelled source" in viewer.heading.text and "metadata gap" in viewer.study_summary.text, "Missing source metadata is shown without inventing an interpretation")
		await capture(str(reference.id))
	await viewer.switch_body("female")
	viewer.select_structure("anatomy.heart.valve.mitral")
	viewer.inspect_alone()
	var temporary := "user://workspace-transfer-" + Crypto.new().generate_random_bytes(8).hex_encode()
	viewer.views_path = temporary + ".json"
	var browser: Window = viewer.show_saved_views()
	browser.name_input.text = "Mitral study"
	browser.save_current()
	browser.notes_input.text = "Review the supplied valve geometry."
	browser.save_notes()
	check(browser.library.export_library(temporary + "-export.json").is_empty(), "UI library exports notes and snapshots")
	browser.preview_import(temporary + "-export.json")
	check(browser.import_plan.imported == 0 and browser.import_plan.skipped == 1, "Import UI previews already-present views")
	await capture("portable-views-preview")
	browser.queue_free()
	await process_frame
	for suffix in [".json", ".json.bak", "-export.json"]:
		DirAccess.remove_absolute(temporary + suffix)
	viewer.queue_free()
	await process_frame
	print("Study workspace failures: ", failures)
	quit(0 if failures == 0 else 1)
