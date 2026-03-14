extends Node

const ChallengePlayer = preload("res://server/rpc_impls/challenge_player/impl.gd")

@rpc("any_peer", 'call_remote', "reliable")
func register_player(player_info: Dictionary) -> void:
	ChallengePlayer.register_player(multiplayer, PlayerInfo.deserialize(player_info))

@rpc("any_peer", "call_remote", "reliable")
func forward_challenge(opponent_id: int) -> void:
	ChallengePlayer.forward_challenge(multiplayer, opponent_id)

@rpc("any_peer", "call_remote", "reliable")
func forward_challenge_accepted(opponent_id: int, challenger_id: int) -> void:
	ChallengePlayer.forward_challenge_accepted(multiplayer, opponent_id, challenger_id)

@rpc('any_peer', "call_remote", "reliable")
func forward_challenge_declined(opponent_id: int, challenger_id: int) -> void:
	ChallengePlayer.forward_challenge_declined(multiplayer, opponent_id, challenger_id)
