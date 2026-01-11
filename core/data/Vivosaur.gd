extends Resource
class_name VivosaurResource

@export_category("Basic Info")
@export var name: String
@export var medal: Texture
@export var sprite: Texture
@export var element: VivosaurInfo.Element
@export_range(1, 40) var team_skill_groups: Array[int]
@export var battle_class: VivosaurInfo.Class
@export var status_immunities: Array[StatusResource]

@export_category("Stats")
@export_range(0, 1000, 1, "or_greater") var lp: int
@export_range(0, 1000, 1, "or_greater") var atk: int
@export_range(0, 1000, 1, "or_greater") var def: int
@export_range(0, 1000, 1, "or_greater") var acc: int
@export_range(0, 1000, 1, "or_greater") var eva: int
@export_range(0, 100, 1, "suffix:%") var crit: int

@export_category("Support Effects")
@export var own_az: bool
@export_range(-99, 99, 1, "suffix:%") var se_atk: int
@export_range(-99, 99, 1, "suffix:%") var se_def: int
@export_range(-99, 99, 1, "suffix:%") var se_acc: int
@export_range(-99, 99, 1, "suffix:%") var se_eva: int

@export_category("Skills")
@export var skills: Array[SkillResource]
