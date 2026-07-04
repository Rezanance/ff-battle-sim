extends Node

@rpc("any_peer", "call_remote", "reliable")
func client_battle_scene_loaded(battle_id: int) -> void:
	assert(multiplayer.is_server())
	
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var player1: int = battle_info.player1_id
	var player2: int = battle_info.player2_id
	battle_info.responses_to_server.append(multiplayer.get_remote_sender_id())
	if (player1 not in battle_info.responses_to_server or
	player2 not in battle_info.responses_to_server):
		return
	
	battle_info.responses_to_server = []
	var battlefield: BattleField = battle_info.battlefield
	battlefield.apply_support_effects(player1)
	battlefield.apply_support_effects(player2)
	
	battlefield.who_goes_first()
	
	battlefield.start_turn()

@rpc("any_peer", "call_remote", "reliable")
func end_turn(battle_id: int) -> void:
	assert(multiplayer.is_server())
	var sender_player_id: int = multiplayer.get_remote_sender_id()
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var battlefield: BattleField = battle_info.battlefield
	if sender_player_id != battlefield.turn_id:
		return
	
	battlefield.end_turn()
	battlefield.start_turn()

@rpc("any_peer", "call_remote", "reliable")
func use_skill(battle_id: int, initiator_zone: int, skill_id: String, target_player_id: int = -1, target_zone: int = -1) -> void:
	assert(multiplayer.is_server())

	var initiator_player_id: int = multiplayer.get_remote_sender_id()
	
	var battle_info: BattleInfo = ServerVariables.battles[battle_id]
	var battlefield: BattleField = battle_info.battlefield
	
	if battlefield.turn_id != initiator_player_id:
		return
	
	var initiator: Vivosaur = battlefield.formations[initiator_player_id].get_vivosaur_from_zone(initiator_zone)
	if not initiator:
		return
	
	var initiator_skill: Skill = initiator.vivosaur_info.skills.filter(func(skill: Skill) -> bool: return skill.id == skill_id)[0]

	var target: Vivosaur = (battlefield.formations[target_player_id].get_vivosaur_from_zone(target_zone)
		if target_player_id != -1 and target_zone != -1 else null)
	
	battlefield.formations[initiator_player_id].spend_fp(initiator_skill.fp_cost)

	Logging.info('%d - %d uses %s' % [battle_id, initiator_player_id, initiator_skill.name])
	
	match initiator_skill.target:
		Skill.Target.ENEMY:
			battlefield.calculate_damage(initiator_player_id, initiator, target, initiator_skill)
