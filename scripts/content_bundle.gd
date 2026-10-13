extends RefCounted
## Mount locally prepared anatomy and discover the optional separate study reference.

const PACK_NAME := "anatomy.pck"
const PREPARED_GEOMETRY_VERSION := 2
const DEVELOPER_DIRECTORIES := ["res://dist", "res://build", "res://tests", "res://tools", "res://docs", "res://addons"]


static func prepared_scene_path(reference_id: String, digest: String) -> String:
	return "res://assets/prepared/%s-%s-geometry-v%d.scn" % [reference_id, digest.left(12), PREPARED_GEOMETRY_VERSION]


static func developer_files(roots: Array = DEVELOPER_DIRECTORIES) -> Array[String]:
	var pending := roots.duplicate()
	var files: Array[String] = []
	while not pending.is_empty():
		var path: String = pending.pop_back()
		var directory := DirAccess.open(path)
		if directory == null:
			continue
		for name in directory.get_files():
			files.append(path.path_join(name))
		for name in directory.get_directories():
			pending.append(path.path_join(name))
	return files


static func verify_export_boundary() -> String:
	if not OS.has_feature("template") and not "--verify-export-boundary" in OS.get_cmdline_user_args():
		return "" # Source-project developer checks intentionally have these directories.
	var unexpected := developer_files()
	if not unexpected.is_empty():
		return "Developer resources were included in the private export: " + unexpected[0]
	print("PASS private export resource boundary")
	return ""


static func study_body() -> Dictionary:
	if FileAccess.file_exists("res://content/bodyparts3d_bone_study.json"):
		var study = JSON.parse_string(FileAccess.get_file_as_string("res://content/bodyparts3d_bone_study.json"))
		if study is Dictionary and study.get("study") == true and FileAccess.file_exists("res://" + str(study.get("asset_path", ""))):
			return study
	return {}


static func supplemental_files() -> Array[Dictionary]:
	var study := study_body()
	if study.is_empty():
		return []
	return [{"local_path": study.asset_path, "sha256": study.sha256, "bytes": study.bytes, "body_id": study.id}]


static func catalogue() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	if not parsed is Dictionary:
		return {}
	var study := study_body()
	if not study.is_empty():
		parsed.bodies.append(study)
	return parsed


static func mount_if_needed() -> String:
	if FileAccess.file_exists("res://assets/hra/female.glb") and FileAccess.file_exists("res://assets/hra/male.glb"):
		return ""
	var directory := OS.get_executable_path().get_base_dir()
	var candidates: Array[String] = [directory.path_join(PACK_NAME)]
	for path in candidates:
		if FileAccess.file_exists(path):
			if not ProjectSettings.load_resource_pack(path, false):
				return "The anatomy package could not be opened. Re-extract the complete private build."
			if FileAccess.file_exists("res://assets/hra/female.glb") and FileAccess.file_exists("res://assets/hra/male.glb"):
				return ""
			return "The anatomy package is incomplete. Re-extract the complete private build."
	if OS.has_feature("template"):
		if OS.get_name() == "macOS":
			return "Anatomy is missing from this application. Re-extract the complete private Mac build."
		return "Anatomy is missing. Keep anatomy.pck beside the application and re-extract the complete private build."
	return ""
