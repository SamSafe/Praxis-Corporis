extends TextureRect
## Display a 3D viewport at screen-pixel density while keeping UI coordinates logical.

signal display_changed

var viewport: SubViewport
var resolution_fraction := 1.0
var displayed_pixels := Vector2i.ZERO
var resolution_limited := false
var last_display_size := Vector2.ZERO


func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	process_priority = -10


func bind_viewport(value: SubViewport) -> void:
	viewport = value
	texture = viewport.get_texture()
	update_resolution()


func update_resolution() -> void:
	if viewport == null or size.x <= 0 or size.y <= 0:
		return
	# The embedder transform includes the window's final canvas stretch. Popup/screen
	# transforms can omit that stretch (including on the headless development host).
	var transform := get_viewport_transform() * get_global_transform()
	var pixels := size * Vector2(transform.x.length(), transform.y.length())
	displayed_pixels = Vector2i(maxi(2, roundi(pixels.x)), maxi(2, roundi(pixels.y)))
	var desired := Vector2(displayed_pixels) * resolution_fraction
	var limit := minf(1.0, 8192.0 / maxf(desired.x, desired.y))
	resolution_limited = limit < 1.0
	var target := Vector2i(maxi(2, roundi(desired.x * limit)), maxi(2, roundi(desired.y * limit)))
	var changed := viewport.size != target or last_display_size != size
	last_display_size = size
	if viewport.size != target:
		viewport.size = target
	if changed:
		display_changed.emit()


func viewport_point(point: Vector2) -> Vector2:
	return point * Vector2(viewport.size) / size


func control_point(point: Vector2) -> Vector2:
	return point * size / Vector2(viewport.size)


func _process(_delta: float) -> void:
	update_resolution()


func _gui_input(event: InputEvent) -> void:
	if viewport == null or not (event is InputEventMouse or event is InputEventGesture):
		return
	update_resolution()
	var transform := Transform2D.IDENTITY.scaled(Vector2(viewport.size) / size)
	viewport.push_input(event.xformed_by(transform), true)
	accept_event()
