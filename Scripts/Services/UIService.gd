extends CanvasLayer
class_name UIService

const UI_PREFAB_BASE := "res://Prefabs/UI/"

var _popup_layer: Control
var _stack: Array = []

func init_service() -> void:
	name = "UIRoot"
	_popup_layer = get_node("PopupLayer") as Control
	tree_exiting.connect(func() -> void:
		_stack.clear()
	)

func shutdown_service() -> void:
	_stack.clear()

func open_by_key(ui_key: String, args: Variant = null) -> Variant:
	var path := "%s%s.tscn" % [UI_PREFAB_BASE, _get_prefab_name(ui_key)]
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("[UIService] UI prefab not found: %s" % path)
		return null
	var inst := packed.instantiate()
	if inst == null:
		push_error("[UIService] Instantiated scene is not UIBase: %s" % path)
		return null
	_popup_layer.add_child(inst)
	_open_instance(inst, args)
	return inst

func open_scene(scene: PackedScene, args: Variant = null) -> Node:
	if scene == null:
		push_error("[UIService] open_scene called with null PackedScene.")
		return null
	var instance := scene.instantiate()
	if instance == null:
		push_error("[UIService] Failed to instantiate UI scene.")
		return null
	_popup_layer.add_child(instance)
	if instance != null and instance.has_method("on_open") and instance.has_method("get_ui_key"):
		_open_instance(instance, args)
	return instance

func close_by_key(ui_key: String) -> void:
	for i in range(_stack.size() - 1, -1, -1):
		var ui: Variant = _stack[i]
		if not is_instance_valid(ui):
			_stack.remove_at(i)
			continue
		if ui.get_ui_key() != ui_key:
			continue
		_stack.remove_at(i)
		ui.on_close()
		ui.queue_free()
		return

func close_top() -> void:
	if _stack.is_empty():
		return
	var ui: Variant = _stack.back()
	_stack.remove_at(_stack.size() - 1)
	if is_instance_valid(ui):
		ui.on_close()
		ui.queue_free()

func is_open_by_key(ui_key: String) -> bool:
	for i in range(_stack.size() - 1, -1, -1):
		var ui: Variant = _stack[i]
		if not is_instance_valid(ui):
			continue
		if ui.get_ui_key() == ui_key:
			return true
	return false

func _open_instance(inst, args: Variant) -> void:
	var key: String = inst.get_ui_key()
	for i in range(_stack.size() - 1, -1, -1):
		var existing: Variant = _stack[i]
		if existing == null or not is_instance_valid(existing):
			_stack.remove_at(i)
			continue
		if existing.get_ui_key() != key:
			continue
		_stack.remove_at(i)
		existing.on_close()
		existing.queue_free()
		break
	inst.on_open(args)
	_stack.append(inst)

func _get_prefab_name(ui_key: String) -> String:
	var uiElementKey := ui_key
	if uiElementKey.ends_with("UI"):
		uiElementKey = uiElementKey.left(uiElementKey.length() - 2)
	return "UI_%s" % uiElementKey
