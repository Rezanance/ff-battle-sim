extends Node

signal support_effects_applied(event: SupportEffectsAppliedEvent)
signal first_player_determined(event: FirstPlayerDeterminedEvent)
signal turn_started(event: TurnStartedEvent)
signal fp_gained(event: FpGainedEvent)

@rpc("authority", "call_remote", "reliable")
func notify_support_effects_applied(event_dict: Dictionary[String, Variant]) -> void:
	support_effects_applied.emit(SupportEffectsAppliedEvent.deserialize(event_dict))

@rpc("authority", "call_remote", "reliable")
func notify_first_player_determined(event_dict: Dictionary[String, int]) -> void:
	first_player_determined.emit(FirstPlayerDeterminedEvent.deserialize(event_dict))

@rpc("authority", "call_remote", "reliable")
func notify_turn_start(event_dict: Dictionary[String, int]) -> void:
	turn_started.emit(TurnStartedEvent.deserialize(event_dict))

@rpc("authority", "call_remote", "reliable")
func notify_fp_gained(event_dict: Dictionary[String, int]) -> void:
	fp_gained.emit(FpGainedEvent.deserialize(event_dict))
