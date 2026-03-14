extends Button
class_name SaveTeamBtn

const TEAM_SAVED: String = "TEAM_SAVED"
const ERROR_SAVING_TEAM: String = 'ERROR_SAVING_TEAM'

@export var file_component: FileComponent
@export var status_notification_component: StatusNotificationComponent

func _on_pressed(team_slots: TeamSlots) -> void:
	var status: Error = file_component.save(
		TeamEditing.editing_team.uuid, 
		'team', 
		team_slots.team.serialize()
	)
	if status == OK:
		status_notification_component.push(status, TEAM_SAVED, [team_slots.team.name])
	else:
		status_notification_component.push(status, ERROR_SAVING_TEAM)

func _on_team_changed(team_name: String, team: Team) -> void:
	disabled = team_name.strip_edges() == '' or not team.is_valid()
