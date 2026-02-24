extends Node
class_name ChangeGameState

@export var target_state: GameStateService.GameState = GameStateService.GameState.MAIN_MENU

func _ready() -> void:
	var svc: GameStateService = Game.Instance.get_service(Game.SERVICE_GAME_STATE)
	if svc != null:
		svc.change_game_state(target_state)
