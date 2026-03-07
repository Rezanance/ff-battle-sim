class_name Status


var id: String
var name: String
var is_negative: bool
var description: String
var turns_active: int

func _init(status_res: StatusResource) -> void:
	assert(status_res.turns_active > 0, "A status condition must be active for at least 1 turn")
	
	id = status_res.name
	name = status_res.name
	is_negative = status_res.is_negative
	description = status_res.description
	turns_active = status_res.turns_active
