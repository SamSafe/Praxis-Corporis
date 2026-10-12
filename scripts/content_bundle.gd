extends RefCounted
## Mount the bundled, locally prepared anatomy before the viewer reads its assets.

const PACK_NAME := "anatomy.pck"


static func mount_if_needed() -> String:
	if FileAccess.file_exists("res://assets/hra/female.glb") and FileAccess.file_exists("res://assets/hra/male.glb"):
		return ""
	var directory := OS.get_executable_path().get_base_dir()
	var candidates: Array[String] = [directory.path_join(PACK_NAME)]
	if OS.get_name() == "macOS":
		# Private ZIPs keep the anatomy next to the .app, preserving its ad-hoc seal.
		candidates.append(directory.get_base_dir().get_base_dir().get_base_dir().path_join(PACK_NAME))
	for path in candidates:
		if FileAccess.file_exists(path):
			if not ProjectSettings.load_resource_pack(path, false):
				return "The anatomy package could not be opened. Re-extract the complete private build."
			if FileAccess.file_exists("res://assets/hra/female.glb") and FileAccess.file_exists("res://assets/hra/male.glb"):
				return ""
			return "The anatomy package is incomplete. Re-extract the complete private build."
	if OS.has_feature("template"):
		return "Anatomy is missing. Keep anatomy.pck beside the application and re-extract the complete private build."
	return ""
