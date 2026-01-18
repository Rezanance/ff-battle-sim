class_name Status


var id: String
var name: String
var is_negative: bool
var description: String
var turns_active: int

func _init(_id: String, _name: String, _is_negative: bool, _description: String, _turns_active: int) -> void:
	assert(_turns_active > 0, "A status condition must be active for at least 1 turn")
	
	id = _id
	name = _name
	is_negative = _is_negative
	description = _description
	turns_active = _turns_active
