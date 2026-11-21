extends RefCounted
## Mount locally prepared anatomy and discover the optional separate study reference.

const PACK_NAME := "anatomy.pck"
const PREPARED_GEOMETRY_VERSION := 2
const DEVELOPER_DIRECTORIES := ["res://dist", "res://build", "res://tests", "res://tools", "res://docs", "res://addons"]


static func prepared_scene_path(reference_id: String, digest: String) -> String:
	return "res://assets/prepared/%s-%s-geometry-v%d.scn" % [reference_id, digest.left(12), PREPARED_GEOMETRY_VERSION]


static func selection_manifest_path(reference_id: String, digest: String) -> String:
	return prepared_scene_path(reference_id, digest).trim_suffix(".scn") + "-selection.json"


static func selection_batch_path(reference_id: String, digest: String, batch: int) -> String:
	return prepared_scene_path(reference_id, digest).trim_suffix(".scn") + "-selection-%04d.res" % batch


static func selection_batch_count(reference_id: String, digest: String) -> int:
	var path := selection_manifest_path(reference_id, digest)
	if not FileAccess.file_exists(path):
		return 0
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not manifest is Dictionary or manifest.get("schema_version") != 1 or manifest.get("reference_id") != reference_id or manifest.get("source_sha256") != digest or manifest.get("engine") != Engine.get_version_info().string:
		return 0
	var count = manifest.get("batch_count", 0)
	if not (count is int or count is float) or not is_finite(float(count)) or count < 1 or count > 2000 or float(count) != int(count):
		return 0
	return int(count)


static func prepared_files(reference_id: String, digest: String) -> Array[String]:
	var count := selection_batch_count(reference_id, digest)
	if count == 0:
		return []
	var files: Array[String] = [prepared_scene_path(reference_id, digest), selection_manifest_path(reference_id, digest)]
	for batch in count:
		files.append(selection_batch_path(reference_id, digest, batch))
	return files


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


## Every BodyParts3D v4.0 source mesh as one separate male body, when prepared.
static func complete_body() -> Dictionary:
	if FileAccess.file_exists("res://content/bodyparts3d_complete_body.json"):
		var study = JSON.parse_string(FileAccess.get_file_as_string("res://content/bodyparts3d_complete_body.json"))
		if study is Dictionary and study.get("study_kind") == "bodyparts3d-complete" and FileAccess.file_exists("res://" + str(study.get("asset_path", ""))):
			return study
	return {}


static func supplemental_files() -> Array[Dictionary]:
	var files: Array[Dictionary] = []
	for study in study_bodies():
		files.append({"local_path": study.asset_path, "sha256": study.sha256, "bytes": study.bytes, "body_id": study.id})
	return files


static func study_bodies() -> Array[Dictionary]:
	var bodies: Array[Dictionary] = []
	var complete := complete_body()
	if not complete.is_empty():
		bodies.append(complete)
	var bones := study_body()
	if not bones.is_empty():
		bodies.append(bones)
	if FileAccess.file_exists("res://content/spinal_studies.json"):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/spinal_studies.json"))
		if parsed is Dictionary and parsed.get("schema_version") == 1 and parsed.get("bodies") is Array:
			for study in parsed.bodies:
				if study is Dictionary and study.get("study_kind") == "hra-spinal" and FileAccess.file_exists("res://" + str(study.get("asset_path", ""))):
					bodies.append(study)
	return bodies


static func catalogue() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	if not parsed is Dictionary:
		return {}
	parsed.bodies.append_array(study_bodies())
	return parsed


## True when every adult reference's source file named in the catalogue is present.
static func reference_files_present() -> bool:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	if not parsed is Dictionary or not parsed.get("bodies") is Array or parsed.bodies.is_empty():
		return false
	for body in parsed.bodies:
		if not FileAccess.file_exists("res://" + str(body.get("asset_path", ""))):
			return false
	return true


static func mount_if_needed() -> String:
	if reference_files_present():
		return ""
	var directory := OS.get_executable_path().get_base_dir()
	var candidates: Array[String] = [directory.path_join(PACK_NAME)]
	for path in candidates:
		if FileAccess.file_exists(path):
			if not ProjectSettings.load_resource_pack(path, false):
				return "The anatomy package could not be opened. Re-extract the complete private build."
			if reference_files_present():
				return ""
			return "The anatomy package is incomplete. Re-extract the complete private build."
	if OS.has_feature("template"):
		if OS.get_name() == "macOS":
			return "Anatomy is missing from this application. Re-extract the complete private Mac build."
		return "Anatomy is missing. Keep anatomy.pck beside the application and re-extract the complete private build."
	return ""
