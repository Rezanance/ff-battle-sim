extends Button


@export var player_lobby: PlayerLobby
@export var player_icon_select: OptionButton
@export var display_name_input: LineEdit 
@export var server_ip_input: LineEdit
@export var send_challenge_btn: Button
@export var server_connection_component: ServerConnectionComponent

func _ready() -> void:
	pressed.connect(_on_pressed)
	
	player_lobby.can_connect.connect(_on_can_connect)
	
	send_challenge_btn.pressed.connect(_on_send_challenge)
	
	server_connection_component.player_connecting.connect(_on_player_connecting)
	server_connection_component.player_connected.connect(_on_player_connected)
	server_connection_component.player_connect_failed.connect(_on_player_disconnected)
	server_connection_component.player_disconnected.connect(_on_player_disconnected)
	server_connection_component.player_disconnecting.connect(_on_player_disconnecting)
	
	ClientChallengePlayer.challenge_declined.connect(_on_challenge_declined)
	
func _on_can_connect(can_connect: bool) -> void:
	disabled = not can_connect
	
func _on_pressed() -> void:
	server_connection_component.go_online(
		server_ip_input.text.strip_edges(), 
		display_name_input.text.strip_edges(), 
		player_icon_select.selected
	)

func _on_player_connecting() -> void:
	disabled = true

func _on_player_connected(_player_info: PlayerInfo) -> void:
	disabled = false
	text = 'Disconnect'
	
func _on_player_disconnecting() -> void:
	disabled = true
	
func _on_player_disconnected() -> void:
	disabled = false
	text = 'Go Online!'

func _on_send_challenge() -> void:
	disabled = true
	
func _on_challenge_declined(_opponent_info: PlayerInfo) -> void:
	disabled = false
