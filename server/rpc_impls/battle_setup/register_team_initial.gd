static func start_battle_setup_timer(battle_id: int, time_to_prepare: int = 90) -> void:
	var timer: Timer = ServerVariables.battles[battle_id].timer
	timer.start(time_to_prepare)
	timer.timeout.connect(
		_on_battle_prep_timeout.bind(battle_id)
	)

static func _on_battle_prep_timeout(battle_id: int) -> void:
	Logging.info('%d - Battle prep time out' % battle_id)
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	
	ServerVariables.battles[battle_id].responses_to_server = []
	
	ClientBattleSetup.notify_battle_prep_time_up.rpc_id(battle_info.player1_id)
	ClientBattleSetup.notify_battle_prep_time_up.rpc_id(battle_info.player2_id)
		
static func notify_battle_prep_started(battle_id: int) -> void:
	Logging.info('%d - Notifying players battle prep started' % battle_id)
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	
	var player1_id: int = battle_info.player1_id
	var player2_id: int = battle_info.player2_id
	ClientBattleSetup.notify_battle_prep_start.rpc_id(
		player2_id, 
		ServerVariables.all_player_info[player1_id].serialize(),
		battle_info.teams[player1_id].serialize()
	)
	ClientBattleSetup.notify_battle_prep_start.rpc_id(
		player1_id, 
		ServerVariables.all_player_info[player2_id].serialize(), 
		battle_info.teams[player2_id].serialize()
	)
