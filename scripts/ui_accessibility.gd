extends RefCounted
## Semantic names and the pinned engine's accessibility value-change bridge.


class ValueInput extends LineEdit:
	func _notification(what: int) -> void:
		if what == NOTIFICATION_ACCESSIBILITY_UPDATE:
			var element := get_accessibility_element()
			if element.is_valid():
				AccessibilityServer.update_add_action(element, AccessibilityServer.ACTION_SET_VALUE, set_accessible_value)


	func set_accessible_value(value: Variant) -> void:
		if not editable or not value is String:
			return
		var previous := text
		text = value
		# Godot 4.7.2's native accessibility setter calls set_text without this
		# signal. Use the ordinary handlers, including the field's length limit.
		if text != previous:
			text_changed.emit(text)


static func describe(control: Control, name: String, description: String = "") -> void:
	control.accessibility_name = name
	control.accessibility_description = description if not description.is_empty() else control.tooltip_text
	for child in control.get_children(true):
		if child is ScrollBar:
			child.accessibility_name = "Scroll " + name.to_lower() + (" horizontally" if child is HScrollBar else " vertically")
