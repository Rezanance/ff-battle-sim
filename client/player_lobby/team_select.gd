extends OptionButton

var config: ConfigFile = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_teams_names()
	selected = 0
	
func add_teams_names() -> void:
	if OS.has_feature('dedicated_server'):
		return
	
	var status: Error = config.load("user://def.cfg")
	if status == OK:
		var id: int = 0
		for team_uuid: String in config.get_sections():
			var team_dict: Dictionary = config.get_value(team_uuid, 'team')
			var team: Team = Team.unserialize(team_uuid, team_dict)
			add_item(team.name, id)
			id += 1
