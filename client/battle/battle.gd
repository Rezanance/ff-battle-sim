extends ColorRect


func _ready() -> void:
	BattleVariables.player_id = Networking.player_info.player_id
	BattleVariables.opponent_id = Networking.opponent_info.player_id
	
	BattleInitiationUI.create_battlefield()
	BattleInitiationUI.add_player_vivosaurs()
	BattleInitiationUI.add_opponent_vivosaurs()
	BattleInitiationUI.initialize_turn_start_ui()
	await get_tree().create_timer(0.2).timeout

	await BattleInitiationUI.animate_entrance()
	await get_tree().create_timer(0.5).timeout

	await SupportEffectsUI.apply_support_effects(BattleVariables.player_id)
	await SupportEffectsUI.apply_support_effects(BattleVariables.opponent_id)
	await get_tree().create_timer(0.5).timeout

	await BattleInitiationUI.animate_who_goes_first()
	await get_tree().create_timer(0.5).timeout

	ClientTurnsOUT.who_goes_first(Networking.battle_id)
	ClientTurns.turn_started.connect(_on_turn_started)

func _on_turn_started(id: int):
	await TurnStartUI.animate_turn_start(id)
	await get_tree().create_timer(0.2).timeout

	await SupportEffectsUI.apply_support_effects(id)

	await TurnStartUI.recharge_fp(id)

func _on_back_pressed() -> void:
	BattleNodes.skill_back.visible = false
	BattleNodes.skill_ok.visible = false
	BattleVariables.is_choosing_target = false

	UIUtils.reset_cursor_modulate()

func _on_ok_pressed() -> void:
	BattleNodes.skill_back.visible = false
	BattleNodes.skill_ok.visible = false
	BattleVariables.is_choosing_target = false

	UIUtils.reset_cursor_modulate()

	# TODO notify server
