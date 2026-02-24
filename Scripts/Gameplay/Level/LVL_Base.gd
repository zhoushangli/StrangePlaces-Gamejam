extends Node2D
class_name LVL_Base

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		var ui: UIService = Game.Instance.get_service(Game.SERVICE_UI)
		if ui.is_ui_open("PauseUI"):
			return
		else:
			ui.open_ui("PauseUI")
			get_viewport().set_input_as_handled()
