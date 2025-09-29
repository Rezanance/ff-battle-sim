extends Node

enum FighterTeam {ALLY, ENEMY}
enum Formation {TRIASSIC, JURASSIC}
enum AttackRange {CLOSE, MID, LONG}
enum SuperRevival {BASE, HEAD, BODY, ARMS, LEGS}
enum Element {FIRE, WATER, AIR, EARTH, NEUTRAL}
enum Target {
	SELF, 
	ALLY, 
	ALLY_EXCEPT_SELF,
	ENEMY, 
	ALL_ALLIES, 
	ALL_ENEMIES, 
	ALL
}
enum SkillType {
	DAMAGE,
	NEUTRAL,
	HEAL,
	ENHANCEMENT,
	PASSIVE,
	TEAM_SKILL
}
enum StatusType {POSITIVE, NEGATIVE}

const SUPER_REVIVAL_LP_MODIFIER = 20
const HEAD_ACC_MODIFIER = 5
const BODY_DEF_MODIFIER = 10
const ARMS_ATK_MODIFIER = 10
const LEGS_EVA_MODIFIER = 5

const RANGES_STR = ['Close', 'Mid', 'Long']


class Stats:
	var life_points: int
	var attack: int
	var defense: int
	var accuracy: int
	var evasion: int
	var crit_chance: float
	
	func _init(_life_points: int, _attack: int, _defense: int, _accuracy: int,
	_evasion: int, _crit_chance: float, super_revival: SuperRevival ):
		assert(_life_points >= 0)
		assert(_attack >= 0)
		assert(_defense >= 0)
		assert(_accuracy >= 0)
		assert(_evasion >= 0)
		assert(_crit_chance >= 0 and _crit_chance <= 1)
		
		var lp_modifier = SUPER_REVIVAL_LP_MODIFIER if super_revival != SuperRevival.BASE else 0
		var atk_modifier = ARMS_ATK_MODIFIER if super_revival == SuperRevival.ARMS else 0
		var def_modifier = BODY_DEF_MODIFIER if super_revival == SuperRevival.BODY else 0
		var acc_modifier = HEAD_ACC_MODIFIER if super_revival == SuperRevival.HEAD else 0
		var eva_modifier = LEGS_EVA_MODIFIER if super_revival == SuperRevival.LEGS else 0
		
		self.life_points = _life_points + lp_modifier
		self.attack = _attack + atk_modifier
		self.defense = _defense + def_modifier
		self.accuracy = _accuracy + acc_modifier
		self.evasion = _evasion + eva_modifier
		self.crit_chance = _crit_chance
		
	
class SupportEffects:
	var own_az: bool
	var attack_modifier: float
	var defense_modifier: float
	var accuracy_modifier: float
	var evasion_modifier: float
	
	func _init(_own_az: bool, _attack_modifier: float, _defense_modifier: float, 
	_accuracy_modifier: float, _evasion_modifier: float):
		assert(_attack_modifier >= -1 and _attack_modifier <= 1)
		assert(_defense_modifier >= -1 and _defense_modifier <= 1)
		assert(_accuracy_modifier >= -1 and _accuracy_modifier <= 1)
		assert(_evasion_modifier >= -1 and _evasion_modifier <= 1)

		self.own_az = _own_az
		self.attack_modifier = _attack_modifier
		self.defense_modifier = _defense_modifier
		self.accuracy_modifier = _accuracy_modifier
		self.evasion_modifier = _evasion_modifier
		
class Status:
	var id: String
	var name: String
	var is_negative: bool
	var description: String
	var turns_active: int
	
	func _init(_id: String, _name: String, _is_negative: bool, _description: String, _turns_active: int):
		assert(_turns_active > 0, "A status condition must be active for at least 1 turn")
		
		self.id = _id
		self.name = _name
		self.is_negative = _is_negative
		self.description = _description
		self.turns_active = _turns_active
		
class Effect:
	var id: String
	var parameters: Dictionary
	
	func _init(_id: String, _parameters: Dictionary):
		self.id = _id
		self.parameters = _parameters
	
class Skill:
	var id: String
	var skill_type: SkillType
	var description: String
	var name: String
	var damage: int
	var fp_cost: int
	var target: Target
	var effects: Dictionary[String, Effect]
	var counterable: bool
	
	func _init(_id: String, _skill_type_str: String, _description: String, _name: String, 
	_damage: int, _fp_cost: int, _target_str: String, _effects: Dictionary[String, Effect], 
	_counterable: bool):
		assert(damage >= 0)
		assert(fp_cost >= 0)
		
		var _skill_type
		match _skill_type_str.to_lower().strip_edges():
			'damage':
				_skill_type = SkillType.DAMAGE
			'neutral':
				_skill_type = SkillType.NEUTRAL
			'heal':
				_skill_type = SkillType.HEAL
			'enhancement':
				_skill_type = SkillType.ENHANCEMENT
			'passive':
				_skill_type = SkillType.PASSIVE
			'team_skill':
				_skill_type = SkillType.TEAM_SKILL
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
		
		self.id = _id
		self.skill_type = _skill_type
		self.description = _description
		self.name = _name
		self.damage = _damage
		self.fp_cost = _fp_cost
		self.target = _target
		self.effects = _effects
		self.counterable = _counterable
	
class Vivosaur:
	var id: String
	var name: String
	var element: Element
	var super_revival: SuperRevival
	var stats: Stats
	var support_effects: SupportEffects
	var skills: Array[Skill]
	var attack_range: AttackRange
	var status_immunities: Array[Status]
	var team_skill_groups: Array[int]
	
	func _init(_id: String, _name: String, _element_str: String, _super_revival: SuperRevival,
	_stats: Stats, _support_effects: SupportEffects, _skills: Array[Skill],
	_attack_range_str: String, _status_immunities: Array[Status],
	_team_skill_groups: Array[int]):
		var _element
		match _element_str.to_lower().strip_edges():
			'fire':
				_element = Element.FIRE
			'water':
				_element = Element.WATER
			'air':
				_element = Element.AIR
			'earth':
				_element = Element.EARTH
			'neutral':
				_element = Element.NEUTRAL
			_:
				assert(false, 'Not a valid element')
		
		var _attack_range
		match _attack_range_str.to_lower().strip_edges():
			'close':
				_attack_range = AttackRange.CLOSE
			'mid':
				_attack_range = AttackRange.MID
			'long':
				_attack_range = AttackRange.LONG
			_:
				assert(false, 'Not a attack range')
				
		self.id = _id
		self.name = _name
		self.element = _element
		self.super_revival = _super_revival
		self.stats = _stats
		self.support_effects = _support_effects
		self.skills = _skills
		self.attack_range = _attack_range
		self.status_immunities = _status_immunities
		self.team_skill_groups = _team_skill_groups
	
class Team:
	var name: String
	var formation: Formation
	var slots: Array
		
	func _init( _name: String = '', _formation: Formation = Formation.JURASSIC, _slots: Array = []):
		self.name = _name
		self.formation = _formation
		
		if len(_slots) != 5:
			self.slots = [null, null, null, null, null]
		else:
			self.slots = _slots
	
	func is_valid():
		assert(len(slots) == 5)
		
		for i in range(3):
			if slots[i] != null:
				return true
		return false
