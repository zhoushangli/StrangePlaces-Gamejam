extends RefCounted
class_name EventService
const EventSubscriptionScript = preload("res://Scripts/Services/EventSubscription.gd")

var _handlers: Dictionary = {}

func init_service() -> void:
	pass

func shutdown_service() -> void:
	_handlers.clear()

func subscribe(event_name: String, handler: Callable) -> Variant:
	if event_name.is_empty() or not handler.is_valid():
		return EventSubscriptionScript.new()
	if not _handlers.has(event_name):
		_handlers[event_name] = []
	var list: Array = _handlers[event_name]
	for existing in list:
		if existing == handler:
			return EventSubscriptionScript.new(self, event_name, handler)
	list.append(handler)
	_handlers[event_name] = list
	return EventSubscriptionScript.new(self, event_name, handler)

func unsubscribe(event_name: String, handler: Callable) -> void:
	_remove_handler(event_name, handler)

func publish(event_name: String, payload: Variant = null) -> bool:
	if not _handlers.has(event_name):
		return false
	var list: Array = _handlers[event_name]
	if list.is_empty():
		return false
	var snapshot := list.duplicate()
	for handler in snapshot:
		if handler is Callable and (handler as Callable).is_valid():
			var consumed := false
			if payload == null:
				consumed = bool((handler as Callable).call())
			else:
				consumed = bool((handler as Callable).call(payload))
			if consumed:
				return true
	return false

func _remove_handler(event_name: String, handler: Callable) -> void:
	if not _handlers.has(event_name):
		return
	var list: Array = _handlers[event_name]
	for i in range(list.size() - 1, -1, -1):
		if list[i] == handler:
			list.remove_at(i)
	if list.is_empty():
		_handlers.erase(event_name)
	else:
		_handlers[event_name] = list
