extends PanelContainer
## A reversible teaching workspace. It never edits source geometry or infers flow.

signal step_requested(index: int)
signal finish_requested
signal route_requested(id: String)
signal route_previous_requested
signal source_requested(url: String)

const STEPS := [
	{"title": "Find the heart", "selection": "anatomy.heart", "mode": "context", "text": "Skin is hidden and lungs are faded. Orbit to locate the heart in its surrounding anatomy."},
	{"title": "Explore the supplied parts", "selection": "anatomy.heart", "mode": "isolate", "text": "The supplied heart is isolated. Labels identify exposed parts; the parts list also reaches covered geometry."},
	{"title": "Separate the chambers", "selection": "anatomy.heart", "mode": "separate", "text": "Four supplied chamber meshes are moved apart for inspection. Blue ghosts mark their source positions. This spacing is a teaching layout."},
	{"title": "Inspect a valve", "selection": "anatomy.heart.valve.mitral", "mode": "isolate", "text": "Inspect the supplied mitral-valve mesh and read its study card. Missing internal surfaces are a source-coverage limit."},
	{"title": "Compare the lungs", "selection": "anatomy.lungs", "mode": "isolate", "text": "Both supplied lung groups are visible. Select either lung or use the parts list to explore its components."},
	{"title": "Return to the chest", "selection": "anatomy.heart", "mode": "context", "text": "The teaching displacement is removed. Finish restores your starting camera, labels, anatomy edits and histories. Save a view first if you want to keep this setup."}
]
var active := false
var mode := "chest"
var route_node := ""
var route_history: Array[String] = []
var step := 0
var original: Dictionary = {}
var original_undo: Array[Dictionary] = []
var original_redo: Array[Dictionary] = []
var original_back: Array[Dictionary] = []
var original_forward: Array[Dictionary] = []
var title_label: Label
var description: Label
var previous: Button
var next: Button
var finish: Button
var branches: HFlowContainer
var citations: HFlowContainer


func _ready() -> void:
	visible = false
	var layout := VBoxContainer.new()
	add_child(layout)
	title_label = Label.new()
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(title_label)
	description = Label.new()
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(description)
	branches = HFlowContainer.new()
	layout.add_child(branches)
	citations = HFlowContainer.new()
	citations.add_theme_constant_override("h_separation", 14)
	citations.add_theme_constant_override("v_separation", 6)
	layout.add_child(citations)
	var navigation := HFlowContainer.new()
	layout.add_child(navigation)
	previous = make_button("Previous", request_previous, navigation)
	next = make_button("Next", request_next, navigation)
	finish = make_button("Finish and restore", func(): finish_requested.emit(), navigation)


func focus_forward_navigation() -> void:
	if mode == "chest" and not next.disabled:
		next.grab_focus()
	elif mode == "circulation" and branches.get_child_count() > 0:
		branches.get_child(0).grab_focus()
	else:
		finish.grab_focus()


func request_previous() -> void:
	var keep_focus := previous.has_focus()
	if mode == "chest":
		step_requested.emit(step - 1)
	else:
		route_previous_requested.emit()
	if keep_focus:
		if not previous.disabled:
			previous.grab_focus()
		else:
			focus_forward_navigation()


func request_next() -> void:
	var keep_focus := next.has_focus()
	step_requested.emit(step + 1)
	if keep_focus:
		focus_forward_navigation()


func request_route(id: String) -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var keep_focus := focused != null and branches.is_ancestor_of(focused)
	route_requested.emit(id)
	if keep_focus:
		focus_forward_navigation()


func make_button(text: String, action: Callable, parent: Node) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 36
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func show_step(index: int) -> void:
	mode = "chest"
	step = index
	visible = active
	branches.visible = false
	citations.visible = false
	next.visible = true
	title_label.text = "GUIDED CHEST · %d / %d · %s" % [index + 1, STEPS.size(), STEPS[index].title]
	description.text = STEPS[index].text
	previous.disabled = index == 0
	next.disabled = index == STEPS.size() - 1


func show_route(id: String, route: Dictionary, sources: Dictionary) -> void:
	mode = "circulation"
	route_node = id
	visible = active
	var node: Dictionary = route.nodes[id]
	title_label.text = "HEART ↔ LUNGS · " + str(node.title)
	description.text = str(node.text) + "\n"
	description.text += "Coverage gap · " + str(node.gap) if node.coverage == "context_only" else "Supplied source mesh · vessel continuity and inner surfaces are unverified."
	description.text += "\nDraft route · human source and medical review pending."
	previous.disabled = route_history.is_empty()
	next.visible = false
	for container in [branches, citations]:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
		container.visible = true
	for target in node.next:
		var button := make_button(("Choose: " if node.next.size() > 1 else "Next: ") + str(route.nodes[target].title), request_route.bind(str(target)), branches)
		button.tooltip_text = "Follow this authored connection; this does not trace a channel through the meshes."
	for source in node.source_ids:
		var link := LinkButton.new()
		link.focus_mode = Control.FOCUS_ALL
		link.text = sources[source].title
		link.tooltip_text = sources[source].url + " · opens in your browser"
		link.pressed.connect(func(): source_requested.emit(str(sources[source].url)))
		citations.add_child(link)
