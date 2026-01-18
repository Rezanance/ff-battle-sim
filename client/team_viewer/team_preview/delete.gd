extends Button

	
func _delete_team(team_uuid: String, team_name: String, team_preview: Node, config: ConfigFile):
	config.erase_section(team_uuid)
	var status = config.save(Constants.teams_file)
	
	if status == OK:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, "\"%s\" deleted sucessfully " % team_name)
		team_preview.queue_free()
	else:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, "Error deleting \"%s\"" % team_name)
