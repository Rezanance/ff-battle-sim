extends Node


const MatchMaking = preload("res://server/match_making/impl.gd")

@rpc("any_peer", 'call_remote', "reliable")
func register_player(new_player_info):
	MatchMaking.register_player(multiplayer, new_player_info)

@rpc("any_peer", "call_remote", "reliable")
func forward_challenge(opponent_id: int):
	MatchMaking.forward_challenge(multiplayer, opponent_id)

@rpc('any_peer', "call_remote", "reliable")
func forward_challenge_declined(opponent_id: int, challenger_id: int):
	MatchMaking.forward_challenge_declined(multiplayer, opponent_id, challenger_id)

@rpc("any_peer", "call_remote", "reliable")
func forward_challenge_accepted(opponent_id: int, challenger_id: int):
	MatchMaking.forward_challenge_accepted(multiplayer, opponent_id, challenger_id)
