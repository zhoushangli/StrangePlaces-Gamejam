extends Node

const SERVICE_EVENT := "event_service"
const SERVICE_GAME_STATE := "game_state_service"
const SERVICE_SCENE := "scene_service"
const SERVICE_AUDIO := "audio_service"
const SERVICE_UI := "ui_service"
const SERVICE_POST_PROCESS := "post_process_service"
const SERVICE_LEVEL := "level_service"
const SERVICE_QUANTUM := "quantum_service"

static var Instance: Game

var _instances: Dictionary = {}
var _init_order: Array[String] = []

func _enter_tree() -> void:
	Instance = self

func _exit_tree() -> void:
	shutdown_all()
	if Instance == self:
		Instance = null

func register_service(service_key: String, instance: Variant) -> void:
	if instance == null:
		push_error("[Game] Service instance is null for key: %s" % service_key)
		return
	if _instances.has(service_key):
		push_error("[Game] Service already registered: %s" % service_key)
		return
	if not instance.has_method("init_service") or not instance.has_method("shutdown_service"):
		push_error("[Game] Service %s missing init_service/shutdown_service." % service_key)
		return

	_instances[service_key] = instance
	_init_order.append(service_key)

func register_new(service_key: String, script_ref: Script) -> Variant:
	if script_ref == null:
		push_error("[Game] register_new called with null script for %s" % service_key)
		return null
	var service: Variant = script_ref.new()
	register_service(service_key, service)
	if _instances.has(service_key):
		service.init_service()
	return service

func register_from_scene(service_key: String, scene_path: String) -> Variant:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("[Game] Service scene not found: %s" % scene_path)
		return null

	var inst := packed.instantiate()
	if inst == null:
		push_error("[Game] Failed to instantiate service scene: %s" % scene_path)
		return null
	register_service(service_key, inst)
	if _instances.has(service_key):
		add_child(inst)
		inst.init_service()
	return inst

func get_service(service_key: String) -> Variant:
	if _instances.has(service_key):
		return _instances[service_key]
	push_error("[Game] Service is not registered: %s" % service_key)
	return null

func try_get_service(service_key: String) -> Variant:
	return _instances.get(service_key, null)

func unregister_service(service_key: String) -> void:
	if not _instances.has(service_key):
		return
	var service: Variant = _instances[service_key]
	if service != null and service.has_method("shutdown_service"):
		service.shutdown_service()
	if service is Node:
		(service as Node).queue_free()
	_instances.erase(service_key)
	_init_order.erase(service_key)

func shutdown_all() -> void:
	for i in range(_init_order.size() - 1, -1, -1):
		var key := _init_order[i]
		var service: Variant = _instances.get(key)
		if service != null and service.has_method("shutdown_service"):
			service.shutdown_service()
	_instances.clear()
	_init_order.clear()
