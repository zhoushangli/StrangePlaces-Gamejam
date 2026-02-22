extends "res://Scripts/UI/UIBase.gd"
class_name HUDUI

@export var _progressCircle: TextureProgressBar
@export var _restartButton: TextureButton
@export var restartTime: float = 1.5
@export var resetSpeed: float = 50.0

var pressing := false

func get_ui_key() -> String:
	return "HUDUI"

func on_open(_args: Variant = null) -> void:
	pressing = false
	_restartButton.button_down.connect(_on_restart_pressed)
	_restartButton.button_up.connect(_on_restart_released)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		pressing = true
	if Input.is_action_just_released("restart"):
		pressing = false

func _physics_process(delta: float) -> void:
	if pressing:
		_progressCircle.value += delta * 100.0 / restartTime
		if _progressCircle.value >= 99.0:
			_progressCircle.value = 0
			var current_scene := get_tree().current_scene.scene_file_path
			get_tree().unload_current_scene()
			var level: Variant = Game.Instance.try_get_service(Game.SERVICE_LEVEL)
			if level != null:
				level.load_level.call_deferred(current_scene)
	else:
		_progressCircle.value -= delta * resetSpeed
		if _progressCircle.value < 0:
			_progressCircle.value = 0

func _on_restart_pressed() -> void:
	pressing = true

func _on_restart_released() -> void:
	pressing = false
