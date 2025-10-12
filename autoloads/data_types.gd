extends Node

enum FighterTeam {ALLY, ENEMY}
enum Element {FIRE, WATER, AIR, EARTH, NEUTRAL, LEGENDARY}
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

const TEAM_SLOTS = 5
const BASE_FP_RECHARGE = 180
const MAX_FP = 500
const FP_GAIN_AFTER_KNOCKOUT = BASE_FP_RECHARGE * 2

class Stats:
	var life_points: int
	var attack: int
	var defense: int
	var accuracy: int
	var evasion: int
	var crit_chance: float
	var ranged_multiplier: float
	
	func _init(_life_points: int, _attack: int, _defense: int, _accuracy: int,
	_evasion: int, _crit_chance: float, _ranged_multiplier: float):
		assert(_life_points >= 0)
		assert(_attack >= 0)
		assert(_defense >= 0)
		assert(_accuracy >= 0)
		assert(_evasion >= 0)
		assert(_crit_chance >= 0 and _crit_chance <= 1)
		assert(_ranged_multiplier >= 0)
				
		self.life_points = _life_points
		self.attack = _attack
		self.defense = _defense
		self.accuracy = _accuracy
		self.evasion = _evasion
		self.crit_chance = _crit_chance
		self.ranged_multiplier = _ranged_multiplier
	
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
	var id: int
	var name: String
	var element: Element
	var stats: Stats
	var support_effects: SupportEffects
	var skills: Array[Skill]
	var battle_class: String
	var status_immunities: Array[Status]
	var team_skill_groups: Array[int]
	
	func _init(_id: int, _name: String, _element_str: String,
	_stats: Stats, _support_effects: SupportEffects, _skills: Array[Skill],
	_battle_class: String, _status_immunities: Array[Status],
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
		
		assert(
			_battle_class == 'attack' or
			_battle_class == 'all-around' or
			_battle_class == 'defense' or
			_battle_class == 'long-range' or
			_battle_class == 'support' or
			_battle_class == 'transformation',
			'Not a valid class'
		)

		self.id = _id
		self.name = _name
		self.element = _element
		self.stats = _stats
		self.support_effects = _support_effects
		self.skills = _skills
		self.battle_class = _battle_class
		self.status_immunities = _status_immunities

class Team:
	var uuid: String
	var name: String
	# Vivosaur | null
	var slots: Array
		
	func _init(_uuid: String, _name: String = '', _slots: Array = []):
		self.uuid = _uuid
		self.name = _name
		
		if len(_slots) != TEAM_SLOTS:
			self.slots = [null, null, null, null, null]
		else:
			self.slots = _slots
	
	func is_valid():
		assert(len(slots) == TEAM_SLOTS)
		
		return slots[0] != null
	
	func serialize() -> Dictionary:
		return {
			'name': name,
			'slots': slots_vivosaur_ids()
		}
	
	func slots_vivosaur_ids():
		return slots.map(func(vivosaur): return vivosaur.id if vivosaur != null else null)
	
	static func unserialize(team_uuid: String, team_dict: Dictionary):
		var _slots = []
		for i in range(TEAM_SLOTS):
			var vivosaur_id = team_dict.slots[i]
			if vivosaur_id != null:
				_slots.append(Global.fossilary[vivosaur_id])
			else:
				_slots.append(null)
		
		return DataTypes.Team.new(team_uuid, team_dict['name'], _slots)

class VivosaurBattle:
	var vivosaur: Vivosaur
	var current_lp: int
	var statuses: Array[Status]
	var can_attack: bool

	func _init(_vivosaur: Vivosaur):
		self.vivosaur = _vivosaur
		self.current_lp = _vivosaur.stats.life_points
		self.statuses = []
		self.can_attack = false

class Zones:
	# VivosaurBattle | null
	var az
	var sz1
	var sz2
	var ez

	func _init(_az, _sz1, _sz2) -> void:
		assert(is_instance_of(_az, VivosaurBattle))
		assert(is_instance_of(_sz1, VivosaurBattle) or _sz1 == null)
		assert(is_instance_of(_sz2, VivosaurBattle) or _sz2 == null)

		self.az = _az
		self.sz1 = _sz1
		self.sz2 = _sz2
		self.ez = null

class BattleField:
	var player1_zones: Zones
	var player1_fp: int
	var player2_zones: Zones
	var player2_fp: int
	var turn: int

	func _init(_player1_zones: Zones, _player2_zones: Zones) -> void:
		self.player1_zones = _player1_zones
		self.player1_fp = 0
		self.player2_zones = _player2_zones
		self.player2_fp = 0
		self.turn = -1
