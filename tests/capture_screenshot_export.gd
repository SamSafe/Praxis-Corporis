extends SceneTree

const ViewCapture = preload("res://scripts/view_capture.gd")
var failures: Array[String] = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var viewer = load("res://scenes/main.tscn").instantiate()
	root.add_child(viewer)
	await process_frame
	await process_frame
	while viewer.loading:
		await process_frame
	for body in ["female", "male", "bodyparts-male-bones-study"]:
		await viewer.switch_body(body)
		if body == "bodyparts-male-bones-study":
			root.size = Vector2i(1100, 720)
			viewer.select_structure("source.bodyparts3d-v4-male.FJ3365")
			viewer.inspect_alone()
			viewer.on_panel_action(0)
			viewer.on_panel_action(1)
		else:
			viewer.chest_view()
			viewer.local_labels_button.button_pressed = true
		var before: Dictionary = viewer.export_view_state()
		var undo_size: int = viewer.model.undo_stack.size()
		var image: Image = await viewer.capture_image()
		check(image != null and not image.is_empty(), "Rendered workspace screenshot is available")
		if image == null:
			continue
		check(image.get_width() == root.size.x and image.get_height() > root.size.y + 80, "Export keeps the full workspace width and adds a source footer")
		check(viewer.export_view_state() == before and viewer.model.undo_stack.size() == undo_size, "Capture does not change camera, anatomy, labels or inspection history")
		var caption := ViewCapture.credits(viewer.model.body, viewer.heading.text)
		check("medical review pending" in caption and "https://creativecommons.org/licenses/by/4.0/" in caption, "Export retains prototype status and a licence link")
		if body == "bodyparts-male-bones-study":
			check("BodyParts3D, © The Database Center for Life Science licensed under CC Attribution 4.0 International" in caption and "no HRA/female alignment" in caption,
				"Separate study export retains exact creator attribution and alignment limits even with panels hidden")
		else:
			check("HuBMAP / Human Reference Atlas" in caption and "selection colours" in caption, "HRA export records source and modifications")
		var output := "/tmp/medicine-viewer-feasibility/export-%s.png" % body
		check(ViewCapture.write_png(image, output) == OK, "PNG writes through a temporary file")
		var loaded := Image.new()
		check(loaded.load(output) == OK and loaded.get_size() == image.get_size(), "Exported PNG reopens at its intended dimensions")
		var hash_before := FileAccess.get_sha256(output)
		check(ViewCapture.write_png(null, output) == ERR_INVALID_PARAMETER and FileAccess.get_sha256(output) == hash_before, "Invalid export does not replace an existing image")
		check(ViewCapture.write_png(image, output + ".jpg") == ERR_INVALID_PARAMETER, "Unsupported file formats are rejected before writing")
		# Footer text must actually be rendered into the image, not only metadata.
		var background := Color("080f19")
		var bright_pixels := 0
		for y in range(root.size.y + 8, image.get_height() - 8, 2):
			for x in range(16, image.get_width() - 16, 3):
				var pixel := image.get_pixel(x, y)
				bright_pixels += int(pixel.r > background.r + 0.1 and pixel.g > background.g + 0.1)
		check(bright_pixels > 500, "The source/status footer contains readable rendered text")
		print("PASS credited screenshot: ", body, " · ", image.get_size())
	viewer.queue_free()
	await process_frame
	print("Screenshot export failures: ", failures.size())
	quit(0 if failures.is_empty() else 1)
