extends TextureRect
class_name PlayerLobby

const PLAYER_CONNECTED: String = 'PLAYER_CONNECTED'
const PLAYER_DISCONNECTED: String = 'PLAYER_DISCONNECTED'
const PLAYER_CONNECT_FAILED: String = 'PLAYER_CONNECT_FAILED'
const OPPONENT_NOT_ONLINE: String = 'OPPONENT_NOT_ONLINE'

@export var teams_file_component: FileComponent
@export var preferences_file_component: FileComponent
@export var team_select: OptionButton
@export var player_icon_select: OptionButton
@export var display_name_input: LineEdit
@export var server_ip_input: LineEdit

@export var status_notification_component: StatusNotificationComponent
@export var challenge_component: ChallengePlayerComponent
@export var battle_setup_component: BattleSetupComponent

signal can_connect(can_connect: bool)

var team_index: int = 0
var icon_id: int = 0
var display_name: String = ''
var server_ip: String

func _ready() -> void:
	var lobby_preferences_serialized: Variant = preferences_file_component.read('Preferences', 'Lobby Preferences')
	
	if lobby_preferences_serialized:
		var lobby_preferences: LobbyPreferences = LobbyPreferences.deserialize(lobby_preferences_serialized)
		server_ip_input.text = lobby_preferences.server_ip
		server_ip = lobby_preferences.server_ip
		player_icon_select.select(lobby_preferences.icon_id)
		display_name_input.text = lobby_preferences.display_name
		display_name = lobby_preferences.display_name
		can_connect.emit(can_go_online())
	else:
		server_ip = server_ip_input.text
	
	ClientChallengePlayer.opponent_not_online.connect(_on_opponent_not_online)
	ClientChallengePlayer.battle_requested.connect(_on_challenge_requested)
	ClientChallengePlayer.challenge_accepted.connect(_on_challenge_accepted)
	
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

func _on_player_connected(_player_info: PlayerInfo) -> void:
	status_notification_component.push(OK, PLAYER_CONNECTED)
	preferences_file_component.save(
		'Preferences', 
		'Lobby Preferences', 
		LobbyPreferences.new(
			icon_id,
			display_name,
			server_ip
		).serialize()
	)

func _on_player_connect_failed() -> void:
	status_notification_component.push(ERR_CANT_CONNECT, PLAYER_CONNECTED)
	
func _on_player_disconnected() -> void:
	status_notification_component.push(OK, PLAYER_DISCONNECTED)

func _on_opponent_not_online() -> void:
	status_notification_component.push(ERR_BUSY, OPPONENT_NOT_ONLINE)

func _on_challenge_requested(opponent_info: PlayerInfo) -> void:
	Networking.opponent_info = opponent_info

func _on_challenge_accepted(challenger_id: int) -> void:
	battle_setup_component.create_battle(challenger_id)

func _on_battle_created(battle_id: int) -> void:
	Networking.battle_id = battle_id
	battle_setup_component.send_team_info(battle_id, load_selected_team_info())

func _on_battle_prep_started(opponent_info: PlayerInfo, opponent_team: Team) -> void:
	Networking.player_team = Team.deserialize('', load_selected_team_info())
	Networking.opponent_info = opponent_info
	Networking.opponent_team = opponent_team
	SceneTransition.change_scene("res://client/scenes/battle_preperation/BattlePreperation.tscn")

func emit_connect_status() -> void:
	can_connect.emit(can_go_online())

func can_go_online() -> bool:
	var display_name_not_empty: bool = len(display_name) > 0
	var server_ip_correct_format: bool = len(server_ip.split('.')) == 4
	var team_selected: bool = team_index != 0
	return display_name_not_empty and server_ip_correct_format and team_selected

func load_selected_team_info() -> Dictionary:
	var team_uuid: String = teams_file_component.read_all()[team_select.selected - 1]
	return teams_file_component.read(team_uuid, 'team')
