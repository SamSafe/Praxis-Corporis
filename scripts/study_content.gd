extends RefCounted
## Authored learning text never derives relationships from mesh proximity or names.

var data: Dictionary = {}
var error := ""


func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/study_content.json"))
	error = load_data(parsed)


func load_data(parsed: Variant) -> String:
	data = {}
	if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("cards") is Dictionary or not parsed.get("sources") is Dictionary:
		return "Study content has an unsupported format."
	if not reviewed_draft(parsed) or not nonempty_text(parsed.get("revision"), 128):
		return "Study content has missing review evidence."
	for id in parsed.sources:
		var source = parsed.sources[id]
		if not nonempty_text(id, 128) or not source is Dictionary or not nonempty_text(source.get("title"), 256) or not safe_url(source.get("url")):
			return "Study content contains an invalid source."
	for id in parsed.cards:
		var record = parsed.cards[id]
		if not nonempty_text(id, 256) or not record is Dictionary or not reviewed_draft(record) or not nonempty_text(record.get("overview")) or not nonempty_text(record.get("function")):
			return "Study content contains an invalid explanation."
		if not string_list(record.get("related")) or not valid_sources(record, parsed.sources):
			return "Study content contains an invalid relationship or citation."
	var routes = parsed.get("routes", {})
	if not routes is Dictionary:
		return "Study routes have an unsupported format."
	for id in routes:
		if not valid_route(routes[id], parsed.sources):
			return "Study content contains an invalid route."
	data = parsed.duplicate(true)
	return ""


static func nonempty_text(value: Variant, limit: int = 4096) -> bool:
	return value is String and not value.strip_edges().is_empty() and value.length() <= limit


static func safe_url(value: Variant) -> bool:
	if not nonempty_text(value, 2048) or not value.begins_with("https://") or value.contains(" ") or value.contains("\n") or value.contains("\r"):
		return false
	var authority: String = value.trim_prefix("https://").get_slice("/", 0)
	return authority.contains(".") and not authority.contains("@") and not authority.contains("\\")


static func reviewed_draft(record: Dictionary) -> bool:
	# New review stages need their own evidence before the UI can claim them.
	return record.get("review_status") == "source_checked" and record.get("expert_review") == "pending"


static func string_list(value: Variant, allow_empty: bool = true) -> bool:
	if not value is Array or value.size() > 64 or (not allow_empty and value.is_empty()):
		return false
	var unique := {}
	for item in value:
		if not nonempty_text(item, 256) or unique.has(item):
			return false
		unique[item] = true
	return true


static func valid_sources(record: Dictionary, sources: Dictionary) -> bool:
	if not string_list(record.get("source_ids"), false):
		return false
	for source in record.source_ids:
		if not sources.has(source):
			return false
	return true


static func valid_route(value: Variant, sources: Dictionary) -> bool:
	if not value is Dictionary or not reviewed_draft(value) or not valid_sources(value, sources) or not nonempty_text(value.get("title"), 128) or not nonempty_text(value.get("scope")):
		return false
	if not string_list(value.get("reference_ids"), false) or not value.get("nodes") is Dictionary or value.nodes.is_empty() or value.nodes.size() > 64 or not value.nodes.has(value.get("start")):
		return false
	for id in value.nodes:
		var node = value.nodes[id]
		if not nonempty_text(id, 128) or not node is Dictionary or not nonempty_text(node.get("title"), 128) or not nonempty_text(node.get("text")) or not valid_sources(node, sources):
			return false
		if not string_list(node.get("next"), false) or not node.get("geometry") is Dictionary:
			return false
		if node.get("coverage") not in ["supplied_mesh", "context_only"] or not node.get("gap") is String or (node.coverage == "context_only" and not nonempty_text(node.gap)):
			return false
		for reference in value.reference_ids:
			var mapping = node.geometry.get(reference)
			if not mapping is Dictionary or not nonempty_text(mapping.get("id"), 256) or not nonempty_text(mapping.get("source_name"), 256) or not mapping.get("ontology") is String:
				return false
		for next in node.next:
			if not value.nodes.has(next):
				return false
	# Every branch must be reachable and offer a route back to the start.
	for start in value.nodes:
		var visited := {}
		var pending: Array = [start]
		while not pending.is_empty():
			var current: String = pending.pop_back()
			if visited.has(current):
				continue
			visited[current] = true
			pending.append_array(value.nodes[current].next)
		if not visited.has(value.start) or (start == value.start and visited.size() != value.nodes.size()):
			return false
	return true


func route(id: String) -> Dictionary:
	return data.get("routes", {}).get(id, {})


func route_available(id: String, body: Dictionary) -> bool:
	var record := route(id)
	if record.is_empty() or body.get("id") not in record.reference_ids:
		return false
	var structures := {}
	for structure in body.get("structures", []):
		structures[structure.id] = structure
	for node in record.nodes.values():
		var mapping: Dictionary = node.geometry[body.id]
		var structure: Dictionary = structures.get(mapping.id, {})
		if structure.get("source_name") != mapping.source_name or structure.get("ontology") != mapping.ontology:
			return false
	return true


func card(id: String) -> Dictionary:
	return data.get("cards", {}).get(id, {})


func text(id: String) -> String:
	var record := card(id)
	if record.is_empty():
		return "No authored explanation for this structure yet."
	return "%s\n\nFunction\n%s\n\nSource-checked draft · medical review pending.\nThe supplied geometry may omit structures or internal surfaces." % [record.overview, record.function]


func credits(id: String) -> String:
	var links: Array[String] = []
	for source in card(id).get("source_ids", []):
		links.append(str(data.sources[source].url))
	return "" if links.is_empty() else "Study text: private source-checked draft; medical review pending. Sources: " + " · ".join(links)
