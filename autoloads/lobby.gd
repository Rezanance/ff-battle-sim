extends Node

signal player_connected(player_info)
signal player_disconnected()

const PORT = 7000
const MAX_PLAYERS = 10
const SERVER_PEER_ID = 1

# Server
var all_player_info = {}

# Local client only
var local_player_info = {}

func _ready() -> void:
	if OS.has_feature('dedicated_server') and DisplayServer.get_name() == "headless":
		start_server()
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func start_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error:
		printerr('Error creating server (error_code=%d)' % error)
		return error
	print("Started server peer_id=%d" % peer.get_unique_id())
	multiplayer.multiplayer_peer = peer

func go_online(server_ip: String, display_name: String, icon_id: int):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_ip, PORT)
	if error:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error connecting to server (%d)' % error)
		return FAILED
	local_player_info['peer_id'] = peer.get_unique_id()
	local_player_info['display_name'] = display_name
	local_player_info['icon_id'] = icon_id
	multiplayer.multiplayer_peer = peer
	player_connected.emit(local_player_info)
	register_player.rpc_id(SERVER_PEER_ID, local_player_info)
	return OK


func _on_player_disconnected(id):
	if multiplayer.is_server():
		print('Player %s disconnected' % id)
		all_player_info.erase(id)
	elif id == local_player_info['peer_id']:
		local_player_info = {}
		player_disconnected.emit()
#	If in the middle of match, terminate battle and cleanup
	pass

func _on_player_connected(id):
	if id == SERVER_PEER_ID:
		register_player.rpc_id(SERVER_PEER_ID, local_player_info)

@rpc("any_peer", 'call_remote', "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	print('Player %s connected' % new_player_id)
	all_player_info[new_player_id] = new_player_info
