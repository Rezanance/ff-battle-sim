class_name BattleState

enum Phase {
	REGISTER_TEAM_INITIAL,
	BATTLE_PREP,
	DETERMINE_WHO_GOES_FIRST,
	APPLY_SUPPORT_EFFECTS,
	RECHARGE_FP,
	SELECT_ACTION,
	RESOLVE_ACTION,
}

var phase: Phase
var player_ids: Array[int]
var teams: Dictionary[int, Team]
var formations: Dictionary[int, Formation]
var turn_id: int
var winner: Variant

var timer: Timer

func _init(
	_player_ids: Array[int],
) -> void:
	player_ids = _player_ids
	teams = {}
	
	turn_id = 0
	timer = Timer.new()
	phase = Phase.REGISTER_TEAM_INITIAL
	winner = null
