extends TextureButton

const ID_COPIED: String = "ID_COPIED"

@export var player_id: Label

@export var server_connection_component: ServerConnectionComponent
@export var status_notification_component: StatusNotificationComponent

func _ready() -> void:
	server_connection_component.player_connected.connect(_on_player_connected)
	server_connection_component.player_connect_failed.connect(_on_player_disconnected)
	server_connection_component.player_disconnected.connect(_on_player_disconnected)
	
func _on_player_connected(_player_info: PlayerInfo) -> void:
	show()
	
func _on_player_disconnected() -> void:
	hide()

func _on_copy_btn_pressed() -> void:
	DisplayServer.clipboard_set(player_id.text)
	status_notification_component.push(Error.OK, ID_COPIED)
