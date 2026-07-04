class_name FpSpentEvent

var player_id: int
var fp_cost: int
var current_fp: int

func _init(_player_id: int, _fp_cost: int, _current_fp: int) -> void:
	player_id = _player_id
	fp_cost = _fp_cost
	current_fp = _current_fp
	
func serialize() -> Dictionary[String, int]:
	return {
		'player_id': player_id,
		'fp_cost': fp_cost,
		'current_fp': current_fp,
	}

static func deserialize(event_dict: Dictionary[String, int]) -> FpSpentEvent:
	return FpSpentEvent.new(
		event_dict['player_id'],
		event_dict['fp_cost'],
		event_dict['current_fp']
	)
