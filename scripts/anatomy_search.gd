extends RefCounted
## Search supplied records only; identifier normalization adds no anatomical aliases.

const RESULT_LIMIT := 100
## Unicode White_Space: separators plus TAB–CR and NEXT LINE. Compile once.
static var spaces := RegEx.create_from_string(r"[\x{0009}-\x{000D}\x{0085}\p{Z}]+")
var entries: Array[Dictionary] = []
var records: Array[Dictionary] = []


static func normalize_spaces(value: String) -> String:
	return spaces.sub(value, " ", true).strip_edges()


static func words(value: String) -> String:
	return normalize_spaces(value.to_lower().replace("_", " "))


static func identifier(value: String) -> String:
	return words(value).replace(" ", "").replace(":", "").replace("-", "").replace(".", "")


func build(structures: Dictionary) -> void:
	entries.clear()
	records.clear()
	for id in structures:
		var record: Dictionary = structures[id]
		var label := words(str(record.label))
		var source := words(str(record.source_name))
		var ontology := str(record.get("ontology", "")).to_lower()
		entries.append({"id": str(id), "label": label, "source": source,
			"raw_source": str(record.source_name).to_lower(), "ontology": ontology,
			"identifier_keys": [identifier(str(id)), identifier(str(record.source_name)), identifier(ontology)],
			"all_text": "%s %s %s %s %s" % [label, source, record.source_name.to_lower(), ontology, str(id).to_lower()]})
		records.append({"id": str(id), "label": label, "source": str(record.source_name).to_lower()})
	records.sort_custom(record_before)


static func record_before(a: Dictionary, b: Dictionary) -> bool:
	if a.label != b.label:
		return a.label < b.label
	if a.source != b.source:
		return a.source < b.source
	return a.id < b.id


func page(offset: int) -> Dictionary:
	var start := clampi(offset, 0, records.size())
	return {"total": records.size(), "results": records.slice(start, start + RESULT_LIMIT)}


func find(query: String) -> Dictionary:
	var phrase := words(query)
	if phrase.is_empty():
		return {"total": 0, "results": []}
	var compact := identifier(query)
	var tokens := phrase.split(" ", false)
	var matches: Array[Dictionary] = []
	for entry in entries:
		var rank := -1
		if phrase == entry.label or query.strip_edges().to_lower() == entry.raw_source or (not compact.is_empty() and compact in entry.identifier_keys):
			rank = 0
		elif entry.label.begins_with(phrase):
			rank = 1
		elif contains_tokens(entry.label, tokens):
			rank = 2
		elif contains_tokens(entry.all_text, tokens):
			rank = 3
		if rank >= 0:
			matches.append({"id": entry.id, "rank": rank, "label": entry.label, "source": entry.raw_source})
	matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.rank != b.rank:
			return a.rank < b.rank
		return record_before(a, b))
	var total := matches.size()
	if total > RESULT_LIMIT:
		matches.resize(RESULT_LIMIT)
	return {"total": total, "results": matches}


static func contains_tokens(text: String, tokens: PackedStringArray) -> bool:
	for token in tokens:
		if token not in text:
			return false
	return true
