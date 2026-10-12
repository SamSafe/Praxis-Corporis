extends SceneTree
## Run from an absolute script path against an exported --main-pack, not the source project.

const ContentBundle = preload("res://scripts/content_bundle.gd")


func _initialize() -> void:
	var unexpected := ContentBundle.developer_files()
	if not unexpected.is_empty():
		push_error("Packed application contains a developer resource: " + unexpected[0])
		quit(1)
		return
	print("PASS standalone packed resource boundary")
	quit()
