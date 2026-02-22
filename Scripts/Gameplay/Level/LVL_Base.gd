extends Node2D
class_name LVL_Base

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		var ui: Variant = Game.Instance.get_service(Game.SERVICE_UI)
		if ui != null:
			ui.open_by_key("PauseUI")
