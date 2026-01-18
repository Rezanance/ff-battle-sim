extends Node
class_name TeamEditor

@onready var context_menu: PopupMenu = $ContextMenu
@onready var vivosaur_summary: VivosaurSummary = $VivosaurSummary
@onready var save_btn: SaveTeamBtn = $SaveTeamBtn
@onready var team_slots: TeamSlots = $TeamSlots

var currently_selected_medal_btn: MedalBtn
var currently_selected_vivosaur_id: int
var current_action: int

func unselect_previous_medal_btn() -> void:
	if currently_selected_medal_btn != null:
		currently_selected_medal_btn.get_node('SelectedAnimation').visible = false

func select_current_medal_btn(medal_btn: MedalBtn, vivosaur_id: int) -> void:
	medal_btn.get_node('SelectedAnimation').visible = true
	currently_selected_vivosaur_id = vivosaur_id
	currently_selected_medal_btn = medal_btn

func show_context_menu(mouse_position: Vector2, medal_btn: MedalBtn) -> void:
	context_menu.clear()
	if not medal_btn in team_slots.medal_btns:
		context_menu.add_item('Assign', 0)
	else:
		context_menu.add_item('Move/Swap', 1)
		context_menu.add_item('Remove', 2)
	context_menu.position = mouse_position
	context_menu.visible = true

func show_vivosaur_summary(vivosaur_id: int) -> void:
	vivosaur_summary.update_summary(vivosaur_id)
