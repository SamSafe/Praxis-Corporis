extends SceneTree

var failures := 0
var viewer
var rendered := false


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func key(dialog: Window, code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	dialog.push_input(event)
	await process_frame


func inspect_dialog(dialog: Window, name: String) -> void:
	await process_frame
	await process_frame
	check(dialog.size.x <= root.size.x and dialog.size.y <= root.size.y, "Information window fits the compact desktop")
	check(dialog.content.get_global_rect().end.y <= dialog.size.y and dialog.get_ok_button().get_global_rect().end.y <= dialog.size.y, "Text and Close stay inside the dialog")
	check(dialog.content.get_parsed_text() == dialog.message, "Source URLs and punctuation remain plain selectable text")
	check(dialog.content.get_theme_font_size("normal_font_size") == 20, "Information text follows the 130% preference")
	var bar: VScrollBar = dialog.content.get_v_scroll_bar()
	if name == "keyboard":
		check(bar.max_value > bar.page, "Large help text has a scroll route")
		await key(dialog, KEY_PAGEDOWN)
		check(bar.value > 0, "Page Down actually scrolls focused help")
		await key(dialog, KEY_HOME)
	if rendered:
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png("/tmp/medicine-improvements/dialog-" + name + ".png") == OK, "Capture bounded dialog")
	await key(dialog, KEY_ESCAPE)
	await process_frame
	check(not is_instance_valid(dialog), "Escape closes and frees the information window")


func _initialize() -> void:
	rendered = DisplayServer.get_name() != "headless"
	call_deferred("run")


func run() -> void:
	viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	var startup: Window = viewer.show_sources()
	check("prototype" in startup.message, "Sources are available before the first reference has loaded")
	startup.queue_free()
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	var preferences: Dictionary = viewer.preference_state()
	preferences.text_scale = 1.3
	viewer.apply_preferences(preferences)
	root.size = Vector2i(1100, 720)
	await process_frame
	var before: Dictionary = viewer.export_view_state().duplicate(true)
	await inspect_dialog(viewer.show_keyboard_help(), "keyboard")
	check(viewer.export_view_state() == before, "Scrolling and closing help preserves exploration")
	for reference in viewer.pack.bodies:
		if viewer.model.body.id != reference.id:
			await viewer.switch_body(reference.id)
		before = viewer.export_view_state().duplicate(true)
		var dialog: Window = viewer.show_sources()
		check("https://" in dialog.message and "review" in dialog.message.to_lower(), "Source information retains URLs and draft status")
		await inspect_dialog(dialog, str(reference.id))
		check(viewer.export_view_state() == before, "Reading sources preserves the reference exploration")
	viewer.queue_free()
	await process_frame
	print("Information dialog failures: ", failures)
	quit(0 if failures == 0 else 1)
