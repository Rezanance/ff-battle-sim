extends Node

@rpc("any_peer", "call_remote", "reliable")
func client_battle_scene_loaded(battle_id: int) -> void:
	assert(multiplayer.is_server())
	
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var player1: int = battle_info.player1_id
	var player2: int = battle_info.player2_id
	battle_info.responses_to_server.append(multiplayer.get_remote_sender_id())
	if (player1 not in battle_info.responses_to_server or 
	player2 not in battle_info.responses_to_server):
		return
	
	battle_info.responses_to_server = []
	var battlefield: BattleField = battle_info.battlefield
	battlefield.apply_support_effects(player1)
	battlefield.apply_support_effects(player2)
	
	battlefield.who_goes_first()
	
	battlefield.start_turn()

@rpc("any_peer", "call_remote", "reliable")
func end_turn(battle_id: int) -> void:
	assert(multiplayer.is_server())
	var sender_player_id: int = multiplayer.get_remote_sender_id()
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var battlefield: BattleField = battle_info.battlefield
	if sender_player_id != battlefield.turn_id:
		return
	
	battlefield.end_turn()
	battlefield.start_turn()
	
	
