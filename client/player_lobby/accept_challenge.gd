extends ConfirmationDialog

func _ready() -> void:
	ClientMatchMaking.challenge_requested.connect(_on_challenge_requested)

func _on_challenge_requested(opponent_info: Dictionary):
	dialog_text = '%s (%d) challenges you to a Fossil Networking. Do you accept??!' % [opponent_info['display_name'], opponent_info['player_id']] 
	show()

func _on_accept_challenge() -> void:
	ClientMatchMakingOUT.accept_challenge()

func _on_decline_challenge() -> void:
	ClientMatchMakingOUT.decline_challenge()
