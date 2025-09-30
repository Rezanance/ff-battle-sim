extends Button

const uuid_util = preload('res://addons/uuid/uuid.gd')

func _on_pressed() -> void:
	Global.editing_team_uuid = uuid_util.v4()
	Global.is_new_team = true
	SceneTransition.change_scene("res://team_viewer/team_editor/team_editor.tscn")
