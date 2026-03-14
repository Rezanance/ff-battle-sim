extends LineEdit

@export var server_connection_component: ServerConnectionComponent

func _ready() -> void:
	server_connection_component.player_connecting.connect(_on_player_connecting)
	server_connection_component.player_connect_failed.connect(_on_player_disconnected)

func _on_player_connecting() -> void:
	editable = false

func _on_player_disconnected() -> void:
	editable = true
