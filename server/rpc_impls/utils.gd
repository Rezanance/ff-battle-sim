static func get_battle_id_from_player(player_id: int) -> int : 
	var battle_id: int  = -1
	for battle: BattleInfo in ServerVariables.battles.values():
		if battle.player1_id == player_id or battle.player2_id == player_id:
			battle_id = battle.battle_id
			break;
	return battle_id
