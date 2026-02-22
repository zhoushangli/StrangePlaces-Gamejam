extends RefCounted
class_name SimpleStateMachine

var _states: Dictionary = {}
var current_state: Variant = null
var _initialized := false

func add_state(state: Variant, on_enter: Callable = Callable(), on_exit: Callable = Callable(), on_update: Callable = Callable()) -> void:
	_states[state] = {
		"on_enter": on_enter,
		"on_exit": on_exit,
		"on_update": on_update,
	}

func init(initial_state: Variant) -> void:
	if not _states.has(initial_state):
		push_error("[SimpleStateMachine] Initial state not configured: %s" % str(initial_state))
		return
	current_state = initial_state
	_initialized = true
	var enter_cb: Callable = _states[initial_state]["on_enter"]
	if enter_cb.is_valid():
		enter_cb.call()

func update(delta: float) -> void:
	if not _initialized:
		return
	if not _states.has(current_state):
		return
	var update_cb: Callable = _states[current_state]["on_update"]
	if update_cb.is_valid():
		update_cb.call(delta)

func change_state(next_state: Variant) -> bool:
	if not _states.has(next_state):
		push_error("[SimpleStateMachine] State not configured: %s" % str(next_state))
		return false
	if current_state == next_state:
		return false

	if _states.has(current_state):
		var exit_cb: Callable = _states[current_state]["on_exit"]
		if exit_cb.is_valid():
			exit_cb.call()

	current_state = next_state
	var enter_cb: Callable = _states[next_state]["on_enter"]
	if enter_cb.is_valid():
		enter_cb.call()
	return true
