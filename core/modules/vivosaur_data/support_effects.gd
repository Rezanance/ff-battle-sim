class_name SupportEffects


var own_az: bool
var attack_modifier: float
var defense_modifier: float
var accuracy_modifier: float
var evasion_modifier: float

func _init(_own_az: bool, _attack_modifier: int, _defense_modifier: int,
_accuracy_modifier: int, _evasion_modifier: int) -> void:
	assert(_attack_modifier >= -100 and _attack_modifier <= 100)
	assert(_defense_modifier >= -100 and _defense_modifier <= 100)
	assert(_accuracy_modifier >= -100 and _accuracy_modifier <= 100)
	assert(_evasion_modifier >= -100 and _evasion_modifier <= 100)

	own_az = _own_az
	attack_modifier = _attack_modifier / 100.0
	defense_modifier = _defense_modifier / 100.0
	accuracy_modifier = _accuracy_modifier / 100.0
	evasion_modifier = _evasion_modifier / 100.0
