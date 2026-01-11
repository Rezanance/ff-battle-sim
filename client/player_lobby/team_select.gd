extends OptionButton

var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_teams_names()
	selected = 0
	
func add_teams_names():
	if OS.has_feature('dedicated_server'):
		return
	
	var status = config.load(Constants.teams_file)
	if status == OK:
		var id = 0
		for team_uuid in config.get_sections():
			var team_dict = config.get_value(team_uuid, 'team')
			var team: Team = Team.unserialize(team_uuid, team_dict)
			add_item(team.name, id)
			id += 1
