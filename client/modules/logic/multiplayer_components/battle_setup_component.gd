extends Node
class_name BattleSetupComponent

func create_battle(challenger_id: int) -> void:
	ServerRPCs.initialize_battle.rpc_id(Networking.SERVER_PEER_ID, challenger_id)

func send_team_info(battle_id: int, team_info: Dictionary) -> void:
	ServerRPCs.register_team_initial.rpc_id(Networking.SERVER_PEER_ID, battle_id, team_info)

func submit_formation(new_team_info: Team) -> void:
	ServerRPCs.submit_formation.rpc_id(Networking.SERVER_PEER_ID, Networking.battle_id, new_team_info.serialize())
