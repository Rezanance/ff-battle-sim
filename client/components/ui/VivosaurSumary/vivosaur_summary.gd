extends Panel
class_name VivosaurSummary

@onready var element: TextureRect = $ScrollContainer/VBoxContainer/HBoxContainer2/Element
@onready var vivosaur_name: Label = $ScrollContainer/VBoxContainer/HBoxContainer2/Name
@onready var battle_class: Label = $ScrollContainer/VBoxContainer/Class
@onready var lp: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer/LpValue
@onready var atk: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer2/AtkValue
@onready var def: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer3/DefValue
@onready var acc: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer4/AccValue
@onready var eva: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/HBoxContainer5/EvaValue
@onready var crit: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/CritValue
@onready var ranged_multiplier: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer/Stats/RangedMultiplier
@onready var own_az: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/OwnAZ
@onready var atk_support: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer2/AtkValue
@onready var def_support: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer3/DefValue
@onready var acc_support: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer4/AccValue
@onready var eva_support: Label = $ScrollContainer/VBoxContainer/StatsSupportEffects/MarginContainer2/SupportEffects/HBoxContainer5/EvaValue
@onready var status_immunities: Label = $ScrollContainer/VBoxContainer/HBoxContainer/StatusImmunities
@onready var team_skill_groups: Label = $ScrollContainer/VBoxContainer/HBoxContainer/TeamSkillGroups
@onready var skills_container: VBoxContainer = $ScrollContainer/VBoxContainer/SkillsContainer

var BASE_HEIGHT: int = 320
var HEIGHT_WITH_SKILLS: int = 720

func update_summary(vivosaur_id: int, skills_included: bool = true) -> void:
	visible = true
	
	var vivosaur: VivosaurInfo = Constants.fossilary[vivosaur_id]
	element.texture = load("res://client/assets/elements/%d.webp" % vivosaur.element)
	vivosaur_name.text = vivosaur.name
	battle_class.text = vivosaur.battle_class.capitalize()
	
	lp.text = "%d" % vivosaur.stats.life_points
	atk.text = "%d" % vivosaur.stats.attack
	def.text = "%d" % vivosaur.stats.defense
	acc.text = "%d" % vivosaur.stats.accuracy
	eva.text = "%d" % vivosaur.stats.evasion
	crit.text = "Crit Chance: %d" % [vivosaur.stats.crit_chance * 100] + "%"
	ranged_multiplier.text = "Ranged Multiplier: %.1f" % vivosaur.stats.ranged_multiplier

	own_az.text = "Own AZ" if vivosaur.support_effects.own_az else "Enemy AZ"
	display_support_effect(atk_support, vivosaur.support_effects.attack_modifier)
	display_support_effect(def_support, vivosaur.support_effects.defense_modifier)
	display_support_effect(acc_support, vivosaur.support_effects.accuracy_modifier)
	display_support_effect(eva_support, vivosaur.support_effects.evasion_modifier)
	
	var status_immunites_begin: String = "Status Immunities: "
	status_immunities.text = status_immunites_begin + ", ".join(vivosaur.status_immunities.map(func(status: Status) -> String: return status.name)) if len(vivosaur.status_immunities) > 0 else status_immunites_begin + "None"
	team_skill_groups.text = "Team Skill Groups: " + ", ".join(vivosaur.team_skill_groups)
	
	if skills_included:
		UIUtils.clear_skills(skills_container)
		UIUtils.update_skills_shown(skills_container, vivosaur.skills, func() -> void: return )
		size.y = HEIGHT_WITH_SKILLS
		return
	size.y = BASE_HEIGHT
	

func display_support_effect(se_label: Label, modifier: float) -> void:
	if modifier > 0:
		se_label.text = "+%d" % [modifier * 100] + "%"
	elif modifier < 0:
		se_label.text = "%d" % [modifier * 100] + "%"
	else:
		se_label.text = "--"
