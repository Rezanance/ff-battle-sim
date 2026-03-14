extends Node

signal opponent_not_online()
signal opponent_busy()
signal battle_requested(challenger_info: PlayerInfo)
signal challenge_declined(opponent_info: PlayerInfo)
signal challenge_accepted(opponent_info: PlayerInfo)

@rpc("authority", "call_remote", "reliable")
func forward_opponent_not_online() -> void:
	opponent_not_online.emit()

@rpc("authority", "call_remote", "reliable")
func forward_opponent_busy() -> void:
	opponent_busy.emit()

@rpc("authority", "call_remote", "reliable")
func forward_challenge(challenger_info: Dictionary) -> void:
	battle_requested.emit(PlayerInfo.deserialize(challenger_info))

@rpc("authority", "call_remote", "reliable")
func forward_decline_challenge(opponent_info: Dictionary) -> void:
	challenge_declined.emit(PlayerInfo.deserialize(opponent_info))

@rpc("authority", "call_remote", "reliable")
func forward_accept_challenge(challenger_id: int) -> void:
	challenge_accepted.emit(challenger_id)
