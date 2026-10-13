extends Resource
## Offline triangle picking shapes for a small group of pinned source meshes.

@export var source_sha256 := ""
@export var engine := ""
@export var mesh_nodes := PackedInt32Array()
@export var shapes: Array[Shape3D] = []
