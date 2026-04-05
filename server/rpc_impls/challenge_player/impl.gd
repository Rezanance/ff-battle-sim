const Utils = preload("res://server/rpc_impls/utils.gd")

static func register_player(
	multiplayer: MultiplayerAPI, 
	player_info: PlayerInfo
) -> void:
	assert(multiplayer.is_server()) 
	var player_id: int = multiplayer.get_remote_sender_id()
	Logging.info('Player %d connected' % player_id)
	ServerVariables.all_player_info[player_id] = player_info

static func forward_challenge(
	multiplayer: MultiplayerAPI,
	opponent_id: int,
) -> void:
	var _challenger_id: int = multiplayer.get_remote_sender_id()
	assert(multiplayer.is_server()) 
	if not ServerVariables.all_player_info.has(opponent_id):
		Logging.info("Player %d is not online" % opponent_id)
		ClientChallengePlayer.forward_opponent_not_online.rpc_id(_challenger_id)
	elif ServerVariables.challenge_requests.has(opponent_id) or Utils.get_battle_id_from_player(opponent_id) != -1:
		Logging.info("Player %d wanted to challenge %d BUT they're already busy (already has a challenge request or currently in battle)" % [_challenger_id, opponent_id])
		ClientChallengePlayer.forward_opponent_busy.rpc_id(_challenger_id)
	else:
		Logging.info("Player %d challenges %d" % [_challenger_id, opponent_id])
		ServerVariables.challenge_requests[_challenger_id] = opponent_id
		ClientChallengePlayer.forward_challenge.rpc_id(opponent_id, ServerVariables.all_player_info[_challenger_id].serialize())

static func forward_challenge_accepted(
	multiplayer: MultiplayerAPI,
	opponent_id: int,
	challenger_id: int
) -> void:
	assert(multiplayer.is_server()) 
	if not ServerVariables.all_player_info.has(challenger_id):
		Logging.info("Player %d is not online" % opponent_id)
		ClientChallengePlayer.forward_opponent_not_online.rpc_id(opponent_id)
	else:
		Logging.info("Player %d ACCEPTED %d's challenge" % [opponent_id, challenger_id])
		ClientChallengePlayer.forward_accept_challenge.rpc_id(challenger_id, challenger_id)

static func forward_challenge_declined(
	multiplayer: MultiplayerAPI,
	opponent_id: int,
	challenger_id: int
) -> void:
	assert(multiplayer.is_server()) 
	Logging.info("Player %d declined %d's challenge" % [opponent_id, challenger_id])
	ServerVariables.challenge_requests.erase(challenger_id)
	if ServerVariables.all_player_info.has(challenger_id):
		ClientChallengePlayer.forward_decline_challenge.rpc_id(challenger_id, ServerVariables.all_player_info[opponent_id].serialize())
