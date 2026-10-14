extends Control
## Camera-relative directions from a fingerprint-matched source frame.

signal view_requested(index: int)

const VIEW_NAMES := ["Front", "Back", "From body left", "From body right", "Above (angled)", "Below (angled)"]
var model: Node3D
var orbit: Node3D
var active := true
var bottom_padding := 12.0
var menu: MenuButton
var frame: Dictionary = {}
var document: Dictionary = {}
var reference_hash := ""
var previous_basis := Basis.IDENTITY


static func checked_frame(reference: Dictionary, data: Dictionary) -> Dictionary:
	if data.get("schema_version") != 1 or not data.get("references") is Dictionary:
		return {}
	var candidate = data.references.get(str(reference.get("id", "")), {})
	if not candidate is Dictionary or candidate.get("source_sha256", "") != reference.get("sha256", "missing"):
		return {}
	var result := {}
	for key in ["left", "superior", "anterior"]:
		var values = candidate.get(key)
		if not values is Array or values.size() != 3:
			return {}
		for value in values:
			if not (value is float or value is int) or not is_finite(float(value)):
				return {}
		var vector := Vector3(float(values[0]), float(values[1]), float(values[2]))
		if not is_equal_approx(vector.length_squared(), 1.0):
			return {}
		result[key] = vector
	if not result.left.cross(result.superior).is_equal_approx(result.anterior):
		return {}
	return result


static func view_direction(axes: Dictionary, index: int) -> Vector3:
	if axes.is_empty() or index < 0 or index >= VIEW_NAMES.size():
		return Vector3.ZERO
	match index:
		0: return axes.anterior
		1: return -axes.anterior
		2: return axes.left
		3: return -axes.left
		4: return (axes.superior + axes.anterior * 0.15).normalized()
		5: return (-axes.superior + axes.anterior * 0.15).normalized()
	return Vector3.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "Source body directions: L left · R right · A front · P back · S above · I below.\nLeft/right refer to the body's sides. Geometry checked; medical review pending."
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/reference_frames.json")) if FileAccess.file_exists("res://content/reference_frames.json") else null
	if parsed is Dictionary:
		document = parsed
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	set_padding(bottom_padding)
	menu = MenuButton.new()
	menu.text = "Camera views"
	menu.flat = false
	menu.focus_mode = Control.FOCUS_ALL
	menu.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	menu.custom_minimum_size.y = 34
	menu.tooltip_text = "Rotate around the current focus; preserve camera distance and anatomy edits."
	add_child(menu)
	for index in VIEW_NAMES.size():
		menu.get_popup().add_radio_check_item(VIEW_NAMES[index], index)
	menu.about_to_popup.connect(refresh_menu)
	menu.get_popup().id_pressed.connect(func(index: int): view_requested.emit(index))
	refresh_reference()


func set_padding(value: float) -> void:
	bottom_padding = value
	offset_left = -166
	offset_right = -12
	offset_top = -166 - value
	offset_bottom = -value


func refresh_reference() -> void:
	reference_hash = str(model.body.get("sha256", ""))
	frame = checked_frame(model.body, document)
	queue_redraw()


func refresh_menu() -> void:
	var direction: Vector3 = (orbit.camera.position - orbit.target).normalized()
	for index in VIEW_NAMES.size():
		menu.get_popup().set_item_checked(index, not frame.is_empty() and direction.is_equal_approx(view_direction(frame, index)))


func _process(_delta: float) -> void:
	if str(model.body.get("sha256", "")) != reference_hash:
		refresh_reference()
	menu.disabled = not active or frame.is_empty()
	if orbit.camera.global_basis != previous_basis:
		previous_basis = orbit.camera.global_basis
		queue_redraw()


func projected_directions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if frame.is_empty():
		return result
	var basis: Basis = orbit.camera.global_basis.inverse()
	for axis in [["L", frame.left], ["R", -frame.left], ["S", frame.superior], ["I", -frame.superior], ["A", frame.anterior], ["P", -frame.anterior]]:
		var direction: Vector3 = basis * axis[1]
		result.append({"label": axis[0], "point": Vector2(77, 96) + Vector2(direction.x, -direction.y) * 37, "depth": direction.z})
	result.sort_custom(func(a: Dictionary, b: Dictionary): return a.depth < b.depth)
	return result


func _draw() -> void:
	if menu == null:
		return
	var style := get_theme_stylebox("panel", "PanelContainer")
	draw_style_box(style, Rect2(0, 39, size.x, size.y - 39))
	var font := get_theme_default_font()
	if frame.is_empty():
		draw_string(font, Vector2(10, 95), "Orientation unavailable", HORIZONTAL_ALIGNMENT_LEFT, size.x - 20, 12, Color("b5c7d8"))
		return
	for axis in projected_directions():
		var color := Color("83cfc9") if axis.depth >= -0.05 else Color("758ca2")
		draw_line(Vector2(77, 96), axis.point, color, 1.5, true)
		draw_circle(axis.point, 11, Color("172433"), true, -1, true)
		draw_circle(axis.point, 11, color, false, 1.0, true)
		var width := font.get_string_size(axis.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		draw_string(font, axis.point + Vector2(-width * 0.5, 4.5), axis.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
	draw_string(font, Vector2(13, 153), "L/R: body's sides", HORIZONTAL_ALIGNMENT_CENTER, size.x - 26, 12, Color("b5c7d8"))
