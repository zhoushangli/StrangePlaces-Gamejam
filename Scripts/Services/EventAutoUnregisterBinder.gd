extends Node
class_name EventAutoUnregisterBinder

const BINDER_NAME := "__EventAutoUnregisterBinder"

var _actions: Array[Callable] = []
var _executed := false

static func get_or_create(targetNode: Node) -> Node:
	var existing := targetNode.get_node_or_null(BINDER_NAME)
	if existing != null:
		return existing
	var binder := preload("res://Scripts/Services/EventAutoUnregisterBinder.gd").new()
	binder.name = BINDER_NAME
	targetNode.add_child(binder)
	return binder

func register_action(action: Callable) -> void:
	if not action.is_valid():
		return
	if _executed:
		action.call()
		return
	_actions.append(action)

func _enter_tree() -> void:
	tree_exiting.connect(_execute_and_clear)

func _exit_tree() -> void:
	if tree_exiting.is_connected(_execute_and_clear):
		tree_exiting.disconnect(_execute_and_clear)

func _execute_and_clear() -> void:
	if _executed:
		return
	_executed = true
	for action in _actions:
		if action.is_valid():
			action.call()
	_actions.clear()
