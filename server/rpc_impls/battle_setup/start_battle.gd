static func create_player_formation(battle_id: int, player_id: int) -> Formation:
	var slot1_vivo_id: String = ServerVariables.battle_teams[battle_id][player_id].slots[0]
	var slot2_vivo_id: String = ServerVariables.battle_teams[battle_id][player_id].slots[1]
	var slot3_vivo_id: String = ServerVariables.battle_teams[battle_id][player_id].slots[2]
	
	return Formation.new(
		VivosaurBattle.new(VivosaurInfo.new(load("res://core/data/vivosaurs/%s.tres" % slot1_vivo_id)))  if slot1_vivo_id != null else null,
		VivosaurBattle.new(VivosaurInfo.new(load("res://core/data/vivosaurs/%s.tres" % slot2_vivo_id))) if slot2_vivo_id != null else null,
		VivosaurBattle.new(VivosaurInfo.new(load("res://core/data/vivosaurs/%s.tres" % slot3_vivo_id))) if slot3_vivo_id != null else null
	)
	
	
static func create_battle_field(
	battle_id: int, 
	player1: int,
	player_1_formation: Formation,
	player2: int,
	player_2_formation: Formation
) -> void:
	var all_zones: Dictionary[int, Formation] = {}
	all_zones[player1] = player_1_formation
	all_zones[player2] = player_2_formation
	ServerVariables.battlefields[battle_id] = BattleField.new(all_zones, false)

	ServerVariables.battlefields[battle_id].support_effects_applied.connect(_apply_next_support_effects.bind(battle_id))

	# Apply supports effects from both teams
	ServerVariables.battlefields[battle_id].apply_support_effects(player1)
	ServerVariables.battlefields[battle_id].apply_support_effects(player2) 

static func _apply_next_support_effects(_id: int, _index: int, battle_id: int) -> void:
	ServerVariables.battlefields[battle_id].apply_next_support_effects.emit()
