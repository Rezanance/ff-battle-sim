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
	id = skill.id
	type = skill.skill_type
	description = skill.description
	name = skill.name
	damage = skill.damage
	fp_cost = skill.fp_cost
	target = skill.target
	effects.assign(skill.skill_effects.map(func(skill_effect_res: SkillEffectResource) -> Effect: return Effect.new(skill_effect_res)))
	counterable = skill.counterable


static func load(skill_id: String) -> Skill:
	var skill_res: SkillResource = load("res://core/data/skills/%s/%s.tres" % [skill_id, skill_id])
	return Skill.new(skill_res)
