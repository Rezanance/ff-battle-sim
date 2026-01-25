extends Button

@onready var opponent_id_input: LineEdit = $'../../HBoxContainer/OpponentPlayerId'

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_direct_challenge_btn_pressed() -> void:
	disabled = true

func _on_opponent_player_id_text_changed(new_text: String) -> void:
	disabled = new_text.strip_edges() == ''

func _on_pressed() -> void:
	ClientMatchMakingOUT.send_challenge(int(opponent_id_input.text.strip_edges()))
	
