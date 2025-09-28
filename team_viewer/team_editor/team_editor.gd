extends TextureRect

var MedalFossilary = preload("res://team_viewer/team_editor/fossilary/MedalFossilary.tscn")
var MedalBtn = preload("res://team_viewer/team_editor/fossilary/MedalBtn.tscn")
var SkillScene = preload("res://team_viewer/team_editor/vivosaur_summary/skill.tscn")

var vivosaurs_json = preload("res://vivosaur/vivosaurs.json").data
var skills_json = preload("res://vivosaur/skills.json").data
var effects_json = preload("res://vivosaur/effects.json").data
var statuses_json = preload("res://vivosaur/statuses.json").data

@onready var formation_slots: TextureRect = $"HBoxContainer/FormationSlots"
@onready var slot1_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot1"
@onready var slot2_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot2"
@onready var slot3_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot3"
@onready var slot4_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot4"
@onready var slot5_selectable: AnimatedSprite2D = $"HBoxContainer/FormationSlots/Slot5"
@onready var fossilary_container = $"TextureRect/Fossilary"
@onready var vivosaur_summary = $"VivosaurSummary"

var currently_selected_vivosaur_id: String
var currently_selected_medal_btn: TextureButton
var current_action: int
var team: DataTypes.Team
var slots_selectable: Array[AnimatedSprite2D] 
var slots_medal_btns: Array
var fossilary_medals: Dictionary[String, TextureRect] = {}

func _ready() -> void:
	team = DataTypes.Team.new()
	slots_medal_btns = [null, null, null, null, null]
	_initialize_selectables()
	
	_add_fossilary_medals()
	
func _initialize_selectables():
	slots_selectable = [slot1_selectable, slot2_selectable, slot3_selectable, slot4_selectable, slot5_selectable]
	for i in range(len(slots_selectable)):
		slots_selectable[i].play()
		slots_selectable[i].get_node("Button").pressed.connect(_perform_context_action.bind(i, slots_selectable[i].global_position))
	
func _add_fossilary_medals():
	for vivosaur_id in Global.fossilary:
		var id_super_revival = vivosaur_id.split('_')
		var _texture = load("res://vivosaur/%s/medals/%s (%d).png" % [id_super_revival[0], id_super_revival[0], int(id_super_revival[1]) * 2 + 2])
		
		var medal_fossilary = MedalFossilary.instantiate()
		var medal_btn: BaseButton = MedalBtn.instantiate()
		medal_fossilary.texture = _texture
		medal_btn.texture_normal = _texture
		medal_btn.fossilary_index = vivosaur_id
		medal_btn.gui_input.connect(medal_btn_clicked.bind(medal_btn, vivosaur_id))
		medal_fossilary.add_child(medal_btn)
		fossilary_medals[vivosaur_id] = medal_fossilary
		fossilary_container.add_child(medal_fossilary)

func medal_btn_clicked(event: InputEvent, medal_btn: BaseButton, vivosaur_id: String):
	if event is InputEventMouseButton:
		if currently_selected_medal_btn:
			currently_selected_medal_btn.get_node('SelectedAnimation').visible = false
		medal_btn.get_node('SelectedAnimation').visible = true
		currently_selected_vivosaur_id = vivosaur_id
		currently_selected_medal_btn = medal_btn
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_show_context_menu(event, medal_btn)
		show_vivosaur_summary(vivosaur_id)
		

@onready var context_menu: PopupMenu = $"ContextMenu"
func _show_context_menu(event: InputEventMouseButton, medal_btn: BaseButton):
	context_menu.clear()
	if not medal_btn in slots_medal_btns:
		context_menu.add_item('Assign', 0)
	else:
		context_menu.add_item('Move/Swap', 1)
		context_menu.add_item('Remove', 2)
	context_menu.id_pressed.connect(_context_menu_item_pressed)
	context_menu.position = event.global_position
	context_menu.visible = true

func _context_menu_item_pressed(id: int):
	if id == 0 or id == 1:
		_show_selectable_slots(id)
	else:
		_remove_medal()
	current_action = id
	
			
func _show_selectable_slots(id: int):
	match id:
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
	
func _perform_context_action(slot: int, pos: Vector2):
	if current_action == 0:
		_assign_slot(slot, pos)
	elif current_action == 1:
		_move_swap_slots(slot)
		
func _assign_slot(slot: int, pos: Vector2):
	assert(slot < 5)
	
	var tween = create_tween()
	tween.tween_property(currently_selected_medal_btn, 
			'global_position', 
			pos + Vector2(48, -2), 1.0).set_trans(Tween.TRANS_SPRING)
			
	_hide_selectable_slots()
	
	team.slots[slot] = Global.fossilary[currently_selected_vivosaur_id]
	slots_medal_btns[slot] = currently_selected_medal_btn
	currently_selected_medal_btn.get_node("SelectedAnimation").visible = false

func _move_swap_slots(new_slot: int):
	var current_slot = slots_medal_btns.find(currently_selected_medal_btn)
	var vivosaur_in_new_slot = team.slots[new_slot]
	team.slots[new_slot] = Global.fossilary[currently_selected_vivosaur_id]
	team.slots[current_slot] = vivosaur_in_new_slot
	
	var medal_btn_in_new_slot = slots_medal_btns[new_slot]
	
	currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
	var tween = create_tween()
	tween.tween_property(currently_selected_medal_btn, 'global_position', slots_selectable[new_slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel()
	if medal_btn_in_new_slot != null:
		tween.tween_property(medal_btn_in_new_slot, 'global_position', slots_selectable[current_slot].global_position + Vector2(0, -2), 1.0).set_trans(Tween.TRANS_SPRING)
	
	slots_medal_btns[new_slot] = slots_medal_btns[current_slot]
	slots_medal_btns[current_slot] = medal_btn_in_new_slot
	
	for slot_medal_btn in slots_medal_btns:
		if slot_medal_btn != null:
			slot_medal_btn.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	
	_hide_selectable_slots()

func _remove_medal():
	var OFFSCREEN_POS = Vector2(currently_selected_medal_btn.global_position.x + 1920, currently_selected_medal_btn.global_position.y + 1000)
	
	currently_selected_medal_btn.get_node("SelectedAnimation").visible = false
	
	var tween = create_tween()
	tween.tween_property(currently_selected_medal_btn, 'global_position', OFFSCREEN_POS, 1.5)
	
	var slot = slots_medal_btns.find(currently_selected_medal_btn)
	slots_medal_btns[slot] = null
	team.slots[slot] = null
	
	tween.finished.connect(_reset_medal)
	
func _reset_medal():
	currently_selected_medal_btn.global_position = fossilary_medals[currently_selected_medal_btn.fossilary_index].global_position
	
func show_vivosaur_summary(vivosaur_id: String):
	_show_vivosaur_summary_main(vivosaur_summary, vivosaur_id)
	
func _show_vivosaur_summary_main(vivosaur_summary_node, vivosaur_id: String):
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
	var vivosaur: DataTypes.Vivosaur = Global.fossilary[vivosaur_id]
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
		
