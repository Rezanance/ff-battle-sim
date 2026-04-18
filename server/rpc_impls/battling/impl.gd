extends Node

static func notify_support_effects_applied(
	support_effects_applied_event: SupportEffectsAppliedEvent,
	player1_id: int, 
	player2_id: int
) -> void:
	var event_dict: Dictionary[String, Variant] = support_effects_applied_event.serialize()
	ClientBattling.notify_support_effects_applied.rpc_id(player1_id, event_dict)
	ClientBattling.notify_support_effects_applied.rpc_id(player2_id, event_dict)

static func notify_first_player_determined(
	first_player_determined_event: FirstPlayerDeterminedEvent,
	player1_id: int, 
	player2_id: int,
) -> void:
	var event_dict: Dictionary[String, int] = first_player_determined_event.serialize()
	ClientBattling.notify_first_player_determined.rpc_id(player1_id, event_dict)
	ClientBattling.notify_first_player_determined.rpc_id(player2_id, event_dict)

static func notify_turn_started(
	turn_started_event: TurnStartedEvent,
	player1_id: int, 
	player2_id: int,
) -> void:
	var event_dict: Dictionary[String, int] = turn_started_event.serialize()
	ClientBattling.notify_turn_start.rpc_id(player1_id, event_dict)
	ClientBattling.notify_turn_start.rpc_id(player2_id, event_dict)


static func notify_fp_gained(
	fp_gained_event: FpGainedEvent,
	player1_id: int, 
	player2_id: int,
) -> void:
	var event_dict: Dictionary[String, int] = fp_gained_event.serialize()
	ClientBattling.notify_fp_gained.rpc_id(player1_id, event_dict)
	ClientBattling.notify_fp_gained.rpc_id(player2_id, event_dict)
