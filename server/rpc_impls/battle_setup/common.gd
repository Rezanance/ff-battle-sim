static func register_team(battle_id: int, player_id: int, team_info: Dictionary) -> void:
	ServerVariables.battles[battle_id].teams[player_id] = Team.deserialize('', team_info)
	ServerVariables.battles[battle_id].responses_to_server.append(player_id)
