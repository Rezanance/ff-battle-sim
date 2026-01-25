extends TextureRect
class_name TeamSlots

signal team_modified(team: Team)

@onready var team_editor: TeamEditor = $'..'
@onready var save_btn: SaveTeamBtn = $'../SaveTeamBtn'
@onready var fossilary_container: FossilaryContainer = $'../TextureRect/ScrollContainer/FossilaryContainer'
@onready var slots: Array[AnimatedSprite2D] = [$AZ, $SZ1, $SZ2, $Extra1, $Extra2]
@onready var context_menu: ContextMenu = $'../ContextMenu'
@onready var vivosaur_summary: VivosaurSummary = $'../VivosaurSummary'

var medal_btns: Array[MedalBtn] = [null, null, null, null, null]
var team: Team

func _ready() -> void:
	initialize()

func _on_team_slot_pressed(slot: int) -> void:
	if team_editor.current_action == "Assign":
		assign_slot(slot)
	elif team_editor.current_action == "Move/Swap":
		move_swap_slots(slot)
	
func initialize() -> void:
	team = TeamEditing.editing_team
	for i: int in range(len(slots)):
		slots[i].get_node("Button").pressed.connect(_on_team_slot_pressed.bind(i))

func assign_slot(slot: int) -> void:
#	Replace old medal button with new medal button
	var duplicate_medal_btn: MedalBtn = team_editor.currently_selected_medal_btn.duplicate()
	duplicate_medal_btn.vivosaur_id = team_editor.currently_selected_medal_btn.vivosaur_id
	duplicate_medal_btn.global_position = team_editor.currently_selected_medal_btn.global_position
	duplicate_medal_btn.get_node("SelectedAnimation").visible = false
	duplicate_medal_btn.gui_input.connect(duplicate_medal_btn._on_gui_input.bind(
		team_editor.unselect_previous_medal_btn,
		team_editor.select_current_medal_btn.bind(duplicate_medal_btn, team_editor.currently_selected_medal_btn.vivosaur_id),
		context_menu.show_menu.bind(duplicate_medal_btn),
		vivosaur_summary.update_summary.bind(team_editor.currently_selected_medal_btn.vivosaur_id)
	))
	team_editor.add_child(duplicate_medal_btn)
	team_editor.currently_selected_medal_btn.queue_free()
	medal_btns[slot] = duplicate_medal_btn
	
#	Move new medal button to the selected team slot
	var tween: Tween = create_tween()
	tween.tween_property(
		duplicate_medal_btn,
		'global_position',
		slots[slot].global_position, 
		1.0
	).set_trans(Tween.TRANS_SPRING)
			
	hide_selectable_slots()
	
#	Update team
	team.slots[slot] = Constants.fossilary[team_editor.currently_selected_vivosaur_id]
	
	team_modified.emit(team)

func move_swap_slots(new_slot: int) -> void:
	var current_slot: int = medal_btns.find(team_editor.currently_selected_medal_btn)
	
#	Swap medal btn slots 
	var medal_btn_in_new_slot: MedalBtn = medal_btns[new_slot]
	medal_btns[new_slot] = medal_btns[current_slot]
	medal_btns[current_slot] = medal_btn_in_new_slot
	
	team_editor.currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
#	Swap btns in UI
	var tween: Tween = create_tween()
	tween.tween_property(
		team_editor.currently_selected_medal_btn, 
		'global_position', 
		slots[new_slot].global_position, 
		1.0
	).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel()
	if medal_btn_in_new_slot != null:
		tween.tween_property(
			medal_btn_in_new_slot, 
			'global_position', 
			slots[current_slot].global_position, 
			1.0
		).set_trans(Tween.TRANS_SPRING)
	
	hide_selectable_slots()
	
#	Swap team slots 
	var vivosaur_in_new_slot: VivosaurInfo = team.slots[new_slot]
	team.slots[new_slot] = team.slots[current_slot]
	team.slots[current_slot] = vivosaur_in_new_slot
	
#	Restore input to buttons in slots
	for slot_medal_btn: MedalBtn in medal_btns:
		if slot_medal_btn != null:
			slot_medal_btn.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP
	
	team_modified.emit(team)
	
func remove_medal() -> void:
	team_editor.currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
#	Move medal offscren
	var OFFSCREEN_POS: Vector2 = Vector2(team_editor.currently_selected_medal_btn.global_position.x + 1920, team_editor.currently_selected_medal_btn.global_position.y + 1000)
	var tween: Tween = create_tween()
	tween.tween_property(team_editor.currently_selected_medal_btn, 'global_position', OFFSCREEN_POS, 1.5)

#	Reset medal's position once its offscreen
	tween.finished.connect(team_editor.currently_selected_medal_btn._reset_position.bind(
		fossilary_container.medal_placeholders[team_editor.currently_selected_medal_btn.vivosaur_id].global_position
	))
	
#	Update variables
	var slot: int = medal_btns.find(team_editor.currently_selected_medal_btn)
	medal_btns[slot] = null
	team.slots[slot] = null 
	
	team_modified.emit(team)

func show_selectable_slots(action: String) -> void:
	match action:
		"Assign":
			for i: int in range(len(TeamEditing.editing_team.slots)):
				if TeamEditing.editing_team.slots[i] == null:
					slots[i].visible = true
			team_editor.current_action = action
		"Move/Swap":
			for i: int in range(len(slots)):
				if team_editor.currently_selected_medal_btn != medal_btns[i]:
					slots[i].visible = true
					if medal_btns[i] != null:
						medal_btns[i].mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
				else:
					slots[i].visible = false
			team_editor.current_action = action


func hide_selectable_slots() -> void:
	for i: int in range(len(slots)):
		slots[i].visible = false
	
