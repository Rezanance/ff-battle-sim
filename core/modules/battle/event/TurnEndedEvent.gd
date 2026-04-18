class_name TurnEndedEvent

var player_id: int

func _init(_player_id: int) -> void:
	player_id = _player_id

func serialize() -> Dictionary[String, int]:
	return {
		'player_id': player_id
	}

static func deserialize(event_dict: Dictionary[String, int]) -> TurnEndedEvent:
	return TurnEndedEvent.new(
		event_dict['player_id']
	)
