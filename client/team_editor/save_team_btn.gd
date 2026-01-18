extends Button
class_name SaveTeamBtn

@onready var team_name_input: LineEdit = $'../TeamNameInput'
@onready var team_slots: TeamSlots = $'../TeamSlots'

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	config.load(Constants.teams_file)

func _on_pressed() -> void:
	team_slots.team.name = team_name_input.text
	config.set_value(TeamEditing.editing_team.uuid, 'team', team_slots.team.serialize())
	var status: Error = config.save(Constants.teams_file)
	if status == OK:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Team Saved')
	else:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error saving team (error_code=%d)' % status)

func _on_team_modified() -> void:
	disabled = team_name_input.text.strip_edges() == '' or not team_slots.team.is_valid()
