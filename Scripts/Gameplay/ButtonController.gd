extends Area2D
class_name ButtonController

@export var _door: Node = null
@export var _anim: AnimatedSprite2D

var _occupants: Dictionary = {}
var _is_active := false
var _has_state := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_set_active(false)

func _on_body_entered(body: Node2D) -> void:
	if not _is_valid_activator(body):
		return
	_occupants[body] = true
	_refresh_state()

func _on_body_exited(body: Node2D) -> void:
	if not _is_valid_activator(body):
		return
	_occupants.erase(body)
	_refresh_state()

func _is_valid_activator(body: Node2D) -> bool:
	return body.has_method("enter_level_pass_state") or body.has_method("try_push")

func _refresh_state() -> void:
	_set_active(_occupants.size() > 0)

func _set_active(active: bool) -> void:
	if _has_state and _is_active == active:
		return
	_has_state = true
	_is_active = active
	if _anim != null:
		_anim.play("active" if active else "deactive")
	if _door != null:
		_door.set_active(active)
