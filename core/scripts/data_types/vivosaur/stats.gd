class_name Stats


var life_points: int
var attack: int
var defense: int
var accuracy: int
var evasion: int
var crit_chance: float
var ranged_multiplier: float

func _init(_life_points: int, _attack: int, _defense: int, _accuracy: int,
_evasion: int, _crit_chance: float, _ranged_multiplier: float) -> void:
	assert(_life_points >= 0)
	assert(_attack >= 0)
	assert(_defense >= 0)
	assert(_accuracy >= 0)
	assert(_evasion >= 0)
	assert(_crit_chance >= 0 and _crit_chance <= 1)
	assert(_ranged_multiplier >= 0)
			
	life_points = _life_points
	attack = _attack
	defense = _defense
	accuracy = _accuracy
	evasion = _evasion
	crit_chance = _crit_chance
	ranged_multiplier = _ranged_multiplier
