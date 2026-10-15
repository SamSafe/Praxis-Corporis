extends PanelContainer
## A reversible teaching workspace. It never edits source geometry or infers flow.

signal step_requested(index: int)
signal finish_requested

const STEPS := [
	{"title": "Find the heart", "selection": "anatomy.heart", "mode": "context", "text": "Skin is hidden and lungs are faded. Orbit to locate the heart in its surrounding anatomy."},
	{"title": "Explore the supplied parts", "selection": "anatomy.heart", "mode": "isolate", "text": "The supplied heart is isolated. Labels identify exposed parts; the parts list also reaches covered geometry."},
	{"title": "Separate the chambers", "selection": "anatomy.heart", "mode": "separate", "text": "Four supplied chamber meshes are moved apart for inspection. Blue ghosts mark their source positions. This spacing is a teaching layout."},
	{"title": "Inspect a valve", "selection": "anatomy.heart.valve.mitral", "mode": "isolate", "text": "Inspect the supplied mitral-valve mesh and read its study card. Missing internal surfaces are a source-coverage limit."},
	{"title": "Compare the lungs", "selection": "anatomy.lungs", "mode": "isolate", "text": "Both supplied lung groups are visible. Select either lung or use the parts list to explore its components."},
	{"title": "Return to the chest", "selection": "anatomy.heart", "mode": "context", "text": "The teaching displacement is removed. Finish restores your starting camera, labels, anatomy edits and histories. Save a view first if you want to keep this setup."}
]
var active := false
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
	var navigation := HBoxContainer.new()
	layout.add_child(navigation)
	previous = make_button("Previous", func(): step_requested.emit(step - 1), navigation)
	next = make_button("Next", func(): step_requested.emit(step + 1), navigation)
	make_button("Finish and restore", func(): finish_requested.emit(), navigation)


func make_button(text: String, action: Callable, parent: Node) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 36
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func show_step(index: int) -> void:
	step = index
	visible = active
	title_label.text = "GUIDED CHEST · %d / %d · %s" % [index + 1, STEPS.size(), STEPS[index].title]
	description.text = STEPS[index].text
	previous.disabled = index == 0
	next.disabled = index == STEPS.size() - 1
