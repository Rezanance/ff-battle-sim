extends Node

var SkillScene = preload("res://team_viewer/team_editor/vivosaur_summary/skill.tscn")

func show_vivosaur_summary(vivosaur_summary_node, fossilary_id: String):
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
	var vivosaur_summary_groups = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/HBoxContainer/TeamSkillGroups")
	var vivosaur_summary_skills_container: VBoxContainer = vivosaur_summary_node.get_node("ScrollContainer/VBoxContainer/SkillsContainer")
	
	vivosaur_summary_node.visible = true
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
