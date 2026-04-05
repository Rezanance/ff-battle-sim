extends Node

signal support_effects_applied(event: SupportEffectsAppliedEvent)
signal turn_started(player_id: int)

@rpc("authority", "call_remote", "reliable")
func notify_support_effects_applied(event_dict: Dictionary[String, Variant]) -> void:
	support_effects_applied.emit(SupportEffectsAppliedEvent.deserialize(event_dict))

@rpc("authority", "call_remote", "reliable")
func notify_first_player_determined(event_dict: Dictionary[String, int]) -> void:
	return

@rpc("authority", "call_remote", "reliable")
func notify_turn_start(player_id: int) -> void:
	turn_started.emit(player_id)
