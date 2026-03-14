extends ConfirmationDialog

@export var challenge_component: ChallengePlayerComponent

func _ready() -> void:
	ClientChallengePlayer.battle_requested.connect(_on_battle_requested)

func _on_battle_requested(opponent_info: PlayerInfo) -> void:
	dialog_text = '%s (%d) challenges you to a Fossil Networking. Do you accept??!' % [opponent_info.display_name, opponent_info.player_id] 
	show()

func _on_accept_challenge() -> void:
	challenge_component.accept_challenge()

func _on_decline_challenge() -> void:
	challenge_component.decline_challenge()
