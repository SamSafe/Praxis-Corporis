extends SceneTree

const ContentBundle = preload("res://scripts/content_bundle.gd")


func _initialize() -> void:
	var path := "user://export-boundary-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(path.path_join("nested"))
	var empty := ContentBundle.developer_files([path])
	var marker := path.path_join("nested/qa-resource.txt")
	var file := FileAccess.open(marker, FileAccess.WRITE)
	file.store_string("A developer-only capture must not reach a native export.")
	file.close()
	var nested := ContentBundle.developer_files([path])
	var absent := ContentBundle.developer_files([path + "-absent"])
	var source_files := ContentBundle.developer_files()
	var failed := not empty.is_empty() or nested != [marker] or not absent.is_empty() or not "res://tests/export_boundary_smoke.gd" in source_files
	DirAccess.remove_absolute(marker)
	DirAccess.remove_absolute(path.path_join("nested"))
	DirAccess.remove_absolute(path)
	if failed:
		push_error("Export boundary failed to distinguish absent/empty/deep developer resources")
	else:
		print("PASS developer resource boundary traversal")
	quit(1 if failed else 0)
