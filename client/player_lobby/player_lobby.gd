extends TextureRect

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

var config = ConfigFile.new()

func _ready() -> void:
	config.load(Constants.teams_file)
	if not OS.has_feature('dedicated_server'):
		ClientServerConnectionOUT.player_connecting.connect(_on_player_connecting)
		ClientServerConnectionOUT.player_connected.connect(_on_player_connected)
		ClientServerConnectionOUT.player_connect_failed.connect(_on_player_connect_failed)
		ClientServerConnectionOUT.player_disconnecting.connect(_on_player_disconnecting)
		ClientServerConnectionOUT.player_disconnected.connect(_on_player_disconnected)
		
		ClientMatchMaking.opponent_not_online.connect(_on_opponent_not_online)
		ClientMatchMaking.challenge_requested.connect(_on_challenge_requested)
		ClientMatchMaking.challenge_declined.connect(_on_challenge_declined)
		ClientMatchMaking.challenge_accepted.connect(_on_challenge_accepted)
		
		ClientBattleSetup.battle_created.connect(_on_battle_created)
		ClientBattleSetup.battle_prep_started.connect(_on_battle_prep_started)

func load_selected_team_info():
	var team_uuid = config.get_sections()[team_select.selected - 1]
	return config.get_value(team_uuid, 'team')
	
func _on_go_online_btn_pressed() -> void:
	var display_name = display_name_input.text.strip_edges()
	var server_ip = server_address_input.text.strip_edges()
	if display_name == '':
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Display name must not be empty')
		return
	if len(server_ip.split('.'))  != 4:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Server IP not the correct format')
		return
	ClientServerConnectionOUT.go_online(server_ip, display_name, player_icon_select.selected)

func _on_player_connecting():
	loading_conn.show()
	go_online_btn.disabled = true
	disable_ui()
	
func _on_player_connected(player_info):
	loading_conn.hide()
	go_online_btn.disabled = false
	go_online_btn.text = 'Disconnect'
	go_online_btn.icon = load("res://client/assets/wifi-icons/no-wifi.png")
	copy_btn.show()
	player_id.show()
	player_id.text = str(player_info['player_id'])
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
	go_online_btn.icon = load("res://client/assets/wifi-icons/wifi.png")
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
	go_online_btn.disabled = false
	direct_challenge_btn.disabled = not Networking.connected or index == 0

func _on_send_challenge_btn_pressed() -> void:
	ClientMatchMakingOUT.send_challenge(int(opponent_id_input.text.strip_edges()))
	
	send_challenge_popup.visible = false
	direct_challenge_btn.disabled = true
	team_select.disabled = true
	waiting_challenge.show()

func _on_opponent_not_online():
	direct_challenge_btn.disabled = false
	team_select.disabled = false
	waiting_challenge.hide()
	DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Opponent is no longer online or the id is incorrect')

func _on_challenge_requested(opponent_info: Dictionary):
	Networking.opponent_info = opponent_info
	accept_challenge_confirmation.dialog_text = '%s (%d) challenges you to a Fossil Networking. Do you accept??!' % [opponent_info['display_name'], opponent_info['player_id']] 
	accept_challenge_confirmation.show()

func _on_decline_challenge() -> void:
	ClientMatchMakingOUT.decline_challenge()

func _on_challenge_declined(opponent_info: Dictionary) -> void:
	GlobalAcceptDialog.dialog_text = "%s (%d) declined your challenge" % [opponent_info['display_name'], opponent_info['player_id']]
	GlobalAcceptDialog.visible = true
	direct_challenge_btn.disabled = false
	waiting_challenge.hide()

func _on_accept_challenge() -> void:
	ClientMatchMakingOUT.accept_challenge()
	
func _on_challenge_accepted(challenger_id: int):
	ClientBattleSetupOUT.create_battle(challenger_id)

func _on_battle_created(battle_id: int):
	Networking.battle_id = battle_id
	ClientBattleSetupOUT.send_team_info(battle_id, load_selected_team_info())

func _on_battle_prep_started(opponent_info, opponent_team_info):
	Networking.player_team = Team.unserialize('', load_selected_team_info())
	Networking.opponent_info = opponent_info
	Networking.opponent_team = Team.unserialize('', opponent_team_info)
	SceneTransition.change_scene("res://client/battle_preperation/BattlePreperation.tscn")
