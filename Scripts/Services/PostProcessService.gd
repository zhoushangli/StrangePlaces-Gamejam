extends CanvasLayer
class_name PostProcessService

@export var _crtEffect: ColorRect
@export var _transitionEffect: ColorRect
@export var transition_out_duration: float
@export var transition_in_duration: float

const TRANSITION_PARAM := "transition"

func init_service() -> void:
	if _crtEffect == null:
		push_warning("[PostProcessService] CRT ColorRect is not assigned.")
	else:
		var crt_mat := _crtEffect.material as ShaderMaterial
		if crt_mat == null:
			push_warning("[PostProcessService] CRT ColorRect has no ShaderMaterial.")
	if _transitionEffect == null:
		push_warning("[PostProcessService] Transition ColorRect is not assigned.")
		return
	var transition_mat := _transitionEffect.material as ShaderMaterial
	if transition_mat == null:
		push_warning("[PostProcessService] Transition ColorRect has no ShaderMaterial.")
		return
	set_transition_value(0.0)

func set_transition_value(value: float) -> void:
	var mat := _transitionEffect.material as ShaderMaterial
	mat.set_shader_parameter(TRANSITION_PARAM, clampf(value, 0.0, 1.0))

func play_scene_transition_out() -> void:
	await _play_transition(1.0, transition_out_duration)

func play_scene_transition_in() -> void:
	await _play_transition(0.0, transition_in_duration)

func _play_transition(target: float, duration: float) -> void:
	var mat := _transitionEffect.material as ShaderMaterial
	if mat == null:
		return
	target = clampf(target, 0.0, 1.0)
	var current_value: Variant = mat.get_shader_parameter(TRANSITION_PARAM)
	var from_value := float(current_value) if current_value is float or current_value is int else 0.0
	set_transition_value(from_value)
	if duration <= 0.0:
		set_transition_value(target)
		return
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/%s" % TRANSITION_PARAM, target, duration)
	await tween.finished

func shutdown_service() -> void:
	pass
