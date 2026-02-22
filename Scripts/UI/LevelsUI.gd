extends "res://Scripts/UI/UIBase.gd"
class_name LevelsUI
const STATE_GAME := 2

@export var _levelButtons: GridContainer
@export var _sceneView: NinePatchRect
@export var _lockedTexture: Texture2D
@export var _unLockedTexture: Texture2D
@export var _hoverTexture: Texture2D
@export var _start: TextureButton
@export var _back: TextureButton
@export var _hoverSound: AudioStream
@export var _pressSound: AudioStream
@export var _gameBgm: AudioStream
@export var finishedCnt: int = 0

var _level_unlocked: Dictionary = {}
var _level_finished: Dictionary = {}
var _levels_idx: Dictionary = {}
var _levels_array: Array[TextureRect] = []
var _button_cnt := 0

func get_ui_key() -> String:
	return "LevelsUI"

func on_open(_args: Variant = null) -> void:
	_button_cnt = 0
	_level_unlocked.clear()
	_levels_idx.clear()
	_levels_array.clear()
	_level_finished.clear()

	_start.mouse_entered.connect(_on_button_hovered_plain)
	_start.pressed.connect(_on_button_pressed_down_plain)
	_start.pressed.connect(_on_start_pressed)

	_back.mouse_entered.connect(_on_button_hovered_plain)
	_back.pressed.connect(_on_button_pressed_down_plain)
	_back.pressed.connect(_on_back_pressed)

	for child in _levelButtons.get_children():
		if child is TextureRect:
			var b := child as TextureRect
			_level_unlocked[b] = false
			_level_finished[b] = false
			_levels_idx[b] = _button_cnt
			_levels_array.append(b)
			_button_cnt += 1
			b.mouse_entered.connect(func() -> void: _on_button_hovered_level(b))
			b.mouse_exited.connect(func() -> void: _on_button_not_hovered_level(b))
			b.gui_input.connect(func(input_event: InputEvent) -> void:
				if input_event is InputEventMouseButton:
					var mouse_event := input_event as InputEventMouseButton
					if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
						_on_button_pressed_down_level(b)
			)

	_enlight_buttons(finishedCnt)
	var columns := _levelButtons.columns
	for i in range(_levels_array.size()):
		var one_level := _levels_array[i]
		var current_col := i % columns
		var current_row := i / columns
		if bool(_level_finished[one_level]):
			var wire_right := one_level.get_node("WireRight") as TextureRect
			wire_right.visible = current_col != columns - 1
			var wire_up := one_level.get_node("WireUp") as TextureRect
			wire_up.visible = false
			var wire_left := one_level.get_node("WireLeft") as TextureRect
			wire_left.visible = (current_row % 2 == 1 and current_col != 0)
			var wire_down := one_level.get_node("WireDown") as TextureRect
			wire_down.visible = false
		else:
			for wire in one_level.get_children():
				if wire is TextureRect:
					(wire as TextureRect).visible = false

func _enlight_buttons(done_count: int) -> void:
	for i in range(done_count):
		if i >= _levels_array.size():
			break
		var level := _levels_array[i]
		_level_finished[level] = true
		_level_unlocked[level] = true
		level.texture = _unLockedTexture
	if done_count < _levels_array.size():
		var next_level := _levels_array[done_count]
		_level_unlocked[next_level] = true
		next_level.texture = _unLockedTexture

func _on_button_hovered_level(level_button: TextureRect) -> void:
	var idx := int(_levels_idx[level_button])
	level_button.texture = _hoverTexture
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _hoverSound != null:
		audio.play_sfx(_hoverSound)
	(_sceneView.get_node("LevelIdx") as Label).text = "Level %d" % idx
	(_sceneView.get_node("LevelName") as Label).text = "This is level %d." % idx

func _on_button_hovered_plain() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _hoverSound != null:
		audio.play_sfx(_hoverSound)

func _on_button_not_hovered_level(level_button: TextureRect) -> void:
	if bool(_level_unlocked[level_button]):
		level_button.texture = _unLockedTexture
	else:
		level_button.texture = _lockedTexture

func _on_button_pressed_down_level(level_button: TextureRect) -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	var game_state: Variant = Game.Instance.try_get_service(Game.SERVICE_GAME_STATE)
	var level: Variant = Game.Instance.try_get_service(Game.SERVICE_LEVEL)
	if audio != null and _pressSound != null:
		audio.play_sfx(_pressSound)
	if audio != null and _gameBgm != null:
		audio.play_bgm(_gameBgm)
	if ui != null:
		ui.close_top()
	if game_state != null:
		game_state.change_game_state(STATE_GAME)
	if level != null:
		level.load_level.call_deferred(level_button.get_meta("LevelPath", "") as String)
	if ui != null:
		ui.open_by_key("HUDUI")

func _on_button_pressed_down_plain() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _pressSound != null:
		audio.play_sfx(_pressSound)

func _on_start_pressed() -> void:
	print("start func not finished.")

func _on_back_pressed() -> void:
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	if ui == null:
		return
	ui.close_top()
	ui.open_by_key("MainMenuUI")
