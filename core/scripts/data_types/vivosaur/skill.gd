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
	ALL_ALLIES,
	ALL_ENEMIES,
	ALL
}
enum EffectParam {
	CHANCE, LP, STATUS, 
}

class Effect:
	var id: String
	var parameters: Dictionary
	
	func _init(_id: String, _parameters: Dictionary):
		id = _id
		parameters = _parameters

var id: String
var type: Type
var description: String
var name: String
var damage: int
var fp_cost: int
var target: Target
var effects: Dictionary[String, Effect]
var counterable: bool

func _init(_id: String, _type_str: String, _description: String, _name: String,
_damage: int, _fp_cost: int, _target_str: String, _effects: Dictionary[String, Effect],
_counterable: bool):
	assert(damage >= 0)
	assert(fp_cost >= 0)
	
	var _skill_type
	match _type_str.to_lower().strip_edges():
		'damage':
			_skill_type = Type.DAMAGE
		'neutral':
			_skill_type = Type.NEUTRAL
		'heal':
			_skill_type = Type.HEAL
		'enhancement':
			_skill_type = Type.ENHANCEMENT
		'passive':
			_skill_type = Type.PASSIVE
		'team_skill':
			_skill_type = Type.TEAM_SKILL
		_:
			assert(false, 'Not a valid skill type')
			
	var _target
	match _target_str.to_lower().strip_edges():
		'self':
			_target = Target.SELF
		'ally':
			_target = Target.ALLY
		'ally_except_self':
			_target = Target.ALLY_EXCEPT_SELF
		'enemy':
			_target = Target.ENEMY
		'all_allies':
			_target = Target.ALL_ALLIES
		'all_enemies':
			_target = Target.ALL_ENEMIES
		'all':
			_target = Target.ALL
		_:
			assert(false, 'Not a valid target')
	
	id = _id
	type = _skill_type
	description = _description
	name = _name
	damage = _damage
	fp_cost = _fp_cost
	target = _target
	effects = _effects
	counterable = _counterable
