extends Label

func _ready() -> void:
	ClientServerConnectionOUT.player_connected.connect(_on_player_connected)
	ClientServerConnectionOUT.player_connect_failed.connect(_on_player_disconnected)
	ClientServerConnectionOUT.player_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_info: Dictionary):
	text = str(player_info['player_id'])

func _on_player_disconnected():
	text = 'N/A'
