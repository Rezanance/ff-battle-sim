class_name BattleField

signal first_player_determined(first_player_determined_event: FirstPlayerDeterminedEvent)
signal turn_started(player_id: int)
signal turn_ended(player_id: int)

var player1_id: int
var player2_id: int
var formations: Dictionary[int, Formation]
var turn: int

func _init(
	_formations: Dictionary[int, Formation], 
	_player1_id: int, 
	_player2_id: int
) -> void:
	assert(len(_formations.keys()) == 2)

	formations = _formations
	turn = -1
	player1_id = _player1_id
	player2_id = _player2_id

func who_goes_first() -> int:
	var player_1_total_lp: int = formations[player1_id].calculate_total_lp()
	var player_2_total_lp: int = formations[player2_id].calculate_total_lp()
	var first_player_id: int
	
	if player_1_total_lp < player_2_total_lp:
		first_player_id = player1_id
	elif player_1_total_lp > player_2_total_lp:
		first_player_id = player2_id
	else:
		first_player_id = player1_id if randi() % 100 < 50 else player2_id
	
	first_player_determined.emit(FirstPlayerDeterminedEvent.new(
		first_player_id,
		player1_id,
		player_1_total_lp,
		player2_id,
		player_2_total_lp
	))
	return first_player_id

func start_turn() -> void:
#	TODO
	return

func end_turn() -> void:
#	TODO
	return

func determine_winner() -> Variant:
#	TODO
	return
	
func get_opponent_id(player_id: int) -> int:
	return player1_id if player_id == player2_id else player2_id

func apply_support_effects(player_id: int) -> void:
	var sz1: Vivosaur = formations[player_id].sz1
	var sz2: Vivosaur = formations[player_id].sz2
	var player_az: Vivosaur = formations[player_id].az
	var opponent_az: Vivosaur = formations[get_opponent_id(player_id)].az
	
	if sz1:
		sz1.apply_support_effects(player_id, Formation.Zone.SZ1, player_az, opponent_az)
	if sz2:
		sz2.apply_support_effects(player_id, Formation.Zone.SZ2, player_az, opponent_az)
