class_name SupportEffectsAppliedEvent

var player_id: int
var support_zone: Formation.Zone
var target_player_id: int
var attack_modifier: float
var defense_modifier: float
var accuracy_modifier: float
var evasion_modifier: float

func _init(
	_player_id: int, 
	_support_zone: Formation.Zone,
	_target_player_id: int,
	_attack_modifier: float,
	_defense_modifier: float,
	_accuracy_modifier: float,
	_evasion_modifier: float
) -> void:
	player_id = _player_id
	support_zone = _support_zone
	target_player_id = _target_player_id
	attack_modifier = _attack_modifier
	defense_modifier = _defense_modifier
	accuracy_modifier = _accuracy_modifier
	evasion_modifier = _evasion_modifier
	
func serialize() -> Dictionary[String, Variant]:
	return {
		'player_id': player_id,
		'support_zone': support_zone,
		'target_player_id': target_player_id,
		'attack_modifier': attack_modifier,
		'defense_modifier': defense_modifier,
		'accuracy_modifier': accuracy_modifier,
		'evasion_modifier': evasion_modifier
	}
	
static func deserialize(event_dict: Dictionary[String, Variant]) -> SupportEffectsAppliedEvent:
	return SupportEffectsAppliedEvent.new(
		event_dict['player_id'],
		event_dict['support_zone'],
		event_dict['target_player_id'],
		event_dict['attack_modifier'],
		event_dict['defense_modifier'],
		event_dict['accuracy_modifier'],
		event_dict['evasion_modifier'],
	)
