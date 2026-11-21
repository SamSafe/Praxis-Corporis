extends RefCounted
## Render a workspace snapshot with its source/status attached inside the PNG.


static func credits(reference: Dictionary, selection_label: String) -> String:
	var context := str(reference.get("short_label", reference.label))
	if not selection_label.is_empty():
		context += " · " + selection_label
	var lines: Array[String] = ["PRAXIS CORPORIS · " + context,
		"Private anatomy prototype · draft geometry/labels · medical review pending"]
	if reference.get("study_kind") == "bodyparts3d-complete":
		lines.append("BodyParts3D, © The Database Center for Life Science licensed under CC Attribution 4.0 International")
		lines.append("Source v4.0: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html")
		lines.append("Current grant: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html · https://creativecommons.org/licenses/by/4.0/")
		lines.append("Separate complete male body; no HRA/female alignment. Legacy OBJ notices retain CC BY-SA 2.1 Japan.")
		lines.append("Changes: repeated source meshes kept once, mm/Z-up to metre/Y-up, source normals retained; display colours and inspection effects.")
	elif reference.get("id") == "bodyparts-male-bones-study":
		lines.append("BodyParts3D, © The Database Center for Life Science licensed under CC Attribution 4.0 International")
		lines.append("Source v4.0: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html")
		lines.append("Current grant: https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html · https://creativecommons.org/licenses/by/4.0/")
		lines.append("Separate male bone study; no HRA/female alignment. Legacy OBJ notices retain CC BY-SA 2.1 Japan.")
		lines.append("Changes: bone subset, mm/Z-up to metre/Y-up, source normals retained; display colours and inspection effects.")
	elif reference.get("study_kind") == "hra-spinal":
		lines.append("Anatomy: HuBMAP / Human Reference Atlas · separate v1.2 spinal source study")
		lines.append("Source: " + str(reference.source_url))
		lines.append("CC BY 4.0: https://creativecommons.org/licenses/by/4.0/")
		lines.append("Source coordinates preserved; no registration to United bodies or other studies. Labels and anatomy unreviewed.")
		lines.append("Changes: cache conversion, selection colours, fading, labels and temporary inspection movement/isolation.")
	else:
		lines.append("Anatomy: HuBMAP / Human Reference Atlas, 3D Reference Object Library · United v1.1")
		lines.append("Source: https://github.com/hubmapconsortium/ccf-3d-reference-object-library")
		lines.append("CC BY 4.0: https://creativecommons.org/licenses/by/4.0/")
		lines.append("Changes: sampling sites excluded, cache conversion, selection colours, fading, labels and temporary inspection movement/isolation.")
	return "\n".join(lines)


static func compose(parent: Node, workspace: Image, caption: String, palette: Theme) -> Image:
	var canvas := SubViewport.new()
	canvas.disable_3d = true
	canvas.world_2d = World2D.new()
	canvas.size = Vector2i(workspace.get_width(), workspace.get_height() + 256)
	canvas.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	parent.add_child(canvas)
	var root := Control.new()
	root.theme = palette
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)
	var background := ColorRect.new()
	background.color = Color("080f19")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var picture := TextureRect.new()
	picture.texture = ImageTexture.create_from_image(workspace)
	picture.size = Vector2(workspace.get_size())
	root.add_child(picture)
	var text := Label.new()
	text.text = caption
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 16)
	text.add_theme_color_override("font_color", Color("c8d6e3"))
	text.position = Vector2(16, workspace.get_height() + 16)
	text.size = Vector2(workspace.get_width() - 32, 224)
	root.add_child(text)
	await parent.get_tree().process_frame
	var footer_height := int(ceil(text.get_minimum_size().y)) + 32
	text.size.y = footer_height - 32
	canvas.size.y = workspace.get_height() + footer_height
	await RenderingServer.frame_post_draw
	var result := canvas.get_texture().get_image()
	canvas.queue_free()
	return result


static func write_png(image: Image, path: String) -> Error:
	if not path.to_lower().ends_with(".png") or image == null or image.is_empty():
		return ERR_INVALID_PARAMETER
	var temporary := path + "." + Crypto.new().generate_random_bytes(16).hex_encode() + ".tmp"
	var error := image.save_png(temporary)
	if error != OK:
		if FileAccess.file_exists(temporary):
			DirAccess.remove_absolute(temporary)
		return error
	error = DirAccess.rename_absolute(temporary, path)
	if error != OK and FileAccess.file_exists(temporary):
		DirAccess.remove_absolute(temporary)
	return error
