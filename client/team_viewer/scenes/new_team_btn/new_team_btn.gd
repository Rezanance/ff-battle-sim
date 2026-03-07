extends Button

const uuid_util = preload('res://addons/uuid/uuid.gd')

func _on_pressed() -> void:
	TeamEditing.editing_team = Team.new(uuid_util.v4())
	TeamEditing.is_new_team = true
	SceneTransition.change_scene("res://client/team_editor/team_editor.tscn")
