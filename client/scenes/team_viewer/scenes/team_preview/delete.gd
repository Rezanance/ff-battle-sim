extends Button
class_name Delete

@export var teams_file_component: FileComponent

func _on_pressed(team_uuid: String, team_preview: Node) -> void:
	var status: Error = teams_file_component.delete(team_uuid)
	
	if status == OK:
		#FIXME
		#StatusNotification.push(StatusNotification.MessageType.SUCCESS, "\"%s\" deleted sucessfully " % team_name)
		team_preview.queue_free()
	else:
		#FIXME
		#StatusNotification.push(StatusNotification.MessageType.ERROR, "Error deleting \"%s\"" % team_name)
		pass
