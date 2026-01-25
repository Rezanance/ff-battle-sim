extends LineEdit


func _ready() -> void:
	ClientServerConnectionOUT.player_connecting.connect(_on_player_connecting)
	ClientServerConnectionOUT.player_connect_failed.connect(_on_player_disconnected)

func _on_player_connecting() -> void:
	editable = false

func _on_player_disconnected() -> void:
	editable = true
