extends Control
class_name UIBase

func get_ui_key() -> String:
	return get_script().resource_path.get_file().get_basename()

func on_open(_args: Variant = null) -> void:
	pass

func on_close() -> void:
	pass
