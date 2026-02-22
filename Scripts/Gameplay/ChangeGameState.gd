extends Node
class_name ChangeGameState

@export var target_state: int = 1

func _ready() -> void:
	var svc: Variant = Game.Instance.get_service(Game.SERVICE_GAME_STATE)
	if svc != null:
		svc.change_game_state(target_state)
