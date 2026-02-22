extends Node
class_name Boot
const STATE_MAIN_MENU := 1
const STATE_GAME := 2

enum DevMode {
	NONE,
	UI,
	GAME,
}

@export var _devMode: DevMode = DevMode.UI
@export var _devScene: PackedScene

func _ready() -> void:
	var game: Variant = Game.Instance
	if game == null:
		push_error("[Boot] Game autoload is not available.")
		return

	game.register_new(Game.SERVICE_EVENT, preload("res://Scripts/Services/EventService.gd"))
	game.register_new(Game.SERVICE_GAME_STATE, preload("res://Scripts/Services/GameStateService.gd"))
	game.register_from_scene(Game.SERVICE_SCENE, "res://Prefabs/Services/SVC_SceneService.tscn")
	game.register_from_scene(Game.SERVICE_AUDIO, "res://Prefabs/Services/Svc_AudioService.tscn")
	game.register_from_scene(Game.SERVICE_UI, "res://Prefabs/Services/Svc_UIService.tscn")
	game.register_from_scene(Game.SERVICE_POST_PROCESS, "res://Prefabs/Services/Svc_PostProcessService.tscn")

	call_deferred("_deferred_startup_route")

func _deferred_startup_route() -> void:
	var game_state: Variant = Game.Instance.get_service(Game.SERVICE_GAME_STATE)
	var ui_service: Variant = Game.Instance.get_service(Game.SERVICE_UI)
	if game_state == null:
		push_error("[Boot] GameStateService missing.")
		return

	match _devMode:
		DevMode.NONE:
			pass
		DevMode.UI:
			game_state.change_game_state(STATE_MAIN_MENU)
			if ui_service != null and _devScene != null:
				ui_service.open_scene(_devScene)
			return
		DevMode.GAME:
			game_state.change_game_state(STATE_GAME)
			var level_service: Variant = Game.Instance.get_service(Game.SERVICE_LEVEL)
			if level_service != null and _devScene != null:
				level_service.load_level.call_deferred(_devScene)
			return

	game_state.change_game_state(STATE_MAIN_MENU)
