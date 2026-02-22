extends CharacterBody2D
class_name PlayerController
const GridUtil = preload("res://Scripts/Utils/GridUtil.gd")

enum PlayerState {
	IDLE,
	MOVING,
}

@export_group("Configuration")
@export var GridSize: int = 16
@export var MoveSpeed: float = 120.0
@export_flags_2d_physics var platformLayers: int
@export_flags_2d_physics var pushableBoxLayerMask: int = 64

@export_group("References")
@export var _anim: AnimatedSprite2D
@export var _stepSounds: Array[AudioStream] = []

var _fsm := preload("res://Scripts/Utils/SimpleStateMachine.gd").new()
var _target_position: Vector2
var _is_passing_level := false

func _ready() -> void:
	_anim.frame_changed.connect(_step_sound)
	global_position = GridUtil.snap_to_grid(global_position, GridSize)
	_target_position = global_position

	_fsm.add_state(
		PlayerState.IDLE,
		func() -> void:
			_anim.play("idle"),
		Callable(),
		func(_delta: float) -> void:
			var dir := _read_input_direction()
			_flip_sprite(dir)
			if dir != Vector2.ZERO and _try_start_move(dir):
				_fsm.change_state(PlayerState.MOVING)
	)

	_fsm.add_state(
		PlayerState.MOVING,
		func() -> void:
			_anim.play("walk"),
		Callable(),
		func(delta: float) -> void:
			var step := MoveSpeed * delta
			global_position = global_position.move_toward(_target_position, step)
			if global_position.distance_to(_target_position) > 0.01:
				return
			global_position = _target_position
			var dir := _read_input_direction()
			_flip_sprite(dir)
			if dir == Vector2.ZERO or not _try_start_move(dir):
				_fsm.change_state(PlayerState.IDLE)
	)

	_fsm.init(PlayerState.IDLE)

func _physics_process(delta: float) -> void:
	if _is_passing_level:
		return
	_fsm.update(delta)

func enter_level_pass_state() -> void:
	if _is_passing_level:
		return
	_is_passing_level = true
	velocity = Vector2.ZERO
	_target_position = global_position
	if _anim != null:
		_anim.play("pass_level")

func _step_sound() -> void:
	if _anim.animation != "walk":
		return
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio == null:
		return
	if _anim.frame == 3 and _stepSounds.size() > 0:
		audio.play_sfx(_stepSounds[0])
	elif _anim.frame == 7 and _stepSounds.size() > 1:
		audio.play_sfx(_stepSounds[1])

func _read_input_direction() -> Vector2:
	if Input.is_action_pressed("move_up"):
		return Vector2.UP
	if Input.is_action_pressed("move_down"):
		return Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		return Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		return Vector2.RIGHT
	return Vector2.ZERO

func _flip_sprite(dir: Vector2) -> void:
	if dir == Vector2.LEFT:
		_anim.flip_h = true
	elif dir == Vector2.RIGHT:
		_anim.flip_h = false

func _try_start_move(dir: Vector2) -> bool:
	var current_cell := GridUtil.snap_to_grid(global_position, GridSize)
	var target_position := GridUtil.snap_to_grid(current_cell + dir * GridSize, GridSize)

	var pushable_box : PushableBoxController = _try_find_pushable_box_at(target_position)
	if pushable_box != null:
		if not pushable_box.try_push(dir, GridSize, platformLayers):
			return false
	elif not GridUtil.has_only_platform_at(self, target_position, platformLayers):
		return false

	_target_position = target_position
	return true

func _try_find_pushable_box_at(target_position: Vector2) -> PushableBoxController:
	var space := get_world_2d().direct_space_state
	var circle := CircleShape2D.new()
	circle.radius = 4.0

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, target_position)
	query.collision_mask = pushableBoxLayerMask
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [get_rid()]

	var hits := space.intersect_shape(query, 1)
	if hits.is_empty():
		return null
	var collider : PushableBoxController = hits[0].get("collider")
	return collider
