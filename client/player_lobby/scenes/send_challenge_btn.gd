extends Button

@export var opponent_id_input: LineEdit
@export var challenge_player_component: ChallengePlayerComponent
	
func _on_direct_challenge_btn_pressed() -> void:
	disabled = true

func _on_opponent_player_id_text_changed(new_text: String) -> void:
	disabled = new_text.strip_edges() == ''

func _on_pressed() -> void:
	challenge_player_component.send_challenge(int(opponent_id_input.text.strip_edges()))
	
