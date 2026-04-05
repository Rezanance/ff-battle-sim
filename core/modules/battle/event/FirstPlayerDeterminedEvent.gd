class_name FirstPlayerDeterminedEvent

var first_player_id: int
var player1_id: int
var player2_id: int
var player1_total_lp: int
var player2_total_lp: int

func _init(
	_first_player_id: int,
	_player1_id: int,
	_player2_id: int,
	_player1_total_lp: int,
	_player2_total_lp: int
) -> void:
	first_player_id = _first_player_id
	player1_id = _player1_id
	player2_id = _player2_id
	player1_total_lp = _player1_total_lp
	player2_total_lp = _player2_total_lp

func serialize() -> Dictionary[String, int]:
	return {
		'first_player_id': first_player_id,
		'player1_id': player1_id,
		'player2_id': player2_id,
		'player1_total_lp': player1_total_lp,
		'player2_total_lp': player2_total_lp
	}

static func deserialize(event_dict: Dictionary[String, int]) -> FirstPlayerDeterminedEvent:
	return FirstPlayerDeterminedEvent.new(
		event_dict['first_player_id'],
		event_dict['player1_id'],
		event_dict['player2_id'],
		event_dict['player1_total_lp'],
		event_dict['player2_total_lp']
	)
