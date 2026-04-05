extends TextureRect

const TEAM_DELETED: String = 'TEAM_DELETED'

const TeamPreviewScene: Resource = preload("res://client/scenes/team_viewer/scenes/team_preview/team_preview.tscn")
const NewTeamBtn: Resource = preload("res://client/scenes/team_viewer/scenes/new_team_btn/new_team_btn.tscn")

@export var file_component: FileComponent
@export var status_notification_component: StatusNotificationComponent
@export var teams_container: VFlowContainer

func _ready() -> void:
	for team_uuid: String in file_component.read_all():
		var team_preview: TeamPreview = TeamPreviewScene.instantiate()
		var team_dict: Dictionary = file_component.read(team_uuid, 'team')
		var team: Team = Team.deserialize(team_uuid, team_dict)
		team_preview.get_node("TeamNameBackground/TeamName").text = team.name
		
		var medal_container: Node = team_preview.get_node("FormationBackground/MedalContainer")
		
		for i: int in range(Team.TEAM_SLOTS):
			var vivosaur_slot: VivosaurInfo = team.slots[i]
			if vivosaur_slot != null:
				medal_container.get_child(i).texture =  UIUtils.load_medal_texture(vivosaur_slot.id)
		
		var delete_btn: Delete = team_preview.get_node("Delete")
		delete_btn.pressed.connect(_on_delete_pressed.bind(team_uuid, team_preview))
		team_preview.gui_input.connect(team_preview._on_gui_input.bind(team))
		teams_container.add_child(team_preview)

	teams_container.add_child(NewTeamBtn.instantiate())


func _on_delete_pressed(team_uuid: String, team_name: String, team_preview: Node) -> void:
	var status: Error = file_component.delete(team_uuid)
	
	if status == OK:
		status_notification_component.push(status, TEAM_DELETED, [team_name])
		team_preview.queue_free()
		return
	status_notification_component.push(status)
	
	
	
