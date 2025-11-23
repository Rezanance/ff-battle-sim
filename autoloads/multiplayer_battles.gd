extends Node


signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info, opponent_team_info)
signal battle_prep_time_up(battle_id: int)
signal battle_started(opponent_team_info)
signal turn_started(player_id: int)

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
var battlefields: Dictionary[int, BattleField] = {}
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
		battle_timers[battle_id].timeout.connect(_on_battle_prep_timeout_server.bind(battle_id))
		
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

func _on_battle_prep_timeout_server(battle_id: int):
	responses_to_server[battle_id] = {}
	for player_id in battle_teams[battle_id]:
		notify_battle_prep_time_up.rpc_id(player_id)
	
@rpc("authority", "call_remote", "reliable")
func notify_battle_prep_time_up():
	battle_prep_time_up.emit()

func send_new_team_info(new_team_info: Team):
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
		
		start_battle_server(battle_id)

func start_battle_server(battle_id: int):
	var player_id = battle_teams[battle_id].keys()[0]
	var opponent_id = battle_teams[battle_id].keys()[1]

	var player_slot1 = battle_teams[battle_id][player_id].slots[0]
	var player_slot2 = battle_teams[battle_id][player_id].slots[1]
	var player_slot3 = battle_teams[battle_id][player_id].slots[2]

	var opponent_slot1 = battle_teams[battle_id][opponent_id].slots[0]
	var opponent_slot2 = battle_teams[battle_id][opponent_id].slots[1]
	var opponent_slot3 = battle_teams[battle_id][opponent_id].slots[2]

	var zones: Dictionary[int, Zones] = {}
	zones[player_id] = Zones.new(
			VivosaurBattle.new(Global.fossilary[player_slot1]) if player_slot1 != null else null,
			VivosaurBattle.new(Global.fossilary[player_slot2]) if player_slot2 != null else null,
			VivosaurBattle.new(Global.fossilary[player_slot3]) if player_slot3 != null else null,
	)
	zones[opponent_id] = Zones.new(
		VivosaurBattle.new(Global.fossilary[opponent_slot1]) if opponent_slot1 != null else null,
		VivosaurBattle.new(Global.fossilary[opponent_slot2]) if opponent_slot2 != null else null,
		VivosaurBattle.new(Global.fossilary[opponent_slot3]) if opponent_slot3 != null else null,
	)
	
	battlefields[battle_id] = BattleField.new(zones, false)

	battlefields[battle_id].support_effects_applied.connect(apply_next_support_effects.bind(battle_id))

	# Apply all supports effects from both teams
	battlefields[battle_id].apply_support_effects(player_id)
	battlefields[battle_id].apply_support_effects(opponent_id)

	notify_battle_start.rpc_id(player_id, battle_teams[battle_id][opponent_id])
	notify_battle_start.rpc_id(opponent_id, battle_teams[battle_id][player_id])

func apply_next_support_effects(_id, _index, battle_id: int):
	battlefields[battle_id].apply_next_support_effects.emit()
	
@rpc("authority", "call_remote", "reliable")
func notify_battle_start(opponent_team_info: Dictionary):
	battle_started.emit(opponent_team_info)

func who_goes_first(battle_id: int):
	who_goes_first_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, battle_id)

@rpc("any_peer", "call_remote", "reliable")
func who_goes_first_server(battle_id: int):
	assert(multiplayer.is_server())

	responses_to_server[battle_id][multiplayer.get_remote_sender_id()] = null
	if len(responses_to_server[battle_id].keys()) == 2:
		responses_to_server[battle_id] = {}
		var battlefield: BattleField = battlefields[battle_id]
		var player_id: int = battle_teams[battle_id].keys()[0]
		var opponent_id: int = battle_teams[battle_id].keys()[1]

		var player_zones = battlefield.zones[player_id]
		var player_az_lp = player_zones.az.get('current_lp') if player_zones.az != null else 0
		var player_sz1_lp = player_zones.sz1.get('current_lp') if player_zones.sz1 != null else 0
		var player_sz2_lp = player_zones.sz2.get('current_lp') if player_zones.sz2 != null else 0

		var opponent_zones = battlefield.zones[opponent_id]
		var opponent_az_lp = opponent_zones.az.get('current_lp') if opponent_zones.az != null else 0
		var opponent_sz1_lp = opponent_zones.sz1.get('current_lp') if opponent_zones.sz1 != null else 0
		var opponent_sz2_lp = opponent_zones.sz2.get('current_lp') if opponent_zones.sz2 != null else 0

		var player_total_lp = player_az_lp + player_sz1_lp + player_sz2_lp
		var opponent_total_lp = opponent_az_lp + opponent_sz1_lp + opponent_sz2_lp

		if player_total_lp < opponent_total_lp:
			battlefield.turn_id = player_id
		elif opponent_total_lp < player_total_lp:
			battlefield.turn_id = opponent_id
		# Coin flip
		elif randf() > 0.5:
			battlefield.turn_id = player_id
		else:
			battlefield.turn_id = opponent_id
		
		Logging.info("Battle %d - Player %d's turn" % [battle_id, battlefield.turn_id])
		battlefield.zones[battlefield.turn_id].fp += Zones.BASE_FP_RECHARGE
		notify_turn_start.rpc_id(player_id, battlefield.turn_id)
		notify_turn_start.rpc_id(opponent_id, battlefield.turn_id)


@rpc("authority", "call_remote", "reliable")
func notify_turn_start(player_id: int):
	turn_started.emit(player_id)

func end_turn(battle_id: int):
	end_turn_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, battle_id)

@rpc("any_peer", "call_remote", "reliable")
func end_turn_server(battle_id: int):
	assert(multiplayer.is_server())
	var battlefield: BattleField = battlefields[battle_id]

	if multiplayer.get_remote_sender_id() == battlefield.turn_id:
		var player_id: int = battle_teams[battle_id].keys()[0]
		var opponent_id: int = battle_teams[battle_id].keys()[1]
		battlefield.turn_id = player_id if battlefield.turn_id == opponent_id else opponent_id
		notify_turn_start.rpc_id(battlefield.turn_id)
