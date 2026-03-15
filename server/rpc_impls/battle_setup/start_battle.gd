static func create_player_formation(battle_id: int, player_id: int) -> Formation:
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var team: Team = battle_info.teams[player_id]
	var slot1_vivo_id: String = team.slots[0].id
	var slot2_vivo_id: String = team.slots[1].id
	var slot3_vivo_id: String = team.slots[2].id
	
	return Formation.new(
		VivosaurBattle.new(DataLoader.load_vivosaur_info(slot1_vivo_id)),
		VivosaurBattle.new(DataLoader.load_vivosaur_info(slot2_vivo_id)),
		VivosaurBattle.new(DataLoader.load_vivosaur_info(slot3_vivo_id))
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
	ServerVariables.battles[battle_id].battlefield = BattleField.new(all_zones, false)
	ServerVariables.battles[battle_id].battlefield.support_effects_applied.connect(
		_apply_next_support_effects.bind(battle_id))

	# Apply supports effects from both teams
	ServerVariables.battles[battle_id].battlefield.apply_support_effects(player1)
	ServerVariables.battles[battle_id].battlefield.apply_support_effects(player2) 

static func _apply_next_support_effects(_id: int, _index: int, battle_id: int) -> void:
	ServerVariables.battles[battle_id].battlefield.apply_next_support_effects.emit()
