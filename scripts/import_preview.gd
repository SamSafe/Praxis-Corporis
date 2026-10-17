extends ConfirmationDialog
## Keep a long compatibility preview readable before choosing an import action.

var message := ""
var content: RichTextLabel


func _ready() -> void:
	transient = true
	exclusive = true
	content = RichTextLabel.new()
	content.text = message
	content.bbcode_enabled = false
	content.selection_enabled = true
	content.focus_mode = Control.FOCUS_ALL
	content.custom_minimum_size = Vector2(540, 240)
	content.add_theme_font_size_override("normal_font_size", theme.default_font_size)
	content.tooltip_text = "Page Up/Down scroll; Ctrl/Cmd+A selects the preview. Tab reaches Import and Cancel; Escape cancels."
	add_child(content)


func open(preferred_size: Vector2i) -> void:
	popup_centered_clamped(preferred_size, 0.9)
	content.grab_focus()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if event.keycode == KEY_ESCAPE:
		set_input_as_handled()
		hide()
		canceled.emit()
	elif content.has_focus() and event.is_action_pressed("ui_accept"):
		set_input_as_handled()
