extends Button

@export var battle_setup_component: BattleSetupComponent

func _on_toggled(_toggled_on: bool) -> void:
	disabled = true
	battle_setup_component.ready_early(Networking.battle_id)
