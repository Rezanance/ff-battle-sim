extends TextureRect
class_name PlayerLobby

const PLAYER_CONNECTED: String = 'PLAYER_CONNECTED'
const PLAYER_DISCONNECTED: String = 'PLAYER_DISCONNECTED'
const PLAYER_CONNECT_FAILED: String = 'PLAYER_CONNECT_FAILED'
const OPPONENT_NOT_ONLINE: String = 'OPPONENT_NOT_ONLINE'

@export var file_component: FileComponent
@export var team_select: OptionButton
@export var player_icon_select: OptionButton
@export var display_name_input: LineEdit
@export var server_ip_input: LineEdit
@export var status_notification_component: StatusNotificationComponent

signal can_connect(can_connect: bool)

var team_index: int = 0
var icon_id: int = 0
var display_name: String = ''
var server_ip: String
var connected: bool = false

func _ready() -> void:
	server_ip = server_ip_input.text
	
	ClientServerConnectionOUT.player_connected.connect(_on_player_connected)
	ClientServerConnectionOUT.player_connect_failed.connect(_on_player_connect_failed)
	ClientServerConnectionOUT.player_disconnected.connect(_on_player_disconnected)

	ClientMatchMaking.opponent_not_online.connect(_on_opponent_not_online)
	ClientMatchMaking.challenge_requested.connect(_on_challenge_requested)
	ClientMatchMaking.challenge_accepted.connect(_on_challenge_accepted)
	
	ClientBattleSetup.battle_created.connect(_on_battle_created)
	ClientBattleSetup.battle_prep_started.connect(_on_battle_prep_started)

func _on_team_changed(new_team: int) -> void:
	team_index = new_team
	emit_connect_status()

func _on_icon_changed(new_icon_id: int) -> void:
	icon_id = new_icon_id

func _on_display_name_changed(new_name: String) -> void:
	display_name = new_name.strip_edges()
	emit_connect_status()
	
func _on_server_ip_changed(new_ip: String) -> void:
	server_ip = new_ip.strip_edges()
	emit_connect_status()

func _on_player_connected(_player_info: Dictionary) -> void:
	status_notification_component.push(OK, PLAYER_CONNECTED)

func _on_player_connect_failed() -> void:
	status_notification_component.push(ERR_CANT_CONNECT, PLAYER_CONNECTED)
	
func _on_player_disconnected() -> void:
	status_notification_component.push(OK, PLAYER_DISCONNECTED)

func _on_opponent_not_online() -> void:
	status_notification_component.push(ERR_BUSY, OPPONENT_NOT_ONLINE)

func _on_challenge_requested(opponent_info: Dictionary) -> void:
	Networking.opponent_info = opponent_info

func _on_challenge_accepted(challenger_id: int) -> void:
	ClientBattleSetupOUT.create_battle(challenger_id)

func _on_battle_created(battle_id: int) -> void:
	Networking.battle_id = battle_id
	ClientBattleSetupOUT.send_team_info(battle_id, load_selected_team_info())

func _on_battle_prep_started(opponent_info: Dictionary, opponent_team_info: Dictionary) -> void:
	Networking.player_team = Team.unserialize('', load_selected_team_info())
	Networking.opponent_info = opponent_info
	Networking.opponent_team = Team.unserialize('', opponent_team_info)
	SceneTransition.change_scene("res://client/battle_preperation/BattlePreperation.tscn")

func emit_connect_status() -> void:
	can_connect.emit(can_go_online())

func can_go_online() -> bool:
	var is_team_selected: bool = team_index != 0
	var display_name_not_empty: bool = len(display_name) > 0
	var server_ip_correct_format: bool = len(server_ip.split('.')) == 4
	return is_team_selected and display_name_not_empty and server_ip_correct_format

func load_selected_team_info() -> Dictionary:
	var team_uuid: String = file_component.read_all()[team_select.selected - 1]
	return file_component.read(team_uuid, 'team')
