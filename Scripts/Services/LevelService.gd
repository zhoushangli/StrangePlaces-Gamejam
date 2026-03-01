extends Node
class_name LevelService

const EVENT_LEVEL_READY := "level_ready"

var _current_level_root: Node

func init_service() -> void:
	pass

func shutdown_service() -> void:
	if _current_level_root != null and is_instance_valid(_current_level_root):
		_current_level_root.queue_free()
	_current_level_root = null

func load_level(level_ref: Variant) -> void:
	var path := ""
	var packed: PackedScene
	if level_ref is PackedScene:
		packed = level_ref as PackedScene
		path = packed.resource_path
	elif level_ref is String:
		path = level_ref
		packed = load(path) as PackedScene
	else:
		push_error("[LevelService] Unsupported level ref: %s" % str(level_ref))
		return

	if packed == null:
		push_error("[LevelService] Failed to load level scene at path: %s" % path)
		return

	var scene_service := Game.Instance.get_service(Game.SERVICE_SCENE) as SceneService
	if scene_service == null:
		push_error("[LevelService] SceneService not available.")
		return

	var before_transition_in := func(current_scene: Node) -> void:
		_spawn_player_to_level(current_scene)
	_current_level_root = await scene_service.change_scene(path, before_transition_in, true)
	if _current_level_root == null:
		return

	var event_service : EventService = Game.Instance.try_get_service(Game.SERVICE_EVENT)
	if event_service != null:
		event_service.publish(EVENT_LEVEL_READY, {"path": path, "root_node": _current_level_root})

func _spawn_player_to_level(level_root: Node) -> void:
	var spawn_point := get_tree().get_first_node_in_group("PlayerSpawnPoint") as Node2D
	var packed_player_scene := load("res://Prefabs/Character/A_Player.tscn") as PackedScene
	var player_instance := packed_player_scene.instantiate() as Node2D

	player_instance.global_position = spawn_point.global_position
	level_root.add_child(player_instance)
