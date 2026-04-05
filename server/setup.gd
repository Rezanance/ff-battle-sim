extends Node

const Utils = preload("res://server/rpc_impls/utils.gd")
const ServerConfig = preload("res://server/config.gd")

func _ready() -> void:
	if OS.has_feature('dedicated_server') and DisplayServer.get_name() == "headless":
		var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		var error: Error = peer.create_server(ServerConfig.PORT, ServerConfig.MAX_PLAYERS)
		if error:
			Logging.error('Error creating server (error_code=%d)' % error)
			return
			
		Logging.info('Started Server')
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_disconnected.connect(_on_client_disconnected)

func _on_client_disconnected(id: int) -> void:
	Logging.info('%d disconnected' % id)
	ServerVariables.all_player_info.erase(id)
	
	var battle_id: int = Utils.get_battle_id_from_player(id)
	if battle_id != -1:
		ServerVariables.battles.erase(battle_id)
		ServerVariables.used_battle_ids.erase(battle_id)
