extends RefCounted
## Reproducible source identity, independent of clipboard access and inspection edits.


static func hierarchy(structures: Dictionary, id: String) -> String:
	var labels := PackedStringArray()
	var visited := {}
	while structures.has(id) and not visited.has(id):
		visited[id] = true
		labels.insert(0, str(structures[id].label))
		id = str(structures[id].get("parent", ""))
	return " › ".join(labels)


static func tooltip(structures: Dictionary, id: String) -> String:
	var record: Dictionary = structures[id]
	return "%s\nSource name: %s\nOntology: %s\nCatalogue ID: %s" % [hierarchy(structures, id), record.source_name,
		str(record.ontology) if not str(record.ontology).is_empty() else "Not supplied", id]


static func text_for(body: Dictionary, record: Dictionary, pack_id: String) -> String:
	if body.is_empty() or record.is_empty():
		return ""
	return "Praxis Corporis · source record\nReference: %s\nReference ID: %s\nDisplay label: %s\nSource name: %s\nOntology: %s\nCatalogue ID: %s\nSource mesh count: %d\nReference SHA-256: %s\nCatalogue pack: %s\nCoverage: %s\nCatalogue status: %s\nAnatomical review: pending" % [
		body.get("short_label", body.label), body.id, record.label, record.source_name,
		str(record.ontology) if not str(record.ontology).is_empty() else "Not supplied", record.id,
		record.mesh_nodes.size(), body.sha256, pack_id, body.get("coverage", "Not supplied"), record.get("review_status", "Not supplied")]
