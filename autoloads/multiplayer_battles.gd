extends Node

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info, opponent_team_info)

# Would use a set but dont exist in godot yet (values always == null)
var used_battle_ids = {}

var player_battles = {} # key=player, value=battle_id
#{
	#91234: {
		#1234567890: {team_info}
		#9876543210: {team_info2}
	#}
	#...
#}
var battles = {} 

func create_battle(challenger_id: int ):
	create_battle_server.rpc_id(MultiplayerLobby.SERVER_PEER_ID, challenger_id)

@rpc("any_peer", "call_remote", "reliable")
func create_battle_server(player1_id: int):
	assert(multiplayer.is_server()) 
	var player2_id = MultiplayerLobby.challenge_requests[player1_id]
	var battle_id = randi()
	while used_battle_ids.has(battle_id) :
		battle_id = randi()
	used_battle_ids[battle_id] = null
	player_battles[player1_id] = battle_id
	player_battles[player2_id] = battle_id
	battles[battle_id] = {}
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
	battles[battle_id][player_id] = team_info
	
	if len(battles[battle_id].keys()) == 2:
		Logging.info("Battle %d Entering Battle Preparation" % battle_id)
		var player1_id = battles[battle_id].keys()[0]
		var player2_id = battles[battle_id].keys()[1]
		notify_battle_prep_start.rpc_id(player1_id, MultiplayerLobby.all_player_info[player2_id], battles[battle_id][player2_id])
		notify_battle_prep_start.rpc_id(player2_id, MultiplayerLobby.all_player_info[player1_id], battles[battle_id][player1_id])

@rpc('authority', "call_remote", 'reliable')
func notify_battle_prep_start(opponent_info: Dictionary, opponent_team_info: Dictionary):
	battle_prep_started.emit(opponent_info, opponent_team_info)
