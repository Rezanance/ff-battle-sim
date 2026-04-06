extends Node
class_name BattlingComponent

func notify_battle_scene_loaded() -> void:
	ServerBattling.client_battle_scene_loaded.rpc_id(
		Networking.SERVER_PEER_ID, 
		Networking.battle_id
	)
