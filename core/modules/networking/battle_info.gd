class_name BattleInfo
	
var battle_id: int
var player1_id: int
var player2_id: int
var teams: Dictionary[int, Team]
var timer: Timer
var battlefield: BattleField
var responses_to_server: Array[int]

func _init(_battle_id: int, _player1_id: int, 
_player2_id: int, _timer: Timer) -> void:
	battle_id = _battle_id
	player1_id = _player1_id
	player2_id = _player2_id
	timer = _timer
	
	teams = {
		player1_id: null,
		player2_id: null
	}
	battlefield = null
	responses_to_server = []
