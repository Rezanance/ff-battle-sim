extends Button

func _ready() -> void:
	ClientServerConnectionOUT.player_connected.connect(_on_player_connected)
	ClientMatchMaking.opponent_not_online.connect(_on_opponent_not_online)
	ClientMatchMaking.challenge_declined.connect(_on_challenge_declined)

func _on_player_connected(_player_info: Dictionary) -> void:
	disabled = false

func _on_opponent_not_online() -> void:
	disabled = false

func _on_challenge_declined(_opponent_info: Dictionary) -> void:
	disabled = false
	
