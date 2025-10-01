extends Node

var vivosaurs_json = preload("res://vivosaur/vivosaurs.json").data
var skills_json = preload("res://vivosaur/skills.json").data
var effects_json = preload("res://vivosaur/effects.json").data
var statuses_json = preload("res://vivosaur/statuses.json").data

# Data on all vivosaurs with the id as the key
var fossilary: Dictionary[String, DataTypes.Vivosaur]

var teams_file = "user://teams.cfg"
var preferences_file = "user://preferences.cfg"

var editing_team: DataTypes.Team
var is_new_team: bool

func _ready() -> void:
	for vivosaur_id in vivosaurs_json:
		var vivosaur = vivosaurs_json[vivosaur_id]
		var vivo_skills: Array[DataTypes.Skill] = []
		for skill_id in vivosaur.skills:
			var skill_json = skills_json[skill_id]
			var skill_effects: Dictionary[String, DataTypes.Effect] = {}
			for effect_id in skill_json.effects:
				var skill_effect = skill_json.effects[effect_id]
				var effect_json = effects_json[effect_id]
				assert(
					effect_json.params.all(func(param): return param in skill_effect.keys()),
					'A parameter is missing in the skill data for id=%s' % [skill_id]
				)
				skill_effects[effect_id] = DataTypes.Effect.new(
					effect_id, skill_effect
				)
			vivo_skills.append(DataTypes.Skill.new(
				skill_id, skill_json.skill_type, skill_json.description, 
				skill_json.name, skill_json.damage, skill_json.fp_cost, 
				skill_json.target, skill_effects, skill_json.counterable
			))
		
		
		var support_effects = DataTypes.SupportEffects.new(
			vivosaur.support_effects.own_az, vivosaur.support_effects.atk,
			vivosaur.support_effects.def, vivosaur.support_effects.acc, 
			vivosaur.support_effects.eva
		)
		if not vivosaur.super_revival_possible:
			var stats = DataTypes.Stats.new(
				vivosaur.stats.lp, vivosaur.stats.atk,
				vivosaur.stats.def, vivosaur.stats.acc, vivosaur.stats.eva, 
				vivosaur.stats.crit, DataTypes.SuperRevival.BASE
			)
		
			fossilary["%d_%d" % [vivosaur.id, DataTypes.SuperRevival.BASE]] = DataTypes.Vivosaur.new(
				vivosaur.id, vivosaur.name, vivosaur.element, DataTypes.SuperRevival.BASE, stats, support_effects,
				vivo_skills, vivosaur.attack_range, vivosaur.status_immunities, 
				vivosaur.team_skill_groups)
		else:
			for super_revival_key in DataTypes.SuperRevival.keys():
				var super_revival = DataTypes.SuperRevival[super_revival_key]
				var stats = DataTypes.Stats.new(
					vivosaur.stats.lp, vivosaur.stats.atk,
					vivosaur.stats.def, vivosaur.stats.acc, vivosaur.stats.eva, 
					vivosaur.stats.crit, super_revival
				)
				var status_immunities = vivosaur.status_immunities.map(
					func(status_id): return DataTypes.Status.new(
						status_id, statuses_json[status_id].name, statuses_json[status_id].is_negative,
						statuses_json[status_id].description, statuses_json[status_id].turns_active
					) 
				)
				#Empty Arrays are weird in GDScript. They need to be assigned a type
#				if they're empty
				var team_skill_groups: Array[int]
				team_skill_groups.assign(vivosaur.team_skill_groups)
				var status_immunities_final: Array[DataTypes.Status]
				status_immunities_final.assign(status_immunities)
				
				fossilary["%s_%d" % [vivosaur_id, super_revival]] = DataTypes.Vivosaur.new(
					vivosaur_id, vivosaur.name, vivosaur.element, super_revival, stats, support_effects,
					vivo_skills, vivosaur.attack_range, status_immunities_final, 
					team_skill_groups)
