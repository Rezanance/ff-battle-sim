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
enum Zone {AZ, SZ1, SZ2, EZ}
enum SupportZone {SZ1, SZ2}

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
				
		life_points = _life_points
		attack = _attack
		defense = _defense
		accuracy = _accuracy
		evasion = _evasion
		crit_chance = _crit_chance
		ranged_multiplier = _ranged_multiplier
	
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

		own_az = _own_az
		attack_modifier = _attack_modifier
		defense_modifier = _defense_modifier
		accuracy_modifier = _accuracy_modifier
		evasion_modifier = _evasion_modifier
		
class Status:
	var id: String
	var name: String
	var is_negative: bool
	var description: String
	var turns_active: int
	
	func _init(_id: String, _name: String, _is_negative: bool, _description: String, _turns_active: int):
		assert(_turns_active > 0, "A status condition must be active for at least 1 turn")
		
		id = _id
		name = _name
		is_negative = _is_negative
		description = _description
		turns_active = _turns_active
		
class Effect:
	var id: String
	var parameters: Dictionary
	
	func _init(_id: String, _parameters: Dictionary):
		id = _id
		parameters = _parameters
	
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
		
		id = _id
		skill_type = _skill_type
		description = _description
		name = _name
		damage = _damage
		fp_cost = _fp_cost
		target = _target
		effects = _effects
		counterable = _counterable
	
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

		id = _id
		name = _name
		element = _element
		stats = _stats
		support_effects = _support_effects
		skills = _skills
		battle_class = _battle_class
		status_immunities = _status_immunities

class Team:
	var uuid: String
	var name: String
	# Vivosaur | null
	var slots: Array
		
	func _init(_uuid: String, _name: String = '', _slots: Array = []):
		uuid = _uuid
		name = _name
		
		if len(_slots) != TEAM_SLOTS:
			slots = [null, null, null, null, null]
		else:
			slots = _slots
	
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
	var vivosaur_info: Vivosaur
	var current_lp: int
	var statuses: Array[Status]
	var can_attack: bool
	var is_support_effects_applied: bool

	func _init(_vivosaur_info: Vivosaur):
		vivosaur_info = _vivosaur_info
		current_lp = _vivosaur_info.stats.life_points
		statuses = []
		can_attack = false
		is_support_effects_applied = false

class AZSupportEffects:
	var atk: float
	var def: float
	var acc: float
	var eva: float

	func _init() -> void:
		atk = 0
		def = 0
		acc = 0
		eva = 0

class Zones:
	# VivosaurBattle | null
	var az
	var sz1
	var sz2
	var ez
	# TextureButton | null
	var az_sprite_btn
	var sz1_sprite_btn
	var sz2_sprite_btn
	var ez_sprite_btn

	var fp: int

	var az_support_effects: AZSupportEffects

	func _init(_az, _sz1, _sz2) -> void:
		assert(is_instance_of(_az, VivosaurBattle))
		assert(is_instance_of(_sz1, VivosaurBattle) or _sz1 == null)
		assert(is_instance_of(_sz2, VivosaurBattle) or _sz2 == null)

		az = _az
		az_sprite_btn = null
		sz1 = _sz1
		sz1_sprite_btn = null
		sz2 = _sz2
		sz2_sprite_btn = null
		ez = null
		ez_sprite_btn = null

		fp = 0

		az_support_effects = AZSupportEffects.new()

	func get_sz_vivosaurs() -> Array:
		return [sz1, sz2]

	func get_support_zones_sprite_btns() -> Array:
		return [sz1_sprite_btn, sz2_sprite_btn]
	
	func get_total_lp():
		var az_lp = az.get('current_lp') if az != null else 0
		var sz1_lp = sz1.get('current_lp') if sz1 != null else 0
		var sz2_lp = sz2.get('current_lp') if sz2 != null else 0

		return az_lp + sz1_lp + sz2_lp
	
	func recharge_fp():
		if fp + BASE_FP_RECHARGE > MAX_FP:
			fp += MAX_FP - fp
		else:
			fp += BASE_FP_RECHARGE
	
	func get_vivosaur_zone(vivo: VivosaurBattle) -> Zone:
		var az_id = az.get('vivosaur_info').get('id')
		var sz1_id = sz1.get('vivosaur_info').get('id')
		var sz2_id = sz2.get('vivosaur_info').get('id')

		match vivo.vivosaur_info.id:
			az_id:
				return Zone.AZ
			sz1_id:
				return Zone.SZ1
			sz2_id:
				return Zone.SZ2
			_:
				return Zone.EZ

	
class Battlefield:
	signal support_effects_applied(player_id: int, index: SupportZone)
	signal apply_next_support_effects()
	signal fp_recharged(player_id: int)

	var on_client: bool
	var zones: Dictionary[int, Zones]
	var turn_id: int

	func _init(_zones: Dictionary[int, Zones], _on_client: bool) -> void:
		assert(len(_zones.keys()) == 2)

		zones = _zones
		turn_id = -1
		on_client = _on_client

	func get_opponent_id(player_id: int):
		return zones.keys().filter(func(id): return id != player_id)[0]

	func apply_support_effects(player_id: int):
		var opponent_id = get_opponent_id(player_id)
		var player_az_support_effects = zones[player_id].az_support_effects
		var opponent_az_support_effects = zones[opponent_id].az_support_effects
		var sz_vivosaurs = zones[player_id].get_sz_vivosaurs()

		for index in range(len(sz_vivosaurs)):
			var vivosaur_battle = sz_vivosaurs[index]
			if vivosaur_battle == null or vivosaur_battle.is_support_effects_applied:
				continue

			var support_effects = vivosaur_battle.vivosaur_info.support_effects
			if support_effects.own_az:
				player_az_support_effects.atk += support_effects.attack_modifier
				player_az_support_effects.def += support_effects.defense_modifier
				player_az_support_effects.acc += support_effects.accuracy_modifier
				player_az_support_effects.eva += support_effects.evasion_modifier
			else:
				opponent_az_support_effects.atk += support_effects.attack_modifier
				opponent_az_support_effects.def += support_effects.defense_modifier
				opponent_az_support_effects.acc += support_effects.accuracy_modifier
				opponent_az_support_effects.eva += support_effects.evasion_modifier
			vivosaur_battle.is_support_effects_applied = true

			support_effects_applied.emit(player_id, index)
			await apply_next_support_effects
	
	func recharge_fp(player_id: int):
		zones[player_id].recharge_fp()
		fp_recharged.emit(player_id)
