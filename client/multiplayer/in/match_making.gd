extends Node


signal opponent_not_online()
signal opponent_busy()
signal challenge_requested(challenger_info: Dictionary)
signal challenge_declined(opponent_info: Dictionary)
signal challenge_accepted(opponent_info: Dictionary)


@rpc("authority", "call_remote", "reliable")
func forward_opponent_not_online():
	opponent_not_online.emit()

@rpc("authority", "call_remote", "reliable")
func forward_opponent_busy():
	opponent_busy.emit()

@rpc("authority", "call_remote", "reliable")
func forward_challenge(challenger_info: Dictionary):
	challenge_requested.emit(challenger_info)

@rpc("authority", "call_remote", "reliable")
func forward_decline_challenge(opponent_info: Dictionary):
	challenge_declined.emit(opponent_info)

@rpc("authority", "call_remote", "reliable")
func forward_accept_challenge(challenger_id: int):
	challenge_accepted.emit(challenger_id)
