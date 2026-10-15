extends SceneTree

const Content = preload("res://scripts/study_content.gd")
var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	var content := Content.new()
	var original: Dictionary = content.data.duplicate(true)
	check(content.error.is_empty() and original.cards.size() == 15 and original.routes.size() == 1, "Bundled explanations and route have valid review evidence")
	var invalid: Array = [null, [], {}, {"schema_version": 2}]
	for change in ["source", "card", "related", "citation", "review", "date", "route-target", "route-gap", "route-unreachable", "route-return", "mapping"]:
		var candidate := original.duplicate(true)
		match change:
			"source": candidate.sources["heart-flow"].url = "javascript:alert(1)"
			"card": candidate.cards["anatomy.heart"] = []
			"related": candidate.cards["anatomy.heart"].related = [3]
			"citation": candidate.cards["anatomy.heart"].source_ids = ["missing"]
			"review": candidate.expert_review = "approved"
			"date": candidate.erase("source_checked_on")
			"route-target": candidate.routes["heart-lung"].nodes["pulmonary-trunk"].next = ["missing"]
			"route-gap": candidate.routes["heart-lung"].nodes["left-exchange"].gap = ""
			"route-unreachable": candidate.routes["heart-lung"].nodes["pulmonary-trunk"].next = ["left-artery"]
			"route-return": candidate.routes["heart-lung"].nodes["aorta"].next = ["aorta"]
			"mapping": candidate.routes["heart-lung"].nodes["right-atrium"].geometry.female = null
		invalid.append(candidate)
	for candidate in invalid:
		check(not content.load_data(candidate).is_empty() and content.data.is_empty(), "Invalid content fails closed with no partial learning claims")
		check(content.card("anatomy.heart").is_empty() and content.credits("anatomy.heart").is_empty(), "Rejected content has no dangling citations")
	check(content.load_data(original).is_empty(), "Valid content can load after an invalid record")
	var catalogue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/sample_pack.json"))
	for body in catalogue.bodies:
		check(content.route_available("heart-lung", body), "Route source mappings match " + body.id)
		var changed: Dictionary = body.duplicate(true)
		for structure in changed.structures:
			if structure.id == "anatomy.heart.atrium.right":
				structure.source_name = "different mesh"
		check(not content.route_available("heart-lung", changed), "Changed source identity disables route instead of silently remapping")
	check(not content.route_available("heart-lung", {"id": "other", "structures": []}), "Unmapped reference has no inferred route")
	print("Study content failures: ", failures)
	quit(0 if failures == 0 else 1)
