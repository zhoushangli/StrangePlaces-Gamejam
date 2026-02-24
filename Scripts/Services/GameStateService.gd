extends RefCounted
class_name GameStateService
const MAIN_MENU_SCENE_PATH := "res://Scenes/Gameplay/SCN_MainMenu.tscn"

enum GameState {
	BOOT,
	MAIN_MENU,
	GAME,
}

const EVENT_GAME_STATE_CHANGED := "game_state_changed"

var _fsm = preload("res://Scripts/Utils/SimpleStateMachine.gd").new()

func init_service() -> void:
	_fsm.add_state(GameState.BOOT)
	_fsm.add_state(
		GameState.MAIN_MENU,
		_enter_main_menu
	)
	_fsm.add_state(
		GameState.GAME,
		_enter_game,
		_exit_game
	)
	_fsm.init(GameState.BOOT)

func shutdown_service() -> void:
	pass

func change_game_state(next_state: GameState) -> bool:
	var prev: GameState = _fsm.current_state
	var changed: bool = _fsm.change_state(next_state)
	if not changed:
		return false
	var event_service: EventService = Game.Instance.try_get_service(Game.SERVICE_EVENT)
	if event_service != null:
		event_service.publish(EVENT_GAME_STATE_CHANGED, {"from": prev, "to": next_state})
	return true

func get_current_state() -> GameState:
	return _fsm.current_state

func _enter_main_menu() -> void:
	_enter_scene(MAIN_MENU_SCENE_PATH)
	var ui_service: UIService = Game.Instance.get_service(Game.SERVICE_UI)
	if ui_service != null:
		ui_service.open_ui("MainMenuUI") 

func _enter_game() -> void: 
	Game.Instance.register_from_scene(Game.SERVICE_LEVEL, "res://Prefabs/Services/SVC_LevelService.tscn")
	Game.Instance.register_from_scene(Game.SERVICE_QUANTUM, "res://Prefabs/Services/SVC_QuantumService.tscn")
	
	var audio_service: AudioService = Game.Instance.get_service(Game.SERVICE_AUDIO)
	audio_service.play_bgm("res://GameAssets/Audio/Game_BGM.mp3")

	var ui_service: UIService = Game.Instance.get_service(Game.SERVICE_UI)
	ui_service.open_ui("HUDUI")

func _exit_game() -> void:
	Game.Instance.unregister_service(Game.SERVICE_QUANTUM)
	Game.Instance.unregister_service(Game.SERVICE_LEVEL)

func _enter_scene(path: String) -> void:
	var scene: SceneService = Game.Instance.try_get_service(Game.SERVICE_SCENE)
	if scene == null:
		push_error("[GameStateService] SceneService is not available.")
		return
	scene.change_scene.call_deferred(path)

