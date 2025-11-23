extends Node


var vivosaurs_json = preload("res://vivosaur/vivosaurs.json").data
var skills_json = preload("res://vivosaur/skills.json").data
var effects_json = preload("res://vivosaur/effects.json").data
var statuses_json = preload("res://vivosaur/statuses.json").data

# Data on all vivosaurs with the id as the key
var fossilary: Dictionary[int, VivosaurInfo]

var teams_file = "user://teams.cfg"
var preferences_file = "user://preferences.cfg"

var editing_team: Team
var is_new_team: bool

func _ready() -> void:
	for vivosaur_id in vivosaurs_json:
		var vivosaur = vivosaurs_json[vivosaur_id]
		var vivo_skills: Array[Skill] = []
		for skill_id in vivosaur.skills:
			var skill_json = skills_json[skill_id]
			var skill_effects: Dictionary[String, Skill.Effect] = {}
			for effect_id in skill_json.effects:
				var skill_effect = skill_json.effects[effect_id]
				var effect_json = effects_json[effect_id]
				assert(
					effect_json.params.all(func(param): return param in skill_effect.keys()),
					'A parameter is missing in the skill data for id=%s' % [skill_id]
				)
				skill_effects[effect_id] = Skill.Effect.new(
					effect_id, skill_effect
				)
			vivo_skills.append(Skill.new(
				skill_id, skill_json.skill_type, skill_json.description,
				skill_json.name, skill_json.damage, skill_json.fp_cost,
				skill_json.target, skill_effects, skill_json.counterable
			))
		
		var status_immunities = vivosaur.status_immunities.map(
			func(status_id): return Status.new(
				status_id, statuses_json[status_id].name, statuses_json[status_id].is_negative,
				statuses_json[status_id].description, statuses_json[status_id].turns_active
			) 
		)
		
		var support_effects = SupportEffects.new(
			vivosaur.support_effects.own_az, vivosaur.support_effects.atk,
			vivosaur.support_effects.def, vivosaur.support_effects.acc,
			vivosaur.support_effects.eva
		)
		var stats = Stats.new(
			vivosaur.stats.lp, vivosaur.stats.atk,
			vivosaur.stats.def, vivosaur.stats.acc, vivosaur.stats.eva,
			vivosaur.stats.crit, vivosaur.stats.ranged_multiplier
		)
		
		# Arrays are weird in GDScript
		var team_skill_groups: Array[int]
		team_skill_groups.assign(vivosaur.team_skill_groups)		
		var status_immunities_final: Array[Status]
		status_immunities_final.assign(status_immunities)
		
		fossilary[int(vivosaur_id)] = VivosaurInfo.new(
			int(vivosaur_id), vivosaur.name, vivosaur.element, stats, support_effects,
			vivo_skills, vivosaur.class, status_immunities_final,
			team_skill_groups)
