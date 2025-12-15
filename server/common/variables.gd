extends Node


# ============
# Match making
#key=player, value=player_info
var all_player_info: Dictionary[int, Dictionary] = {} 
# key=player, value=opponent
var challenge_requests: Dictionary[int, int] = {} 

# =========
# Battling 
# Would use a set but dont exist in godot yet (values always == null)
var used_battle_ids: Dictionary[int, Variant] = {}
# key=player, value=battle_id
var player_battles: Dictionary[int, int] = {} 
# {
# 	battle_id: {
# 		player1_id: {team_info}
# 		player2_id: {team_info2}
# 	}
# 	...
# }
var battle_teams: Dictionary[int, Dictionary] = {}
# key=battle_id
var battlefields: Dictionary[int, BattleField] = {} 
# key=battle_id
var battle_timers: Dictionary[int, Timer] = {} 
# key=battle_id, value={set of players who responded}
var responses_to_server: Dictionary[int, Dictionary] = {} 
