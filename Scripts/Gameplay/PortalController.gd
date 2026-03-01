extends Area2D
class_name PortalController

@export var _anim: AnimatedSprite2D

const LEVEL_PATTERN := "^LVL_(\\d{2})_(\\d{2})$"
const CHAPTER_MAX := {
	1: 6,
	2: 9,
}

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

func _play_pass_and_transit(player: PlayerController) -> void:
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
	var level_service: LevelService = Game.Instance.get_service(Game.SERVICE_LEVEL)
	if level_service != null:
		level_service.load_level.call_deferred(next_level_path)

func _build_next_level_path(current_path: String) -> String:
	if current_path.strip_edges().is_empty():
		push_error("[PortalController] Current scene path is empty.")
		return ""
	var file_name := current_path.get_file().get_basename()
	var regex := RegEx.new()
	if regex.compile(LEVEL_PATTERN) != OK:
		push_error("[PortalController] Failed to compile level regex.")
		return ""
	var match := regex.search(file_name)
	if match == null:
		push_error("[PortalController] Scene name is not in LVL_XX_XX format: %s" % file_name)
		return ""

	var chapter_str := match.get_string(1)
	var level_str := match.get_string(2)
	if not chapter_str.is_valid_int() or not level_str.is_valid_int():
		push_error("[PortalController] Failed to parse chapter/index from scene name: %s" % file_name)
		return ""

	var current_chapter := chapter_str.to_int()
	var current_index := level_str.to_int()
	if not CHAPTER_MAX.has(current_chapter):
		push_error("[PortalController] Unsupported chapter: %d" % current_chapter)
		return ""

	var max_index: int = CHAPTER_MAX[current_chapter]
	if current_index < max_index:
		return "res://Scenes/Gameplay/Levels/LVL_%02d_%02d.tscn" % [current_chapter, current_index + 1]

	var next_chapter := current_chapter + 1
	if CHAPTER_MAX.has(next_chapter):
		return "res://Scenes/Gameplay/Levels/LVL_%02d_%02d.tscn" % [next_chapter, 1]
	return ""

func _return_to_main_menu() -> void:
	var ui_service: UIService = Game.Instance.try_get_service(Game.SERVICE_UI)
	if ui_service != null:
		ui_service.close_top()
	var game_state: GameStateService = Game.Instance.get_service(Game.SERVICE_GAME_STATE)
	if game_state != null:
		game_state.change_game_state(GameStateService.GameState.MAIN_MENU)
