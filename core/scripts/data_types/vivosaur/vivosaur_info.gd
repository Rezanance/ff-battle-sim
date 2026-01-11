class_name VivosaurInfo


enum Element {FIRE, WATER, AIR, EARTH, NEUTRAL, LEGENDARY}
enum Class {ATTACK, LONG_RANGE, SUPPORT}

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
