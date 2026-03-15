extends Node

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info: PlayerInfo, opponent_team_info: Team)
signal battle_prep_time_up(battle_id: int)
signal battle_started(opponent_team_info: Team)

@rpc('authority', "call_remote", 'reliable')
func notify_battle_created_server(battle_id: int) -> void:
	battle_created.emit(battle_id)

@rpc('authority', "call_remote", 'reliable')
func notify_battle_prep_start(opponent_info: Dictionary, opponent_team_info: Dictionary) -> void:
	battle_prep_started.emit(PlayerInfo.deserialize(opponent_info), Team.deserialize('', opponent_team_info))

@rpc("authority", "call_remote", "reliable")
func notify_battle_prep_time_up() -> void:
	battle_prep_time_up.emit()

@rpc("authority", "call_remote", "reliable")
func notify_battle_start(opponent_team_info: Dictionary) -> void:
	battle_started.emit(Team.deserialize('', opponent_team_info))
