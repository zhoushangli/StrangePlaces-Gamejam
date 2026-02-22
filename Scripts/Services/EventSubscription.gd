extends RefCounted
class_name EventSubscription

var _event_service
var _event_name: String
var _handler: Callable
var _disposed := false

func _init(event_service = null, event_name: String = "", handler: Callable = Callable()) -> void:
	_event_service = event_service
	_event_name = event_name
	_handler = handler

func unregister() -> void:
	if _disposed:
		return
	_disposed = true
	if _event_service != null and _handler.is_valid():
		_event_service._remove_handler(_event_name, _handler)

func unregister_on_destroy(owner: Node) -> EventSubscription:
	if _disposed:
		return self
	if owner == null:
		push_warning("[EventService] unregister_on_destroy called with null owner.")
		return self
	if not owner.is_inside_tree() or owner.is_queued_for_deletion():
		unregister()
		return self
	var binder := preload("res://Scripts/Services/EventAutoUnregisterBinder.gd").get_or_create(owner)
	binder.register_action(Callable(self, "unregister"))
	return self
