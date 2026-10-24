class_name ActionCallback

var action: Variant
var callback: Callable

func _init(_action: Variant, _callback: Callable) -> void:
	action = _action
	callback = _callback
