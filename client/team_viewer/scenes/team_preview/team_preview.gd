class_name TeamPreview extends VBoxContainer

func _on_gui_input(event: InputEvent, team: Team) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			TeamEditing.editing_team = team
			TeamEditing.is_new_team = false
			SceneTransition.change_scene("res://client/team_editor/team_editor.tscn")
