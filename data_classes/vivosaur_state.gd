class_name VivosaurState

var player_id: int
var info: VivosaurInfo

var statuses: Array[Status]
var can_use_skill: bool
var support_received: Array[PlayerZone]

var current_lp: int
var attack_modifier: float
var defense_modifier: float
var accuracy_modifier: float
var evasion_modifier: float

func _init(_player_id: int, _info: VivosaurInfo) -> void:
	assert(_info != null, "Info cannot be null")
	
	player_id = _player_id
	info = _info
	current_lp = _info.stats.life_points
	statuses = []
	can_use_skill = false
	support_received = []
	
func serialize() -> Dictionary[String, Variant]:
	return {
		'player_id': player_id,
		'vivosaur_id': info.id,
	}

static func deserialize(vivosaur_dict: Dictionary[String, Variant]) -> VivosaurState:
	return VivosaurState.new(
		vivosaur_dict['player_id'],
		VivosaurInfo.load(vivosaur_dict['vivosaur_id']),
	)
