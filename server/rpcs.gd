# Autoload ServerRPCs
extends Node

@rpc("any_peer", 'call_remote', "reliable")
func register_player(player_info: Dictionary) -> void:
	assert(multiplayer.is_server())
	var player_id: int = multiplayer.get_remote_sender_id()
	Logging.info('Player %d connected' % player_id)
	ServerVariables.all_player_info[player_id] = Serializer.deserialize(player_info, PlayerInfo)

@rpc("any_peer", "call_remote", "reliable")
func forward_challenge(opponent_id: int) -> void:
	var challenger_id: int = multiplayer.get_remote_sender_id()
	assert(multiplayer.is_server())
	if not ServerVariables.all_player_info.has(opponent_id):
		Logging.info("Player %d is not online" % opponent_id)
		ClientRPCs.forward_opponent_not_online.rpc_id(challenger_id)
	elif ServerVariables.challenge_requests.has(opponent_id) or ServerUtils.get_battle_id_from_player(opponent_id) != -1:
		Logging.info("Player %d wanted to challenge %d BUT they're already busy (already has a challenge request or currently in battle)" % [challenger_id, opponent_id])
		ClientRPCs.forward_opponent_busy.rpc_id(challenger_id)
	else:
		Logging.info("Player %d challenges %d" % [challenger_id, opponent_id])
		ServerVariables.challenge_requests[challenger_id] = opponent_id
		ClientRPCs.forward_challenge.rpc_id(opponent_id, Serializer.serialize(ServerVariables.all_player_info[challenger_id]))

@rpc("any_peer", "call_remote", "reliable")
func forward_challenge_accepted(opponent_id: int, challenger_id: int) -> void:
	assert(multiplayer.is_server())
	if not ServerVariables.all_player_info.has(challenger_id):
		Logging.info("Player %d is not online" % opponent_id)
		ClientRPCs.forward_opponent_not_online.rpc_id(opponent_id)
	else:
		Logging.info("Player %d ACCEPTED %d's challenge" % [opponent_id, challenger_id])
		ClientRPCs.forward_accept_challenge.rpc_id(challenger_id, Serializer.serialize(ServerVariables.all_player_info[opponent_id]))

@rpc('any_peer', "call_remote", "reliable")
func forward_challenge_declined(opponent_id: int, challenger_id: int) -> void:
	assert(multiplayer.is_server())
	Logging.info("Player %d declined %d's challenge" % [opponent_id, challenger_id])
	ServerVariables.challenge_requests.erase(challenger_id)
	if ServerVariables.all_player_info.has(challenger_id):
		ClientRPCs.forward_decline_challenge.rpc_id(challenger_id, Serializer.serialize(ServerVariables.all_player_info[opponent_id]))

@rpc("any_peer", "call_remote", "reliable")
func initialize_battle(player1_id: int) -> void:
	assert(multiplayer.is_server())
	var player2_id: int = ServerVariables.challenge_requests[player1_id]
	var battle_id: int = ServerUtils.generate_battle_id(player1_id, player2_id)
	var player_ids: Array[int] = [player1_id, player2_id]
	
	var engine: BattleEngine = BattleEngine.new(BattleState.new([player1_id, player2_id]))

	engine.battle_prep_started.connect(ServerUtils.notify_battle_prep_start)
	engine.battle_started.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_battle_start.rpc_id))
	engine.support_effects_applied.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_support_effects_applied.rpc_id))
	engine.first_player_determined.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_first_player_determined.rpc_id))
	engine.fp_gained.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_fp_gained.rpc_id))
	engine.fp_spent.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_fp_spent.rpc_id))
	engine.turn_started.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_turn_start.rpc_id))
	engine.vivosaur_swapped_to_ez.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_vivosaur_swapped_to_ez.rpc_id))
	engine.vivosaur_back_to_sz.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_vivosaur_swapped_to_ez.rpc_id))
	# engine.skill_used.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_skill_used.rpc_id))
	engine.skill_missed.connect(ServerUtils.notify_event.bind(player_ids, ClientRPCs.notify_skill_missed.rpc_id))
	
	ServerVariables.battle_engines[battle_id] = engine
	ServerVariables.battle_engines[battle_id].start()

	for player_id: int in player_ids:
		ClientRPCs.notify_battle_created_server.rpc_id(player_id, battle_id)
	
@rpc("any_peer", 'call_remote', "reliable")
func register_team_initial(battle_id: int, team_info: Dictionary) -> void:
	assert(multiplayer.is_server())
	var player_id: int = multiplayer.get_remote_sender_id()
	BattleActions.register_team_initial(ServerVariables.battle_engines[battle_id], player_id, Team.deserialize(team_info))

@rpc("any_peer", 'call_remote', "reliable")
func submit_formation(battle_id: int, new_team_info: Dictionary) -> void:
	assert(multiplayer.is_server())
	var player_id: int = multiplayer.get_remote_sender_id()
	BattleActions.submit_formation(ServerVariables.battle_engines[battle_id], player_id, Team.deserialize(new_team_info))

@rpc("any_peer", 'call_remote', "reliable")
func notify_battle_scene_loaded(battle_id: int) -> void:
	assert(multiplayer.is_server())
	var player_id: int = multiplayer.get_remote_sender_id()
	BattleActions.client_scene_loaded(ServerVariables.battle_engines[battle_id], player_id)
