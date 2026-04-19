extends Button

@export var server_connection_component: ServerConnectionComponent

func _ready() -> void:
	server_connection_component.player_connecting.connect(_on_player_connecting)
	server_connection_component.player_disconnected.connect(_on_player_disconnected)
	server_connection_component.player_connect_failed.connect(_on_player_disconnected)

func _on_pressed() -> void:
	SceneTransition.change_scene('res://client/scenes/team_viewer/team_viewer.tscn')

func _on_player_connecting() -> void:
	disabled = true
	
func _on_player_disconnected() -> void:
	disabled = false
	
	
