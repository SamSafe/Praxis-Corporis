extends RefCounted
## Authored learning text never derives relationships from mesh proximity or names.

var data: Dictionary = {}


func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://content/study_content.json"))
	if parsed is Dictionary and parsed.get("schema_version") == 1 and parsed.get("cards") is Dictionary and parsed.get("sources") is Dictionary:
		data = parsed


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
