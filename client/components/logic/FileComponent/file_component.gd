extends Node
class_name FileComponent

enum File {TEAMS, PREFERENCES}
const files : Dictionary[File, String]= {
	File.TEAMS: 'user://teams.cfg',
	File.PREFERENCES: 'user://preferences.cfg',
}

signal file_saved(status: Error)

@export var file: File = File.TEAMS
@onready var file_path: String = files[file]
var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	config.load(file_path)

func save(section: String, key: String, value: Variant ) -> Error:
	config.set_value(section, key, value)
	var status: Error = config.save(file_path)
	file_saved.emit(status)
	return status
	
func delete(section: String) -> Error:
	config.erase_section(section)
	return config.save(file_path)
	
func read_all() -> PackedStringArray:
	return config.get_sections()

func read(section: String, key: String) -> Dictionary:
	return config.get_value(section, key)
