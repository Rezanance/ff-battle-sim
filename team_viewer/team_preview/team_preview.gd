extends VBoxContainer

var team: DataTypes.Team
	
func _on_gui_input(event: InputEvent, team_id: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Global.editing_team_id = team_id
			SceneTransition.change_scene("res://team_viewer/team_editor/team_editor.tscn")
