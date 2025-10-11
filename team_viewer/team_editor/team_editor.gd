extends TextureRect

var MedalFossilary = preload("res://team_viewer/team_editor/fossilary/medal_fossilary.tscn")
var MedalBtn = preload("res://team_viewer/team_editor/fossilary/medal_btn.tscn")
var SkillScene = preload("res://team_viewer/team_editor/vivosaur_summary/skill.tscn")

var vivosaurs_json = preload("res://vivosaur/vivosaurs.json").data
var skills_json = preload("res://vivosaur/skills.json").data
var effects_json = preload("res://vivosaur/effects.json").data
var statuses_json = preload("res://vivosaur/statuses.json").data

@onready var formation_slots: TextureRect = $"FormationSlots"
@onready var slot1_selectable: AnimatedSprite2D = $"FormationSlots/Slot1"
@onready var slot2_selectable: AnimatedSprite2D = $"FormationSlots/Slot2"
@onready var slot3_selectable: AnimatedSprite2D = $"FormationSlots/Slot3"
@onready var slot4_selectable: AnimatedSprite2D = $"FormationSlots/Slot4"
@onready var slot5_selectable: AnimatedSprite2D = $"FormationSlots/Slot5"
@onready var fossilary_container = $"TextureRect/ScrollContainer/Fossilary"
@onready var vivosaur_summary = $"VivosaurSummary"
@onready var context_menu: PopupMenu = $"ContextMenu"
@onready var team_name_input: LineEdit = $"TeamName"
@onready var save_btn: BaseButton = $"SaveTeam"

var currently_selected_vivosaur_id: int
var currently_selected_medal_btn: TextureButton
var current_action: int
var team: DataTypes.Team
var slots_selectable: Array[AnimatedSprite2D]
var slots_medal_btns: Array = [null, null, null, null, null]
var fossilary_medals: Dictionary[int, TextureRect] = {}
var config = ConfigFile.new()

func _ready() -> void:
	team = Global.editing_team
	config.load(Global.teams_file)
	_initialize_selectables()
	_initialize_team_UI()
	_add_fossilary_medals()
	_enable_disable_save_team_btn()

func _initialize_team_UI():
	team_name_input.text = team.name
	
func _add_fossilary_medals():
	for vivosaur_id in Global.fossilary:
		var _texture = _load_medal_texture(vivosaur_id)
		var medal_btn = _create_medal_btn(_texture, vivosaur_id)
		var medal_fossilary = _create_medal_fossilary(_texture, vivosaur_id, medal_btn)
		fossilary_medals[vivosaur_id] = medal_fossilary
		fossilary_container.add_child(medal_fossilary)
		
func _position_team_medals():
	for slot in range(len(slots_medal_btns)):
		var medal_btn = slots_medal_btns[slot]
		if medal_btn != null:
			medal_btn.global_position = slots_selectable[slot].global_position + Vector2(0, 0)

func _load_medal_texture(vivosaur_id: int):
	return load("res://vivosaur/%d/medal/%d (2).png" % [vivosaur_id, vivosaur_id])

func _create_medal_btn(_texture, vivosaur_id: int):
	var medal_btn: BaseButton = MedalBtn.instantiate()
	medal_btn.texture_normal = _texture
	medal_btn.vivosaur_id = vivosaur_id
	medal_btn.gui_input.connect(_medal_btn_clicked.bind(medal_btn, vivosaur_id))
	return medal_btn

func _create_medal_fossilary(_texture, vivosaur_id: int, medal_btn: BaseButton):
	var medal_fossilary = MedalFossilary.instantiate()
	medal_fossilary.texture = _texture
	var slot = team.slots_vivosaur_ids().find(vivosaur_id)
	if slot != -1:
		slots_medal_btns[slot] = medal_btn
		add_child(medal_btn)
	else:
		medal_fossilary.add_child(medal_btn)
	return medal_fossilary

func _medal_btn_clicked(event: InputEvent, medal_btn: BaseButton, vivosaur_id: int):
	if event is InputEventMouseButton:
		_unselect_previous_medal_btn()
		_select_current_medal_btn(medal_btn, vivosaur_id)
#		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_show_context_menu(event, medal_btn)
		show_vivosaur_summary(vivosaur_id)

func _unselect_previous_medal_btn():
	if currently_selected_medal_btn != null:
		currently_selected_medal_btn.get_node('SelectedAnimation').visible = false

func _select_current_medal_btn(medal_btn: BaseButton, vivosaur_id: int):
	medal_btn.get_node('SelectedAnimation').visible = true
	currently_selected_vivosaur_id = vivosaur_id
	currently_selected_medal_btn = medal_btn
	
func _show_context_menu(event: InputEventMouseButton, medal_btn: BaseButton):
	context_menu.clear()
	if not medal_btn in slots_medal_btns:
		context_menu.add_item('Assign', 0)
	else:
		context_menu.add_item('Move/Swap', 1)
		context_menu.add_item('Remove', 2)
	context_menu.position = event.global_position
	context_menu.visible = true

func _context_menu_item_pressed(context_menu_id: int):
	_hide_selectable_slots()
	if context_menu_id == 0 or context_menu_id == 1:
		_show_selectable_slots(context_menu_id)
	else:
		_remove_medal()
	current_action = context_menu_id
	
func _initialize_selectables():
	slots_selectable = [slot1_selectable, slot2_selectable, slot3_selectable, slot4_selectable, slot5_selectable]
	for i in range(len(slots_selectable)):
		slots_selectable[i].play()
		slots_selectable[i].get_node("Button").pressed.connect(_select_slot_handler.bind(i))
		
func _show_selectable_slots(context_menu_id: int):
	match context_menu_id:
		0:
			for i in range(len(team.slots)):
				if team.slots[i] == null:
					slots_selectable[i].visible = true
		1:
			for i in range(len(slots_selectable)):
				if currently_selected_medal_btn != slots_medal_btns[i]:
					slots_selectable[i].visible = true
#					Temporarily ignore input from buttons
					if slots_medal_btns[i] != null:
						slots_medal_btns[i].mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
				else:
					slots_selectable[i].visible = false
	
func _hide_selectable_slots():
	for i in range(len(slots_selectable)):
		slots_selectable[i].visible = false
	
func _select_slot_handler(slot: int):
	if current_action == 0:
		_assign_slot(slot)
	elif current_action == 1:
		_move_swap_slots(slot)
		
func _assign_slot(slot: int):
	var duplicate_medal_btn = currently_selected_medal_btn.duplicate()
	duplicate_medal_btn.vivosaur_id = currently_selected_medal_btn.vivosaur_id
	duplicate_medal_btn.global_position = currently_selected_medal_btn.global_position
	duplicate_medal_btn.gui_input.connect(_medal_btn_clicked.bind(duplicate_medal_btn, currently_selected_vivosaur_id))
	add_child(duplicate_medal_btn)
	currently_selected_medal_btn.queue_free()
	
	var tween = create_tween()
	tween.tween_property(duplicate_medal_btn,
			'global_position',
			slots_selectable[slot].global_position + Vector2(0, 0), 1.0).set_trans(Tween.TRANS_SPRING)
			
	_hide_selectable_slots()
	
	team.slots[slot] = Global.fossilary[currently_selected_vivosaur_id]
	
	slots_medal_btns[slot] = duplicate_medal_btn
	
	duplicate_medal_btn.get_node("SelectedAnimation").visible = false
	
	_enable_disable_save_team_btn()

func _move_swap_slots(new_slot: int):
	var current_slot = slots_medal_btns.find(currently_selected_medal_btn)
	
#	Swap medal btn slots 
	var medal_btn_in_new_slot = slots_medal_btns[new_slot]
	slots_medal_btns[new_slot] = slots_medal_btns[current_slot]
	slots_medal_btns[current_slot] = medal_btn_in_new_slot
	
	currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
#	Swap btns in UI
	var tween = create_tween()
	tween.tween_property(currently_selected_medal_btn, 'global_position', slots_selectable[new_slot].global_position + Vector2(0, 0), 1.0).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel()
	if medal_btn_in_new_slot != null:
		tween.tween_property(medal_btn_in_new_slot, 'global_position', slots_selectable[current_slot].global_position + Vector2(0, 0), 1.0).set_trans(Tween.TRANS_SPRING)
	
	_hide_selectable_slots()
	
#	Swap team slots 
	var vivosaur_in_new_slot = team.slots[new_slot]
	team.slots[new_slot] = team.slots[current_slot]
	team.slots[current_slot] = vivosaur_in_new_slot
	
#	Restore input to buttons in slots
	for slot_medal_btn in slots_medal_btns:
		if slot_medal_btn != null:
			slot_medal_btn.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	
	
	_enable_disable_save_team_btn()

func _remove_medal():
	var OFFSCREEN_POS = Vector2(currently_selected_medal_btn.global_position.x + 1920, currently_selected_medal_btn.global_position.y + 1000)
	
	currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
	var tween = create_tween()
	tween.tween_property(currently_selected_medal_btn, 'global_position', OFFSCREEN_POS, 1.5)
	tween.finished.connect(_reset_medal_btn_pos)
	
	var slot = slots_medal_btns.find(currently_selected_medal_btn)
	slots_medal_btns[slot] = null
	team.slots[slot] = null
	
	_enable_disable_save_team_btn()
	
func _reset_medal_btn_pos():
	currently_selected_medal_btn.global_position = fossilary_medals[currently_selected_medal_btn.vivosaur_id].global_position

func show_vivosaur_summary(vivosaur_id: int):
	VivosaurSummary.show_vivosaur_summary(vivosaur_summary, vivosaur_id)
		
func _enable_disable_save_team_btn():
	save_btn.disabled = team_name_input.text.strip_edges() == '' or not team.is_valid()


func _on_save_team_pressed() -> void:
	team.name = team_name_input.text
	
	config.set_value(Global.editing_team.uuid, 'team', team.serialize())
	
	var status = config.save(Global.teams_file)
	
	if status == OK:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.SUCCESS, 'Team Saved')
	else:
		DialogPopup.reveal_dialog(DialogPopup.MessageType.ERROR, 'Error saving team (error_code=%d)' % status)


func _on_team_name_text_changed(new_text: String) -> void:
	save_btn.disabled = new_text.strip_edges() == '' or not team.is_valid()
