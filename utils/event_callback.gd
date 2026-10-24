class_name EventCallback

var event: Variant
var callback: Callable

func _init(_event: Variant, _callback: Callable) -> void:
	event = _event
	callback = _callback
