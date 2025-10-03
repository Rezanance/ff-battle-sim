extends VideoStreamPlayer

@onready var player_icon_select: OptionButton = $'PlayerIcons'
@onready var display_name_input: LineEdit = $'DisplayName'
@onready var server_address_input: LineEdit = $'ServerIP'
@onready var go_online_btn: Button = $'GoOnlineBtn'
@onready var team_select: OptionButton = $'VBoxContainer/TeamSelect'
@onready var challenge_user_btn = $'VBoxContainer/ChallengeUserBtn'

var connected = false

func _ready() -> void:
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.player_disconnected.connect(_on_player_disconnected)

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
	
func _on_player_connected(player_info):
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Successfully connected to server!')
	display_name_input.text = player_info['display_name']
	go_online_btn.text = 'Disconnect'
	go_online_btn.icon = load("res://common_assets/wifi-icons/no-wifi.png")
	player_icon_select.disabled = true
	display_name_input.editable = false
	server_address_input.editable = false
	challenge_user_btn.disabled = false

func _on_player_disconnected():
	reset_ui()

func reset_ui():
	go_online_btn.text = 'Go Online'
	go_online_btn.icon = load("res://common_assets/wifi-icons/wifi.png")
	player_icon_select.disabled = false
	display_name_input.editable = true
	server_address_input.editable = true
	challenge_user_btn.disabled = true
