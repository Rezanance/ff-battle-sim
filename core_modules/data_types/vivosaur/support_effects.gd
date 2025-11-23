class_name SupportEffects


var own_az: bool
var attack_modifier: float
var defense_modifier: float
var accuracy_modifier: float
var evasion_modifier: float

func _init(_own_az: bool, _attack_modifier: float, _defense_modifier: float,
_accuracy_modifier: float, _evasion_modifier: float):
	assert(_attack_modifier >= -1 and _attack_modifier <= 1)
	assert(_defense_modifier >= -1 and _defense_modifier <= 1)
	assert(_accuracy_modifier >= -1 and _accuracy_modifier <= 1)
	assert(_evasion_modifier >= -1 and _evasion_modifier <= 1)

	own_az = _own_az
	attack_modifier = _attack_modifier
	defense_modifier = _defense_modifier
	accuracy_modifier = _accuracy_modifier
	evasion_modifier = _evasion_modifier
