extends Node

const TeamPreviewScene = preload("res://team_viewer/team_preview/team_preview.tscn")
const NewTeamBtn = preload("res://team_viewer/new_team_btn.tscn")

func _ready() -> void:
	var config = ConfigFile.new()
	
	var status = config.load(Global.teams_file)
	
	if status == OK :
		for teamUUID in config.get_sections():
			var team_preview = TeamPreviewScene.instantiate()
			var team = config.get_value(teamUUID, 'team')
			pass
			
	_add_new_team_btn()
	
	
func _add_new_team_btn():
	add_child(NewTeamBtn.instantiate()) 
