extends RefCounted
## Authored learning text never derives relationships from mesh proximity or names.

var data: Dictionary = {}
var error := ""
# Body-specific source structure ID -> card ID, from explicit card geometry
# mappings. Mapped structures are confirmed against the loaded body before use.
var aliases: Dictionary = {}


func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/study_content.json"))
	error = load_data(parsed)


func load_data(parsed: Variant) -> String:
	data = {}
	aliases = {}
	var mapped := {}
	if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("cards") is Dictionary or not parsed.get("sources") is Dictionary:
		return "Study content has an unsupported format."
	if not draft_record(parsed) or not nonempty_text(parsed.get("revision"), 128):
		return "Study content has missing review evidence."
	for id in parsed.sources:
		var source = parsed.sources[id]
		if not nonempty_text(id, 128) or not source is Dictionary or not nonempty_text(source.get("title"), 256) or not safe_url(source.get("url")):
			return "Study content contains an invalid source."
	var assistance = parsed.get("assistant_checks")
	if not assistance is Dictionary or assistance.get("actor") != "assistant" or assistance.get("kind") != "preliminary_source_cross_check" or not nonempty_text(assistance.get("checked_on"), 10) or not nonempty_text(assistance.get("scope")) or not valid_sources(assistance, parsed.sources):
		return "Study content has invalid preliminary source-check metadata."
	for id in parsed.cards:
		var record = parsed.cards[id]
		if not nonempty_text(id, 256) or not record is Dictionary or not draft_record(record) or not nonempty_text(record.get("overview")) or not nonempty_text(record.get("function")):
			return "Study content contains an invalid explanation."
		if not string_list(record.get("related")) or not valid_sources(record, parsed.sources):
			return "Study content contains an invalid relationship or citation."
		if record.has("geometry"):
			# Explicit per-body source mappings for cards whose structures have no
			# shared ID. A mapped structure may belong to only one card.
			if not record.geometry is Dictionary or record.geometry.is_empty():
				return "Study content contains an invalid structure mapping."
			for reference in record.geometry:
				var mapping = record.geometry[reference]
				if not nonempty_text(reference, 64) or not valid_mapping(mapping) or mapped.has(mapping.id) or parsed.cards.has(mapping.id):
					return "Study content contains an invalid structure mapping."
				mapped[mapping.id] = id
	var routes = parsed.get("routes", {})
	if not routes is Dictionary:
		return "Study routes have an unsupported format."
	for id in routes:
		if not valid_route(routes[id], parsed.sources):
			return "Study content contains an invalid route."
	var conditions = parsed.get("conditions", {})
	if not conditions is Dictionary:
		return "Condition information has an unsupported format."
	for id in conditions:
		var condition = conditions[id]
		if not nonempty_text(id, 128) or not condition is Dictionary or not draft_record(condition) or not valid_sources(condition, parsed.sources):
			return "Condition information has missing review evidence or citations."
		if not nonempty_text(condition.get("title"), 128) or not nonempty_text(condition.get("summary")) or not nonempty_text(condition.get("location")):
			return "Condition information contains invalid text."
		if not string_list(condition.get("related_anatomy"), false) or not string_list(condition.get("display_on"), false) or condition.get("focus_id") not in condition.related_anatomy or condition.get("geometry_mode") != "reference_location_only":
			return "Condition information has unsupported geometry or anatomy mappings."
		if condition.has("not_depicted") and not nonempty_text(condition.not_depicted, 512):
			return "Condition information contains invalid text."
	data = parsed.duplicate(true)
	aliases = mapped
	return ""


static func valid_mapping(mapping: Variant) -> bool:
	return mapping is Dictionary and nonempty_text(mapping.get("id"), 256) and nonempty_text(mapping.get("source_name"), 256) and mapping.get("ontology") is String


static func nonempty_text(value: Variant, limit: int = 4096) -> bool:
	return value is String and not value.strip_edges().is_empty() and value.length() <= limit


static func safe_url(value: Variant) -> bool:
	if not nonempty_text(value, 2048) or not value.begins_with("https://") or value.contains(" ") or value.contains("\n") or value.contains("\r"):
		return false
	var authority: String = value.trim_prefix("https://").get_slice("/", 0)
	return authority.contains(".") and not authority.contains("@") and not authority.contains("\\")


static func draft_record(record: Dictionary) -> bool:
	# New review stages need their own evidence before the UI can claim them.
	# Assistant cross-checks never qualify as human source or expert review.
	return record.get("review_status") == "draft" and record.get("human_source_review") == "pending" and record.get("expert_review") == "pending"


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
	if not value is Dictionary or not draft_record(value) or not valid_sources(value, sources) or not nonempty_text(value.get("title"), 128) or not nonempty_text(value.get("scope")):
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


## Card ID for a structure ID: shared IDs are card IDs; mapped source IDs resolve
## through their card's explicit geometry.
func concept_id(id: String) -> String:
	return str(aliases.get(id, id))


func card(id: String) -> Dictionary:
	return data.get("cards", {}).get(concept_id(id), {})


## Structure in the loaded body for a card or anatomy ID, or "" if the body has
## none. A mapping only applies while its source name and ontology still match.
func structure_id(id: String, structures: Dictionary) -> String:
	if structures.has(id):
		return id
	for mapping in data.get("cards", {}).get(id, {}).get("geometry", {}).values():
		var structure: Dictionary = structures.get(mapping.id, {})
		if not structure.is_empty() and structure.get("source_name") == mapping.source_name and structure.get("ontology") == mapping.ontology:
			return str(mapping.id)
	return ""


func condition(id: String) -> Dictionary:
	return data.get("conditions", {}).get(id, {})


func conditions_for(anatomy_id: String) -> Array[String]:
	var result: Array[String] = []
	var concept := concept_id(anatomy_id)
	for id in data.get("conditions", {}):
		if concept in condition(id).display_on:
			result.append(str(id))
	return result


func condition_available(id: String, structures: Dictionary) -> bool:
	var record := condition(id)
	if record.is_empty():
		return false
	for related in record.related_anatomy:
		var structure := structure_id(related, structures)
		if structure.is_empty() or structures[structure].get("mesh_nodes", []).is_empty():
			return false
	return true


func condition_focus(id: String, structures: Dictionary) -> String:
	return structure_id(str(condition(id).get("focus_id", "")), structures)


func condition_text(id: String) -> String:
	var record := condition(id)
	if record.is_empty():
		return "Condition information is unavailable."
	var result: String = str(record.summary) + "\n\nReference location\n" + str(record.location)
	result += "\n\nREFERENCE ANATOMY ONLY\nThe supplied geometry is unreviewed reference anatomy. " + str(record.get("not_depicted", "Disease-related tissue changes, motion and flow are not depicted."))
	result += "\n\nDraft learning text · human source and medical review pending.\n\nSources"
	for source in record.source_ids:
		result += "\n\n%s\n%s" % [data.sources[source].title, data.sources[source].url]
	return result


func text(id: String) -> String:
	var record := card(id)
	if record.is_empty():
		return "No authored explanation for this structure yet."
	return "%s\n\nFunction\n%s\n\nDraft learning text · human source and medical review pending.\nThe supplied geometry may omit structures or internal surfaces." % [record.overview, record.function]


func credits(id: String) -> String:
	var links: Array[String] = []
	for source in card(id).get("source_ids", []):
		links.append(str(data.sources[source].url))
	return "" if links.is_empty() else "Study text: private draft; human source and medical review pending. Sources: " + " · ".join(links)
