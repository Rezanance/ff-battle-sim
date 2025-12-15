extends Node


func send_challenge(opponent_id: int):
	ServerMatchMaking.forward_challenge.rpc_id(Networking.SERVER_PEER_ID, opponent_id)

func decline_challenge():
	ServerMatchMaking.forward_challenge_declined.rpc_id(
		Networking.SERVER_PEER_ID, 
		multiplayer.get_unique_id(), 
		Networking.opponent_info['player_id']
	)

func accept_challenge():
	ServerMatchMaking.forward_challenge_accepted.rpc_id(
		Networking.SERVER_PEER_ID, 
		multiplayer.get_unique_id(), 
		Networking.opponent_info['player_id']
	)
