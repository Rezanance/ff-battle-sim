extends Node


func display_support_effects(
	id: int, 
	index: int
):
	var support_sprites = BattleVariables.battlefield.formations[id].get_support_zones_sprite_btns()
	
	var tween = create_tween()
	BattleNodes.player_atk_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.player_id].az_support_effects.atk * 100) + '%'
	BattleNodes.player_def_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.player_id].az_support_effects.def * 100) + '%'
	BattleNodes.player_acc_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.player_id].az_support_effects.acc * 100) + '%'
	BattleNodes.player_eva_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.player_id].az_support_effects.eva * 100) + '%'

	BattleNodes.opponent_atk_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.opponent_id].az_support_effects.atk * 100) + '%'
	BattleNodes.opponent_def_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.opponent_id].az_support_effects.def * 100) + '%'
	BattleNodes.opponent_acc_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.opponent_id].az_support_effects.acc * 100) + '%'
	BattleNodes.opponent_eva_modifier.text = "%d" % (BattleVariables.battlefield.formations[BattleVariables.opponent_id].az_support_effects.eva * 100) + '%'
	
	tween.tween_property(support_sprites[index], 'scale', Vector2(1.2, 1.2), 0.1)
	tween.tween_property(support_sprites[index], 'scale', Vector2(1.0, 1.0), 0.1)
	await tween.finished
	await get_tree().create_timer(0.33).timeout
	BattleVariables.battlefield.apply_next_support_effects.emit()

func apply_support_effects(id: int):
	await BattleVariables.battlefield.apply_support_effects(id)
