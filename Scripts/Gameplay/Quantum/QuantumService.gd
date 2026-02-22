extends Node
class_name QuantumService

var _observers: Array[QuantumObserver] = []
var _items: Array[QuantumItem] = []

func init_service() -> void:
	pass

func shutdown_service() -> void:
	_observers.clear()
	_items.clear()

func register_observer(observer) -> void:
	if observer == null or not is_instance_valid(observer):
		return
	if not _observers.has(observer):
		_observers.append(observer)

func unregister_observer(observer) -> void:
	_observers.erase(observer)

func register_item(item) -> void:
	if item == null or not is_instance_valid(item):
		return
	if not _items.has(item):
		_items.append(item)

func unregister_item(item) -> void:
	_items.erase(item)

func _process(_delta: float) -> void:
	for item in _items:
		if not is_instance_valid(item):
			continue
		var observed_now := false
		for observer in _observers:
			if is_instance_valid(observer) and observer.can_observe(item):
				observed_now = true
				break
		item.set_observed(observed_now)
