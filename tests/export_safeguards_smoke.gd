extends SceneTree

const SavedViews = preload("res://scripts/saved_views.gd")
const StudyVerification = preload("res://scripts/study_verification.gd")
var storage = SavedViews
var failures := 0
var directory := "user://export-guard-" + Crypto.new().generate_random_bytes(8).hex_encode()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func relative_file(absolute: String) -> String:
	var base := DirAccess.open(".").get_current_dir().split("/")
	var target := absolute.split("/")
	if base[0] != target[0]:
		return absolute # Different Windows volumes have no relative path.
	var shared := 0
	while shared < mini(base.size(), target.size()) and base[shared] == target[shared]:
		shared += 1
	return "../".repeat(base.size() - shared) + "/".join(target.slice(shared))


func _initialize() -> void:
	# An optional old script demonstrates that these cases detect the original bug.
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--storage-script="):
			storage = load(argument.trim_prefix("--storage-script="))
	DirAccess.make_dir_recursive_absolute(directory + "/actual/nested")
	DirAccess.make_dir_recursive_absolute(directory + "/other")
	var original = storage.new()
	original.path = directory + "/actual/views.json"
	original.load_library()
	check(original.add_view("My source view", {"reference_hash": "fixture", "camera": [0.123456789012345]}).is_empty(), "Create the original library")
	var id: String = original.entries[0].id
	original.set_notes(id, "Original note")
	var stale_entries: Array = original.entries.duplicate(true)
	var newer = storage.new()
	newer.path = original.path
	newer.load_library()
	newer.set_notes(id, "Keep this newer note 🫀")
	var absolute := ProjectSettings.globalize_path(original.path)
	var expected := FileAccess.get_file_as_bytes(absolute)
	check("outside the active" in original.export_library(absolute) and FileAccess.get_file_as_bytes(absolute) == expected,
		"Absolute and user paths cannot overwrite a newer active library")
	check("outside the active" in original.export_library(absolute.get_base_dir() + "/nested/../views.json") and FileAccess.get_file_as_bytes(absolute) == expected,
		"Dot segments cannot bypass the active-library guard")
	var relative := relative_file(absolute)
	check("outside the active" in original.export_library(relative) and FileAccess.get_file_as_bytes(absolute) == expected,
		"A relative export path cannot overwrite the active library")
	var case_alias := absolute.get_base_dir().path_join("VIEWS.JSON")
	var fs := DirAccess.open(absolute.get_base_dir())
	var sensitive := fs.is_case_sensitive(absolute.get_base_dir())
	if sensitive:
		check(original.export_library(case_alias).is_empty() and FileAccess.file_exists(case_alias), "Distinct letter-case filenames remain available on a case-sensitive directory")
		DirAccess.remove_absolute(case_alias)
	else:
		check("outside the active" in original.export_library(case_alias), "Letter-case aliases cannot bypass the guard on a case-insensitive directory")
	check(FileAccess.get_file_as_bytes(absolute) == expected, "Letter-case handling preserves the newer active file")
	# A separate file with identical bytes is a legitimate export destination.
	var distinct := directory + "/other/views.json"
	DirAccess.copy_absolute(absolute, distinct)
	check(original.export_library(distinct).is_empty(), "An independent copy with identical content can be replaced by an explicit export")
	var exported: Dictionary = original.read_file(distinct)
	check(exported.error.is_empty() and exported.entries[0].notes == "Original note" and original.entries == stale_entries and FileAccess.get_file_as_bytes(absolute) == expected,
		"Separate export writes the visible library without changing memory or the newer active file")
	var relative_export := relative_file(ProjectSettings.globalize_path(directory + "/other/relative.json"))
	check(original.export_library(relative_export).is_empty() and FileAccess.file_exists(directory + "/other/relative.json"), "Relative paths remain usable for separate export files")
	var root_path := ProjectSettings.globalize_path(directory)
	var alias := root_path + "/alias"
	var child_alias := root_path + "/child-alias"
	var file_alias := root_path + "/file-alias.json"
	var backup_alias := root_path + "/backup-alias.json"
	var links := DirAccess.open(root_path)
	# Directory/file links are exercised where the platform permits creating them.
	var directory_link := links.create_link(absolute.get_base_dir(), alias) == OK
	var child_link := links.create_link(absolute.get_base_dir() + "/nested", child_alias) == OK
	var file_link := links.create_link(absolute, file_alias) == OK
	var backup_link := links.create_link(absolute + ".bak", backup_alias) == OK
	if OS.get_name() == "Linux":
		check(directory_link and child_link and file_link and backup_link, "The Linux regression fixture creates all four symbolic links")
	if directory_link:
		check("outside the active" in original.export_library(alias + "/views.json") and FileAccess.get_file_as_bytes(absolute) == expected,
			"A directory link cannot overwrite a newer active library")
	if child_link:
		var before_files := DirAccess.get_files_at(absolute.get_base_dir())
		check("Choose the folder directly" in original.export_library(child_alias + "/../views.json") and FileAccess.get_file_as_bytes(absolute) == expected and DirAccess.get_files_at(absolute.get_base_dir()) == before_files,
			"Ambiguous parent segments after a directory link fail before writing any file")
	if file_link:
		check("outside the active" in original.export_library(file_alias) and links.is_link(file_alias) and FileAccess.get_file_as_bytes(absolute) == expected,
			"A file link to the active library stays intact and cannot bypass the guard")
	if backup_link:
		var backup_bytes := FileAccess.get_file_as_bytes(absolute + ".bak")
		check("outside the active" in original.export_library(backup_alias) and links.is_link(backup_alias) and FileAccess.get_file_as_bytes(absolute + ".bak") == backup_bytes,
			"A JSON-named link to the active backup cannot replace that backup link")
	check(DirAccess.rename_absolute(absolute, absolute + ".held") == OK, "Temporarily hold the active file to exercise missing-file protection")
	if directory_link:
		check("outside the active" in original.export_library(alias + "/views.json") and not FileAccess.file_exists(absolute),
			"A directory alias cannot recreate a missing active file from a stale reader")
	if not sensitive:
		check("outside the active" in original.export_library(case_alias) and not FileAccess.file_exists(absolute),
			"A case alias cannot recreate a missing active file from a stale reader")
	# The old implementation may have created a stale file; remove only this fixture.
	if FileAccess.file_exists(absolute):
		DirAccess.remove_absolute(absolute)
	check(DirAccess.rename_absolute(absolute + ".held", absolute) == OK and FileAccess.get_file_as_bytes(absolute) == expected,
		"The held newer file returns unchanged")
	check(not original.export_library(directory + "/absent/export.json").is_empty(), "Missing export directories fail without writing an active file")
	for link in [alias, child_alias, file_alias, backup_alias]:
		if links.is_link(link) or FileAccess.file_exists(link):
			DirAccess.remove_absolute(link)
	for folder in [directory + "/actual", directory + "/other"]:
		for name in DirAccess.get_files_at(folder):
			DirAccess.remove_absolute(folder.path_join(name))
	DirAccess.remove_absolute(directory + "/actual/nested")
	DirAccess.remove_absolute(directory + "/actual")
	DirAccess.remove_absolute(directory + "/other")
	DirAccess.remove_absolute(directory)
	if storage == SavedViews:
		check(StudyVerification.verify_export_protection({"reference_hash": "fixture"}, "fixture"), "The bundled export-safeguard routine passes with the current storage module")
	print("Export safeguard failures: ", failures, " · case-sensitive directory: ", sensitive, " · link fixtures: ", directory_link and child_link and file_link and backup_link)
	quit(0 if failures == 0 else 1)
