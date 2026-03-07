class_name StateMachine extends Node
"""
A class that represents a Finite State Machine
"""

var current_state: Variant
var machine: Dictionary[Variant, ActionEndStateArray]

class ActionEndState:
	var guard: Callable ## func(...) -> bool
	var action: Callable ## func(...) -> void
	var end_state: Variant
	
	func _init(_guard: Callable, _action: Callable, _end_state: Variant) -> void:
		guard = _guard
		action = _action
		end_state = _end_state

class ActionEndStateArray:
	var action_end_states: Array[ActionEndState]
	func _init(_action_end_states: Array[ActionEndState]) -> void:
		action_end_states = _action_end_states

func _init(
	start_state: Variant, 
	_machine: Dictionary[Variant, ActionEndStateArray]
) -> void:
	current_state = start_state
	machine = _machine

## Returns false if guard check faild or any problems transitioning, else true
func transition(old_state: Variant, new_state: Variant) -> bool:
	var action_end_states: Array[ActionEndState] = machine[old_state].action_end_states.filter(
		func(_action_end_state: ActionEndState) -> bool: 
			return _action_end_state.end_state == new_state
	)
	if len(action_end_states) == 0:
		assert(false, "'%s' not an end state of '%s'" % [old_state, new_state])
		return false
	elif len(action_end_states) >= 2:
		assert(false, "The end states of '%s' must be unique (guilty end state '%s')" % [old_state, new_state])
		return false
	
	var action_end_state: ActionEndState = action_end_states[0]
	if not action_end_state.guard.call():
		return false
	
	action_end_state.action.call()
	current_state = action_end_state.end_state
	return true
	
	
	
