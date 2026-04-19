extends TextureRect

@export var team_slots: TeamSlots 
@export var opponent_team_slots: TeamSlots 

@export var context_menu: PopupMenu
@export var vivosaur_summary: VivosaurSummary
@export var timer: RichTextLabel

@export var player_icon: TextureRect
@export var player_name: Label
@export var opp_icon: TextureRect
@export var opp_name: Label

@export var battle_setup_component: BattleSetupComponent
@export var team_mananger: TeamManager
@export var opp_team_mananger: TeamManager

# Dev mode only
@export var ready_btn: Button

var currently_selected_medal_btn: MedalBtn
var current_action: TeamSlots.Action

var time_left: float = 90.0
 
func _ready() -> void:
	initialize_UI()
	initialize_teams()
	
	ClientBattleSetup.battle_prep_time_up.connect(_on_battle_prep_time_up)
	ClientBattleSetup.battle_started.connect(_on_battle_started)
	
	var args: PackedStringArray = OS.get_cmdline_args()
	if '--client1' in args or '--client2' in args:
		dev_mode()

func _process(delta: float) -> void:
	if time_left > 0:
		time_left -= delta
		if time_left > 0:
			timer.text = "%.2f" % time_left
		else:
			timer.text = "0"

func initialize_UI() -> void:
	var icon_path: String = 'res://client/assets/player-icons/'
	var icon_files: PackedStringArray = ResourceLoader.list_directory(icon_path)
	player_icon.texture = load(icon_path + icon_files[Networking.player_info['icon_id']])
	opp_icon.texture = load(icon_path + icon_files[Networking.opponent_info['icon_id']])
	player_name.text = Networking.player_info['display_name']
	opp_name.text = Networking.opponent_info['display_name']

func initialize_teams() -> void:
	team_mananger.init(Networking.player_team)
	opp_team_mananger.init(Networking.opponent_team)

func _on_battle_prep_time_up() -> void:
	battle_setup_component.send_new_team_info(Networking.player_team)

func _on_battle_started(formations: Dictionary[int, Formation]) -> void:
	Battling.formations = formations
	SceneTransition.change_scene("res://client/scenes/battle/Battle.tscn")

func dev_mode() -> void:
	ready_btn.toggled.emit(true)
