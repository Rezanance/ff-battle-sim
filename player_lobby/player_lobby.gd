extends VideoStreamPlayer

@onready var player_icon_select: OptionButton = $'PlayerIcons'
@onready var display_name_input: LineEdit = $'DisplayName'
@onready var server_address_input: LineEdit = $'ServerIP'
@onready var go_online_btn: Button = $'GoOnlineBtn'
@onready var loading_conn: AnimatedSprite2D = $'LoadingConn'
@onready var copy_btn: TextureButton = $CopyBtn
@onready var player_id: Label = $'PlayerID'
@onready var team_select: OptionButton = $'VBoxContainer/TeamSelect'
@onready var send_challenge_popup: PopupPanel = $'SendChallenge'
@onready var direct_challenge_btn: Button = $'VBoxContainer/DirectChallengeBtn'
@onready var opponent_id_input: LineEdit = $SendChallenge/CenterContainer/VBoxContainer/HBoxContainer/OpponentPlayerId
@onready var send_challenge_btn: Button = $SendChallenge/CenterContainer/VBoxContainer/CenterContainer/SendChallengeBtn
@onready var waiting_challenge: AnimatedSprite2D = $'WaitingChallenge'
@onready var accept_challenge_confirmation: ConfirmationDialog = $AcceptChallenge

func _ready() -> void:
	Lobby.player_connecting.connect(_on_player_connecting)
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.player_connect_failed.connect(_on_player_connect_failed)
	Lobby.player_disconnecting.connect(_on_player_disconnecting)
	Lobby.player_disconnected.connect(_on_player_disconnected)
	
	Lobby.opponent_not_online.connect(_on_opponent_not_online)
	Lobby.challenge_requested.connect(_on_challenge_requested)
	
func _on_go_online_btn_pressed() -> void:
	var display_name = display_name_input.text.strip_edges()
	var server_ip = server_address_input.text.strip_edges()
	if display_name == '':
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Display name must not be empty')
		return
	if len(server_ip.split('.'))  != 4:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Server IP not the correct format')
		return
	Lobby.go_online(server_ip, display_name, player_icon_select.selected)

func _on_player_connecting():
	loading_conn.show()
	go_online_btn.disabled = true
	disable_ui()
	
func _on_player_connected(player_info):
	loading_conn.hide()
	go_online_btn.disabled = false
	go_online_btn.text = 'Disconnect'
	go_online_btn.icon = load("res://common_assets/wifi-icons/no-wifi.png")
	copy_btn.show()
	player_id.show()
	player_id.text = str(player_info['peer_id'])
	direct_challenge_btn.disabled = team_select.selected == 0
	disable_ui()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Successfully connected to server!')

func _on_player_connect_failed():
	loading_conn.hide()
	enable_ui()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error connecting to server')

func _on_player_disconnecting():
	loading_conn.show()
	copy_btn.hide()
	player_id.hide()
	go_online_btn.disabled = true
	
func _on_player_disconnected():
	loading_conn.hide()
	go_online_btn.disabled = false
	direct_challenge_btn.disabled = true
	enable_ui()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Successfully Disconnected from server')

func disable_ui():
	player_icon_select.disabled = true
	display_name_input.editable = false
	server_address_input.editable = false
	
func enable_ui():
	go_online_btn.disabled = false
	go_online_btn.text = 'Go Online'
	go_online_btn.icon = load("res://common_assets/wifi-icons/wifi.png")
	player_icon_select.disabled = false
	display_name_input.editable = true
	server_address_input.editable = true
	copy_btn.hide()
	player_id.hide()

func _on_copy_btn_pressed() -> void:
	DisplayServer.clipboard_set(player_id.text)
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Copied ID to clipboard!')

func _on_battle_btn_pressed() -> void:
	send_challenge_popup.visible = true
	opponent_id_input.text = ''
	send_challenge_btn.disabled = true

func _on_opponent_player_id_text_changed(new_text: String) -> void:
	var stripped = new_text.strip_edges()
	send_challenge_btn.disabled = stripped == ''

func _on_team_selected(index: int) -> void:
	direct_challenge_btn.disabled = not Lobby.connected or index == 0

func _on_send_challenge_btn_pressed() -> void:
	Lobby.send_challenge(int(opponent_id_input.text.strip_edges()))
	
	send_challenge_popup.visible = false
	direct_challenge_btn.disabled = true
	waiting_challenge.show()

func _on_opponent_not_online():
	direct_challenge_btn.disabled = false
	waiting_challenge.hide()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Opponent is no longer online or the id is incorrect')

func _on_challenge_requested(peer_id: int, player_info: Dictionary):
	accept_challenge_confirmation.dialog_text = '%s (%d) challenges you to a Fossil Battle. Do you accept??!' % [player_info['display_name'], peer_id] 
	accept_challenge_confirmation.show()
