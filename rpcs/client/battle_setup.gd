extends Node

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info: PlayerInfo, opponent_team_info: Team)
signal battle_prep_time_up(battle_id: int)
signal battle_started(formations: Dictionary[int, Formation])

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
func notify_battle_start(
	formations_serialized: Dictionary[int, Dictionary]
) -> void:
	var formations: Dictionary[int, Formation] = {}
	for player_id: int in formations_serialized.keys():
		formations[player_id] = Formation.deserialize(formations_serialized[player_id])
	
	battle_started.emit(formations)
