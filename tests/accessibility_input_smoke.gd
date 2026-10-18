extends SceneTree

const UiAccessibility = preload("res://scripts/ui_accessibility.gd")


func _initialize() -> void:
	var field := UiAccessibility.ValueInput.new()
	field.max_length = 5
	var changes := []
	field.text_changed.connect(func(value: String): changes.append(value))
	field.set_accessible_value("Café 🫀")
	var valid := field.text == "Café " and changes == ["Café "]
	field.set_accessible_value("Café 🫀")
	valid = valid and changes.size() == 1
	field.editable = false
	field.set_accessible_value("other")
	valid = valid and field.text == "Café " and changes.size() == 1
	field.editable = true
	field.set_accessible_value(123)
	valid = valid and field.text == "Café " and changes.size() == 1
	field.set_accessible_value("")
	valid = valid and field.text.is_empty() and changes == ["Café ", ""]
	field.free()
	if not valid:
		push_error("Accessible value changes lost field limits, read-only state or single-change delivery")
	print("Accessible input failures: ", 0 if valid else 1)
	quit(0 if valid else 1)
