extends Button

@export var server_connection_component: ServerConnectionComponent

func _ready() -> void:
	server_connection_component.player_connected.connect(_on_player_connected)
	
	ClientChallengePlayer.opponent_not_online.connect(_on_opponent_not_online)
	ClientChallengePlayer.challenge_declined.connect(_on_challenge_declined)

func _on_player_connected(_player_info: PlayerInfo) -> void:
	disabled = false

func _on_opponent_not_online() -> void:
	disabled = false

func _on_challenge_declined(_opponent_info: PlayerInfo) -> void:
	disabled = false
