extends SceneTree
## Separate candidate geometry preview. Does not alter the app's HRA references.

const AnatomyModel = preload("res://scripts/anatomy_model.gd")
const OrbitCamera = preload("res://scripts/orbit_camera.gd")


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	var body = JSON.parse_string(FileAccess.get_file_as_string("res://content/bodyparts3d_bone_study.json"))
	if not body is Dictionary:
		push_error("Prepare the BodyParts3D bone study first")
		quit(1)
		return
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("0b1522")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b1c4d9")
	environment.environment.ambient_light_energy = 0.55
	root.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-25, -35, 0)
	key.light_energy = 1.5
	root.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(20, 130, 0)
	fill.light_color = Color("9dbdcc")
	fill.light_energy = 0.65
	root.add_child(fill)
	var model := AnatomyModel.new()
	root.add_child(model)
	var error: String = model.load_body(body)
	if not error.is_empty() or model.meshes.size() != 203:
		push_error("Study geometry failed: " + error)
		quit(1)
		return
	var orbit := OrbitCamera.new()
	root.add_child(orbit)
	orbit.focus(model.bounds_for("anatomy.body"))
	var title := Label.new()
	title.text = "BODYPARTS3D · MALE BONE STUDY\n203 source meshes · source labels and anatomy review pending"
	title.position = Vector2(24, 20)
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var credit := Label.new()
	credit.text = "Standalone source coordinates · no registration to HRA or female anatomy\nBodyParts3D, © The Database Center for Life Science · current official CC BY 4.0 grant; legacy notices retained"
	credit.position = Vector2(24, 835)
	credit.add_theme_font_size_override("font_size", 14)
	root.add_child(credit)
	await physics_frame
	await physics_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("/tmp/medicine-viewer-feasibility/bodyparts-male-bone-study.png")
	print("PASS separate bone study: ", model.meshes.size(), " meshes · bounds ", model.bounds_for("anatomy.body"))
	quit(0 if result == OK else 1)
