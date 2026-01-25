extends AnimatedSprite2D

func _ready() -> void:
	play()
	ClientServerConnectionOUT.player_connecting.connect(_on_player_connecting)
	ClientServerConnectionOUT.player_connected.connect(_on_player_connected)
	ClientServerConnectionOUT.player_connect_failed.connect(_on_player_disconnected)
	ClientServerConnectionOUT.player_disconnecting.connect(_on_player_disconnecting)

func _on_player_connecting() -> void:
	show()
	
func _on_player_connected() -> void:
	hide()

func _on_player_disconnecting() -> void:
	show()
	
func _on_player_disconnected() -> void:
	hide()
