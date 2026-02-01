extends TextureButton

@onready var player_id: Label = $'../PlayerID'

func _ready() -> void:
	ClientServerConnectionOUT.player_connected.connect(_on_player_connected)

func _on_player_connected(_player_info: Dictionary) -> void:
	show()

func _on_copy_btn_pressed() -> void:
	DisplayServer.clipboard_set(player_id.text)
	# FIXME
	#StatusNotification.push(StatusNotification.MessageType.SUCCESS, 'Copied ID to clipboard!')
	
