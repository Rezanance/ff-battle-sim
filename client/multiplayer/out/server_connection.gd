extends Node


const Config = preload("res://client/multiplayer/config.gd")

signal player_connecting()
signal player_connected(player_info: Dictionary)
signal player_connect_failed()
signal player_disconnecting()
signal player_disconnected()

func _ready() -> void:
	if not OS.has_feature('dedicated_server') and not DisplayServer.get_name() == "headless":
		multiplayer.connected_to_server.connect(_on_player_connected)
		multiplayer.connection_failed.connect(_on_player_connect_failed)
		multiplayer.server_disconnected.connect(_on_player_disconnected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func go_online(server_ip: String, display_name: String, icon_id: int):
	if not Networking.connected:
		var peer = ENetMultiplayerPeer.new()
		var error = peer.create_client(server_ip, Config.PORT)
		if error:
			DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error connecting to server (%d)' % error)
			return FAILED
		Networking.player_info['player_id'] = peer.get_unique_id()
		Networking.player_info['display_name'] = display_name
		Networking.player_info['icon_id'] = icon_id
		multiplayer.multiplayer_peer = peer
		player_connecting.emit()
		return OK
	else:
		multiplayer.multiplayer_peer.close()
		player_disconnecting.emit()

func _on_player_connect_failed():
	player_connect_failed.emit()

func _on_player_connected():
	Networking.connected = true
	ServerMatchMaking.register_player.rpc_id(Networking.SERVER_PEER_ID, Networking.player_info)
	player_connected.emit(Networking.player_info)

func _on_player_disconnected():
	Networking.connected = false
	Networking.player_info = {}
	player_disconnected.emit()

func _on_peer_disconnected(_id: int):
	#TODO If in the middle of match, terminate battle and cleanup etc.
	pass
