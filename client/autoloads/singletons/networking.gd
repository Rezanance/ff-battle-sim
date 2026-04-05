extends Node

const SERVER_PEER_ID: int = 1

var battle_id: int
var player_info: PlayerInfo = PlayerInfo.new(123, 'Rez', 4)
var player_team: Team
var opponent_info: PlayerInfo = PlayerInfo.new(456, 'Echo', 8)
var opponent_team: Team
