extends "res://Scripts/Gameplay/Level/LVL_Base.gd"
class_name LVL_01_02

@export var _observer: Node = null
@export var _observerToggleInterval: float = 2.0

func _ready() -> void:
	var tween := create_tween().set_loops()
	tween.tween_callback(func() -> void:
		if _observer != null:
			_observer.toggle_observing()
	)
	tween.tween_interval(_observerToggleInterval)
