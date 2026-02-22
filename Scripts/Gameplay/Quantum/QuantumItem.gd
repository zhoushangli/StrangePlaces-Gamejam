extends StaticBody2D
class_name QuantumItem

@export var _anchors: Array[Node2D] = []
@export var _moveSfx: AudioStream
@export var _moveParticles: Array[GPUParticles2D] = []

var is_observed := false
var _anchor_index := 0

func _ready() -> void:
	var quantum_service: Variant = Game.Instance.try_get_service(Game.SERVICE_QUANTUM)
	if quantum_service != null:
		quantum_service.register_item(self)
	else:
		push_warning("[QuantumItem] QuantumService not ready when '%s' entered tree." % name)

	if not _anchors.is_empty() and _anchors[0] != null:
		global_position = GridUtil.snap_to_grid(_anchors[0].global_position)
	else:
		global_position = GridUtil.snap_to_grid(global_position)

	for move_particles in _moveParticles:
		if move_particles == null:
			continue
		move_particles.global_position = global_position
	call_deferred("_attach_moveParticles_to_scene_deferred")

func _exit_tree() -> void:
	var quantum_service: Variant = Game.Instance.try_get_service(Game.SERVICE_QUANTUM)
	if quantum_service != null:
		quantum_service.unregister_item(self)

func set_observed(observed: bool) -> void:
	if is_observed == observed:
		return
	var was_observed := is_observed
	is_observed = observed
	if was_observed and not observed:
		_move_to_next_anchor()

func _move_to_next_anchor() -> void:
	if _anchors.is_empty():
		return
	var old_position := global_position
	for move_particles in _moveParticles:
		if move_particles == null:
			continue
		move_particles.global_position = old_position
		move_particles.emitting = true
		move_particles.restart()
	var audio: Variant = Game.Instance.try_get_service(Game.SERVICE_AUDIO)
	if audio != null and _moveSfx != null:
		audio.play_sfx(_moveSfx)
	_anchor_index = (_anchor_index + 1) % _anchors.size()
	global_position = GridUtil.snap_to_grid(_anchors[_anchor_index].global_position)

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
