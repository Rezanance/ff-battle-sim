extends LineEdit

@onready var save_btn: SaveTeamBtn = $'../SaveTeamBtn'

func _ready() -> void:
	text = TeamEditing.editing_team.name
