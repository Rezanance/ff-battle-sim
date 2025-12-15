extends Node


const WhoGoesFirst = preload("res://server/turns/impl/who_goes_first.gd")

@rpc("any_peer", "call_remote", "reliable")
func who_goes_first_server(battle_id: int):
	assert(multiplayer.is_server())

	ServerVariables.responses_to_server[battle_id][multiplayer.get_remote_sender_id()] = null
	if len(ServerVariables.responses_to_server[battle_id].keys()) < 2:
		return
	
	var player_1: int = ServerVariables.battle_teams[battle_id].keys()[0]
	var player_2: int = ServerVariables.battle_teams[battle_id].keys()[1]
	
	var player_1_total_lp = WhoGoesFirst.calculate_total_lp(battle_id, player_1)
	var player_2_total_lp = WhoGoesFirst.calculate_total_lp(battle_id, player_2)
	
	var battlefield = ServerVariables.battlefields[battle_id]
	battlefield.turn_id = WhoGoesFirst.who_goes_first(
		player_1,
		player_1_total_lp,
		player_2,
		player_2_total_lp
	)
	
	Logging.info("Networking %d - Player %d's turn" % [battle_id, battlefield.turn_id])
	battlefield.formations[battlefield.turn_id].fp += Formation.BASE_FP_RECHARGE
	ClientTurns.notify_turn_start.rpc_id(player_1, battlefield.turn_id)
	ClientTurns.notify_turn_start.rpc_id(player_2, battlefield.turn_id)

@rpc("any_peer", "call_remote", "reliable")
func end_turn_server(battle_id: int):
	assert(multiplayer.is_server())
	var battlefield = ServerVariables.battlefields[battle_id]

	if multiplayer.get_remote_sender_id() != battlefield.turn_id:
		return
		
	var player_1_id: int = ServerVariables.battle_teams[battle_id].keys()[0]
	var player_2_id: int = ServerVariables.battle_teams[battle_id].keys()[1]
	battlefield.turn_id = player_1_id if battlefield.turn_id == player_2_id else player_2_id
	ClientTurns.notify_turn_start.rpc_id(battlefield.turn_id)
	
