extends CanvasLayer
class_name PostProcessService

@export var _colorRect: ColorRect

func init_service() -> void:
	if _colorRect == null:
		push_warning("[PostProcessService] ColorRect is not assigned.")
		return
	var mat := _colorRect.material as ShaderMaterial
	if mat == null:
		push_error("ColorRect has no ShaderMaterial")

func shutdown_service() -> void:
	pass
