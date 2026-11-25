extends RefCounted
## Prepared cut-aways: a structure, a body-direction camera view and a cut depth that
## open it. Each one only sets the selection, the camera and the display-only cut;
## no caps, cut surfaces or interior anatomy are made, and source geometry is unchanged.

## view: an index into ReferenceOrientation.VIEW_NAMES. depth: centimetres in front of
## the focus point (0 cuts through it). part: for a card mapped to several parts on a
## body, the ending of the source name to open (the left eye of the pair).
const CUTS := [
	{"id": "heart-chambers", "title": "Heart chambers, from the front", "card": "anatomy.heart", "part": "", "view": 0, "depth": 0.0,
		"note": "A cut through the middle of the heart, facing forward, opens the chambers and shows the walls and valves inside it."},
	{"id": "brain-midline", "title": "Brain, midline from the left", "card": "anatomy.brain", "part": "", "view": 2, "depth": 0.0,
		"note": "A cut down the middle of the head, between the two halves of the brain, shows the corpus callosum, the ventricles, the brainstem and the cerebellum."},
	{"id": "brain-coronal", "title": "Brain, front-to-back section", "card": "anatomy.brain", "part": "", "view": 0, "depth": 0.0,
		"note": "A cut across the brain from side to side, through its middle, shows both hemispheres and the deep structures between them."},
	{"id": "eye-left", "title": "Left eye, from the side", "card": "anatomy.eyes", "part": "eye_L", "view": 2, "depth": 0.0,
		"note": "A cut through the middle of the left eye shows the cornea, lens and the wall of the eyeball, with the optic nerve behind it."},
	{"id": "kidney-right", "title": "Right kidney, from behind", "card": "anatomy.kidney.right", "part": "", "view": 1, "depth": 0.0,
		"note": "A cut through the middle of the right kidney, seen from the back, shows its cortex, medulla and the collecting system inside it."},
]


## The structure a prepared cut opens on a body, or "" when the body lacks it. A card
## without its own per-body mapping uses its own ID, as the heart does.
static func structure_for(cut: Dictionary, body_id: String, structures: Dictionary, cards: Dictionary) -> String:
	var card = cards.get(str(cut.card), {})
	if not card is Dictionary:
		return ""
	if not card.has("geometry"):
		return str(cut.card) if structures.has(str(cut.card)) else ""
	var geometry = card.geometry.get(body_id)
	if geometry == null:
		return ""
	var mappings: Array = geometry if geometry is Array else [geometry]
	var part := str(cut.part)
	for mapping in mappings:
		if mapping is Dictionary and structures.has(str(mapping.get("id", ""))):
			if part.is_empty() or str(mapping.get("source_name", "")).ends_with(part):
				return str(mapping.id)
	return ""
