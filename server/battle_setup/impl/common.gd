static func register_team(battle_id: int, player_id: int, team_info: Dictionary):
	ServerVariables.battle_teams[battle_id][player_id] = team_info
	ServerVariables.responses_to_server[battle_id][player_id] = null
