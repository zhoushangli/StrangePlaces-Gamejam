extends Node2D
class_name WangZhihangTest

func _ready() -> void:
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	if ui != null:
		ui.open_by_key("LevelsUI")
