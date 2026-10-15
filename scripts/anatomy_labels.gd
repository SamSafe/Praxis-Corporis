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
var text_scale := 1.0
var suspended := false
var buttons: Dictionary = {}
var anchors: Dictionary = {}
var visible_ids: Array[String] = []
var elapsed := 0.0
var rays_left := 0
var exclusion_controls: Array[Control] = []
var selection_actions
var action_anchor := Vector2(INF, INF)


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
	action_anchor = Vector2(INF, INF)
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
	action_anchor = Vector2(INF, INF)
	for button in buttons.values():
		button.visible = false
	if suspended or model == null or camera == null or size.x < 80 or size.y < 80:
		queue_redraw()
		return
	var candidates: Array[String] = []
	var parts: Array[String] = []
	if local_enabled:
		parts = local_ids()
	var actions_visible: bool = selection_actions != null and selection_actions.visible
	if actions_visible:
		selection_actions.anchored = false
		selection_actions.position = selection_actions.fallback
		selection_actions.size = selection_actions.custom_minimum_size
	if (selection_enabled or actions_visible) and model.structures.has(model.selected_id):
		candidates.append(model.selected_id)
	elif parts.has(model.selected_id):
		candidates.append(model.selected_id)
	if local_enabled:
		for id in parts:
			if not candidates.has(id):
				candidates.append(id)
	var occupied: Array[Rect2] = []
	# Convert each overlay's position into scene-surface logical coordinates.
	for control in exclusion_controls:
		if is_instance_valid(control) and control.is_visible_in_tree():
			var local_position := get_global_transform().affine_inverse() * control.global_position
			occupied.append(Rect2(local_position, control.size))
	var fallback_rect := Rect2()
	if actions_visible:
		fallback_rect = Rect2(selection_actions.position, selection_actions.size)
		occupied.append(fallback_rect)
	for id in candidates:
		var selected_actions: bool = actions_visible and id == model.selected_id
		if visible_ids.size() >= density and not selected_actions:
			break
		var anchor := surface_anchor(id)
		if anchor.is_empty():
			continue
		var button: Button = buttons[id] if buttons.has(id) else make_button(id)
		var font_size := roundi(14 * text_scale)
		button.add_theme_font_size_override("font_size", font_size)
		var font := button.get_theme_font("font")
		var width := clampf(font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 28, 100, minf(220 * text_scale, size.x - 16))
		var label_wanted: bool = id != model.selected_id or selection_enabled or parts.has(id)
		var height := maxf(34, 34 * text_scale)
		var extent := Vector2(width, height) if label_wanted else Vector2.ZERO
		var label_extent := extent
		if selected_actions:
			occupied.erase(fallback_rect)
			extent = Vector2(extent.x + (6 if label_wanted else 0) + selection_actions.size.x, maxf(height, selection_actions.size.y))
		var point: Vector2 = anchor.screen
		var placed := place_rect(point, extent, occupied)
		if selected_actions:
			if placed.is_finite():
				selection_actions.position = placed + Vector2(label_extent.x + (6 if label_wanted else 0), 0)
				selection_actions.anchored = true
				action_anchor = point
			else:
				occupied.append(fallback_rect)
				if label_wanted:
					extent = label_extent
					placed = place_rect(point, extent, occupied)
		if not placed.is_finite():
			continue
		occupied.append(Rect2(placed, extent))
		if label_wanted:
			button.position = placed
			button.size = label_extent
			button.add_theme_color_override("font_color", Color("ffe0b6") if id == model.selected_id else Color("bce5e0"))
			button.visible = true
			anchors[id] = point
			visible_ids.append(id)
	queue_redraw()


func place_rect(point: Vector2, extent: Vector2, occupied: Array[Rect2]) -> Vector2:
	if extent.x <= 0 or extent.x > size.x - 16 or extent.y > size.y - 16:
		return Vector2(INF, INF)
	# Try both sides, then increasingly distant rows, without overlapping controls.
	for row in [0, -1, 1, -2, 2, -3, 3, -4, 4]:
		for side in [1, -1]:
			var position := point + Vector2(22 if side == 1 else -extent.x - 22, -17 + row * 40)
			position = position.clamp(Vector2(8, 8), size - extent - Vector2(8, 8))
			var rect := Rect2(position, extent)
			var overlaps := rect.grow(6).has_point(point)
			for other in occupied:
				overlaps = overlaps or rect.grow(4).intersects(other)
			if not overlaps:
				return position
	return Vector2(INF, INF)


func _physics_process(delta: float) -> void:
	# Bound both ray-query frequency and candidate count, independent of atlas size.
	elapsed += delta
	if elapsed >= 0.1:
		elapsed = 0.0
		update_labels()


func _draw() -> void:
	if action_anchor.is_finite() and not anchors.has(model.selected_id):
		var end := action_anchor.clamp(selection_actions.position, selection_actions.position + selection_actions.size)
		draw_line(action_anchor, end, Color("edb877"), 1.5, true)
		draw_circle(action_anchor, 3, Color("edb877"), true, -1, true)
	for id in visible_ids:
		var button: Button = buttons[id]
		var point: Vector2 = anchors[id]
		var end := point.clamp(button.position, button.position + button.size)
		var color := Color("edb877") if id == model.selected_id else Color("71b9b6")
		draw_line(point, end, color, 1.5, true)
		draw_circle(point, 3, color, true, -1, true)
