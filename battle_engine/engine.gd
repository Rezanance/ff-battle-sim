class_name BattleEngine

const Phase = BattleState.Phase
const Zone = PlayerZone.Zone
const Element = VivosaurInfo.Element

signal initial_teams_registered()
signal battle_prep_started(event: BattlePrepStartedEvent)
signal formations_submitted()
signal all_client_scenes_loaded()
signal battle_started(event: BattleStartedEvent)
signal support_effects_applied(event: SupportEffectsAppliedEvent)
signal first_player_determined(event: FirstPlayerDeterminedEvent)
signal fp_gained(event: FpGainedEvent)
signal fp_spent(event: FpSpentEvent)
signal turn_started(event: TurnStartedEvent)
signal turn_ended(event: TurnEndedEvent)
signal vivosaur_swapped_to_ez(event: VivosaurSwappedToEZEvent)
signal vivosaur_back_to_sz(event: VivosaurBackToSzEvent)
signal skill_used(event: SkillUsedEvent)
signal skill_missed(event: SkillMissedEvent)
signal vivosaur_damaged(event: VivosaurDamagedEvent)

signal action_queued(action: Variant, engine_callback: Callable)
var action_queue: Array[ActionCallback] = []

var state: BattleState

func _init(initial_state: BattleState) -> void:
	state = initial_state

func start() -> void:
	# each player calls register_team_initial outside
	await initial_teams_registered

	_start_battle_prep()

	# each player calls 
	await formations_submitted

	_start_battle()

	await all_client_scenes_loaded
	
	for id: int in state.player_ids:
		_apply_support_effects(id)
	_determine_who_goes_first()

	# Game loop
	while true:
		_start_turn()

		var winner: Variant = null
		# Turn loop
		while true:
			state.phase = Phase.SELECT_ACTION
			# The player whos turn it is can use a skill, swap to ez or end turn
			await action_queued
			var action_callback: ActionCallback = action_queue.pop_front()

			await action_callback.callback.call(action_callback.action)
			
			if state.winner != null:
				winner = state.winner
				break
			
			if action_callback.action is EndTurnAction:
				break
		
		if winner != null:
			break
		
func _start_battle_prep() -> void:
	state.phase = Phase.BATTLE_PREP
	var player1: int = state.player_ids[0]
	var player2: int = state.player_ids[1]

	var event: BattlePrepStartedEvent = BattlePrepStartedEvent.new()
	event.player1 = player1
	event.team1 = state.teams[player1].serialize()
	event.player2 = player2
	event.team2 = state.teams[player2].serialize()
	battle_prep_started.emit(event)

func _start_battle() -> void:
	var player1: int = state.player_ids[0]
	var player2: int = state.player_ids[1]

	var event: BattleStartedEvent = BattleStartedEvent.new()
	event.player1 = player1
	event.team1 = state.teams[player1].serialize()
	event.player2 = player2
	event.team2 = state.teams[player2].serialize()
	battle_started.emit(event)

func _get_opponent_id(player_id: int) -> int:
	return state.player_ids[state.player_ids.find_custom(func(id: int) -> bool: return id != player_id)]

func _apply_support_effects(player_id: int) -> void:
	state.phase = Phase.APPLY_SUPPORT_EFFECTS
	var opponent_id: int = _get_opponent_id(player_id)

	for sz: Zone in [Zone.SZ1, Zone.SZ2]:
		var sz_vivo: VivosaurState = state.formations[player_id].vivosaurs[sz]

		if not sz_vivo:
			continue
		
		var support_effects: SupportEffects = sz_vivo.info.support_effects

		var target_az: VivosaurState
		if sz_vivo.info.support_effects.own_az:
			target_az = state.formations[player_id].vivosaurs[Zone.AZ]
		else:
			target_az = state.formations[opponent_id].vivosaurs[Zone.AZ]
		
		# Check if support effects have already been applied by this vivosaur
		if target_az.support_received.find_custom(func(sup: PlayerZone) -> bool: return sup.player_id == player_id and sup.zone == sz) != -1:
			continue

		target_az.attack_modifier += support_effects.attack_modifier
		target_az.defense_modifier += support_effects.defense_modifier
		target_az.accuracy_modifier += support_effects.accuracy_modifier
		target_az.evasion_modifier += support_effects.evasion_modifier

		target_az.support_received.append(PlayerZone.new(player_id, sz))

		var event: SupportEffectsAppliedEvent = SupportEffectsAppliedEvent.new()
		event.player_id = player_id
		event.support_zone = sz
		event.target_player_id = target_az.player_id
		event.attack_modifier = support_effects.attack_modifier
		event.defense_modifier = support_effects.defense_modifier
		event.accuracy_modifier = support_effects.accuracy_modifier
		event.evasion_modifier = support_effects.evasion_modifier
		support_effects_applied.emit(event)

func _calculate_total_lp(vivosaurs: Array[VivosaurState]) -> int:
	return vivosaurs.reduce(func(acc: int, vivo: VivosaurState) -> int: return acc + (vivo.info.stats.life_points if vivo else 0), 0)

func _determine_who_goes_first() -> void:
	state.phase = Phase.DETERMINE_WHO_GOES_FIRST
	var player1_id: int = state.player_ids[0]
	var player2_id: int = state.player_ids[1]
	var player_1_total_lp: int = _calculate_total_lp(state.formations[state.player_ids[0]].vivosaurs)
	var player_2_total_lp: int = _calculate_total_lp(state.formations[state.player_ids[1]].vivosaurs)

	var first_player_id: int
	
	if player_1_total_lp < player_2_total_lp:
		first_player_id = player1_id
	elif player_1_total_lp > player_2_total_lp:
		first_player_id = player2_id
	else:
		first_player_id = player1_id if randi() % 100 < 50 else player2_id
	
	var event: FirstPlayerDeterminedEvent = FirstPlayerDeterminedEvent.new()
	event.player1_id = player1_id
	event.player1_total_lp = player_1_total_lp
	event.player2_id = player2_id
	event.player2_total_lp = player_2_total_lp
	first_player_determined.emit(event)
	
	state.turn_id = first_player_id

func _recharge_fp() -> void:
	state.phase = Phase.RECHARGE_FP
	var formation: Formation = state.formations[state.turn_id]
	var fp_diff: int
	if formation.fp + Formation.BASE_FP_RECHARGE > Formation.MAX_FP:
		fp_diff = Formation.MAX_FP - formation.fp
		state.formations[state.turn_id].fp += fp_diff
	else:
		fp_diff = Formation.BASE_FP_RECHARGE
		formation.fp += fp_diff
	
	var event: FpGainedEvent = FpGainedEvent.new()
	event.player_id = state.turn_id
	event.fp_diff = fp_diff
	event.current_fp = formation.fp
	fp_gained.emit(event)

func _start_turn() -> void:
	var event: TurnStartedEvent = TurnStartedEvent.new()
	event.player_id = state.turn_id
	turn_started.emit(event)

	var formation: Formation = state.formations[state.turn_id]
	var vivosaurs: Array[VivosaurState] = formation.vivosaurs

	if formation.turns_left_in_ez > 0:
		formation.turns_left_in_ez -= 1
	if vivosaurs[Zone.EZ] != null and formation.turns_left_in_ez == 0:
		_move_back_to_ez(formation)

	for zone: Zone in [Zone.AZ, Zone.SZ1, Zone.SZ2]:
		var vivo: VivosaurState = vivosaurs[zone]
		if not vivo:
			continue
		vivo.can_use_skill = true

	for id: int in state.player_ids:
		_apply_support_effects(id)

	_recharge_fp()

func end_turn(_action: EndTurnAction) -> void:
	state.phase = Phase.RESOLVE_ACTION
	
	Logging.info(state.turn_id)
	state.turn_id = _get_opponent_id(state.turn_id)
	Logging.info(state.turn_id)

	# TODO apply statuses and reduce turn count.

	var event: TurnEndedEvent = TurnEndedEvent.new()
	event.player_id = state.turn_id
	turn_ended.emit(event)


func swap_to_ez(action: SwapToEzAction) -> void:
	state.phase = Phase.RESOLVE_ACTION
	
	var vivosaurs: Array[VivosaurState] = state.formations[action.player_id].vivosaurs

	if vivosaurs[Zone.EZ] != null:
		Logging.error('Cannot swap to EZ when there is already a vivosaur already in the EZ')
		return
	if vivosaurs[action.sz] == null:
		Logging.error('No vivosaur in that support zone')
		return

	vivosaurs[Zone.EZ] = vivosaurs[Zone.AZ]
	vivosaurs[Zone.AZ] = vivosaurs[action.sz]
	vivosaurs[action.sz] = null

	vivosaurs[Zone.EZ].attack_modifier = 0
	vivosaurs[Zone.EZ].defense_modifier = 0
	vivosaurs[Zone.EZ].accuracy_modifier = 0
	vivosaurs[Zone.EZ].evasion_modifier = 0

	vivosaurs[Zone.AZ].attack_modifier = 0
	vivosaurs[Zone.AZ].defense_modifier = 0
	vivosaurs[Zone.AZ].accuracy_modifier = 0
	vivosaurs[Zone.AZ].evasion_modifier = 0

	vivosaurs[Zone.EZ].can_use_skill = false

	state.formations[action.player_id].turns_left_in_ez = 3

	var event: VivosaurSwappedToEZEvent = VivosaurSwappedToEZEvent.new()
	event.player_id = action.player_id
	event.support_zone = action.sz
	vivosaur_swapped_to_ez.emit(event)

func _move_back_to_ez(formation: Formation) -> void:
	var vivosaurs: Array[VivosaurState] = formation.vivosaurs
	if vivosaurs[Zone.SZ1] == null:
		vivosaurs[Zone.SZ1] = vivosaurs[Zone.EZ]
	else:
		vivosaurs[Zone.SZ2] = vivosaurs[Zone.EZ]
	
	vivosaurs[Zone.EZ] = null

	var event: VivosaurBackToSzEvent = VivosaurBackToSzEvent.new()
	event.player_id = state.turn_id
	vivosaur_back_to_sz.emit()

func _spend_fp(player_id: int, fp_cost: int) -> bool:
	var formation: Formation = state.formations[player_id]
	if formation.fp - fp_cost < 0:
		return false

	formation.fp -= fp_cost

	var event: FpSpentEvent = FpSpentEvent.new()
	event.player_id = player_id
	event.fp_cost = fp_cost
	event.current_fp = formation.fp
	fp_spent.emit(event)
	return true

func _is_hit(initiator: VivosaurState, target: VivosaurState) -> bool:
	var acc_min_speed: float = initiator.info.stats.accuracy - target.info.stats.evasion
	var chance: float = 0
	if acc_min_speed < -10:
		chance = 0.1
	elif acc_min_speed >= -10 and acc_min_speed < 0:
		chance = 0.8 + 0.7 * sin(PI * acc_min_speed / 20)
	elif acc_min_speed >= 0 and acc_min_speed < 10:
		chance = 0.8 + 0.2 * sin(PI * acc_min_speed / 20)
	else:
		chance = 1
	
	return randf() <= chance

func _get_vivosaur_zone(vivosaur: VivosaurState) -> Zone:
	var vivosaurs: Array[VivosaurState] = state.formations[vivosaur.player_id].vivosaurs
	var az_id: String = vivosaurs[Zone.AZ].info.id
	var sz1_id: String = vivosaurs[Zone.SZ1].info.id if vivosaurs[Zone.SZ1] else ''
	var sz2_id: String = vivosaurs[Zone.SZ2].info.id if vivosaurs[Zone.SZ2] else ''

	match vivosaur.info.id:
		az_id:
			return Zone.AZ
		sz1_id:
			return Zone.SZ1
		sz2_id:
			return Zone.SZ2
		_:
			return Zone.EZ

func _calculate_damage(initiator: VivosaurState, target: VivosaurState, skill: Skill) -> void:
	var element_multiplier: float = 1
	var initiator_element: Element = initiator.info.element
	var target_element: Element = target.info.element
	var range_multiplier: float = (initiator.info.stats.ranged_multiplier if
			(_get_vivosaur_zone(initiator) == Zone.AZ and _get_vivosaur_zone(target) in [Zone.SZ1, Zone.SZ2])
			or (_get_vivosaur_zone(initiator) in [Zone.SZ1, Zone.SZ2] and _get_vivosaur_zone(target) == Zone.AZ)
		else 1.0)
	var critical_hit_multiplier: float = 1.5 if skill.type != Skill.Type.TEAM_SKILL and randf() <= initiator.info.stats.crit_chance else 1.0

	# Favorable matchup
	if ((initiator_element == Element.AIR and target_element == Element.WATER)
			or (initiator_element == Element.EARTH and target_element == Element.AIR)
			or (initiator_element == Element.FIRE and target_element == Element.EARTH)
			or (initiator_element == Element.WATER and target_element == Element.FIRE)):
		element_multiplier = 1.5
	elif ((initiator_element == Element.AIR and target_element == Element.EARTH)
			or (initiator_element == Element.EARTH and target_element == Element.FIRE)
			or (initiator_element == Element.FIRE and target_element == Element.WATER)
			or (initiator_element == Element.WATER and target_element == Element.AIR)):
		element_multiplier = 0.75

	var damage: int = ((((initiator.info.stats.attack + skill.damage) * (1 + initiator.attack_modifier))
		- (target.info.stats.defense * (1 + target.defense_modifier)))
		* randfn(1.0, 0.025)
		* element_multiplier
		* range_multiplier
		* critical_hit_multiplier) as int
		# TODO: add parting blow modifier
	
	Logging.info('Damage info - atk: %d, skill dmg: %d, atk mod: %f, def: %d, def mod: %f, element mod: %f, range mod: %d, crit mod: %f' % [
		initiator.info.stats.attack, skill.damage, initiator.attack_modifier, target.info.stats.defense,
		target.defense_modifier, element_multiplier, range_multiplier, critical_hit_multiplier
	])

	var event: VivosaurDamagedEvent = VivosaurDamagedEvent.new()
	event.player_id = target.player_id
	event.zone = _get_vivosaur_zone(target)
	event.damage = damage
	event.is_critical_hit = critical_hit_multiplier == 1.5
	event.current_lp_percent = target.current_lp / (target.info.stats.life_points as float) * 100

	vivosaur_damaged.emit(event)
	
func use_skill(action: UseSkillAction) -> void:
	if state.turn_id != action.player_id:
		Logging.error('Player %d can\'t use a skill now. Not their turn' % action.player_id)
		return
	if action.zone in [PlayerZone.Zone.SZ1, PlayerZone.Zone.SZ2] and action.target.zone in [PlayerZone.Zone.SZ1, PlayerZone.Zone.SZ2]:
		Logging.error('A vivosaur in the SZ cannot target another vivosaur in the enemy SZ, only the AZ')

	var initiator: VivosaurState = state.formations[action.player_id].vivosaurs[action.zone]
	if initiator == null:
		Logging.error('Vivosaur does not exist')
		return
	if initiator.can_use_skill == null:
		Logging.error('This vivosaur already used a skill this turn')
		return

	var initiator_skill: Skill = initiator.info.skills[initiator.info.skills.find_custom(func(skill: Skill) -> bool: return skill.id == action.skill_id)]

	if not _spend_fp(action.player_id, initiator_skill.fp_cost):
		Logging.error('Not enough FP use skill')
		return
	
	var target: VivosaurState = state.formations[action.target.player_id].vivosaurs[action.target.zone]

	Logging.info('Player %d\'s %s uses %s' % [action.player_id, initiator.info.name, initiator_skill.name])

	var skill_used_event: SkillUsedEvent = SkillUsedEvent.new()
	skill_used_event.player_id = action.player_id
	skill_used_event.zone = action.zone
	skill_used_event.skill_id = action.skill_id
	skill_used_event.target_id = action.target.player_id
	skill_used_event.target_zone = action.target.zone
	skill_used.emit(skill_used_event)
	
	match initiator_skill.target:
		Skill.Target.ENEMY:
			if not target:
				Logging.error('Single enemy target skills must specify a target')
				return
			if _is_hit(initiator, target):
				_calculate_damage(initiator, target, initiator_skill)
			else:
				var skill_missed_event: SkillMissedEvent = SkillMissedEvent.new()
				skill_missed_event.player_id = action.target.player_id
				skill_missed_event.target_zone = action.target.zone
				skill_missed.emit(skill_missed_event)
		Skill.Target.ENEMY_AZ_AND_SZ:
			var opponent_id: int = _get_opponent_id(action.player_id)
			for zone: PlayerZone.Zone in [PlayerZone.Zone.AZ, PlayerZone.Zone.SZ1, PlayerZone.Zone.SZ2]:
				target = state.formations[opponent_id].vivosaurs[zone]
				if target and _is_hit(initiator, target):
					_calculate_damage(initiator, target, initiator_skill)
					
		_:
			Logging.error('Not implemented yet')
			return
	
	initiator.can_use_skill = false
