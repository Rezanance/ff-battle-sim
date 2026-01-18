extends LineEdit

@onready var save_btn: SaveTeamBtn = $'../SaveTeamBtn'

func _ready() -> void:
	text = TeamEditing.editing_team.name

func _on_text_changed(_new_text: String) -> void:
	save_btn._on_team_modified()
