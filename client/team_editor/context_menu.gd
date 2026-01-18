extends PopupMenu

@onready var team_editor: TeamEditor = $'..'
@onready var fossilary_container: FossilaryContainer = $'../TextureRect/ScrollContainer/FossilaryContainer'
@onready var team_name_input: LineEdit = $'../TeamNameInput'
@onready var team_slots: TeamSlots = $'../TeamSlots'

func _on_id_pressed(context_menu_id: int) -> void:
	team_slots.hide_selectable_slots()
	if context_menu_id == 0 or context_menu_id == 1:
		team_slots.show_selectable_slots(context_menu_id)
	else:
		team_slots.remove_medal()
	team_editor.current_action = context_menu_id

func _reset_medal_btn_pos() -> void:
	team_editor.currently_selected_medal_btn.global_position = fossilary_container.medal_placeholders[team_editor.currently_selected_medal_btn.vivosaur_id].global_position
