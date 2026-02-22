extends "res://Scripts/UI/UIBase.gd"
class_name MainMenuUI
const STATE_GAME := 2

@export var _startButton: TextureButton
@export var _quitButton: TextureButton
@export var _pressStartButton: TextureButton
@export var _levelButton: TextureButton
@export var _startPlate: NinePatchRect
@export var sparkSpeed: float = 1.0
@export var _hoverSound: AudioStream
@export var _confirmSound: AudioStream
@export var _bgm: AudioStream
@export var _gameBgm: AudioStream
@export var _firstLevelPath: String

var _start_pressed := false
var _increasing := 1.0

func get_ui_key() -> String:
	return "MainMenuUI"

func on_open(_args: Variant = null) -> void:
	_start_pressed = false
	_increasing = 1.0
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _bgm != null:
		audio.play_bgm(_bgm)

	_startButton.pressed.connect(_on_start_pressed)
	_quitButton.pressed.connect(_on_quit_pressed)
	_pressStartButton.pressed.connect(_on_press_start_pressed)
	_levelButton.pressed.connect(_on_levels_pressed)

	_startButton.pressed.connect(_on_confirmed)
	_quitButton.pressed.connect(_on_confirmed)
	_pressStartButton.pressed.connect(_on_confirmed)
	_levelButton.pressed.connect(_on_confirmed)

	_startButton.mouse_entered.connect(_on_hovered)
	_quitButton.mouse_entered.connect(_on_hovered)
	_levelButton.mouse_entered.connect(_on_hovered)

	_startPlate.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_on_press_start_pressed()
	elif event is InputEventJoypadButton and event.pressed:
		_on_press_start_pressed()
	elif event is InputEventMouseButton and event.pressed:
		_on_press_start_pressed()

func _process(delta: float) -> void:
	_spark(delta)

func _on_hovered() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _hoverSound != null:
		audio.play_sfx(_hoverSound)

func _on_confirmed() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _confirmSound != null:
		audio.play_sfx(_confirmSound)

func _spark(delta: float) -> void:
	var old_alpha := _pressStartButton.modulate.a
	if old_alpha >= 1.0:
		_increasing = -1.0
	elif old_alpha <= 0.0:
		_increasing = 1.0
	old_alpha += _increasing * sparkSpeed * delta
	_pressStartButton.modulate = Color(1, 1, 1, old_alpha)

func _on_start_pressed() -> void:
	if _start_pressed:
		return
	
	_start_pressed = true
	
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	var game_state: Variant = Game.Instance.try_get_service(Game.SERVICE_GAME_STATE)
		
	ui.close_top()
	audio.play_bgm(_gameBgm)
	game_state.change_game_state(STATE_GAME)

	var level: LevelService = Game.Instance.try_get_service(Game.SERVICE_LEVEL)
	level.load_level.call_deferred(_firstLevelPath)
	
	ui.open_by_key("HUDUI")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_levels_pressed() -> void:
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	if ui == null:
		return
	ui.close_top()
	ui.open_by_key("LevelsUI")

func _on_press_start_pressed() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _confirmSound != null:
		audio.play_sfx(_confirmSound)
	_pressStartButton.visible = false
	_startPlate.visible = true
