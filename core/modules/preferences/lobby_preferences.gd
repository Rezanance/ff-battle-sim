class_name LobbyPreferences

var icon_id: int
var display_name: String
var server_ip: String

func _init(_icon_id: int, _display_name: String, _server_ip: String) -> void:
	icon_id = _icon_id
	display_name = _display_name
	server_ip = _server_ip
	
func serialize() -> Dictionary[String, Variant]:
	return {
		"icon_id": icon_id,
		"display_name": display_name,
		"server_ip": server_ip
	}
	
static func deserialize(preferences: Dictionary[String, Variant]) -> LobbyPreferences:
	return LobbyPreferences.new(
		preferences["icon_id"],
		preferences["display_name"],
		preferences["server_ip"],
	)
