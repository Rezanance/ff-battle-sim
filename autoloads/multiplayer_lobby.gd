extends Node

signal player_connecting()
signal player_connected(player_info: Dictionary)
signal player_connect_failed()
signal player_disconnecting()
signal player_disconnected()

signal opponent_not_online()
signal opponent_busy()
signal challenge_requested(challenger_info: Dictionary)
signal challenge_declined(opponent_info: Dictionary)
signal challenge_accepted(opponent_info: Dictionary)

const PORT = 7000
const MAX_PLAYERS = 10
const SERVER_PEER_ID = 1

# Server
var all_player_info = {} #key=player
var challenge_requests = {} # key=player, value=opponent

# Local client only
var connected = false
var local_player_info = {}
var challenger_info: Dictionary

func _ready() -> void:
	if OS.has_feature('dedicated_server') and DisplayServer.get_name() == "headless":
		start_server()
	else:
#		Client
		multiplayer.connected_to_server.connect(_on_player_connected)
		multiplayer.connection_failed.connect(_on_player_connect_failed)
		multiplayer.server_disconnected.connect(_on_player_disconnected)
		
	multiplayer.peer_disconnected.connect(_on_client_disconnected)

func start_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error:
		Logging.error('Error creating server (error_code=%d)' % error)
		return error
	print("Started server")
	multiplayer.multiplayer_peer = peer

func go_online(server_ip: String, display_name: String, icon_id: int):
	if not connected:
		var peer = ENetMultiplayerPeer.new()
		var error = peer.create_client(server_ip, PORT)
		if error:
			DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error connecting to server (%d)' % error)
			return FAILED
		local_player_info['player_id'] = peer.get_unique_id()
		local_player_info['display_name'] = display_name
		local_player_info['icon_id'] = icon_id
		multiplayer.multiplayer_peer = peer
		player_connecting.emit()
		return OK
	else:
		multiplayer.multiplayer_peer.close()
		player_disconnecting.emit()

func _on_player_connect_failed():
	player_connect_failed.emit()

func _on_player_connected():
	connected = true
	register_player.rpc_id(SERVER_PEER_ID, local_player_info)
	player_connected.emit(local_player_info)

func _on_client_disconnected(id: int):
	if multiplayer.is_server():
		Logging.info('%d disconnected' % id)
		all_player_info.erase(id)
		
		if MultiplayerBattles.player_battles.has(id):
			var battle_id = MultiplayerBattles.player_battles[id]
			var opponent_id = MultiplayerBattles.battles[battle_id].keys().filter(func (player_id): return player_id != id)[0]
			
			MultiplayerBattles.player_battles.erase(id)
			MultiplayerBattles.player_battles.erase(opponent_id)
			MultiplayerBattles.battles.erase(battle_id)
	else:
#		TODO If in the middle of match, terminate battle and cleanup
		pass

func _on_player_disconnected():
	connected = false
	local_player_info = {}
	player_disconnected.emit()

@rpc("any_peer", 'call_remote', "reliable")
func register_player(new_player_info):
	assert(multiplayer.is_server()) 
	var new_player_id = multiplayer.get_remote_sender_id()
	Logging.info('Player %d connected' % new_player_id)
	all_player_info[new_player_id] = new_player_info

func send_challenge(opponent_id: int):
	send_challenge_server.rpc_id(SERVER_PEER_ID, opponent_id)

@rpc("any_peer", "call_remote", "reliable")
func send_challenge_server(opponent_id: int):
	var _challenger_id = multiplayer.get_remote_sender_id()
	assert(multiplayer.is_server()) 
	if not all_player_info.has(opponent_id):
		Logging.info("Player %d is not online" % opponent_id)
		forward_opponent_not_online.rpc_id(_challenger_id)
	elif challenge_requests.has(opponent_id) or MultiplayerBattles.player_battles.has(opponent_id):
		Logging.info("Player %d sent challenge to %d BUT %d is busy (already has challenge request or in battle)" % [_challenger_id, opponent_id, opponent_id])
		forward_opponent_busy.rpc_id(_challenger_id)
	else:
		Logging.info("Player %d sent challenge to %d" % [_challenger_id, opponent_id])
		challenge_requests[_challenger_id] = opponent_id
		forward_challenge.rpc_id(opponent_id, all_player_info[_challenger_id])

@rpc("authority", "call_remote", "reliable")
func forward_opponent_not_online():
	opponent_not_online.emit()

@rpc("authority", "call_remote", "reliable")
func forward_opponent_busy():
	opponent_busy.emit()

@rpc("authority", "call_remote", "reliable")
func forward_challenge(_challenger_info: Dictionary):
	challenger_info = _challenger_info
	challenge_requested.emit(_challenger_info)

func decline_challenge():
	decline_challenge_server.rpc_id(SERVER_PEER_ID, multiplayer.get_unique_id(), challenger_info['player_id'])

@rpc('any_peer', "call_remote", "reliable")
func decline_challenge_server(opponent_id: int, challenger_id: int):
	assert(multiplayer.is_server()) 
	Logging.info("Player %d declined %d's challenge" % [opponent_id, challenger_id])
	challenge_requests.erase(challenger_id)
	if all_player_info.has(challenger_id):
		forward_decline_challenge.rpc_id(challenger_id, all_player_info[opponent_id])
	
@rpc("authority", "call_remote", "reliable")
func forward_decline_challenge(opponent_info: Dictionary):
	challenge_declined.emit(opponent_info)

func accept_challenge():
	accept_challenge_server.rpc_id(SERVER_PEER_ID, multiplayer.get_unique_id(), challenger_info['player_id'])

@rpc("any_peer", "call_remote", "reliable")
func accept_challenge_server(opponent_id: int, challenger_id: int):
	assert(multiplayer.is_server()) 
	if not all_player_info.has(challenger_id):
		Logging.info("Player %d is not online" % opponent_id)
		forward_opponent_not_online.rpc_id(opponent_id)
	else:
		Logging.info("Player %d ACCEPTED %d's challenge" % [opponent_id, challenger_id])
		forward_accept_challenge.rpc_id(challenger_id, challenger_id)

@rpc("authority", "call_remote", "reliable")
func forward_accept_challenge(challenger_id: int):
	challenge_accepted.emit(challenger_id)
