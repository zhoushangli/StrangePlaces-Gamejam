extends Area2D
class_name PortalController

@export var _anim: AnimatedSprite2D

const LEVEL_PREFIX := "LVL_01_0"
const MAX_LEVEL_IN_CHAPTER := 5
const STATE_MAIN_MENU := 1

var _triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if _anim != null:
		_anim.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.has_method("enter_level_pass_state"):
		return
	_triggered = true
	_play_pass_and_transit(body)

func _play_pass_and_transit(player) -> void:
	player.enter_level_pass_state()
	await player._anim.animation_finished

	var current_path := ""
	var tree := get_tree()
	if tree != null and tree.current_scene != null:
		current_path = tree.current_scene.scene_file_path
	var next_level_path := _build_next_level_path(current_path)
	if next_level_path.is_empty():
		_return_to_main_menu()
		return
	var level_service: Variant = Game.Instance.get_service(Game.SERVICE_LEVEL)
	if level_service != null:
		level_service.load_level.call_deferred(next_level_path)

func _build_next_level_path(current_path: String) -> String:
	if current_path.strip_edges().is_empty():
		push_error("[PortalController] Current scene path is empty.")
		return ""
	var file_name := current_path.get_file().get_basename()
	if not file_name.begins_with(LEVEL_PREFIX):
		push_error("[PortalController] Scene name is not in LVL_01_0X format: %s" % file_name)
		return ""
	var idx_str := file_name.trim_prefix(LEVEL_PREFIX)
	if not idx_str.is_valid_int():
		push_error("[PortalController] Failed to parse level index from scene name: %s" % file_name)
		return ""
	var current_index := idx_str.to_int()
	if current_index >= MAX_LEVEL_IN_CHAPTER:
		return ""
	var next_index := current_index + 1
	return "res://Scenes/Gameplay/Levels/%s%d.tscn" % [LEVEL_PREFIX, next_index]

func _return_to_main_menu() -> void:
	var ui_service: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	if ui_service != null:
		ui_service.close_top()
	var game_state: Variant = Game.Instance.get_service(Game.SERVICE_GAME_STATE)
	if game_state != null:
		game_state.change_game_state(STATE_MAIN_MENU)
