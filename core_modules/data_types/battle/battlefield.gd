class_name BattleField


signal support_effects_applied(player_id: int, index: Zones.SupportZone)
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
