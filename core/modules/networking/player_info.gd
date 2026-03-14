class_name PlayerInfo

var player_id: int
var display_name: String
var icon_id: int

func _init(_player_id: int, _display_name: String, _icon_id: int) -> void:
	player_id = _player_id
	display_name = _display_name
	icon_id = _icon_id

func serialize() -> Dictionary:
	return {
		'player_id': player_id,
		'display_name': display_name,
		'icon_id': icon_id
	}
	
static func deserialize(player_info: Dictionary) -> PlayerInfo:
	return PlayerInfo.new(
		player_info['player_id'],
		player_info['display_name'],
		player_info['icon_id']
	)
