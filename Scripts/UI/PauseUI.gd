extends "res://Scripts/UI/UIBase.gd"
class_name PauseUI
const STATE_MAIN_MENU := 1

@export var _resumeButton: TextureButton
@export var _backButton: TextureButton
@export var _exitButton: TextureButton
@export var _focusSound: AudioStream
@export var _confirmSound: AudioStream

func get_ui_key() -> String:
	return "PauseUI"

func on_open(_args: Variant = null) -> void:
	_resumeButton.pressed.connect(_on_resume_pressed)
	_backButton.pressed.connect(_on_back_pressed)
	_exitButton.pressed.connect(_on_quit_pressed)

	_resumeButton.mouse_entered.connect(_on_hovered)
	_backButton.mouse_entered.connect(_on_hovered)
	_exitButton.mouse_entered.connect(_on_hovered)

func _on_hovered() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _focusSound != null:
		audio.play_sfx(_focusSound)

func _on_resume_pressed() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	if audio != null and _confirmSound != null:
		audio.play_sfx(_confirmSound)
	if ui != null:
		ui.close_top()

func _on_back_pressed() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	var ui: Variant = Game.Instance.try_get_service(Game.SERVICE_UI)
	var game_state: Variant = Game.Instance.try_get_service(Game.SERVICE_GAME_STATE)
	if audio != null and _confirmSound != null:
		audio.play_sfx(_confirmSound)
	if ui != null:
		ui.close_top()
	if game_state != null:
		game_state.change_game_state(STATE_MAIN_MENU)

func _on_quit_pressed() -> void:
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _confirmSound != null:
		audio.play_sfx(_confirmSound)
	get_tree().quit()
