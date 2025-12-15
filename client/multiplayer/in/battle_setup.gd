extends Node

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info, opponent_team_info)
signal battle_prep_time_up(battle_id: int)
signal battle_started(opponent_team_info)

@rpc('authority', "call_remote", 'reliable')
func notify_battle_created_server(battle_id: int):
	battle_created.emit(battle_id)

@rpc('authority', "call_remote", 'reliable')
func notify_battle_prep_start(opponent_info: Dictionary, opponent_team_info: Dictionary):
	battle_prep_started.emit(opponent_info, opponent_team_info)

@rpc("authority", "call_remote", "reliable")
func notify_battle_prep_time_up():
	battle_prep_time_up.emit()

@rpc("authority", "call_remote", "reliable")
func notify_battle_start(opponent_team_info: Dictionary):
	battle_started.emit(opponent_team_info)
