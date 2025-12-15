extends Button


func _on_toggled(_toggled_on: bool) -> void:
	disabled = true
	ClientBattleSetupOUT.ready_early(Networking.battle_id)
