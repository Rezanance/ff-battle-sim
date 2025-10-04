extends TextureRect

var MedalFossilary = preload("res://team_viewer/team_editor/fossilary/medal_fossilary.tscn")
var MedalBtn = preload("res://team_viewer/team_editor/fossilary/medal_btn.tscn")
var SkillScene = preload("res://team_viewer/team_editor/vivosaur_summary/skill.tscn")

var vivosaurs_json = preload("res://vivosaur/vivosaurs.json").data
var skills_json = preload("res://vivosaur/skills.json").data
var effects_json = preload("res://vivosaur/effects.json").data
var statuses_json = preload("res://vivosaur/statuses.json").data

@onready var formation_slots: TextureRect = $"HBoxContainer/FormationSlots"
@onready var formation_toggle: TextureButton = $"HBoxContainer/FormationToggle"
@onready var slot1_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot1"
@onready var slot2_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot2"
@onready var slot3_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot3"
@onready var slot4_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot4"
@onready var slot5_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot5"
@onready var fossilary_container = $"TextureRect/ScrollContainer/Fossilary"
@onready var vivosaur_summary = $"VivosaurSummary"
@onready var context_menu: PopupMenu = $"ContextMenu"
@onready var team_name_input: LineEdit = $"TeamName"
@onready var save_btn: BaseButton = $"SaveTeam"

var currently_selected_fossilary_id: String
var currently_selected_medal_btn: TextureButton
var current_action: int
var team: DataTypes.Team
var slots_selectable: Array[AnimatedSprite2D] 
var slots_medal_btns: Array = [null, null, null, null, null]
var fossilary_medals: Dictionary[String, TextureRect] = {}
var config = ConfigFile.new()

func _ready() -> void:
	team = Global.editing_team
	config.load(Global.teams_file)
	_initialize_selectables()
	_initialize_team_UI()
	_add_fossilary_medals()
	_enable_disable_save_team_btn()

func _initialize_team_UI():
	formation_toggle.button_pressed = team.formation == DataTypes.Formation.TRIASSIC
	team_name_input.text = team.name
	
func _add_fossilary_medals():
	for fossilary_id in Global.fossilary:
		var _texture = _load_medal_texture(fossilary_id)
		var medal_btn = _create_medal_btn(_texture, fossilary_id)
		var medal_fossilary = _create_medal_fossilary(_texture, fossilary_id, medal_btn )
		fossilary_medals[fossilary_id] = medal_fossilary
		fossilary_container.add_child(medal_fossilary)
		
func _position_team_medals():
	for slot in range(len(slots_medal_btns)):
		var medal_btn = slots_medal_btns[slot]
		if medal_btn != null:
			medal_btn.global_position = slots_selectable[slot].global_position + Vector2(0, -2)

func _load_medal_texture(fossilary_id):
	var id = fossilary_id.split('_')[0]
	var super_revival = fossilary_id.split('_')[1]
	return load("res://vivosaur/%s/medals/%s (%d).png" % [id, id, int(super_revival) * 2 + 2])

func _create_medal_btn(_texture, fossilary_id: String):
	var medal_btn: BaseButton = MedalBtn.instantiate()
	medal_btn.texture_normal = _texture
	medal_btn.fossilary_id = fossilary_id
	medal_btn.gui_input.connect(_medal_btn_clicked.bind(medal_btn, fossilary_id))
	return medal_btn

func _create_medal_fossilary(_texture, fossilary_id: String, medal_btn: BaseButton):
	var medal_fossilary = MedalFossilary.instantiate()
	medal_fossilary.texture = _texture
	var slot = team.slots_fossilary_ids().find(fossilary_id)
	if  slot != -1:
		slots_medal_btns[slot] = medal_btn 
		add_child(medal_btn)
	else:
		medal_fossilary.add_child(medal_btn)
	return medal_fossilary

func _medal_btn_clicked(event: InputEvent, medal_btn: BaseButton, fossilary_id: String):
	if event is InputEventMouseButton:
		_unselect_previous_medal_btn()
		_select_current_medal_btn(medal_btn, fossilary_id)
#		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_show_context_menu(event, medal_btn)
		show_vivosaur_summary(fossilary_id)

func _unselect_previous_medal_btn():
	if currently_selected_medal_btn != null:
		currently_selected_medal_btn.get_node('SelectedAnimation').visible = false

func _select_current_medal_btn(medal_btn: BaseButton, fossilary_id: String):
	medal_btn.get_node('SelectedAnimation').visible = true
	currently_selected_fossilary_id = fossilary_id
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
	duplicate_medal_btn.fossilary_id = currently_selected_medal_btn.fossilary_id
	duplicate_medal_btn.global_position = currently_selected_medal_btn.global_position
	duplicate_medal_btn.gui_input.connect(_medal_btn_clicked.bind(duplicate_medal_btn, currently_selected_fossilary_id))
	add_child(duplicate_medal_btn)
	currently_selected_medal_btn.queue_free()
	
	var tween = create_tween()
	tween.tween_property(duplicate_medal_btn, 
			'global_position', 
			slots_selectable[slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
			
	_hide_selectable_slots()
	
	team.slots[slot] = Global.fossilary[currently_selected_fossilary_id]
	
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
	tween.tween_property(currently_selected_medal_btn, 'global_position', slots_selectable[new_slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel()
	if medal_btn_in_new_slot != null:
		tween.tween_property(medal_btn_in_new_slot, 'global_position', slots_selectable[current_slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
	
	_hide_selectable_slots()
	
#	Swap team slots 
	var vivosaur_in_new_slot = team.slots[new_slot]
	team.slots[new_slot] = team.slots[current_slot]
	team.slots[current_slot] = vivosaur_in_new_slot
	
#	Temporarily ignore inpit from medal btns in slots
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
	currently_selected_medal_btn.global_position = fossilary_medals[currently_selected_medal_btn.fossilary_id].global_position

func show_vivosaur_summary(fossilary_id: String):
	_show_vivosaur_summary_main(vivosaur_summary, fossilary_id)
	
func _show_vivosaur_summary_main(vivosaur_summary_node, fossilary_id: String):
	var vivosaur_summary_element = vivosaur_summary_node.get_node('ScrollContainer/VBoxContainer/HBoxContainer2/Element')
	var vivosaur_summary_name = vivosaur_summary_node.get_node('ScrollContainer/VBoxContainer/HBoxContainer2/Name')
	var vivosaur_summary_range = vivosaur_summary_node.get_node('ScrollContainer/VBoxContainer/Range')
	var vivosaur_summary_lp = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer/LpValue")
	var vivosaur_summary_atk = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer2/AtkValue")
	var vivosaur_summary_def = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer3/DefValue")
	var vivosaur_summary_acc = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer4/AccValue")
	var vivosaur_summary_eva = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer5/EvaValue")
	var vivosaur_summary_crit = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/CritValue")
	var vivosaur_summary_se_az = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/AZ")
	var vivosaur_summary_se_atk = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer2/AtkValue")
	var vivosaur_summary_se_def = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer3/DefValue")
	var vivosaur_summary_se_acc = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer4/AccValue")
	var vivosaur_summary_se_eva = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer5/EvaValue")
	var vivosaur_summary_immunities = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/HBoxContainer/StatusImmunities")
	var vivosaur_summary_groups = vivosaur_summary.get_node("ScrollContainer/VBoxContainer/HBoxContainer/TeamSkillGroups")
	var vivosaur_summary_skills_container: VBoxContainer = vivosaur_summary.get_node("ScrollContainer/VBoxContainer/SkillsContainer")
	
	vivosaur_summary.visible = true
	var vivosaur: DataTypes.Vivosaur = Global.fossilary[fossilary_id]
	vivosaur_summary_element.texture = load("res://common_assets/elements/%d.webp" % vivosaur.element)
	vivosaur_summary_name.text = "%s %s" % [vivosaur.name, get_super_revival_str(vivosaur.super_revival)]
	vivosaur_summary_range.text = DataTypes.RANGES_STR[vivosaur.attack_range]
	
	vivosaur_summary_lp.text = "%d + %d" % [vivosaur.stats.life_points - DataTypes.SUPER_REVIVAL_LP_MODIFIER, DataTypes.SUPER_REVIVAL_LP_MODIFIER] if vivosaur.super_revival != DataTypes.SuperRevival.BASE else "%d" % vivosaur.stats.life_points
	vivosaur_summary_atk.text = "%d + %d" % [vivosaur.stats.attack - DataTypes.ARMS_ATK_MODIFIER, DataTypes.ARMS_ATK_MODIFIER] if vivosaur.super_revival == DataTypes.SuperRevival.ARMS else "%d" % vivosaur.stats.attack
	vivosaur_summary_def.text = "%d + %d" % [vivosaur.stats.defense - DataTypes.BODY_DEF_MODIFIER, DataTypes.BODY_DEF_MODIFIER] if vivosaur.super_revival == DataTypes.SuperRevival.BODY else "%d" % vivosaur.stats.defense
	vivosaur_summary_acc.text = "%d + %d" % [vivosaur.stats.accuracy - DataTypes.HEAD_ACC_MODIFIER, DataTypes.HEAD_ACC_MODIFIER] if vivosaur.super_revival == DataTypes.SuperRevival.HEAD else "%d" % vivosaur.stats.accuracy
	vivosaur_summary_eva.text = "%d + %d" % [vivosaur.stats.evasion - DataTypes.LEGS_EVA_MODIFIER, DataTypes.LEGS_EVA_MODIFIER] if vivosaur.super_revival == DataTypes.SuperRevival.LEGS else "%d" % vivosaur.stats.evasion
	vivosaur_summary_crit.text = "Crit Chance: %d" % [vivosaur.stats.crit_chance * 100] + "%"
	
	vivosaur_summary_se_az.text = "Own AZ" if vivosaur.support_effects.own_az else "Enemy AZ"
	
	display_support_effect(vivosaur_summary_se_atk, vivosaur.support_effects.attack_modifier)
	display_support_effect(vivosaur_summary_se_def, vivosaur.support_effects.defense_modifier)
	display_support_effect(vivosaur_summary_se_acc, vivosaur.support_effects.attack_modifier)
	display_support_effect(vivosaur_summary_se_eva, vivosaur.support_effects.attack_modifier)
	
	var status_immunites_begin = "Status Immunities: " 
	vivosaur_summary_immunities.text =  status_immunites_begin + "%s" % ", ".join(
		vivosaur.status_immunities.map(func(status): return status.name)) if len(vivosaur.status_immunities) > 0 else status_immunites_begin + "None"
	
	vivosaur_summary_groups.text = "Team Skill Groups: " + ", ".join(vivosaur.team_skill_groups)
	
	for old_skill in vivosaur_summary_skills_container.get_children():
		old_skill.queue_free()
	
	for skill in vivosaur.skills:
		var skill_node: Panel = SkillScene.instantiate()

		var style_box_flat: StyleBoxFlat = skill_node.theme.get_stylebox('panel', 'Panel').duplicate()
		
		if skill.skill_type == DataTypes.SkillType.DAMAGE or skill.skill_type == DataTypes.SkillType.NEUTRAL:
			style_box_flat.bg_color = Color.hex(0xe67538ff)
		elif skill.skill_type == DataTypes.SkillType.HEAL or skill.skill_type == DataTypes.SkillType.ENHANCEMENT:
			style_box_flat.bg_color = Color.hex(0x4ab444ff)
		elif skill.skill_type == DataTypes.SkillType.TEAM_SKILL:
			style_box_flat.bg_color = Color.hex(0xcb3031ff)
		else:
			style_box_flat.bg_color = Color.hex(0x0eade1ff)
		skill_node.add_theme_stylebox_override('panel', style_box_flat)
		
		var skill_name = skill_node.get_node("HBoxContainer/VBoxContainer/Name")
		skill_name.text = skill.name
		
		var skill_dmg = skill_node.get_node("HBoxContainer/VBoxContainer/HBoxContainer/Damage")
		skill_dmg.text = "Dmg: %d" % skill.damage 
		
		var skill_fp = skill_node.get_node("HBoxContainer/VBoxContainer/HBoxContainer/FpCost")
		skill_fp.text = "%d FP" %  skill.fp_cost
		
		var skill_counterable = skill_node.get_node("HBoxContainer/VBoxContainer/Counterable")
		skill_counterable.text = "Counterable: yes" if skill.counterable else "Counterable: no"
		
		var skill_effect = skill_node.get_node("HBoxContainer/Description")
		skill_effect.text = skill.description
			
		vivosaur_summary_skills_container.add_child(skill_node)
	
func display_support_effect(se_label, modifier):
	if modifier > 0:
		se_label.text = "+%d" % [modifier * 100] + "%"
	elif modifier < 0:
		se_label.text = "%d" % [modifier * 100] + "%"
	else:
		se_label.text = "--"

func get_super_revival_str(super_revial: DataTypes.SuperRevival) -> String:
	match super_revial:
		DataTypes.SuperRevival.HEAD:
			return "(Silver Head)"
		DataTypes.SuperRevival.BODY:
			return "(Silver Body)"
		DataTypes.SuperRevival.ARMS:
			return "(Silver Arms)"
		DataTypes.SuperRevival.LEGS:
			return "(Silver Legs)"
		_:
			return ''
		
func _on_formation_toggled(toggled_on: bool) -> void:
	if toggled_on:
		team.formation = DataTypes.Formation.TRIASSIC
		formation_slots.texture = load("res://common_assets/formation/triassic_slots.png")
	else:
		team.formation = DataTypes.Formation.JURASSIC 
		formation_slots.texture = load("res://common_assets/formation/jurassic_slots.png")
		
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
	
