class_name Skill


enum Type {
	DAMAGE,
	NEUTRAL,
	HEAL,
	ENHANCEMENT,
	PASSIVE,
	TEAM_SKILL
}
enum Target {
	SELF,
	ALLY,
	ALLY_EXCEPT_SELF,
	ENEMY,
	ALLY_AZ_AND_SZ,
	ENEMY_AZ_AND_SZ,
	ALL,
#	For unique skills like Mighty stomp
	ALL_ALLIES,
	ALL_ENEMIES,
}
enum EffectParam {
	CHANCE, LP, STATUS, 
}

class Effect:
	var id: String
	var parameters: Dictionary[EffectParam, Variant]
	
	func _init(effect_res: SkillEffectResource) -> void:
		for required_param: EffectParam in effect_res.effect.required_params:
			assert(effect_res.params.has(required_param), 'Missing required param')
		
		id = effect_res.resource_name
		parameters = effect_res.params

var id: String
var type: Type
var description: String
var name: String
var damage: int
var fp_cost: int
var target: Target
var effects: Array[Effect]
var counterable: bool

func _init(skill: SkillResource) -> void:
	id = skill.resource_name
	type = skill.skill_type
	description = skill.description
	name = skill.name
	damage = skill.damage
	fp_cost = skill.fp_cost
	target = skill.target
	effects.assign(skill.skill_effects.map(func (skill_effect_res: SkillEffectResource) -> Effect: return Effect.new(skill_effect_res)))
	counterable = skill.counterable
