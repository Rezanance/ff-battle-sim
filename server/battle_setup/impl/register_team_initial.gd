static func start_battle_setup_timer(battle_id: int, time_to_prepare: int = 90):
	ServerVariables.battle_timers[battle_id].start(time_to_prepare)
	ServerVariables.battle_timers[battle_id].timeout.connect(
		_on_battle_prep_timeout.bind(battle_id)
	)

static func _on_battle_prep_timeout(battle_id: int):
	Logging.info('%d - Battle prep time out' % battle_id)
	ServerVariables.responses_to_server[battle_id] = {}
	for player_id in ServerVariables.battle_teams[battle_id]:
		ClientBattleSetup.notify_battle_prep_time_up.rpc_id(player_id)
		
static func notify_battle_prep_started(battle_id: int):
	Logging.info('%d - Notifying players battle prep started' % battle_id)
	var player1_id = ServerVariables.battle_teams[battle_id].keys()[0]
	var player2_id = ServerVariables.battle_teams[battle_id].keys()[1]
	ClientBattleSetup.notify_battle_prep_start.rpc_id(
		player1_id, 
		ServerVariables.all_player_info[player2_id],
		ServerVariables.battle_teams[battle_id][player2_id]
	)
	ClientBattleSetup.notify_battle_prep_start.rpc_id(
		player2_id, 
		ServerVariables.all_player_info[player1_id], 
		ServerVariables.battle_teams[battle_id][player1_id]
	)
