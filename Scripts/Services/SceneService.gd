extends Node
class_name SceneService

const MAIN_MENU_SCENE_PATH := "res://Scenes/Gameplay/SCN_MainMenu.tscn"
const GAME_SCENE_PATH := "res://Scenes/Gameplay/SCN_Game.tscn"

const EVENT_SCENE_LOADED := "scene_loaded"

var _is_changing_scene := false

func init_service() -> void:
	pass

func shutdown_service() -> void:
	pass

func change_scene(path: String, before_transition_in: Callable = Callable(), transition: bool = true) -> Node:
	if _is_changing_scene:
		push_warning("[SceneService] Ignored scene change while another change is in progress: %s" % path)
		return null
	_is_changing_scene = true

	var tree: SceneTree = get_tree()
	if tree == null:
		push_error("[SceneService] SceneTree is not available.")
		_is_changing_scene = false
		return null

	var post_process := Game.Instance.try_get_service(Game.SERVICE_POST_PROCESS) as PostProcessService
	if post_process != null and transition:
		await post_process.play_scene_transition_out()
	
	var ui_service := Game.Instance.try_get_service(Game.SERVICE_UI) as UIService
	if ui_service != null:
		print("[SceneService] flush pending UI before scene change.")
		ui_service.flush_pending()

	var err := tree.change_scene_to_file(path)
	if err != OK:
		push_error("[SceneService] Failed to change scene to: %s" % path)
		if post_process != null and transition:
			await post_process.play_scene_transition_in()
		_is_changing_scene = false
		return null

	await tree.scene_changed
	var current_scene := tree.current_scene

	if before_transition_in.is_valid():
		before_transition_in.call(current_scene)

	var event_service: EventService = Game.Instance.try_get_service(Game.SERVICE_EVENT)
	if event_service != null:
		event_service.publish(EVENT_SCENE_LOADED, {"path": path})
	if post_process != null and transition:
		await post_process.play_scene_transition_in()

	_is_changing_scene = false
	return current_scene
