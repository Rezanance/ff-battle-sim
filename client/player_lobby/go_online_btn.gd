extends Button


@onready var player_lobby: PlayerLobby = $'..'
@onready var player_icon_select: OptionButton = $'../PlayerIconSelect'
@onready var display_name_input: LineEdit = $'../DisplayNameInput'
@onready var server_ip_input: LineEdit = $'../ServerIPInput'

func _ready() -> void:
	player_lobby.can_connect.connect(_on_can_connect)
	pressed.connect(_on_pressed)
	ClientServerConnectionOUT.player_connecting.connect(_on_player_connecting)
	ClientServerConnectionOUT.player_connected.connect(_on_player_connected)
	ClientServerConnectionOUT.player_connect_failed.connect(_on_player_disconnected)
	ClientServerConnectionOUT.player_disconnecting.connect(_on_player_disconnecting)

func _on_can_connect(can_connect: bool) -> void:
	disabled = not can_connect
	
func _on_pressed() -> void:
	ClientServerConnectionOUT.go_online(
		server_ip_input.text.strip_edges(), 
		display_name_input.text.strip_edges(), 
		player_icon_select.selected,
		player_lobby.connected)

func _on_player_connecting() -> void:
	disabled = true

func _on_player_connected(_player_info: Dictionary) -> void:
	disabled = false
	
func _on_player_disconnecting() -> void:
	disabled = true
	
func _on_player_disconnected() -> void:
	disabled = false
