extends Node

static func notify_support_effects_applied(
	support_effects_applied_event: SupportEffectsAppliedEvent,
	player1_id: int, 
	player2_id: int
) -> void:
	var event_dict: Dictionary[String, Variant] = support_effects_applied_event.serialize()
	ClientBattle.notify_support_effects_applied.rpc_id(player1_id, event_dict)
	ClientBattle.notify_support_effects_applied.rpc_id(player2_id, event_dict)

static func notify_first_player_determined(
	first_player_determined_event: FirstPlayerDeterminedEvent,
	player1_id: int, 
	player2_id: int,
) -> void:
	var event_dict: Dictionary[String, int] = first_player_determined_event.serialize()
	ClientBattle.notify_first_player_determined.rpc_id(player1_id, event_dict)
	ClientBattle.notify_first_player_determined.rpc_id(player2_id, event_dict)
