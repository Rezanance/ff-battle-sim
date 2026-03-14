extends Node
class_name ServerConnectionComponent

const ServerConfig = preload("res://server/config.gd")

signal player_connecting()
signal player_connected(player_info: PlayerInfo)
signal player_connect_failed()
signal player_disconnecting()
signal player_disconnected()

var connected: bool = false

func _ready() -> void:
	if not OS.has_feature('dedicated_server') and not DisplayServer.get_name() == "headless":
		multiplayer.connected_to_server.connect(_on_player_connected)
		multiplayer.connection_failed.connect(_on_player_connect_failed)
		multiplayer.server_disconnected.connect(_on_player_disconnected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func go_online(server_ip: String, display_name: String, icon_id: int) -> Error:
	if not connected:
		var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		var error: Error = peer.create_client(server_ip, ServerConfig.PORT)
		if error:
#			FIXME put this line outside (single responsibility)
			#StatusNotification.push(StatusNotification.MessageType.ERROR, 'Error connecting to server (%d)' % error)
			return FAILED
		Networking.player_info = PlayerInfo.new(peer.get_unique_id(), display_name, icon_id)
		multiplayer.multiplayer_peer = peer
		player_connecting.emit()
		return OK
	else:
		multiplayer.multiplayer_peer.close()
		player_disconnecting.emit()
		return OK

func _on_player_connected() -> void:
	ServerChallengePlayer.register_player.rpc_id(
		Networking.SERVER_PEER_ID, 
		Networking.player_info.serialize()
	)
	connected = true
	player_connected.emit(Networking.player_info)

func _on_player_connect_failed() -> void:
	connected = false
	player_connect_failed.emit()

func _on_player_disconnected() -> void:
	Networking.player_info = null
	connected = false
	player_disconnected.emit()

func _on_peer_disconnected(_id: int) -> void:
	#TODO If in the middle of match, terminate battle and cleanup etc.
	pass
