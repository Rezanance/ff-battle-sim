class_name Vivosaur

signal support_effects_applied(support_effects_applied_event: SupportEffectsAppliedEvent)

var player_id: int
var vivosaur_info: VivosaurInfo

var statuses: Array[Status]
var can_attack: bool
var support_received: Array[Formation.Zone]

var current_lp: int
var attack_modifier: float
var defense_modifier: float
var accuracy_modifier: float
var evasion_modifier: float

func _init(_player_id: int, _vivosaur_info: VivosaurInfo) -> void:
	assert(_vivosaur_info != null)
	
	player_id = _player_id
	vivosaur_info = _vivosaur_info
	current_lp = _vivosaur_info.stats.life_points
	statuses = []
	can_attack = false
	support_received = []
	
# Server shouldn't send all the vivosaurs data since it can be computed on client side
# Just for initial formation
func serialize() -> Dictionary[String, Variant]:
	return {
		'player_id': player_id,
		'vivosaur_id': vivosaur_info.id,
	}

static func deserialize(vivosaur_dict: Dictionary[String, Variant]) -> Vivosaur:
	return Vivosaur.new(
		vivosaur_dict['player_id'],
		DataLoader.load_vivosaur_info(vivosaur_dict['vivosaur_id']),
	)

func use_skill(skill: Skill, target: Vivosaur) -> void:
	return 

func take_damage(damage: int, is_critical: bool) -> void:
	return

func move_to_zone(zone: Formation.Zone = Formation.Zone.EZ) -> void:
	return

func apply_support_effects(
	support_zone: Formation.Zone,
	player_az: Vivosaur, 
	opponent_az: Vivosaur
) -> void:
	var support_effects: SupportEffects = vivosaur_info.support_effects
	var target_player_id: int
	if support_effects.own_az:
		player_az.attack_modifier += support_effects.attack_modifier
		player_az.defense_modifier += support_effects.defense_modifier
		player_az.accuracy_modifier += support_effects.accuracy_modifier
		player_az.evasion_modifier += support_effects.evasion_modifier
		player_az.support_received.append(support_zone)
		target_player_id = player_az.player_id
	else:
		opponent_az.attack_modifier += support_effects.attack_modifier
		opponent_az.defense_modifier += support_effects.defense_modifier
		opponent_az.accuracy_modifier += support_effects.accuracy_modifier
		opponent_az.evasion_modifier += support_effects.evasion_modifier
		opponent_az.support_received.append(support_zone)
		target_player_id = opponent_az.player_id
		
	support_effects_applied.emit(SupportEffectsAppliedEvent.new(
		player_id, 
		support_zone, 
		target_player_id,
		support_effects.attack_modifier,
		support_effects.defense_modifier,
		support_effects.accuracy_modifier,
		support_effects.evasion_modifier
	))

func remove_support_effects() -> void:
	return

func receive_status(status: Status) -> void:
	return

func remove_status(status: Status) -> void:
	return

func heal(lp: int) -> void:
	return

func die() -> void:
	return
