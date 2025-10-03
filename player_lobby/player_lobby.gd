extends VideoStreamPlayer

@onready var player_icon_select: OptionButton = $'PlayerIcons'
@onready var display_name_input: LineEdit = $'DisplayName'
@onready var server_address_input: LineEdit = $'ServerIP'
@onready var go_online_btn: Button = $'GoOnlineBtn'
@onready var loading_conn: AnimatedSprite2D = $'LoadingConn'
@onready var copy_btn: TextureButton = $CopyBtn
@onready var player_id: Label = $'PlayerID'
@onready var team_select: OptionButton = $'VBoxContainer/TeamSelect'
@onready var battle_btn = $'VBoxContainer/BattleBtn'

var connected = false

func _ready() -> void:
	Lobby.player_connecting.connect(_on_player_connecting)
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.player_connect_failed.connect(_on_player_connect_failed)
	Lobby.player_disconnecting.connect(_on_player_disconnecting)
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

func _on_player_connecting():
	loading_conn.visible = true
	disable_ui()
	
func _on_player_connected(player_info):
	loading_conn.visible = false
	go_online_btn.disabled = false
	go_online_btn.text = 'Disconnect'
	go_online_btn.icon = load("res://common_assets/wifi-icons/no-wifi.png")
	copy_btn.visible = true
	player_id.visible = true
	player_id.text = str(player_info['peer_id'])
	disable_ui()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Successfully connected to server!')

func _on_player_connect_failed():
	loading_conn.visible = false
	enable_ui()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error connecting to server')

func _on_player_disconnecting():
	loading_conn.visible = true
	copy_btn.visible = false
	player_id.visible = false
	go_online_btn.disabled = true
	
func _on_player_disconnected():
	loading_conn.visible = false
	go_online_btn.disabled = false
	enable_ui()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Successfully Disconnected from server')

func disable_ui():
	player_icon_select.disabled = true
	display_name_input.editable = false
	server_address_input.editable = false
	battle_btn.disabled = false
	
func enable_ui():
	go_online_btn.disabled = false
	go_online_btn.text = 'Go Online'
	go_online_btn.icon = load("res://common_assets/wifi-icons/wifi.png")
	player_icon_select.disabled = false
	display_name_input.editable = true
	server_address_input.editable = true
	battle_btn.disabled = true
	copy_btn.visible = false
	player_id.visible = false


func _on_copy_btn_pressed() -> void:
	DisplayServer.clipboard_set(player_id.text)
	DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Copied ID to clipboard!')
