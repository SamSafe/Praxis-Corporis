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
	check(content.error.is_empty() and original.cards.size() == 200 and original.routes.size() == 1 and original.conditions.size() == 117, "Bundled explanations, route and conditions retain explicit draft-review status")
	var invalid: Array = [null, [], {}, {"schema_version": 2}]
	for change in ["source", "card", "related", "citation", "review", "date", "promotion", "human-review", "assistant-actor", "route-target", "route-gap", "route-unreachable", "route-return", "mapping", "condition", "condition-focus", "condition-geometry", "condition-review", "condition-citation", "card-geometry", "card-mapping", "card-duplicate", "card-shadow", "condition-depiction", "card-list-empty", "card-list-entry", "card-list-duplicate"]:
		var candidate := original.duplicate(true)
		match change:
			"source": candidate.sources["heart-flow"].url = "javascript:alert(1)"
			"card": candidate.cards["anatomy.heart"] = []
			"related": candidate.cards["anatomy.heart"].related = [3]
			"citation": candidate.cards["anatomy.heart"].source_ids = ["missing"]
			"review": candidate.expert_review = "approved"
			"promotion": candidate.review_status = "source_checked"
			"human-review": candidate.human_source_review = "completed"
			"assistant-actor": candidate.assistant_checks.actor = "human"
			"date": candidate.assistant_checks.erase("checked_on")
			"route-target": candidate.routes["heart-lung"].nodes["pulmonary-trunk"].next = ["missing"]
			"route-gap": candidate.routes["heart-lung"].nodes["left-exchange"].gap = ""
			"route-unreachable": candidate.routes["heart-lung"].nodes["pulmonary-trunk"].next = ["left-artery"]
			"route-return": candidate.routes["heart-lung"].nodes["aorta"].next = ["aorta"]
			"mapping": candidate.routes["heart-lung"].nodes["right-atrium"].geometry.female = null
			"condition": candidate.conditions["condition.aortic-stenosis"] = []
			"condition-focus": candidate.conditions["condition.aortic-stenosis"].focus_id = "missing"
			"condition-geometry": candidate.conditions["condition.aortic-stenosis"].geometry_mode = "simulated_pathology"
			"condition-review": candidate.conditions["condition.aortic-stenosis"].expert_review = "approved"
			"condition-citation": candidate.conditions["condition.aortic-stenosis"].source_ids = []
			"card-geometry": candidate.cards["anatomy.liver"].geometry = {}
			"card-mapping": candidate.cards["anatomy.liver"].geometry.female.erase("source_name")
			# One source structure cannot carry two different cards.
			"card-duplicate": candidate.cards["anatomy.spleen"].geometry.female = candidate.cards["anatomy.liver"].geometry.female.duplicate()
			# A mapping cannot hide a card that already uses the shared ID.
			"card-shadow": candidate.cards["anatomy.liver"].geometry.female.id = "anatomy.heart"
			"condition-depiction": candidate.conditions["condition.cirrhosis"].not_depicted = ""
			"card-list-empty": candidate.cards["anatomy.cornea"].geometry.female = []
			"card-list-entry": candidate.cards["anatomy.cornea"].geometry.female[1].erase("ontology")
			# A paired part cannot also belong to another card.
			"card-list-duplicate": candidate.cards["anatomy.iris"].geometry.female.append(candidate.cards["anatomy.cornea"].geometry.female[0].duplicate())
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
	for body in catalogue.bodies:
		var structures := {}
		for structure in body.structures:
			structures[structure.id] = structure
		var liver := content.structure_id("anatomy.liver", structures)
		check(not liver.is_empty() and structures[liver].source_name.ends_with("_liver") and content.card(liver) == content.card("anatomy.liver"), "Mapped liver card resolves in " + body.id)
		check(content.conditions_for(liver) == ["condition.gallstones", "condition.cirrhosis", "condition.nafld", "condition.viral-hepatitis", "condition.liver-cancer"] and content.condition_focus("condition.cirrhosis", structures) == liver, "Mapped structures list and focus their conditions in " + body.id)
		# Paired parts share one card; the first mapped side is its focus.
		var corneas: Array = original.cards["anatomy.cornea"].geometry[body.id]
		check(corneas.size() == 2 and content.card(corneas[1].id) == content.card("anatomy.cornea") and content.structure_id("anatomy.cornea", structures) == corneas[0].id, "Both corneas resolve to one card in " + body.id)
		check(content.conditions_for(content.structure_id("anatomy.retina", structures)) == ["condition.glaucoma", "condition.amd", "condition.diabetic-retinopathy", "condition.retinal-detachment", "condition.floaters", "condition.retinal-artery-occlusion"], "Retina lists its sourced eye conditions in " + body.id)
		check(content.condition_focus("condition.amd", structures) == content.structure_id("anatomy.macula", structures), "AMD focuses the supplied macula in " + body.id)
		check(content.structure_id("anatomy.heart", structures) == "anatomy.heart", "Shared IDs resolve unchanged in " + body.id)
		check(content.structure_id("anatomy.prostate", structures).is_empty() == (body.id == "female"), "Sex-specific cards stay in their own body: " + body.id)
		check(content.condition_available("condition.bph", structures) == (body.id == "male") and content.condition_available("condition.endometriosis", structures) == (body.id == "female"), "Sex-specific conditions need their own supplied anatomy: " + body.id)
		var changed := structures.duplicate(true)
		changed[liver].source_name = "different mesh"
		check(content.structure_id("anatomy.liver", changed).is_empty() and not content.condition_available("condition.cirrhosis", changed), "Changed source identity disables a mapped card instead of silently remapping")
	check("Pathological narrowing, leakage, leaflet motion and blood flow are not depicted." in content.condition_text("condition.aortic-stenosis"), "Valve conditions keep their original depiction limits")
	check("Scarring and changes in liver shape or texture are not depicted." in content.condition_text("condition.cirrhosis"), "Each condition states its own depiction limits")
	print("Study content failures: ", failures)
	quit(0 if failures == 0 else 1)
