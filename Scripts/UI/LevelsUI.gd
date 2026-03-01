extends UIBase
class_name LevelsUI

@export var _levelLabel: Label
@export var _levelBtnTemplate: TextureButton
@export var _levelButtons: GridContainer
@export var _back: TextureButton
@export var _hoverSound: AudioStream
@export var _pressSound: AudioStream
@export var _gameBgm: AudioStream

const LEVELS_DIR := "res://Scenes/Gameplay/Levels"
const LEVEL_FILE_PATTERN := "^LVL_(\\d{2})_(\\d{2})\\.tscn$"
const DEFAULT_LEVEL_LABEL := "Choose your level"
const EMPTY_LEVEL_LABEL := "No Levels Found"

static var _cache_built := false
static var _cached_levels: Array[Dictionary] = []

func get_ui_key() -> String:
	return "LevelsUI"

func _ready() -> void:
	_ensure_level_cache()

func on_open(_args: Variant = null) -> void:
	_ensure_level_cache()
	_connect_static_signals()
	_rebuild_level_buttons()
	if _levelLabel == null:
		return
	_levelLabel.text = EMPTY_LEVEL_LABEL if _cached_levels.is_empty() else DEFAULT_LEVEL_LABEL

func _connect_static_signals() -> void:
	if _back == null:
		return
	var hover_callable := Callable(self, "_on_button_hovered_plain")
	if not _back.mouse_entered.is_connected(hover_callable):
		_back.mouse_entered.connect(hover_callable)
	var press_callable := Callable(self, "_on_button_pressed_down_plain")
	if not _back.pressed.is_connected(press_callable):
		_back.pressed.connect(press_callable)
	var back_callable := Callable(self, "_on_back_pressed")
	if not _back.pressed.is_connected(back_callable):
		_back.pressed.connect(back_callable)

func _rebuild_level_buttons() -> void:
	if _levelButtons == null or _levelBtnTemplate == null:
		return
	for child in _levelButtons.get_children():
		if child != _levelBtnTemplate and child is TextureButton:
			child.queue_free()
	_levelBtnTemplate.visible = false

	for level_data in _cached_levels:
		var level_button := _levelBtnTemplate.duplicate() as TextureButton
		if level_button == null:
			continue
		level_button.visible = true
		level_button.set_meta("RuntimeGenerated", true)
		level_button.set_meta("LevelPath", String(level_data["level_path"]))
		level_button.set_meta("Chapter", int(level_data["chapter"]))
		level_button.set_meta("Puzzle", int(level_data["puzzle"]))
		var enter_callable := Callable(self, "_on_button_hovered_level").bind(level_button)
		if not level_button.mouse_entered.is_connected(enter_callable):
			level_button.mouse_entered.connect(enter_callable)
		var exit_callable := Callable(self, "_on_button_not_hovered_level")
		if not level_button.mouse_exited.is_connected(exit_callable):
			level_button.mouse_exited.connect(exit_callable)
		var pressed_callable := Callable(self, "_on_button_pressed_down_level").bind(level_button)
		if not level_button.pressed.is_connected(pressed_callable):
			level_button.pressed.connect(pressed_callable)
		_levelButtons.add_child(level_button)

func _on_button_hovered_level(level_button: TextureButton) -> void:
	var audio: AudioService = Game.Instance.get_service(Game.SERVICE_AUDIO)
	audio.play_sfx(_hoverSound)
	if _levelLabel == null:
		return
	var chapter := int(level_button.get_meta("Chapter", 0))
	var puzzle := int(level_button.get_meta("Puzzle", 0))
	_levelLabel.text = "Chapter %d Puzzle %d" % [chapter, puzzle]

func _on_button_hovered_plain() -> void:
	var audio: AudioService = Game.Instance.get_service(Game.SERVICE_AUDIO)
	audio.play_sfx(_hoverSound)

func _on_button_not_hovered_level() -> void:
	if _levelLabel != null:
		_levelLabel.text = DEFAULT_LEVEL_LABEL

func _on_button_pressed_down_level(level_button: TextureButton) -> void:
	var audio: AudioService = Game.Instance.get_service(Game.SERVICE_AUDIO)
	var ui: UIService = Game.Instance.get_service(Game.SERVICE_UI)
	var game_state: GameStateService = Game.Instance.get_service(Game.SERVICE_GAME_STATE)
	var level_path := level_button.get_meta("LevelPath", "") as String
	if level_path.is_empty():
		push_error("[LevelsUI] LevelPath is missing for selected level button.")
		return

	audio.play_sfx(_pressSound)
	audio.play_bgm(_gameBgm)
	game_state.change_game_state(GameStateService.GameState.GAME)
		
	var level: LevelService = Game.Instance.get_service(Game.SERVICE_LEVEL)
	ui.enqueue_close_top()
	level.load_level.call_deferred(level_path)

func _on_button_pressed_down_plain() -> void:
	var audio: AudioService = Game.Instance.get_service(Game.SERVICE_AUDIO)
	audio.play_sfx(_pressSound)

func _on_back_pressed() -> void:
	var ui: UIService = Game.Instance.get_service(Game.SERVICE_UI)
	ui.close_top()
	ui.open_ui("MainMenuUI")

func _ensure_level_cache() -> void:
	if _cache_built:
		return
	_cached_levels.clear()

	var level_dir := DirAccess.open(LEVELS_DIR)
	if level_dir == null:
		push_error("[LevelsUI] Failed to open level directory: %s" % LEVELS_DIR)
		_cache_built = true
		return

	var file_regex := RegEx.new()
	var compile_status := file_regex.compile(LEVEL_FILE_PATTERN)
	if compile_status != OK:
		push_error("[LevelsUI] Failed to compile level pattern: %s" % LEVEL_FILE_PATTERN)
		_cache_built = true
		return

	for file_name in level_dir.get_files():
		var match := file_regex.search(file_name)
		if match == null:
			continue
		var chapter := int(match.get_string(1))
		var puzzle := int(match.get_string(2))
		_cached_levels.append(
			{
				"level_path": "%s/%s" % [LEVELS_DIR, file_name],
				"chapter": chapter,
				"puzzle": puzzle,
				"file_name": file_name,
			}
		)

	_cached_levels.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var chapter_a := int(a["chapter"])
		var chapter_b := int(b["chapter"])
		if chapter_a == chapter_b:
			return int(a["puzzle"]) < int(b["puzzle"])
		return chapter_a < chapter_b
	)

	_cache_built = true
