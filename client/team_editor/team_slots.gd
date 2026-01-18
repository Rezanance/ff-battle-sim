extends TextureRect
class_name TeamSlots

signal team_slots_loaded()
signal team_modified()

@onready var team_editor: TeamEditor = $'..'
@onready var save_btn: SaveTeamBtn = $'../SaveTeamBtn'
@onready var fossilary_container: FossilaryContainer = $'../TextureRect/ScrollContainer/FossilaryContainer'
@onready var slots: Array[AnimatedSprite2D] = [$AZ, $SZ1, $SZ2, $Extra1, $Extra2]

var medal_btns: Array[MedalBtn] = [null, null, null, null, null]
var team: Team

func _ready() -> void:
	team = TeamEditing.editing_team
	initialize()
	save_btn._on_team_modified()
	team_slots_loaded.emit()

func _on_team_slot_pressed(slot: int) -> void:
	if team_editor.current_action == 0:
		assign_slot(slot)
	elif team_editor.current_action == 1:
		move_swap_slots(slot)
	
func initialize() -> void:
	for i: int in range(len(slots)):
		slots[i].get_node("Button").pressed.connect(_on_team_slot_pressed.bind(i))

func assign_slot(slot: int) -> void:
	var duplicate_medal_btn: MedalBtn = team_editor.currently_selected_medal_btn.duplicate()
	duplicate_medal_btn.vivosaur_id = team_editor.currently_selected_medal_btn.vivosaur_id
	duplicate_medal_btn.global_position = team_editor.currently_selected_medal_btn.global_position
	duplicate_medal_btn.gui_input.connect(duplicate_medal_btn._on_gui_input.bind(
		team_editor.unselect_previous_medal_btn,
		team_editor.select_current_medal_btn.bind(duplicate_medal_btn, team_editor.currently_selected_medal_btn.vivosaur_id),
		team_editor.show_context_menu.bind(duplicate_medal_btn),
		team_editor.show_vivosaur_summary.bind(team_editor.currently_selected_medal_btn.vivosaur_id)
	))
	team_editor.add_child(duplicate_medal_btn)
	team_editor.currently_selected_medal_btn.queue_free()
	
	var tween: Tween = create_tween()
	tween.tween_property(
		duplicate_medal_btn,
		'global_position',
		slots[slot].global_position + Vector2(0, 0), 
		1.0
	).set_trans(Tween.TRANS_SPRING)
			
	hide_selectable_slots()
	
	team.slots[slot] = Constants.fossilary[team_editor.currently_selected_vivosaur_id]
	
	medal_btns[slot] = duplicate_medal_btn
	
	duplicate_medal_btn.get_node("SelectedAnimation").visible = false
	
	team_modified.emit()

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
		slots[new_slot].global_position + Vector2(0, 0), 
		1.0
	).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel()
	if medal_btn_in_new_slot != null:
		tween.tween_property(
			medal_btn_in_new_slot, 
			'global_position', 
			slots[current_slot].global_position + Vector2(0, 0), 
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
	
	team_modified.emit()
	
func remove_medal() -> void:
	var OFFSCREEN_POS: Vector2 = Vector2(team_editor.currently_selected_medal_btn.global_position.x + 1920, team_editor.currently_selected_medal_btn.global_position.y + 1000)
	
	team_editor.currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
	var tween: Tween = create_tween()
	tween.tween_property(team_editor.currently_selected_medal_btn, 'global_position', OFFSCREEN_POS, 1.5)
	tween.finished.connect(team_editor.currently_selected_medal_btn._reset_position.bind(
		fossilary_container.medal_placeholders[team_editor.currently_selected_medal_btn.vivosaur_id].global_position
	))
	
	var slot: int = medal_btns.find(team_editor.currently_selected_medal_btn)
	medal_btns[slot] = null
	team.slots[slot] = null 
	
	team_modified.emit()

func show_selectable_slots(context_menu_id: int) -> void:
	match context_menu_id:
		0:
			for i: int in range(len(TeamEditing.editing_team.slots)):
				if TeamEditing.editing_team.slots[i] == null:
					slots[i].visible = true
		1:
			for i: int in range(len(slots)):
				if team_editor.currently_selected_medal_btn != medal_btns[i]:
					slots[i].visible = true
					if medal_btns[i] != null:
						medal_btns[i].mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
				else:
					slots[i].visible = false

func hide_selectable_slots() -> void:
	for i: int in range(len(slots)):
		slots[i].visible = false
	
