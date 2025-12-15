extends Node


const Common = preload("res://server/battle_setup/impl/common.gd")
const InitializeBattle = preload("res://server/battle_setup/impl/initialize_battle.gd")
const RegisterTeamInitial = preload("res://server/battle_setup/impl/register_team_initial.gd")
const StartBattle = preload("res://server/battle_setup/impl/start_battle.gd")

@rpc("any_peer", "call_remote", "reliable")
func initialize_battle(player1_id: int): 
	assert(multiplayer.is_server())
	var player2_id = ServerVariables.challenge_requests[player1_id]
	var battle_id = InitializeBattle.generate_battle_id()
	InitializeBattle.initialize_global_vars(battle_id, player1_id, player2_id)
	InitializeBattle.notify_contenders(battle_id, player1_id, player2_id)
	
@rpc("any_peer", 'call_remote', "reliable")
func register_team_initial(battle_id: int, team_info: Dictionary):
	assert(multiplayer.is_server())
	
	Common.register_team(battle_id, multiplayer.get_remote_sender_id(), team_info)
	if len(ServerVariables.responses_to_server[battle_id].keys()) < 2:
		return
	
	ServerVariables.responses_to_server[battle_id] = {}
	RegisterTeamInitial.start_battle_setup_timer(battle_id)
	RegisterTeamInitial.notify_battle_prep_started(battle_id)

@rpc("any_peer", "call_remote", "reliable")
func ready_early(battle_id: int):
	assert(multiplayer.is_server())
	
	ServerVariables.responses_to_server[battle_id][multiplayer.get_remote_sender_id()] = null
	if len(ServerVariables.responses_to_server[battle_id].keys()) < 2:
		return
	
	ServerVariables.responses_to_server[battle_id] = {}
	ServerVariables.battle_timers[battle_id].stop()
	ServerVariables.battle_timers[battle_id].timeout.emit()
	
@rpc("any_peer", "call_remote", "reliable")
func start_battle(battle_id: int, team_info_final: Dictionary):
	assert(multiplayer.is_server())
	
	Common.register_team(battle_id, multiplayer.get_remote_sender_id(), team_info_final)
	if len(ServerVariables.responses_to_server[battle_id].keys()) < 2:
		return
	
	ServerVariables.responses_to_server[battle_id] = {}
	var player_1 = ServerVariables.battle_teams[battle_id].keys()[0]
	var player_2 = ServerVariables.battle_teams[battle_id].keys()[1]
	var player_1_formation = StartBattle.create_player_formation(battle_id, player_1)
	var player_2_formation = StartBattle.create_player_formation(battle_id, player_2)
	StartBattle.create_battle_field(battle_id, player_1, player_1_formation, player_2, player_2_formation)
	
	ClientBattleSetup.notify_battle_start.rpc_id(player_1, ServerVariables.battle_teams[battle_id][player_2])
	ClientBattleSetup.notify_battle_start.rpc_id(player_2, ServerVariables.battle_teams[battle_id][player_1])
