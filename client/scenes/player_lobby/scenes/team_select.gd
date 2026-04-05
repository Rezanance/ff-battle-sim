extends OptionButton

@export var file_component: FileComponent

func _ready() -> void:
	if OS.has_feature('dedicated_server'):
		return
		
	add_teams_names()
	selected = 0
	
func add_teams_names() -> void:
	var id: int = 0
	for team_uuid: String in file_component.read_all():
		var team_dict: Dictionary = file_component.read(team_uuid, 'team')
		var team: Team = Team.deserialize(team_uuid, team_dict)
		add_item(team.name, id)
		id += 1
