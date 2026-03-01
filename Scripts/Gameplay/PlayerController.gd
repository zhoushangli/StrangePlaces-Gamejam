extends CharacterBody2D
class_name PlayerController

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
@export var _flashlight: QuantumObserver
@export var _stepSounds: Array[AudioStream] = []

var _fsm := SimpleStateMachine.new()
var _target_position: Vector2
var _is_passing_level := false
var _current_level: LVL_Base

func _ready() -> void:
	_anim.frame_changed.connect(_step_sound)
	global_position = GridUtil.snap_to_grid(global_position, GridSize)
	_target_position = global_position
	_current_level = _resolve_current_level()
	_sync_flashlight_with_level_rule()

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
			if dir == Vector2.ZERO:
				_fsm.change_state(PlayerState.IDLE)
				return
			if _try_start_move(dir):
				return
			if _is_waiting_for_moving_box(dir):
				return
			_fsm.change_state(PlayerState.IDLE)
	)

	_fsm.init(PlayerState.IDLE)

func _physics_process(delta: float) -> void:
	_update_flashlight_logic()
	if _is_passing_level:
		return
	_fsm.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("toggle_flash_light") or event.is_echo():
		return
	_handle_flashlight_toggle_input()
	get_viewport().set_input_as_handled()

func enter_level_pass_state() -> void:
	if _is_passing_level:
		return
	_is_passing_level = true
	velocity = Vector2.ZERO
	_target_position = global_position
	if _anim != null:
		_anim.play("pass_level")

func force_snap_to_cell(cell: Vector2, grid_size: int) -> void:
	var snapped_cell := GridUtil.snap_to_grid(cell, grid_size)
	velocity = Vector2.ZERO
	_target_position = snapped_cell
	global_position = snapped_cell

func _step_sound() -> void:
	if _anim.animation != "walk":
		return
	var audio: AudioService = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
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
		var box_chain := _collect_pushable_box_chain(target_position, dir)
		if box_chain.is_empty():
			return false
		if not _can_push_chain(box_chain, dir):
			return false
		_begin_push_chain(box_chain, dir)
	elif not GridUtil.has_only_platform_at(self, target_position, platformLayers):
		return false

	_target_position = target_position
	return true

func _collect_pushable_box_chain(first_cell: Vector2, dir: Vector2) -> Array[PushableBoxController]:
	var chain: Array[PushableBoxController] = []
	var probe_cell := first_cell
	while true:
		var box := _try_find_pushable_box_at(probe_cell)
		if box == null:
			break
		if chain.has(box) or box.is_moving_now():
			var failed: Array[PushableBoxController] = []
			return failed
		chain.append(box)
		probe_cell = GridUtil.snap_to_grid(probe_cell + dir * GridSize, GridSize)
	return chain

func _can_push_chain(chain: Array[PushableBoxController], dir: Vector2) -> bool:
	if chain.is_empty():
		return false
	var last_box := chain[chain.size() - 1]
	var last_cell := last_box.get_cell(GridSize)
	var next_cell := GridUtil.snap_to_grid(last_cell + dir * GridSize, GridSize)
	return GridUtil.has_only_platform_at(self, next_cell, platformLayers)

func _begin_push_chain(chain: Array[PushableBoxController], dir: Vector2) -> void:
	for i in range(chain.size() - 1, -1, -1):
		var box := chain[i]
		var cell := box.get_cell(GridSize)
		var next_cell := GridUtil.snap_to_grid(cell + dir * GridSize, GridSize)
		box.begin_push_to(next_cell, GridSize)

func _is_waiting_for_moving_box(dir: Vector2) -> bool:
	var current_cell := GridUtil.snap_to_grid(global_position, GridSize)
	var probe_cell := GridUtil.snap_to_grid(current_cell + dir * GridSize, GridSize)
	var box := _try_find_pushable_box_at(probe_cell)
	if box == null:
		return false
	if box.is_moving_now():
		return true
	return false

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

func _handle_flashlight_toggle_input() -> void:
	if not _is_flashlight_allowed():
		_flashlight.set_observing(false)
		return
	_flashlight.toggle_observing()

func _update_flashlight_logic() -> void:
	if not _is_flashlight_allowed():
		_flashlight.set_observing(false)
		return
	if _flashlight.is_observing:
		_flashlight.look_at(get_global_mouse_position())

func _sync_flashlight_with_level_rule() -> void:
	if not _is_flashlight_allowed():
		_flashlight.set_observing(false)

func _is_flashlight_allowed() -> bool:
	if _current_level == null or not is_instance_valid(_current_level):
		_current_level = _resolve_current_level()
	if _current_level == null:
		return false
	return _current_level.isFlashLightOpen

func _resolve_current_level() -> LVL_Base:
	var parent_node := get_parent()
	if parent_node is LVL_Base:
		return parent_node as LVL_Base
	var node := parent_node
	while node != null:
		if node is LVL_Base:
			return node as LVL_Base
		node = node.get_parent()
	return null
