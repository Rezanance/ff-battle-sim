extends Node

var teams_file = "user://teams.save"

const TeamPreviewScene = preload("res://team_viewer/team_preview/team_preview.tscn")
const NewTeamBtn = preload("res://team_viewer/new_team_btn.tscn")

func _ready() -> void:
	var config = ConfigFile.new()
	
	var status = config.load(teams_file)
	
	if status == OK :
		for team in config.get_sections():
			var team_preview = TeamPreviewScene.instantiate()
			team_preview.team = config.get_value(team, 'team')
			add_child(team_preview)
			
	_add_new_team_btn()
	
	
func _add_new_team_btn():
	add_child(NewTeamBtn.instantiate()) 
