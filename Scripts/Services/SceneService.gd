extends Node
class_name SceneService

const MAIN_MENU_SCENE_PATH := "res://Scenes/Gameplay/SCN_MainMenu.tscn"
const GAME_SCENE_PATH := "res://Scenes/Gameplay/SCN_Game.tscn"
const EVENT_SCENE_LOADED := "scene_loaded"

func init_service() -> void:
	pass

func shutdown_service() -> void:
	pass

func change_scene(path: String) -> Node:
	var tree: SceneTree = get_tree()
	if tree == null:
		push_error("[SceneService] SceneTree is not available.")
		return null
	var err := tree.change_scene_to_file(path)
	if err != OK:
		push_error("[SceneService] Failed to change scene to: %s" % path)
		return null
	await tree.scene_changed
	var event_service: Variant = Game.Instance.try_get_service(Game.SERVICE_EVENT)
	if event_service != null:
		event_service.publish(EVENT_SCENE_LOADED, {"path": path})
	return tree.current_scene
