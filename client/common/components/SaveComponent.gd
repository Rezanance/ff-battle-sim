extends Node
class_name SaveComponent
"""
Persist data to file
"""
@export_file var file: String

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	config.load(file)

func save(section: String, key: String, value: Variant ) -> Error:
	config.set_value(section, key, value)
	return config.save(file)
	
