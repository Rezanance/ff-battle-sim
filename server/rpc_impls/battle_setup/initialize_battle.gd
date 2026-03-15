static func generate_battle_id() -> int:
	var battle_id: int = randi()
	while ServerVariables.used_battle_ids.has(battle_id):
		battle_id = randi()
	ServerVariables.used_battle_ids[battle_id] = null
	return battle_id

static func initialize_global_vars(
	battle_id: int, 
	player1_id: int, 
	player2_id: int
) -> void:
	ServerVariables.battles[battle_id] = BattleInfo.new(battle_id, player1_id, player2_id, Timer.new())
	ServerVariables.add_child(ServerVariables.battles[battle_id].timer)
	
static func notify_contenders(battle_id: int, player1_id: int, player2_id: int) -> void:
	Logging.info("%d - Battle created (%d vs. %d)" % [battle_id, player1_id, player2_id])
	ClientBattleSetup.notify_battle_created_server.rpc_id(player1_id, battle_id)
	ClientBattleSetup.notify_battle_created_server.rpc_id(player2_id, battle_id)
