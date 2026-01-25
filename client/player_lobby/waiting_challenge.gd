extends AnimatedSprite2D

func _ready() -> void:
	play()
	ClientMatchMaking.opponent_not_online.connect(_on_opponent_not_online)
	ClientMatchMaking.challenge_declined.connect(_on_challenge_declined)

func _on_opponent_not_online() -> void:
	hide()

func _on_challenge_declined(_opponent_info: Dictionary) -> void:
	hide()
