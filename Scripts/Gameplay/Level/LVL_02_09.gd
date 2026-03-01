extends LVL_Base
class_name LVL_02_09

@export var _observer: Node = null
@export var _observerToggleInterval: float = 2.0

@export var _portal: PortalController
@export var _victoryVfxs: Array[GPUParticles2D]
@export var _victorySfx: AudioStream

func _ready() -> void:
	var tween := create_tween().set_loops()
	tween.tween_callback(func() -> void:
		if _observer != null:
			_observer.toggle_observing()
	)
	tween.tween_interval(_observerToggleInterval)

	_portal.body_entered.connect(_on_portal_body_entered)

func _on_portal_body_entered(body: Node2D) -> void:
	if not body.has_method("enter_level_pass_state"):
		return
	
	for vfx in _victoryVfxs:
		vfx.emitting = true
	
	var audio = Game.Instance.get_service(Game.SERVICE_AUDIO) as AudioService
	audio.play_sfx(_victorySfx)