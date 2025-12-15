extends Node

const ServerConfig = preload("res://server/config.gd")

func _ready() -> void:
	if OS.has_feature('dedicated_server') and DisplayServer.get_name() == "headless":
		var peer = ENetMultiplayerPeer.new()
		var error = peer.create_server(ServerConfig.PORT, ServerConfig.MAX_PLAYERS)
		if error:
			Logging.error('Error creating server (error_code=%d)' % error)
			return
			
		Logging.info('Started Server')
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_disconnected.connect(_on_client_disconnected)

func _on_client_disconnected(id: int):
	Logging.info('%d disconnected' % id)
	ServerVariables.all_player_info.erase(id)
	
	if ServerVariables.player_battles.has(id):
		var battle_id = ServerVariables.player_battles[id]
		var opponent_id = ServerVariables.battle_teams[battle_id].keys().filter(func (player_id): return player_id != id)[0]
		
		ServerVariables.player_battles.erase(id)
		ServerVariables.player_battles.erase(opponent_id)
		ServerVariables.battle_teams.erase(battle_id)
		ServerVariables.battle_timers.erase(battle_id)
		ServerVariables.battlefields.erase(battle_id)
		ServerVariables.responses_to_server.erase(battle_id)
		ServerVariables.used_battle_ids.erase(battle_id)
