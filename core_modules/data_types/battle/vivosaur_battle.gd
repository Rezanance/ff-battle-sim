class_name VivosaurBattle


var vivosaur_info: VivosaurInfo
var current_lp: int
var statuses: Array[Status]
var can_attack: bool
var is_support_effects_applied: bool

func _init(_vivosaur_info: VivosaurInfo):
	assert(_vivosaur_info != null)
	
	vivosaur_info = _vivosaur_info
	current_lp = _vivosaur_info.stats.life_points
	statuses = []
	can_attack = false
	is_support_effects_applied = false
