extends TextureRect

var MedalBtn = preload("res://team_viewer/team_editor/fossilary/medal_btn.tscn")

@onready var formation_slots: TextureRect = $"PlayerFormation/FormationSlots"
@onready var formation_toggle: TextureButton = $PlayerFormation/FormationToggle

@onready var player_slot1_selectable: AnimatedSprite2D = $"PlayerFormation/FormationSlots/Slot1"
@onready var player_slot2_selectable: AnimatedSprite2D = $"PlayerFormation/FormationSlots/Slot2"
@onready var player_slot3_selectable: AnimatedSprite2D = $"PlayerFormation/FormationSlots/Slot3"
@onready var player_slot4_selectable: AnimatedSprite2D = $"PlayerFormation/FormationSlots/Slot4"
@onready var player_slot5_selectable: AnimatedSprite2D = $"PlayerFormation/FormationSlots/Slot5"

@onready var opponent_slot1: TextureButton = $OpponentFormation/Slot1
@onready var opponent_slot2: TextureButton = $OpponentFormation/Slot2
@onready var opponent_slot3: TextureButton = $OpponentFormation/Slot3
@onready var opponent_slot4: TextureButton = $OpponentFormation/Slot4
@onready var opponent_slot5: TextureButton = $OpponentFormation/Slot5

@onready var context_menu: PopupMenu = $"ContextMenu"
@onready var vivosaur_summary = $VivosaurSummary

@onready var player_icon: TextureRect = $TextureRect/PlayerIcon
@onready var player_name: Label = $TextureRect/PlayerName
@onready var opp_icon: TextureRect = $TextureRect2/OppIcon
@onready var opp_name: Label = $TextureRect2/OppName

var currently_selected_medal_btn: TextureButton
var selectable_slots: Array[AnimatedSprite2D] 
var opponent_slots: Array[TextureButton] 
var slots_medal_btns: Array = [null, null, null, null, null] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_UI()
	initialize_player_slots()
	add_player_team_medals()
	initialize_opponent_slots()
	add_opponent_team_medals()

func initialize_UI():
	var icon_path = 'res://common_assets/player-icons'
	var icon_files = ResourceLoader.list_directory(icon_path)
	player_icon.texture = load(icon_path + '/' + icon_files[Battle.player_info['icon_id']])
	opp_icon.texture = load(icon_path + '/' + icon_files[Battle.opponent_info['icon_id']])
	player_name.text = Battle.player_info['display_name']
	opp_name.text = Battle.opponent_info['display_name']

func _on_formation_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Battle.player_team.formation = DataTypes.Formation.TRIASSIC
		formation_slots.texture = load("res://common_assets/formation/triassic_slots.png")
	else:
		Battle.player_team.formation = DataTypes.Formation.JURASSIC 
		formation_slots.texture = load("res://common_assets/formation/jurassic_slots.png")
		
func initialize_player_slots():
	selectable_slots = [player_slot1_selectable, player_slot2_selectable, player_slot3_selectable, player_slot4_selectable, player_slot5_selectable]
	for i in range(len(selectable_slots)):
		selectable_slots[i].play()
		selectable_slots[i].get_node("Button").pressed.connect(move_swap_slots.bind(i))

func initialize_opponent_slots():
	opponent_slots = [opponent_slot1, opponent_slot2, opponent_slot3, opponent_slot4, opponent_slot5]

func add_player_team_medals():
	add_medals(true)
	
func add_opponent_team_medals():
	add_medals(false)

func add_medals(is_player_team: bool):
	var slots = Battle.player_team.slots if is_player_team else Battle.opponent_team.slots
	for slot: int in range(len(slots)):
		var vivosaur = slots[slot]
		if vivosaur != null:
			var fossilary_id = vivosaur.get_fossilary_id()
			var _texture = load_medal_texture(fossilary_id)
			var medal_btn = create_medal_btn(_texture, fossilary_id, is_player_team)
			if is_player_team:
				slots_medal_btns[slot] = medal_btn
				medal_btn.global_position = selectable_slots[slot].global_position + Vector2(50, -2)
			else:
				medal_btn.global_position = opponent_slots[slot].global_position + Vector2(0, 2)
			add_child(medal_btn)

func load_medal_texture(fossilary_id):
	var id = fossilary_id.split('_')[0]
	var super_revival = fossilary_id.split('_')[1]
	return load("res://vivosaur/%s/medals/%s (%d).png" % [id, id, int(super_revival) * 2 + 2])

func create_medal_btn(_texture, fossilary_id: String, is_player_team: bool):
	var medal_btn: BaseButton = MedalBtn.instantiate()
	medal_btn.texture_normal = _texture
	medal_btn.fossilary_id = fossilary_id
	medal_btn.gui_input.connect(medal_btn_clicked.bind(medal_btn, fossilary_id, is_player_team))
	return medal_btn

func move_swap_slots(new_slot: int):
	var current_slot = slots_medal_btns.find(currently_selected_medal_btn)
	
#	Swap medal btn slots 
	var medal_btn_in_new_slot = slots_medal_btns[new_slot]
	slots_medal_btns[new_slot] = slots_medal_btns[current_slot]
	slots_medal_btns[current_slot] = medal_btn_in_new_slot
	
	currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
			
#	Swap btns in UI
	var tween = create_tween()
	tween.tween_property(currently_selected_medal_btn, 'global_position', selectable_slots[new_slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel()
	if medal_btn_in_new_slot != null:
		tween.tween_property(medal_btn_in_new_slot, 'global_position', selectable_slots[current_slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
	
	hide_selectable_slots()
	
#	Swap team slots 
	var vivosaur_in_new_slot = Battle.player_team.slots[new_slot]
	Battle.player_team.slots[new_slot] = Battle.player_team.slots[current_slot]
	Battle.player_team.slots[current_slot] = vivosaur_in_new_slot
	
#	Restore input to buttons
	for slot_medal_btn in slots_medal_btns:
		if slot_medal_btn != null:
			slot_medal_btn.mouse_filter = MouseFilter.MOUSE_FILTER_STOP

func show_selectable_slots():
	for i in range(len(selectable_slots)):
		if currently_selected_medal_btn != slots_medal_btns[i]:
			selectable_slots[i].visible = true
#			Temporarily ignore input from buttons
			if slots_medal_btns[i] != null:
				slots_medal_btns[i].mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
		else:
			selectable_slots[i].visible = false

func hide_selectable_slots():
	for i in range(len(selectable_slots)):
		selectable_slots[i].visible = false
		
func show_context_menu(event: InputEventMouseButton):
	context_menu.clear()
	context_menu.add_item('Move/Swap')
	context_menu.position = event.global_position
	context_menu.visible = true

func context_menu_item_pressed(_context_menu_id: int):
	hide_selectable_slots()
	show_selectable_slots()
	
func medal_btn_clicked(event: InputEvent, medal_btn: BaseButton, fossilary_id: String, is_player_team: bool):
	if event is InputEventMouseButton:
		unselect_previous_medal_btn()
		select_current_medal_btn(medal_btn)

		if is_player_team and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			show_context_menu(event)
		VivosaurSummary.show_vivosaur_summary(vivosaur_summary, fossilary_id)

func select_current_medal_btn(medal_btn: BaseButton):
	medal_btn.get_node('SelectedAnimation').visible = true
	currently_selected_medal_btn = medal_btn

func unselect_previous_medal_btn():
	if currently_selected_medal_btn != null:
		currently_selected_medal_btn.get_node('SelectedAnimation').visible = false
