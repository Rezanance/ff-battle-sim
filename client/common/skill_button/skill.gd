extends Panel
class_name SkillButton

@onready var skill_name: Label =  $HBoxContainer/VBoxContainer/Name
@onready var dmg: Label =  $HBoxContainer/VBoxContainer/HBoxContainer/Damage
@onready var fp: Label =  $HBoxContainer/VBoxContainer/HBoxContainer/FpCost
@onready var counterable: Label =  $HBoxContainer/VBoxContainer/Counterable
@onready var description: Label =  $HBoxContainer/Description

@onready var style_box: StyleBox = theme.get_stylebox('panel', 'Panel')

func initialize(skill: Skill, _on_skill_clicked: Callable ) -> void:
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
	
	skill_name.text = skill.name
	dmg.text = "Dmg: %d" % skill.damage
	fp.text = "%d FP" % skill.fp_cost	
	counterable.text = "Counterable: yes" if skill.counterable else "Counterable: no"
	description.text = skill.description

	if _on_skill_clicked != null:
		gui_input.connect(_on_skill_clicked.bind(skill))
