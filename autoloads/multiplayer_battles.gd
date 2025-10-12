extends Node

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info, opponent_team_info)
signal battle_prep_time_up(battle_id: int)
signal battle_started(opponent_team_info)

# Would use a set but dont exist in godot yet (values always == null)
var used_battle_ids = {}
var player_battles: Dictionary[int, int] = {} # key=player, value=battle_id
# {
# 	battle_id: {
# 		player1_id: {team_info}
# 		player2_id: {team_info2}
# 	}
# 	...
# }
var battle_teams = {}
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
var battlefields = {}
var responses_to_server = {} # key=battle_id, value=[players]

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
	battlefields[battle_id] = {}
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
		
		var battle_prep_timer = Timer.new()
		add_child(battle_prep_timer)
		battle_prep_timer.start(92)
		battle_prep_timer.timeout.connect(_on_battle_prep_timeout.bind(battle_prep_timer, battle_id))
		
		var player1_id = battle_teams[battle_id].keys()[0]
		var player2_id = battle_teams[battle_id].keys()[1]
		notify_battle_prep_start.rpc_id(player1_id, MultiplayerLobby.all_player_info[player2_id], battle_teams[battle_id][player2_id])
		notify_battle_prep_start.rpc_id(player2_id, MultiplayerLobby.all_player_info[player1_id], battle_teams[battle_id][player1_id])

@rpc('authority', "call_remote", 'reliable')
func notify_battle_prep_start(opponent_info: Dictionary, opponent_team_info: Dictionary):
	battle_prep_started.emit(opponent_info, opponent_team_info)

func _on_battle_prep_timeout(battle_prep_timer: Timer, battle_id: int):
	for player_id in battle_teams[battle_id]:
		notify_battle_prep_time_up.rpc_id(player_id)
	battle_prep_timer.queue_free()
	
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

	battlefields[battle_id] = DataTypes.BattleField.new(
		DataTypes.Zones.new(
			DataTypes.VivosaurBattle.new(Global.fossilary.get(battle_teams[battle_id][player1_id].slots[0])),
			DataTypes.VivosaurBattle.new(Global.fossilary.get(battle_teams[battle_id][player1_id].slots[1])),
			DataTypes.VivosaurBattle.new(Global.fossilary.get(battle_teams[battle_id][player1_id].slots[2])),
		),
		DataTypes.Zones.new(
			DataTypes.VivosaurBattle.new(Global.fossilary.get(battle_teams[battle_id][player2_id].slots[0])),
			DataTypes.VivosaurBattle.new(Global.fossilary.get(battle_teams[battle_id][player2_id].slots[1])),
			DataTypes.VivosaurBattle.new(Global.fossilary.get(battle_teams[battle_id][player2_id].slots[2])),
		),
	)

	notify_battle_start.rpc_id(player1_id, battle_teams[battle_id][player2_id])
	notify_battle_start.rpc_id(player2_id, battle_teams[battle_id][player1_id])

@rpc("authority", "call_remote", "reliable")
func notify_battle_start(opponent_team_info: Dictionary):
	battle_started.emit(opponent_team_info)
