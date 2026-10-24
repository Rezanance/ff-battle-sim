class_name PlayerInfo

var player_id: int
var display_name: String
var icon_id: int

func _init(_player_id: int=0, _display_name: String='', _icon_id: int=0) -> void:
	player_id = _player_id
	display_name = _display_name
	icon_id = _icon_id
