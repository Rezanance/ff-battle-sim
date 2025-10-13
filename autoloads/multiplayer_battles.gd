extends Node

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info, opponent_team_info)
signal battle_prep_time_up(battle_id: int)
signal battle_started(opponent_team_info)

# Would use a set but dont exist in godot yet (values always == null)
var used_battle_ids: Dictionary[int, Variant] = {}
var player_battles: Dictionary[int, int] = {} # key=player, value=battle_id
# {
# 	battle_id: {
# 		player1_id: {team_info}
# 		player2_id: {team_info2}
# 	}
# 	...
# }
var battle_teams: Dictionary[int, Dictionary] = {}
# {
# 	battle_id: {
# 		player1_id: {
# 			AZ: VivosaurBattle,
# 			SZ1: VivosaurBattle,
# 			SZ2: VivosaurBattle,
# 			EZ: null,
# 			FP: 0
# 		},
# 		player2_id: {
# 			...
# 		},
# 	},
#   ...
# }
var battlefields: Dictionary[int, DataTypes.BattleField] = {}
var battle_timers: Dictionary[int, Timer] = {}
var responses_to_server: Dictionary[int, Dictionary] = {} # key=battle_id, value=[players]

func create_battle(challenger_id: int):
	create_battle_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, challenger_id)

@rpc("any_peer", "call_remote", "reliable")
func create_battle_server(player1_id: int):
	assert(multiplayer.is_server())
	var player2_id = MultiplayerLobby.challenge_requests[player1_id]
	var battle_id = randi()
	while used_battle_ids.has(battle_id):
		battle_id = randi()
	used_battle_ids[battle_id] = null
	player_battles[player1_id] = battle_id
	player_battles[player2_id] = battle_id
	battle_teams[battle_id] = {}
	battle_timers[battle_id] = Timer.new()
	add_child(battle_timers[battle_id])
	responses_to_server[battle_id] = {}
	used_battle_ids[battle_id] = null
	MultiplayerLobby.challenge_requests.erase(player1_id)

	Logging.info("Battle created (%d vs. %d)" % [player1_id, player2_id])
	notify_battle_created_server.rpc_id(player1_id, battle_id)
	notify_battle_created_server.rpc_id(player2_id, battle_id)
	
@rpc('authority', "call_remote", 'reliable')
func notify_battle_created_server(battle_id: int):
	battle_created.emit(battle_id)

func send_team_info(battle_id: int, team_info: Dictionary):
	send_team_info_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, battle_id, team_info)

@rpc("any_peer", 'call_remote', "reliable")
func send_team_info_server(battle_id: int, team_info: Dictionary):
	assert(multiplayer.is_server())
	
	var player_id = multiplayer.get_remote_sender_id()
	battle_teams[battle_id][player_id] = team_info
	responses_to_server[battle_id][player_id] = null
	
	if len(responses_to_server[battle_id].keys()) == 2:
		Logging.info("Battle %d entering battle preparation" % battle_id)
		responses_to_server[battle_id] = {}
		
		battle_timers[battle_id].start(90)
		battle_timers[battle_id].timeout.connect(_on_battle_prep_timeout.bind(battle_id))
		
		var player1_id = battle_teams[battle_id].keys()[0]
		var player2_id = battle_teams[battle_id].keys()[1]
		notify_battle_prep_start.rpc_id(player1_id, MultiplayerLobby.all_player_info[player2_id], battle_teams[battle_id][player2_id])
		notify_battle_prep_start.rpc_id(player2_id, MultiplayerLobby.all_player_info[player1_id], battle_teams[battle_id][player1_id])

@rpc('authority', "call_remote", 'reliable')
func notify_battle_prep_start(opponent_info: Dictionary, opponent_team_info: Dictionary):
	battle_prep_started.emit(opponent_info, opponent_team_info)

func ready(battle_id: int):
	ready_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, battle_id)

@rpc("any_peer", "call_remote", "reliable")
func ready_server(battle_id: int):
	assert(multiplayer.is_server())
	
	var player_id = multiplayer.get_remote_sender_id()
	responses_to_server[battle_id][player_id] = null
	
	if len(responses_to_server[battle_id].keys()) == 2:
		battle_timers[battle_id].stop()
		battle_timers[battle_id].timeout.emit()

func _on_battle_prep_timeout(battle_id: int):
	responses_to_server[battle_id] = {}
	for player_id in battle_teams[battle_id]:
		notify_battle_prep_time_up.rpc_id(player_id)
	
@rpc("authority", "call_remote", "reliable")
func notify_battle_prep_time_up():
	battle_prep_time_up.emit()

func send_new_team_info(new_team_info: DataTypes.Team):
	send_new_team_info_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, Battle.battle_id, new_team_info.serialize())

@rpc("any_peer", "call_remote", "reliable")
func send_new_team_info_server(battle_id: int, new_team_info: Dictionary):
	assert(multiplayer.is_server())
	
	var player_id = multiplayer.get_remote_sender_id()
#	Check for cheating (no new vivosaurs)
	battle_teams[battle_id][player_id] = new_team_info
	responses_to_server[battle_id][player_id] = null
	
	if len(responses_to_server[battle_id].keys()) == 2:
		Logging.info("Battle %d starting!" % battle_id)
		responses_to_server[battle_id] = {}
		
		start_battle(battle_id)

func start_battle(battle_id: int):
	var player1_id = battle_teams[battle_id].keys()[0]
	var player2_id = battle_teams[battle_id].keys()[1]

	var player_slot1 = battle_teams[battle_id][player1_id].slots[0]
	var player_slot2 = battle_teams[battle_id][player1_id].slots[1]
	var player_slot3 = battle_teams[battle_id][player1_id].slots[2]

	var opponent_slot1 = battle_teams[battle_id][player2_id].slots[0]
	var opponent_slot2 = battle_teams[battle_id][player2_id].slots[1]
	var opponent_slot3 = battle_teams[battle_id][player2_id].slots[2]


	battlefields[battle_id] = DataTypes.BattleField.new(
		DataTypes.Zones.new(
			DataTypes.VivosaurBattle.new(Global.fossilary[player_slot1]) if player_slot1 != null else null,
			DataTypes.VivosaurBattle.new(Global.fossilary[player_slot2]) if player_slot2 != null else null,
			DataTypes.VivosaurBattle.new(Global.fossilary[player_slot3]) if player_slot3 != null else null,
		),
		DataTypes.Zones.new(
			DataTypes.VivosaurBattle.new(Global.fossilary[opponent_slot1]) if opponent_slot1 != null else null,
			DataTypes.VivosaurBattle.new(Global.fossilary[opponent_slot2]) if opponent_slot2 != null else null,
			DataTypes.VivosaurBattle.new(Global.fossilary[opponent_slot3]) if opponent_slot3 != null else null,
		),
	)

	calculate_support_effects(
		battlefields[battle_id],
		[battlefields[battle_id].player_zones.sz1, battlefields[battle_id].player_zones.sz2],
		false
	)
	calculate_support_effects(
		battlefields[battle_id],
		[battlefields[battle_id].opponent_zones.sz1, battlefields[battle_id].opponent_zones.sz2],
		true
	)

	notify_battle_start.rpc_id(player1_id, battle_teams[battle_id][player2_id])
	notify_battle_start.rpc_id(player2_id, battle_teams[battle_id][player1_id])

func calculate_support_effects(battlefield, support_zones, is_player1: bool):
	for i in range(len(support_zones)):
		var vivosaur_battle = support_zones[i]
		if vivosaur_battle == null:
			continue

		var support_effects = vivosaur_battle.vivosaur_info.support_effects
		if (is_player1 and support_effects.own_az) or (not is_player1 and not support_effects.own_az):
			battlefield.opponent_az_effects.atk += support_effects.attack_modifier
			battlefield.opponent_az_effects.def += support_effects.defense_modifier
			battlefield.opponent_az_effects.acc += support_effects.accuracy_modifier
			battlefield.opponent_az_effects.eva += support_effects.evasion_modifier
		else:
			battlefield.player_az_effects.atk += support_effects.attack_modifier
			battlefield.player_az_effects.def += support_effects.defense_modifier
			battlefield.player_az_effects.acc += support_effects.accuracy_modifier
			battlefield.player_az_effects.eva += support_effects.evasion_modifier


@rpc("authority", "call_remote", "reliable")
func notify_battle_start(opponent_team_info: Dictionary):
	battle_started.emit(opponent_team_info)
