# Autoload ClientRPCs
extends Node

signal opponent_not_online()
signal opponent_busy()
signal battle_requested(challenger_info: PlayerInfo)
signal challenge_declined(opponent_info: PlayerInfo)
signal challenge_accepted(opponent_info: PlayerInfo)

@rpc("authority", "call_remote", "reliable")
func forward_opponent_not_online() -> void:
	opponent_not_online.emit()

@rpc("authority", "call_remote", "reliable")
func forward_opponent_busy() -> void:
	opponent_busy.emit()

@rpc("authority", "call_remote", "reliable")
func forward_challenge(challenger_info: Dictionary) -> void:
	battle_requested.emit(Serializer.deserialize(challenger_info, PlayerInfo))

@rpc("authority", "call_remote", "reliable")
func forward_decline_challenge(opponent_info: Dictionary) -> void:
	challenge_declined.emit(Serializer.deserialize(opponent_info, PlayerInfo))

@rpc("authority", "call_remote", "reliable")
func forward_accept_challenge(opponent_info: Dictionary) -> void:
	challenge_accepted.emit(Serializer.deserialize(opponent_info, PlayerInfo))

signal battle_created(battle_id: int)
signal battle_prep_started(opponent_info: PlayerInfo, opponent_team_info: Team)
signal battle_started(formations: Dictionary[int, Formation])

@rpc('authority', "call_remote", 'reliable')
func notify_battle_created_server(battle_id: int) -> void:
	battle_created.emit(battle_id)

@rpc('authority', "call_remote", 'reliable')
func notify_battle_prep_start(event: Dictionary) -> void:
	battle_prep_started.emit(Serializer.deserialize(event, BattlePrepStartedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_battle_start(
	event: Dictionary
) -> void:
	var formations: Dictionary[int, Formation] = {}
	var battle_started_event: BattleStartedEvent = Serializer.deserialize(event, BattleStartedEvent)
	var team1: Team = Team.deserialize(battle_started_event.team1)
	var team2: Team = Team.deserialize(battle_started_event.team2)
	formations[battle_started_event.player1] = Formation.new(
		VivosaurState.new(battle_started_event.player1, VivosaurInfo.load(team1.slots[Team.Zone.AZ])),
		VivosaurState.new(battle_started_event.player1, VivosaurInfo.load(team1.slots[Team.Zone.SZ1])) if team1.slots[Team.Zone.SZ1] else null,
		VivosaurState.new(battle_started_event.player1, VivosaurInfo.load(team1.slots[Team.Zone.SZ2])) if team1.slots[Team.Zone.SZ2] else null,
	)
	formations[battle_started_event.player2] = Formation.new(
		VivosaurState.new(battle_started_event.player2, VivosaurInfo.load(team2.slots[Team.Zone.AZ])),
		VivosaurState.new(battle_started_event.player2, VivosaurInfo.load(team2.slots[Team.Zone.SZ1])) if team2.slots[Team.Zone.SZ1] else null,
		VivosaurState.new(battle_started_event.player2, VivosaurInfo.load(team2.slots[Team.Zone.SZ2])) if team2.slots[Team.Zone.SZ2] else null,
	)
	
	battle_started.emit(formations)

signal support_effects_applied(event: SupportEffectsAppliedEvent)
signal first_player_determined(event: FirstPlayerDeterminedEvent)
signal turn_started(event: TurnStartedEvent)
signal fp_gained(event: FpGainedEvent)
signal fp_spent(event: FpSpentEvent)
signal vivosaur_damaged(event: VivosaurDamagedEvent)
signal vivosaur_swapped_to_ez(event: VivosaurSwappedToEZEvent)
signal vivosaur_back_to_sz(event: VivosaurBackToSzEvent)
signal skill_missed(event: SkillMissedEvent)

@rpc("authority", "call_remote", "reliable")
func notify_support_effects_applied(event_dict: Dictionary[String, Variant]) -> void:
	support_effects_applied.emit(Serializer.deserialize(event_dict, SupportEffectsAppliedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_first_player_determined(event_dict: Dictionary[String, int]) -> void:
	first_player_determined.emit(Serializer.deserialize(event_dict, FirstPlayerDeterminedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_turn_start(event_dict: Dictionary[String, int]) -> void:
	turn_started.emit(Serializer.deserialize(event_dict, TurnStartedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_fp_gained(event_dict: Dictionary[String, int]) -> void:
	fp_gained.emit(Serializer.deserialize(event_dict, FpGainedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_fp_spent(event_dict: Dictionary[String, int]) -> void:
	fp_spent.emit(Serializer.deserialize(event_dict, FpSpentEvent))

@rpc("authority", "call_remote", "reliable")
func notify_vivosaur_damaged(event_dict: Dictionary[String, Variant]) -> void:
	vivosaur_damaged.emit(Serializer.deserialize(event_dict, VivosaurDamagedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_vivosaur_swapped_to_ez(event_dict: Dictionary[String, Variant]) -> void:
	vivosaur_swapped_to_ez.emit(Serializer.deserialize(event_dict, VivosaurSwappedToEZEvent))

@rpc("authority", "call_remote", "reliable")
func notify_skill_missed(event_dict: Dictionary[String, Variant]) -> void:
	skill_missed.emit(Serializer.deserialize(event_dict, SkillMissedEvent))

@rpc("authority", "call_remote", "reliable")
func notify_vivosaur_back_to_sz(event_dict: Dictionary[String, Variant]) -> void:
	vivosaur_back_to_sz.emit(Serializer.deserialize(event_dict, VivosaurBackToSzEvent))
