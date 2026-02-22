extends StaticBody2D
class_name DoorController

@export var _anim: AnimatedSprite2D
@export var _collisionShape: CollisionShape2D

var _is_active := false
var _has_state := false

func _ready() -> void:
	set_active(false)

func set_active(active: bool) -> void:
	if _has_state and _is_active == active:
		return
	_has_state = true
	_is_active = active
	if _anim != null:
		_anim.play("active" if active else "deactive")
	if _collisionShape != null:
		_collisionShape.call_deferred("set_disabled", active)
