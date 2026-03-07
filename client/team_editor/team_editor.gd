extends Node
class_name TeamEditor

@export var team_manager: TeamManager
@export var team_name_input: LineEdit
@export var save_team_btn: SaveTeamBtn

var currently_selected_medal_btn: MedalBtn
var current_action: TeamSlots.Action

func _ready() -> void:
	init_save_team_btn()
	init_team_manager()

func _on_team_name_changed(new_name: String) -> void:
	team_manager.team_slots.team.name = new_name
	save_team_btn._on_team_changed(
		new_name, 
		TeamEditing.editing_team
	)

func _on_team_slots_team_modified(team: Team) -> void:
	save_team_btn._on_team_changed(team_name_input.text, team)

func init_save_team_btn() -> void:
	save_team_btn.pressed.connect(save_team_btn._on_pressed.bind(
		team_manager.team_slots,
	))
	save_team_btn._on_team_changed(
		team_name_input.text, 
		TeamEditing.editing_team
	)

func init_team_manager() -> void:
	team_manager.init(TeamEditing.editing_team)
