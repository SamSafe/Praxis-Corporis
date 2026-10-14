extends MenuButton
## Supported actions for a single, explicitly captured anatomy selection.

signal action_requested(id: int, selection: String)
signal refresh_requested

enum Action { FOCUS, INSPECT, RETURN_CONTEXT, SELECTION_LABELS, LOCAL_LABELS,
	SHOW, HIDE, FADE, MOVE, RESTORE, UNDO, REDO, COPY_SOURCE }
const HEADER := 1000
const VISIBILITY := 1001
const HISTORY := 1002
var visibility_menu: PopupMenu
var history_menu: PopupMenu
var selection := ""
var menu_selection := ""
var anchored := false
var fallback := Vector2(12, 12)


func _ready() -> void:
	text = "Actions"
	flat = false
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(90, 34)
	visible = false
	var popup := get_popup()
	popup.add_item("Selected anatomy", HEADER)
	popup.set_item_disabled(0, true)
	popup.add_item("Focus selection", Action.FOCUS)
	popup.add_item("Inspect alone", Action.INSPECT)
	popup.add_item("Return to context", Action.RETURN_CONTEXT)
	popup.add_separator()
	popup.add_check_item("Selection label", Action.SELECTION_LABELS)
	popup.add_check_item("Local part labels", Action.LOCAL_LABELS)
	visibility_menu = PopupMenu.new()
	popup.add_child(visibility_menu)
	visibility_menu.add_item("Show", Action.SHOW)
	visibility_menu.add_item("Hide", Action.HIDE)
	visibility_menu.add_item("Fade · click-through", Action.FADE)
	popup.add_submenu_node_item("Visibility", visibility_menu, VISIBILITY)
	popup.add_check_item("Move selected", Action.MOVE)
	popup.add_item("Restore selected", Action.RESTORE)
	popup.add_separator()
	history_menu = PopupMenu.new()
	popup.add_child(history_menu)
	history_menu.add_item("Undo inspection", Action.UNDO)
	history_menu.add_item("Redo inspection", Action.REDO)
	popup.add_submenu_node_item("Inspection history", history_menu, HISTORY)
	popup.add_item("Copy source record", Action.COPY_SOURCE)
	for menu in [popup, visibility_menu, history_menu]:
		menu.id_pressed.connect(func(id: int): action_requested.emit(id, menu_selection))
	about_to_popup.connect(func():
		refresh_requested.emit()
		menu_selection = selection)


func sync_selection(id: String, label: String, available: bool) -> void:
	if selection != id or not available:
		close_menu()
	selection = id
	visible = available
	disabled = not available
	tooltip_text = "Actions for " + label + " · Shift+F10 with the 3D view focused"
	get_popup().set_item_text(0, label.left(44) + ("…" if label.length() > 44 else ""))
	get_popup().set_item_tooltip(0, label)


func close_menu() -> void:
	visibility_menu.hide()
	history_menu.hide()
	get_popup().hide()


func menu_for(id: int) -> PopupMenu:
	if id in [Action.SHOW, Action.HIDE, Action.FADE]:
		return visibility_menu
	if id in [Action.UNDO, Action.REDO]:
		return history_menu
	return get_popup()


func set_action_disabled(id: int, value: bool) -> void:
	var popup := menu_for(id)
	popup.set_item_disabled(popup.get_item_index(id), value)


func action_disabled(id: int) -> bool:
	var popup := menu_for(id)
	var index := popup.get_item_index(id)
	return index < 0 or popup.is_item_disabled(index)


func set_checked(id: int, value: bool) -> void:
	var popup := menu_for(id)
	popup.set_item_checked(popup.get_item_index(id), value)
