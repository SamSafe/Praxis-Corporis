extends SceneTree

const Verification = preload("res://scripts/study_verification.gd")


func _initialize() -> void:
	var valid := Verification.verify_text_encoding({"body": "fixture", "selection": "first"}, "fixture", func(_state: Dictionary): return "")
	print("Saved-view UTF-8 failures: ", 0 if valid else 1)
	quit(0 if valid else 1)
