extends Node

const TeamPreviewScene: Resource = preload("res://client/team_viewer/team_preview/team_preview.tscn")
const NewTeamBtn: Resource = preload("res://client/team_viewer/new_team_btn.tscn")

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	
	var status: Error = config.load(Constants.teams_file)
	
	if status == OK :
		for team_uuid: String in config.get_sections():
			var team_preview: TeamPreview = TeamPreviewScene.instantiate()
			var team_dict: Dictionary = config.get_value(team_uuid, 'team')
			var team: Team = Team.unserialize(team_uuid, team_dict)
			team_preview.get_node("TeamNameBackground/TeamName").text = team.name
			
			var medal_container: Node = team_preview.get_node("FormationBackground/MedalContainer")
			
			for i: int in range(Team.TEAM_SLOTS):
				var vivosaur_slot: VivosaurInfo = team.slots[i]
				if vivosaur_slot != null:
					medal_container.get_child(i).texture = load("res://client/assets/vivosaurs/%s/medal/%s (2).png" % [vivosaur_slot.id, vivosaur_slot.id])
			
			var delete_btn: Delete = team_preview.get_node("Delete")
			delete_btn.pressed.connect(delete_btn._on_pressed.bind(team_uuid, team.name, team_preview, config))
			team_preview.gui_input.connect(team_preview._on_gui_input.bind(team))
			add_child(team_preview)
			
	add_new_team_btn()
	
func add_new_team_btn() -> void:
	add_child(NewTeamBtn.instantiate()) 
