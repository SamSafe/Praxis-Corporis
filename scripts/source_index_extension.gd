extends GLTFDocumentExtension
## Tag source indices before Godot replaces importer mesh nodes with runtime nodes.


func _import_preflight(_state: GLTFState, _extensions: PackedStringArray) -> Error:
	return OK


func _import_node(state: GLTFState, _gltf_node: GLTFNode, _json: Dictionary, node: Node) -> Error:
	node.set_meta("source_index", state.get_node_index(node))
	return OK
