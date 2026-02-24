extends StaticBody2D
class_name QuantumItem

@export var _anchor_root: Node2D
@export var _moveSfx: AudioStream
@export var _moveParticles: Array[GPUParticles2D] = []

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

	for move_particles in _moveParticles:
		if move_particles == null:
			continue
		move_particles.global_position = global_position
	call_deferred("_attach_moveParticles_to_scene_deferred")

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
	var old_position := global_position
	for move_particles in _moveParticles:
		if move_particles == null:
			continue
		move_particles.global_position = old_position
		move_particles.emitting = true
		move_particles.restart()
	var audio: AudioService = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _moveSfx != null:
		audio.play_sfx(_moveSfx)
	_anchor_index = (_anchor_index + 1) % _anchors_position.size()
	global_position = _anchors_position[_anchor_index]

func _attach_moveParticles_to_scene_deferred() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	for move_particles in _moveParticles:
		if move_particles == null or move_particles.get_parent() == scene:
			continue
		var particles_parent: Node = move_particles.get_parent()
		if particles_parent != null:
			particles_parent.remove_child(move_particles)
		scene.add_child(move_particles)
		move_particles.global_position = global_position
		move_particles.z_index = 100
