extends "res://Scripts/UI/UIBase.gd"
class_name LoadingUI

@export var _bar: TextureProgressBar
@export var _lightings: GPUParticles2D
@export var _alter: Sprite2D
@export var _fillingSpeed: float = 20.0

var percentage := 0.0
var startLoad := false
var _clocker := 0.0

func get_ui_key() -> String:
	return "LoadingUI"

func _ready() -> void:
	percentage = 0.0
	startLoad = false

func on_open(_args: Variant = null) -> void:
	startLoad = true

func change_percent(target_val: float) -> void:
	percentage = target_val

func _process(delta: float) -> void:
	if not startLoad:
		return
	_clocker += delta
	_lightings.amount_ratio = percentage / 100.0
	if percentage >= 70.0:
		_alter.frame = 1
	if _clocker < 3.0 and _clocker >= 2.9:
		change_percent(30)
	if _clocker < 6.0 and _clocker >= 5.9:
		change_percent(70)
	if _clocker < 7.0 and _clocker >= 6.9:
		change_percent(100)
	if _bar.value < percentage:
		_bar.value += delta * _fillingSpeed
	elif _bar.value >= percentage:
		_bar.value -= delta * _fillingSpeed
