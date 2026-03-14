extends AcceptDialog

func _ready() -> void:
	ClientChallengePlayer.challenge_declined.connect(_on_challenge_declined)

func _on_challenge_declined(opponent_info: PlayerInfo) -> void:
	dialog_text = "%s (%d) declined your challenge" % [opponent_info.display_name, opponent_info.player_id]
	visible = true
