extends Button

@export var server_connection_component: ServerConnectionComponent

var connected: bool = false
var team_selected: bool = false

func _ready() -> void:
	server_connection_component.player_connected.connect(_on_player_connected)
	server_connection_component.player_disconnected.connect(_on_player_connected)
	
	ClientChallengePlayer.opponent_not_online.connect(_on_opponent_not_online)
	ClientChallengePlayer.challenge_declined.connect(_on_challenge_declined)

func _on_player_connected(_player_info: PlayerInfo) -> void:
	connected = true
	disabled =  not team_selected

func _on_player_disconnected() -> void:
	connected = false
	disabled = true

func _on_opponent_not_online() -> void:
	disabled = false

func _on_challenge_declined(_opponent_info: PlayerInfo) -> void:
	disabled = false

func _on_send_challenge_btn_pressed() -> void:
	disabled = true

func _on_team_selected(_index: int) -> void:
	team_selected = true
	disabled = not connected
	
