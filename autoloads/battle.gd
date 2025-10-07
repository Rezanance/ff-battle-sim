extends Node

var battle_id: int
var player_info: Dictionary
var player_team: DataTypes.Team
var opponent_info: Dictionary
var opponent_team: DataTypes.Team

#
## delete after
#var config= ConfigFile.new()
#func _ready() -> void:
	#config.load(Global.teams_file)
	#var team_uuid = config.get_sections()[0]
	#player_team = DataTypes.Team.unserialize(team_uuid, config.get_value(team_uuid, 'team'))
	#opponent_team = DataTypes.Team.unserialize(team_uuid, config.get_value(team_uuid, 'team'))
