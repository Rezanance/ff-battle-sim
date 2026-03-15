extends Node

# ============
# Challenges
# key=player_id
var all_player_info: Dictionary[int, PlayerInfo] = {} 
# key=player_id, value=opponent_id
var challenge_requests: Dictionary[int, int] = {} 

# =========
# Battling 
# Would use a set but dont exist in godot yet (values always == null)
var used_battle_ids: Dictionary[int, Variant] = {}
# key=battle_id
var battles: Dictionary[int, BattleInfo] = {}
# key=battle_id, value=list of players who responded
var responses_to_server: Dictionary[int, Array] = {} 
