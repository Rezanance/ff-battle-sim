extends Node

const TeamPreviewScene = preload("res://team_viewer/team_preview/team_preview.tscn")
const NewTeamBtn = preload("res://team_viewer/new_team_btn.tscn")

var config = ConfigFile.new()

func _ready() -> void:
	
	var status = config.load(Global.teams_file)
	
	if status == OK :
		for team_uuid in config.get_sections():
			var team_preview = TeamPreviewScene.instantiate()
			var team_dict = config.get_value(team_uuid, 'team')
			var team: DataTypes.Team = DataTypes.Team.unserialize(team_uuid, team_dict)
			team_preview.get_node("TeamNameBackground/TeamName").text = team.name
			
			var medal_container: Node = team_preview.get_node("FormationBackground/MedalContainer")
			
			for i in range(DataTypes.TEAM_SLOTS):
				var vivosaur_slot: DataTypes.Vivosaur = team.slots[i]
				if vivosaur_slot != null:
					medal_container.get_child(i).texture = load("res://vivosaur/%s/medal/%s (2).png" % [vivosaur_slot.id, vivosaur_slot.id])
			
			team_preview.get_node("Delete").pressed.connect(_delete_team.bind(team_uuid, team.name, team_preview))
			team_preview.gui_input.connect(_on_team_preview_gui_input.bind(team))
			add_child(team_preview)
			
	_add_new_team_btn()
	
	
func _add_new_team_btn():
	add_child(NewTeamBtn.instantiate()) 

func _on_team_preview_gui_input(event: InputEvent, team: DataTypes.Team) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Global.editing_team = team
			Global.is_new_team = false
			SceneTransition.change_scene("res://team_viewer/team_editor/team_editor.tscn")

func _delete_team(team_uuid: String, team_name: String, team_preview: Node):
	config.erase_section(team_uuid)
	var status = config.save(Global.teams_file)
	
	if status == OK:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, "\"%s\" deleted sucessfully " % team_name)
		team_preview.queue_free()
	else:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, "Error deleting \"%s\"" % team_name)
