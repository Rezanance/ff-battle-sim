extends AnimatedSprite2D

@export var server_connection_component: ServerConnectionComponent

func _ready() -> void:
	play()
	server_connection_component.player_connecting.connect(_on_player_connecting)
	server_connection_component.player_connected.connect(_on_player_connected)
	server_connection_component.player_disconnected.connect(_on_player_disconnected)
	server_connection_component.player_connect_failed.connect(_on_player_disconnected)
	server_connection_component.player_disconnecting.connect(_on_player_disconnecting)

func _on_player_connecting() -> void:
	show()
	
func _on_player_connected(_player_info: PlayerInfo) -> void:
	hide()

func _on_player_disconnecting() -> void:
	show()
	
func _on_player_disconnected() -> void:
	hide()
