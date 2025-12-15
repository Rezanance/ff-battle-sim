static func register_player(
	multiplayer: MultiplayerAPI, 
	new_player_info: Dictionary
):
	assert(multiplayer.is_server()) 
	var new_player_id = multiplayer.get_remote_sender_id()
	Logging.info('Player %d connected' % new_player_id)
	ServerVariables.all_player_info[new_player_id] = new_player_info

static func forward_challenge(
	multiplayer: MultiplayerAPI,
	opponent_id: int,
):
	var _challenger_id = multiplayer.get_remote_sender_id()
	assert(multiplayer.is_server()) 
	if not ServerVariables.all_player_info.has(opponent_id):
		Logging.info("Player %d is not online" % opponent_id)
		ClientMatchMaking.forward_opponent_not_online.rpc_id(_challenger_id)
	elif ServerVariables.challenge_requests.has(opponent_id) or ServerVariables.player_battles.has(opponent_id):
		Logging.info("Player %d sent challenge to %d BUT %d is busy (already has challenge request or in battle)" % [_challenger_id, opponent_id, opponent_id])
		ClientMatchMaking.forward_opponent_busy.rpc_id(_challenger_id)
	else:
		Logging.info("Player %d sent challenge to %d" % [_challenger_id, opponent_id])
		ServerVariables.challenge_requests[_challenger_id] = opponent_id
		ClientMatchMaking.forward_challenge.rpc_id(opponent_id, ServerVariables.all_player_info[_challenger_id])

static func forward_challenge_accepted(
	multiplayer: MultiplayerAPI,
	opponent_id: int,
	challenger_id: int
):
	assert(multiplayer.is_server()) 
	if not ServerVariables.all_player_info.has(challenger_id):
		Logging.info("Player %d is not online" % opponent_id)
		ClientMatchMaking.forward_opponent_not_online.rpc_id(opponent_id)
	else:
		Logging.info("Player %d ACCEPTED %d's challenge" % [opponent_id, challenger_id])
		ClientMatchMaking.forward_accept_challenge.rpc_id(challenger_id, challenger_id)

static func forward_challenge_declined(
	multiplayer: MultiplayerAPI,
	opponent_id: int,
	challenger_id: int
):
	assert(multiplayer.is_server()) 
	Logging.info("Player %d declined %d's challenge" % [opponent_id, challenger_id])
	ServerVariables.challenge_requests.erase(challenger_id)
	if ServerVariables.all_player_info.has(challenger_id):
		ClientMatchMaking.forward_decline_challenge.rpc_id(challenger_id, ServerVariables.all_player_info[opponent_id])
