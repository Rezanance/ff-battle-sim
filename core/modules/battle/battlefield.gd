class_name BattleField

signal support_effects_applied(player_id: int, index: Formation.SupportZone)
signal apply_next_support_effects()
signal fp_recharged(player_id: int)

var on_client: bool
var formations: Dictionary[int, Formation]
var turn_id: int

func _init(_formations: Dictionary[int, Formation], _on_client: bool) -> void:
	assert(len(_formations.keys()) == 2)

	formations = _formations
	turn_id = -1
	on_client = _on_client

func get_opponent_id(player_id: int) -> int:
	return formations.keys().filter(func(id: int) -> bool: return id != player_id)[0]

func apply_support_effects(player_id: int) -> void:
	var opponent_id: int = get_opponent_id(player_id)
	var player_az_support_effects: Formation.AZSupportEffects = formations[player_id].az_support_effects
	var opponent_az_support_effects: Formation.AZSupportEffects = formations[opponent_id].az_support_effects
	var sz_vivosaurs: Array[VivosaurBattle] = formations[player_id].get_sz_vivosaurs()

	for index: int in range(len(sz_vivosaurs)):
		var vivosaur_battle: VivosaurBattle = sz_vivosaurs[index]
		if vivosaur_battle == null or vivosaur_battle.is_support_effects_applied:
			continue

		var support_effects: SupportEffects = vivosaur_battle.vivosaur_info.support_effects
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

func recharge_fp(player_id: int) -> void:
	formations[player_id].recharge_fp()
	fp_recharged.emit(player_id)
