extends Node2D
class_name WangZhihangTest

func _ready() -> void:
	var ui: UIService = Game.Instance.try_get_service(Game.SERVICE_UI)
	if ui != null:
		ui.open_ui("LevelsUI")
