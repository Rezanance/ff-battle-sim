extends Node

func animate_turn_start(id: int):
	if id == multiplayer.get_unique_id():
		BattleNodes.opponent_fp_bg.texture = load("res://client/assets/fp_counter/opp_not_turn.png")
		BattleNodes.player_fp_bg.texture = load("res://client/assets/fp_counter/player_turn.png")
	else:
		BattleNodes.player_fp_bg.texture = load("res://client/assets/fp_counter/player_not_turn.png")
		BattleNodes.opponent_fp_bg.texture = load("res://client/assets/fp_counter/opp_turn.png")

	var tween = create_tween()
	var turn: Control
	var turn_start: Control
	if id == multiplayer.get_unique_id():
		turn = BattleNodes.player_turn
		turn_start = BattleNodes.player_turn_start
	else:
		turn = BattleNodes.opponent_turn
		turn_start = BattleNodes.opponent_turn_start
	
	tween.tween_property(turn, "position", Vector2(0, 0), 0.2)
	
	await tween.finished
	await get_tree().create_timer(0.33).timeout
	
	turn.position = turn_start.position
	
func recharge_fp(id: int):
	BattleVariables.battlefield.recharge_fp(id)

	var fp: Label
	var fp_delta: Label

	if id == multiplayer.get_unique_id():
		fp = BattleNodes.player_fp
		fp_delta = BattleNodes.player_fp_delta
	else:
		fp = BattleNodes.opponent_fp
		fp_delta = BattleNodes.opponent_fp_delta
	
	var old_fp: int = int(fp.text)
	var delta_fp: int = BattleVariables.battlefield.formations[id].fp - old_fp
	
	fp_delta.visible = true
	fp_delta.text = '+%d' % delta_fp

	for i in range(1, delta_fp + 1, 5):
		fp.text = '%d' % (old_fp + i)
		await get_tree().create_timer(0.0056).timeout
	
	fp.text = '%d' % (old_fp + delta_fp)
	fp_delta.visible = false
