extends AcceptDialog
## Long help and source text stays inside a bounded, keyboard-scrollable window.

var message := ""
var content: RichTextLabel


func _ready() -> void:
	transient = true
	exclusive = true
	ok_button_text = "Close"
	content = RichTextLabel.new()
	content.text = message
	content.bbcode_enabled = false
	content.selection_enabled = true
	content.focus_mode = Control.FOCUS_ALL
	content.custom_minimum_size = Vector2(300, 240)
	content.add_theme_font_size_override("normal_font_size", theme.default_font_size)
	content.set_meta("base_normal_font_size", 15)
	add_child(content)
	confirmed.connect(queue_free)
	canceled.connect(queue_free)


func open(preferred_size: Vector2i) -> void:
	popup_centered_clamped(preferred_size, 0.9)
	content.grab_focus()


func _input(event: InputEvent) -> void:
	# Selectable text can consume Escape; the window must keep a clear exit route.
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		set_input_as_handled()
		hide()
		canceled.emit()
