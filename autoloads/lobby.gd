extends Node

signal player_connecting()
signal player_connected(player_info)
signal player_connect_failed()
signal player_disconnecting()
signal player_disconnected()

signal opponent_not_online()
signal challenge_requested(peer_id, player_info)

const PORT = 7000
const MAX_PLAYERS = 10
const SERVER_PEER_ID = 1

# Server
var all_player_info = {} #key=player
var challenge_requests = {} # key=player, value=opponent

# Local client only
var connected = false
var local_player_info = {}

func _ready() -> void:
	if OS.has_feature('dedicated_server') and DisplayServer.get_name() == "headless":
		start_server()
	else:
#		Client
		multiplayer.connected_to_server.connect(_on_player_connected)
		multiplayer.connection_failed.connect(_on_player_connect_failed)
		multiplayer.server_disconnected.connect(_on_player_disconnected)
		
	multiplayer.peer_disconnected.connect(_on_client_disconnected)

# Server 
func start_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error:
		printerr('Error creating server (error_code=%d)' % error)
		return error
	print("Started server peer_id=%d" % peer.get_unique_id())
	multiplayer.multiplayer_peer = peer

# Local
func go_online(server_ip: String, display_name: String, icon_id: int):
	if not connected:
		var peer = ENetMultiplayerPeer.new()
		var error = peer.create_client(server_ip, PORT)
		if error:
			DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error connecting to server (%d)' % error)
			return FAILED
		local_player_info['peer_id'] = peer.get_unique_id()
		local_player_info['display_name'] = display_name
		local_player_info['icon_id'] = icon_id
		multiplayer.multiplayer_peer = peer
		player_connecting.emit()
		return OK
	else:
		multiplayer.multiplayer_peer.close()
		player_disconnecting.emit()

# Local
func _on_player_connect_failed():
	player_connect_failed.emit()

# Local
func _on_player_connected():
	connected = true
	register_player.rpc_id(SERVER_PEER_ID, local_player_info)
	player_connected.emit(local_player_info)

# Local
func _on_client_disconnected(id: int):
	if multiplayer.is_server():
		print('Player %s disconnected' % id)
		all_player_info.erase(id)
	else:
#		TODO If in the middle of match, terminate battle and cleanup
		pass

# Local
func _on_player_disconnected():
	connected = false
	local_player_info = {}
	player_disconnected.emit()


@rpc("any_peer", 'call_remote', "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	print('Player %s connected' % new_player_id)
	all_player_info[new_player_id] = new_player_info

func send_challenge(opponent_peer_id: int):
	send_challenge_to_client.rpc_id(SERVER_PEER_ID, multiplayer.get_unique_id(), opponent_peer_id)

@rpc("any_peer", "call_remote", "reliable")
func send_challenge_to_client(peer_id: int, opponent_peer_id: int):
	assert(multiplayer.is_server()) 
	if all_player_info.has(opponent_peer_id):
		print("Player %d sent challenge to %d" % [peer_id, opponent_peer_id])
		challenge_requests[peer_id] = opponent_peer_id
		forward_challenge_to_opponent.rpc_id(opponent_peer_id, peer_id, all_player_info[peer_id])
	else:
		print("Player %d is not online" % opponent_peer_id)
		opponent_player_not_exists.rpc_id(peer_id)
		
@rpc("authority", "call_remote", "reliable")
func opponent_player_not_exists():
	opponent_not_online.emit()

@rpc("authority", "call_remote", "reliable")
func forward_challenge_to_opponent(peer_id: int, player_info: Dictionary):
	challenge_requested.emit(peer_id, player_info)
