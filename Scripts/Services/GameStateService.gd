extends RefCounted
class_name GameStateService
const MAIN_MENU_SCENE_PATH := "res://Scenes/Gameplay/SCN_MainMenu.tscn"

const STATE_BOOT := 0
const STATE_MAIN_MENU := 1
const STATE_GAME := 2

const EVENT_GAME_STATE_CHANGED := "game_state_changed"

var _fsm = preload("res://Scripts/Utils/SimpleStateMachine.gd").new()

func init_service() -> void:
	_fsm.add_state(STATE_BOOT)
	_fsm.add_state(
		STATE_MAIN_MENU,
		Callable(self, "_enter_main_menu")
	)
	_fsm.add_state(
		STATE_GAME,
		Callable(self, "_enter_game"),
		Callable(self, "_exit_game")
	)
	_fsm.init(STATE_BOOT)

func shutdown_service() -> void:
	pass

func change_game_state(next_state: int) -> bool:
	var prev: Variant = _fsm.current_state
	var changed: bool = _fsm.change_state(next_state)
	if not changed:
		return false
	var event_service: Variant = Game.Instance.try_get_service(Game.SERVICE_EVENT)
	if event_service != null:
		event_service.publish(EVENT_GAME_STATE_CHANGED, {"from": prev, "to": next_state})
	return true

func get_current_state() -> int:
	return int(_fsm.current_state)

func _enter_main_menu() -> void:
	_enter_scene(MAIN_MENU_SCENE_PATH)
	var ui_service: Variant = Game.Instance.get_service(Game.SERVICE_UI)
	if ui_service != null:
		ui_service.open_by_key("MainMenuUI")

func _enter_game() -> void:
	Game.Instance.register_from_scene(Game.SERVICE_LEVEL, "res://Prefabs/Services/SVC_LevelService.tscn")
	Game.Instance.register_from_scene(Game.SERVICE_QUANTUM, "res://Prefabs/Services/SVC_QuantumService.tscn")

func _exit_game() -> void:
	Game.Instance.unregister_service(Game.SERVICE_QUANTUM)
	Game.Instance.unregister_service(Game.SERVICE_LEVEL)

func _enter_scene(path: String) -> void:
	var scene: Variant = Game.Instance.try_get_service(Game.SERVICE_SCENE)
	if scene == null:
		push_error("[GameStateService] SceneService is not available.")
		return
	scene.change_scene.call_deferred(path)
