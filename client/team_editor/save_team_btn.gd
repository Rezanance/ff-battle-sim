extends Button
class_name SaveTeamBtn

@onready var save_component: SaveComponent = $SaveComponent

func _on_pressed(team_slots: TeamSlots) -> void:
	var status: Error = save_component.save(
		TeamEditing.editing_team.uuid, 
		'team', 
		team_slots.team.serialize()
	)
	show_popup(status)

func _on_team_changed(team_name: String, team: Team) -> void:
	disabled = team_name.strip_edges() == '' or not team.is_valid()

#func save_team(team_slots: TeamSlots, team_name: String) -> Error:
	#team_slots.team.name = team_name.strip_edges()
	#config.set_value(TeamEditing.editing_team.uuid, 'team', team_slots.team.serialize())
	#return config.save(Constants.teams_file)

func show_popup(status: Error) -> void:
	if status == OK:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Team Saved')
	else:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error saving team (error_code=%d)' % status)
