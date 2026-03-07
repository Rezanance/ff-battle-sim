class_name VivosaurInfo

enum Element {FIRE, WATER, AIR, EARTH, NEUTRAL, LEGENDARY}
enum Class {ATTACK, LONG_RANGE, SUPPORT}

static var battle_classes: Dictionary[Class, String]
static func _static_init() -> void:
	battle_classes[Class.ATTACK] = 'Attack'
	battle_classes[Class.LONG_RANGE] = 'Long-range'
	battle_classes[Class.SUPPORT] = 'Support'

var id: String
var name: String
var element: Element
var stats: Stats
var support_effects: SupportEffects
var skills: Array[Skill]
var battle_class: String
var status_immunities: Array[Status]
var team_skill_groups: Array[int]

func _init(vivosaur_res: VivosaurResource) -> void:
	id = vivosaur_res.resource_name
	name = vivosaur_res.name
	element = vivosaur_res.element
	status_immunities.assign(vivosaur_res.status_immunities.map(func (status_res: StatusResource) -> Status: return Status.new(status_res))) 
	battle_class = battle_classes[vivosaur_res.battle_class]
	team_skill_groups = vivosaur_res.team_skill_groups
	stats = Stats.new(
		vivosaur_res.lp,
		vivosaur_res.atk,
		vivosaur_res.def,
		vivosaur_res.acc,
		vivosaur_res.eva,
		vivosaur_res.crit,
		vivosaur_res.range_multiplier
	)
	support_effects = SupportEffects.new(
		vivosaur_res.own_az,
		vivosaur_res.se_atk,
		vivosaur_res.se_def,
		vivosaur_res.se_acc,
		vivosaur_res.se_eva
	)
	skills.assign(vivosaur_res.skills.map(func (skill_res: SkillResource) -> Skill: return Skill.new(skill_res)))
