extends Button


func _on_toggled(_toggled_on: bool) -> void:
	disabled = true
	MultiplayerBattles.ready(Battle.battle_id)
