extends Panel
class_name SkillButton

func initialize(skill: Skill, _on_skill_clicked: Callable ) -> void:
	var style_box: StyleBox = theme.get_stylebox('panel', 'Panel')
	var style_box_flat: StyleBoxFlat = style_box.duplicate()
	if skill.type == Skill.Type.DAMAGE or skill.type == Skill.Type.NEUTRAL:
			style_box_flat.bg_color = Color.hex(0xe67538ff)
	elif skill.type == Skill.Type.HEAL or skill.type == Skill.Type.ENHANCEMENT:
		style_box_flat.bg_color = Color.hex(0x4ab444ff)
	elif skill.type == Skill.Type.TEAM_SKILL:
		style_box_flat.bg_color = Color.hex(0xcb3031ff)
	else:
		style_box_flat.bg_color = Color.hex(0x0eade1ff)
	add_theme_stylebox_override('panel', style_box_flat)
	
	$HBoxContainer/VBoxContainer/Name.text = skill.name
	$HBoxContainer/VBoxContainer/HBoxContainer/Damage.text = "Dmg: %d" % skill.damage
	$HBoxContainer/VBoxContainer/HBoxContainer/FpCost.text = "%d FP" % skill.fp_cost	
	$HBoxContainer/VBoxContainer/Counterable.text = "Counterable: yes" if skill.counterable else "Counterable: no"
	$HBoxContainer/Description.text = skill.description

	gui_input.connect(_on_skill_clicked.bind(skill))
