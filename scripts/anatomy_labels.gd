extends Control
## Screen-space labels anchored only to a first-hit, opaque anatomy surface.

signal selected(id: String)

const MAX_CANDIDATES := 64
const MAX_RAYS := 160
var model: Node3D
var camera: Camera3D
var scene_surface: Control
var context_id := ""
var selection_enabled := true
var local_enabled := false
var density := 8
var suspended := false
var buttons: Dictionary = {}
var anchors: Dictionary = {}
var visible_ids: Array[String] = []
var elapsed := 0.0
var rays_left := 0
var exclusion_controls: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true


func set_selection(id: String) -> void:
	# Keep an organ's local set while selecting one of its supplied components.
	if model.structures.has(context_id) and is_descendant(id, context_id):
		return
	context_id = ""
	if not model.structures.has(id):
		return
	var candidate := id
	while model.structures.has(candidate):
		var record: Dictionary = model.structures[candidate]
		if record.mesh_nodes.size() > 1 and record.mesh_nodes.size() <= MAX_CANDIDATES:
			context_id = candidate
			return
		if record.mesh_nodes.size() > MAX_CANDIDATES:
			return
		candidate = str(record.parent)


func is_descendant(id: String, ancestor: String) -> bool:
	while model.structures.has(id):
		if id == ancestor:
			return true
		id = str(model.structures[id].parent)
	return false


func local_ids() -> Array[String]:
	var result: Array[String] = []
	if not model.structures.has(context_id):
		return result
	var pending: Array[String] = [context_id]
	while not pending.is_empty() and result.size() < MAX_CANDIDATES:
		var id: String = pending.pop_front()
		var record: Dictionary = model.structures[id]
		if record.children.is_empty():
			if not record.mesh_nodes.is_empty():
				result.append(id)
		else:
			for child in record.children:
				pending.append(str(child))
	return result


func clear_labels() -> void:
	for button in buttons.values():
		button.free()
	buttons.clear()
	anchors.clear()
	visible_ids.clear()
	context_id = ""
	queue_redraw()


func surface_anchor(id: String) -> Dictionary:
	var record: Dictionary = model.structures[id]
	var allowed := {}
	for index in record.mesh_nodes:
		if model.effective_visibility(int(index)) == "visible":
			allowed[int(index)] = true
	if allowed.is_empty():
		return {}
	var bounds: AABB = model.bounds_for(id)
	var center := bounds.get_center()
	if camera.is_position_behind(center):
		return {}
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	for corner in range(8):
		var point := bounds.get_endpoint(corner)
		if camera.is_position_behind(point):
			return {}
		var projected := control_point(camera.unproject_position(point))
		minimum = minimum.min(projected)
		maximum = maximum.max(projected)
	var samples: Array[Vector2] = [control_point(camera.unproject_position(center))]
	for y in [0.25, 0.5, 0.75]:
		for x in [0.25, 0.5, 0.75]:
			samples.append(minimum + (maximum - minimum) * Vector2(x, y))
	for point in samples:
		if not Rect2(Vector2.ZERO, size).has_point(point):
			continue
		if rays_left == 0:
			return {}
		rays_left -= 1
		var hit: Dictionary = model.ray_hit(camera, viewport_point(point))
		if not hit.is_empty() and allowed.has(int(hit.collider.get_meta("mesh_index"))):
			# Use the actual visible triangle hit, never the bounds centre behind it.
			return {"screen": control_point(camera.unproject_position(hit.position)), "world": hit.position}
	return {}


func viewport_point(point: Vector2) -> Vector2:
	return scene_surface.viewport_point(point) if scene_surface != null else point


func control_point(point: Vector2) -> Vector2:
	return scene_surface.control_point(point) if scene_surface != null else point


func make_button(id: String) -> Button:
	var button := Button.new()
	button.text = str(model.structures[id].label)
	button.tooltip_text = button.text + " · select and focus"
	button.add_theme_font_size_override("font_size", 14)
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.clip_text = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(func(): selected.emit(id))
	add_child(button)
	buttons[id] = button
	return button


func update_labels() -> void:
	rays_left = MAX_RAYS
	visible_ids.clear()
	anchors.clear()
	for button in buttons.values():
		button.visible = false
	if suspended or model == null or camera == null or size.x < 80 or size.y < 80:
		queue_redraw()
		return
	var candidates: Array[String] = []
	var parts: Array[String] = []
	if local_enabled:
		parts = local_ids()
	if selection_enabled and model.structures.has(model.selected_id):
		candidates.append(model.selected_id)
	elif parts.has(model.selected_id):
		candidates.append(model.selected_id)
	if local_enabled:
		for id in parts:
			if not candidates.has(id):
				candidates.append(id)
	var occupied: Array[Rect2] = []
	# These overlays share the same scene-surface parent and logical coordinates.
	for control in exclusion_controls:
		if is_instance_valid(control) and control.is_visible_in_tree():
			occupied.append(Rect2(control.position, control.size))
	for id in candidates:
		if visible_ids.size() >= density:
			break
		var anchor := surface_anchor(id)
		if anchor.is_empty():
			continue
		var button: Button = buttons[id] if buttons.has(id) else make_button(id)
		var font := button.get_theme_font("font")
		var width := clampf(font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x + 28, 100, minf(220, size.x - 16))
		var extent := Vector2(width, 34)
		var point: Vector2 = anchor.screen
		var placed := false
		# Try both sides, then increasingly distant rows, without overlapping pills.
		for row in [0, -1, 1, -2, 2, -3, 3, -4, 4]:
			for side in [1, -1]:
				var position := point + Vector2(22 if side == 1 else -width - 22, -17 + row * 40)
				position = position.clamp(Vector2(8, 8), size - extent - Vector2(8, 8))
				var rect := Rect2(position, extent)
				var overlaps := false
				for other in occupied:
					overlaps = overlaps or rect.grow(4).intersects(other)
				if overlaps or rect.grow(6).has_point(point):
					continue
				button.position = position
				button.size = extent
				button.add_theme_color_override("font_color", Color("ffe0b6") if id == model.selected_id else Color("bce5e0"))
				button.visible = true
				anchors[id] = point
				visible_ids.append(id)
				occupied.append(rect)
				placed = true
				break
			if placed:
				break
	queue_redraw()


func _physics_process(delta: float) -> void:
	# Bound both ray-query frequency and candidate count, independent of atlas size.
	elapsed += delta
	if elapsed >= 0.1:
		elapsed = 0.0
		update_labels()


func _draw() -> void:
	for id in visible_ids:
		var button: Button = buttons[id]
		var point: Vector2 = anchors[id]
		var end := point.clamp(button.position, button.position + button.size)
		var color := Color("edb877") if id == model.selected_id else Color("71b9b6")
		draw_line(point, end, color, 1.5, true)
		draw_circle(point, 3, color, true, -1, true)
