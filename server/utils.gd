class_name ServerUtils

static func get_battle_id_from_player(player_id: int) -> int:
	var battle_id: int = -1
	for id: int in ServerVariables.battle_engines.keys():
		var engine: BattleEngine = ServerVariables.battle_engines[id]
		if player_id in engine.state.player_ids:
			battle_id = id
			break ;
	return battle_id

static func generate_battle_id(player1_id: int, player2_id: int) -> int:
	var battle_id: int = player1_id + player2_id + randi()
	ServerVariables.used_battle_ids[battle_id] = null
	return battle_id

static func notify_battle_prep_start(event: BattlePrepStartedEvent) -> void:
	var event_data: Dictionary = Serializer.serialize(event)
	ClientRPCs.notify_battle_prep_start.rpc_id(event.player1, event_data)
	ClientRPCs.notify_battle_prep_start.rpc_id(event.player2, event_data)

static func notify_event(event: Variant, player_ids: Array[int], callback: Callable) -> void:
	for player_id: int in player_ids:
		callback.call(player_id, Serializer.serialize(event))
