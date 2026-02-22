extends Area2D
class_name QuantumObserver

@export var _light: PointLight2D

var is_observing := false

func _ready() -> void:
	is_observing = false
	if _light != null:
		_light.visible = is_observing
	var quantum_service: Variant = Game.Instance.try_get_service(Game.SERVICE_QUANTUM)
	if quantum_service != null:
		quantum_service.register_observer(self)
	else:
		push_warning("[QuantumObserver] QuantumService not ready when '%s' entered tree." % name)

func _exit_tree() -> void:
	var quantum_service: Variant = Game.Instance.try_get_service(Game.SERVICE_QUANTUM)
	if quantum_service != null:
		quantum_service.unregister_observer(self)

func can_observe(item) -> bool:
	if not is_observing or item == null:
		return false
	return overlaps_body(item)

func set_observing(observing: bool) -> void:
	is_observing = observing
	if _light != null:
		_light.visible = is_observing

func toggle_observing() -> void:
	set_observing(not is_observing)
