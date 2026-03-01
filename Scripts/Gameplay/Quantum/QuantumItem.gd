extends AnimatableBody2D
class_name QuantumItem

@export var _anchor_root: Node2D
@export var _moveSfx: AudioStream
@export var _particles: Array[GPUParticles2D] = []

const GRID_SIZE := 16
const PUSHABLE_BOX_LAYER_MASK := 64

var is_observed := false
var _anchors_position: Array[Vector2] = []
var _anchor_index := 0

func _ready() -> void:
	_refresh_anchors_position()

	var quantum_service: QuantumService = Game.Instance.try_get_service(Game.SERVICE_QUANTUM)
	if quantum_service != null:
		quantum_service.register_item(self )
	else:
		push_warning("[QuantumItem] QuantumService not ready when '%s' entered tree." % name)

	if not _anchors_position.is_empty():
		global_position = _anchors_position[0]
	else:
		global_position = GridUtil.snap_to_grid(global_position)

	for particle in _particles:
		if particle == null:
			continue
		particle.top_level = true
		particle.z_as_relative = false
		particle.z_index = 100
		particle.global_position = global_position

func _refresh_anchors_position() -> void:
	_anchors_position.clear()
	var snapped_position := GridUtil.snap_to_grid(global_position)
	var has_current_anchor := false
	if _anchor_root != null:
		for anchor in _anchor_root.get_children():
			if not (anchor is Node2D):
				continue
			var anchor_position := GridUtil.snap_to_grid(anchor.global_position)
			_anchors_position.append(anchor_position)
			if anchor_position.distance_to(snapped_position) < 0.1:
				has_current_anchor = true
	if not has_current_anchor:
		_anchors_position.insert(0, snapped_position)

func _exit_tree() -> void:
	var quantum_service: QuantumService = Game.Instance.try_get_service(Game.SERVICE_QUANTUM)
	if quantum_service != null:
		quantum_service.unregister_item(self )

func set_observed(observed: bool) -> void:
	if is_observed == observed:
		return
	var was_observed := is_observed
	is_observed = observed
	if was_observed and not observed:
		_move_to_next_anchor()

func _move_to_next_anchor() -> void:
	if _anchors_position.is_empty():
		return
	var target_anchor_index := (_anchor_index + 1) % _anchors_position.size()
	var target_cell := GridUtil.snap_to_grid(_anchors_position[target_anchor_index], GRID_SIZE)
	var carried_box := _find_single_overlapping_box()
	var carried_player := _find_single_overlapping_player()

	var old_position := global_position
	var jump_direction_2d := (target_cell - old_position).normalized()
	for particle in _particles:
		if particle == null:
			continue
		particle.global_position = old_position
		if particle.name == "Debris":
			var process_material := particle.process_material as ParticleProcessMaterial
			if process_material != null:
				process_material.direction = Vector3(jump_direction_2d.x, jump_direction_2d.y, 0.0)
		particle.emitting = true
		particle.restart()
	var audio: AudioService = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _moveSfx != null:
		audio.play_sfx(_moveSfx)
	_anchor_index = target_anchor_index
	global_position = target_cell
	if carried_box != null and is_instance_valid(carried_box):
		# Quantum jump wins over push movement in the same frame.
		carried_box.force_snap_to_cell(target_cell, GRID_SIZE)
	if carried_player != null and is_instance_valid(carried_player):
		carried_player.force_snap_to_cell(target_cell, GRID_SIZE)

func _find_single_overlapping_box() -> PushableBoxController:
	var boxes: Array[PushableBoxController] = []
	var hits := _query_overlapping_colliders(16, PUSHABLE_BOX_LAYER_MASK)
	for hit in hits:
		if not hit.has("collider"):
			continue
		var box := hit["collider"] as PushableBoxController
		if box == null or not is_instance_valid(box):
			continue
		if not boxes.has(box):
			boxes.append(box)
	if boxes.size() > 1:
		push_warning("[QuantumItem] More than one overlapping pushable box on '%s'. Carrying the first one only." % name)
	if boxes.is_empty():
		return null
	return boxes[0]

func _find_single_overlapping_player() -> PlayerController:
	var hits := _query_overlapping_colliders(16, 0xFFFFFFFF)
	var players: Array[PlayerController] = []
	for hit in hits:
		if not hit.has("collider"):
			continue
		var player := hit["collider"] as PlayerController
		if player == null or not is_instance_valid(player):
			continue
		if not players.has(player):
			players.append(player)
	if players.is_empty():
		return null
	return players[0]

func _query_overlapping_colliders(max_results: int, mask: int) -> Array:
	var space := get_world_2d().direct_space_state
	var circle := CircleShape2D.new()
	circle.radius = 4.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = mask
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [get_rid()]
	return space.intersect_shape(query, max_results)
