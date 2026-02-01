extends Button
class_name SaveTeamBtn

@onready var file_component: FileComponent = $FileComponent
@onready var status_notification_component: StatusNotificationComponent = $StatusNotificationComponent

func _on_pressed(team_slots: TeamSlots) -> void:
	var status: Error = file_component.save(
		TeamEditing.editing_team.uuid, 
		'team', 
		team_slots.team.serialize()
	)
	status_notification_component.push(status)
	

func _on_team_changed(team_name: String, team: Team) -> void:
	disabled = team_name.strip_edges() == '' or not team.is_valid()
