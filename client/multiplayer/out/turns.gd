extends Node


func who_goes_first(battle_id: int):
	ServerTurns.who_goes_first_server.rpc_id(Networking.SERVER_PEER_ID, battle_id)

func end_turn(battle_id: int):
	ServerTurns.end_turn_server.rpc_id(Networking.SERVER_PEER_ID, battle_id)
