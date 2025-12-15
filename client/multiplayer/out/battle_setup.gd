extends Node


func create_battle(challenger_id: int):
	ServerBattleSetup.initialize_battle.rpc_id(Networking.SERVER_PEER_ID, challenger_id)

func send_team_info(battle_id: int, team_info: Dictionary):
	ServerBattleSetup.register_team_initial.rpc_id(Networking.SERVER_PEER_ID, battle_id, team_info)

func ready_early(battle_id: int):
	ServerBattleSetup.ready_early.rpc_id(Networking.SERVER_PEER_ID, battle_id)

func send_new_team_info(new_team_info: Team):
	ServerBattleSetup.start_battle.rpc_id(Networking.SERVER_PEER_ID, Networking.battle_id, new_team_info.serialize())
