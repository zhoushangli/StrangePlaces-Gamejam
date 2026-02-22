extends StaticBody2D
class_name PushableBoxController

@export_group("Movement")
@export var PushMoveSpeed: float = 120.0

var _target_position: Vector2
var _is_moving := false

func _ready() -> void:
	global_position = GridUtil.snap_to_grid(global_position, 16)
	_target_position = global_position

func _physics_process(delta: float) -> void:
	if not _is_moving:
		return
	var step := PushMoveSpeed * delta
	global_position = global_position.move_toward(_target_position, step)
	if global_position.distance_to(_target_position) > 0.01:
		return
	global_position = _target_position
	_is_moving = false

func try_push(dir: Vector2, grid_size: int, platform_layer_mask: int) -> bool:
	if _is_moving:
		return false
	var current_cell := GridUtil.snap_to_grid(global_position, grid_size)
	var next_cell := GridUtil.snap_to_grid(current_cell + dir * grid_size, grid_size)
	if not GridUtil.has_only_platform_at(self, next_cell, platform_layer_mask):
		return false
	if _has_other_box_at(next_cell):
		return false
	global_position = current_cell
	_target_position = next_cell
	_is_moving = true
	return true

func _has_other_box_at(targetPosition: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var circle := CircleShape2D.new()
	circle.radius = 4.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, targetPosition)
	query.collision_mask = collision_layer
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [get_rid()]
	var hits := space.intersect_shape(query, 2)
	return not hits.is_empty()
