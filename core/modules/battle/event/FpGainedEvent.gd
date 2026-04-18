class_name FpGainedEvent

var player_id: int
var fp_diff: int
var current_fp: int

func _init(_player_id: int, _fp_diff: int, _current_fp: int) -> void:
	player_id = _player_id
	fp_diff = _fp_diff
	current_fp = _current_fp
	
func serialize() -> Dictionary[String, int]:
	return {
		'player_id': player_id,
		'fp_diff': fp_diff,
		'current_fp': current_fp,
	}

static func deserialize(event_dict: Dictionary[String, int]) -> FpGainedEvent:
	return FpGainedEvent.new(
		event_dict['player_id'],
		event_dict['fp_diff'],
		event_dict['current_fp']
	)
