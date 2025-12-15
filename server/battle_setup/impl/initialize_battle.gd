static func generate_battle_id():
	var battle_id = randi()
	while ServerVariables.used_battle_ids.has(battle_id):
		battle_id = randi()
	ServerVariables.used_battle_ids[battle_id] = null
	return battle_id

static func initialize_global_vars(
	battle_id: int, 
	player1_id: int, 
	player2_id: int
):
	ServerVariables.player_battles[player1_id] = battle_id
	ServerVariables.player_battles[player2_id] = battle_id
	ServerVariables.battle_teams[battle_id] = {}
	ServerVariables.responses_to_server[battle_id] = {}
	ServerVariables.used_battle_ids[battle_id] = null
	ServerVariables.challenge_requests.erase(player1_id)
	ServerVariables.battle_timers[battle_id] = Timer.new()
	ServerVariables.add_child(ServerVariables.battle_timers[battle_id])
	
static func notify_contenders(battle_id: int, player1_id: int, player2_id: int):
	Logging.info("%d - Battle created (%d vs. %d)" % [battle_id, player1_id, player2_id])
	ClientBattleSetup.notify_battle_created_server.rpc_id(player1_id, battle_id)
	ClientBattleSetup.notify_battle_created_server.rpc_id(player2_id, battle_id)
