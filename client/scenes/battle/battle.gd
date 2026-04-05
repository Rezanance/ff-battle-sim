extends Node

var event_queue: Array[Variant] = []

@export var player_formation_ui: FormationUI
@export var opponent_formation_ui: FormationUI

func _ready() -> void:
	ClientBattle.support_effects_applied.connect(_update_support_effects)

func _update_support_effects(event: SupportEffectsAppliedEvent) -> void:
	return
