extends StaticBody2D
class_name DoorController

const PROGRESS_PER_SECOND := 0.6

@export var _anim: AnimatedSprite2D
@export var _collisionShape: CollisionShape2D

var _progress := 0.0
var _is_active := false
var _is_open := false
var _warned_invalid_anim := false

func _ready() -> void:
	_progress = clamp(_progress, 0.0, 1.0)
	_apply_progress_visual()
	_sync_collision_from_progress()

func _process(delta: float) -> void:
	if _is_active:
		_progress += delta * PROGRESS_PER_SECOND
		_progress = clamp(_progress, 0.0, 1.0)
	else:
		_progress -= delta * PROGRESS_PER_SECOND
		_progress = clamp(_progress, 0.0, 1.0)

	_apply_progress_visual()
	_sync_collision_from_progress()

func set_active(active: bool) -> void:
	_is_active = active

func get_progress() -> float:
	return _progress

func _apply_progress_visual() -> void:
	if _anim == null:
		return
	_anim.pause()
	var sprite_frames := _anim.sprite_frames
	var anim_name := _anim.animation
	if sprite_frames == null or anim_name == StringName():
		if not _warned_invalid_anim:
			_warned_invalid_anim = true
			push_warning("DoorController: missing sprite frames or animation name, cannot sample frame by progress.")
		return
	var frame_count := sprite_frames.get_frame_count(anim_name)

	var target_frame := int(floor(_progress * float(frame_count - 1)))
	target_frame = clamp(target_frame, 0, frame_count - 1)
	_anim.frame = target_frame

func _sync_collision_from_progress() -> void:
	var should_open := _progress >= 1.0
	if _is_open == should_open:
		return
	_is_open = should_open
	if _collisionShape != null:
		_collisionShape.call_deferred("set_disabled", should_open)
