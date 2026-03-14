extends Node

signal turn_started(player_id: int)

@rpc("authority", "call_remote", "reliable")
func notify_turn_start(player_id: int) -> void:
	turn_started.emit(player_id)
