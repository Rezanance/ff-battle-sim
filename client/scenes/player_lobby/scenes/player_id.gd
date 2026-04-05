extends Label

@export var server_connection_component: ServerConnectionComponent

func _ready() -> void:
	server_connection_component.player_connected.connect(_on_player_connected)
	server_connection_component.player_connect_failed.connect(_on_player_disconnected)
	server_connection_component.player_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_info: PlayerInfo) -> void:
	text = str(player_info.player_id)

func _on_player_disconnected() -> void:
	text = 'N/A'
