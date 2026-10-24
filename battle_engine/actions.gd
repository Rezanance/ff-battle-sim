class_name BattleActions

const Phase = BattleState.Phase

static func register_team_initial(engine: BattleEngine, player_id: int, team: Team) -> void:
	var teams: Dictionary[int, Team] = engine.state.teams
	if player_id not in teams.keys():
		teams[player_id] = team

	var team_player_ids: Array[int] = teams.keys()
	team_player_ids.sort()
	engine.state.player_ids.sort()
	if team_player_ids == engine.state.player_ids:
		engine.initial_teams_registered.emit()

static func submit_formation(engine: BattleEngine, player_id: int, team: Team) -> void:
	var state: BattleState = engine.state

	if not team.is_valid() or player_id in state.formations or state.phase != BattleState.Phase.BATTLE_PREP:
		return
	
	state.teams[player_id] = team

	var az_info: VivosaurInfo = VivosaurInfo.load(team.slots[Team.Zone.AZ])
	var sz1_info: VivosaurInfo = VivosaurInfo.load(team.slots[Team.Zone.SZ1])
	var sz2_info: VivosaurInfo = VivosaurInfo.load(team.slots[Team.Zone.SZ2])
	
	state.formations[player_id] = Formation.new(
		VivosaurState.new(player_id, az_info),
		VivosaurState.new(player_id, sz1_info) if sz1_info else null,
		VivosaurState.new(player_id, sz2_info) if sz2_info else null,
	)

	if len(state.formations.keys()) == len(state.player_ids):
		engine.formations_submitted.emit()

static func end_turn(engine: BattleEngine, action: EndTurnAction) -> void:
	if engine.state.phase != Phase.SELECT_ACTION or engine.state.turn_id != action.player_id:
		return
	
	var action_callback: ActionCallback = ActionCallback.new(action, engine._end_turn)
	engine.action_queue.append(action_callback)
	engine.action_queued.emit()

func swap_to_ez(engine: BattleEngine, action: SwapToEzAction) -> void:
	if engine.state.phase != Phase.SELECT_ACTION or engine.state.turn_id != action.player_id:
		return
	
	var action_callback: ActionCallback = ActionCallback.new(action, engine._move_back_to_ez)
	engine.action_queue.append(action_callback)
	engine.action_queued.emit()

func use_skill(engine: BattleEngine, action: UseSkillAction) -> void:
	if engine.state.phase != Phase.SELECT_ACTION or engine.state.turn_id != action.player_id:
		return
	
	var action_callback: ActionCallback = ActionCallback.new(action, engine._use_skill)
	engine.action_queue.append(action_callback)
	engine.action_queued.emit()
