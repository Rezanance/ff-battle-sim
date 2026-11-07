extends Resource
class_name SkillResource

@export var id: String
@export var name: String
@export var description: String
@export var skill_type: Skill.Type
@export_range(0, 1000) var damage: int
@export_range(0, 1000) var fp_cost: int
@export var target: Skill.Target
@export var skill_effects: Array[SkillEffectResource]
@export var counterable: bool

func load(skill_id: String) -> SkillResource:
    return load("res://core/data/skills/%s.tres" % skill_id)