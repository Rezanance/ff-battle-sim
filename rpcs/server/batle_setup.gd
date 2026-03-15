extends Node


const Common = preload("res://server/rpc_impls/battle_setup/common.gd")
const InitializeBattle = preload("res://server/rpc_impls/battle_setup/initialize_battle.gd")
const RegisterTeamInitial = preload("res://server/rpc_impls/battle_setup/register_team_initial.gd")
const StartBattle = preload("res://server/rpc_impls/battle_setup/start_battle.gd")

@rpc("any_peer", "call_remote", "reliable")
func initialize_battle(player1_id: int) -> void: 
	assert(multiplayer.is_server())
	var player2_id: int = ServerVariables.challenge_requests[player1_id]
	var battle_id: int = InitializeBattle.generate_battle_id()
	InitializeBattle.initialize_global_vars(battle_id, player1_id, player2_id)
	InitializeBattle.notify_contenders(battle_id, player1_id, player2_id)
	
@rpc("any_peer", 'call_remote', "reliable")
func register_team_initial(battle_id: int, team_info: Dictionary) -> void:
	assert(multiplayer.is_server())
	
	Common.register_team(battle_id, multiplayer.get_remote_sender_id(), team_info)
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var player1: int = battle_info.player1_id
	var player2: int = battle_info.player2_id
	if (player1 in battle_info.responses_to_server and 
	player2 in battle_info.responses_to_server):
		return
	
	ServerVariables.battles[battle_id].responses_to_server = []
	RegisterTeamInitial.start_battle_setup_timer(battle_id)
	RegisterTeamInitial.notify_battle_prep_started(battle_id)

@rpc("any_peer", "call_remote", "reliable")
func ready_early(battle_id: int) -> void:
	assert(multiplayer.is_server())
	
	ServerVariables.battles[battle_id].responses_to_server.append(multiplayer.get_remote_sender_id())
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var player1: int = battle_info.player1_id
	var player2: int = battle_info.player2_id
	if (player1 in battle_info.responses_to_server and 
	player2 in battle_info.responses_to_server):
		return
	
	ServerVariables.battles[battle_id].responses_to_server = []
	ServerVariables.battles[battle_id].timer.stop()
	ServerVariables.battles[battle_id].timer.timeout.emit()
	
@rpc("any_peer", "call_remote", "reliable")
func start_battle(battle_id: int, team_info_final: Dictionary) -> void:
	assert(multiplayer.is_server())
	
	Common.register_team(battle_id, multiplayer.get_remote_sender_id(), team_info_final)
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var player1: int = battle_info.player1_id
	var player2: int = battle_info.player2_id
	if (player1 in battle_info.responses_to_server and 
	player2 in battle_info.responses_to_server):
		return
	
	ServerVariables.battles[battle_id].responses_to_server = []
	var player1_formation: Formation = StartBattle.create_player_formation(battle_id, player1)
	var player2_formation: Formation = StartBattle.create_player_formation(battle_id, player2)
	StartBattle.create_battle_field(battle_id, player1, player1_formation, player2, player2_formation)
	
	ClientBattleSetup.notify_battle_start.rpc_id(player1, ServerVariables.battle_teams[battle_id][player2])
	ClientBattleSetup.notify_battle_start.rpc_id(player2, ServerVariables.battle_teams[battle_id][player1])
