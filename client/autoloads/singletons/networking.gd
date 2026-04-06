extends Node

const SERVER_PEER_ID: int = 1

var battle_id: int
var player_info: PlayerInfo = PlayerInfo.new(123, 'Rez', 4)
var player_team: Team
var opponent_info: PlayerInfo = PlayerInfo.new(456, 'Echo', 8)
var opponent_team: Team

func get_opponent_id(player_id: int) -> int:
	if player_id == player_info.player_id:
		return opponent_info.player_id
	else:
		return player_info.player_id
