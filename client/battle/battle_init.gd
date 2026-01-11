extends Node


enum Zone {AZ, SZ1, SZ2}

func create_battlefield():
	var player_slot1 = Networking.player_team.slots[0]
	var player_slot2 = Networking.player_team.slots[1]
	var player_slot3 = Networking.player_team.slots[2]

	var opponent_slot1 = Networking.opponent_team.slots[0]
	var opponent_slot2 = Networking.opponent_team.slots[1]
	var opponent_slot3 = Networking.opponent_team.slots[2]

	var formations: Dictionary[int, Formation] = {}
	formations[Networking.player_info.player_id] = Formation.new(
		VivosaurBattle.new(player_slot1) if player_slot1 != null else null,
		VivosaurBattle.new(player_slot2) if player_slot2 != null else null,
		VivosaurBattle.new(player_slot3) if player_slot3 != null else null,
	)
	formations[Networking.opponent_info.player_id] = Formation.new(
		VivosaurBattle.new(opponent_slot1) if opponent_slot1 != null else null,
		VivosaurBattle.new(opponent_slot2) if opponent_slot2 != null else null,
		VivosaurBattle.new(opponent_slot3) if opponent_slot3 != null else null,
	)
	BattleVariables.battlefield = BattleField.new(formations, true)

	BattleVariables.battlefield.support_effects_applied.connect(SupportEffectsUI.display_support_effects)

func add_player_vivosaurs():
	var formation = BattleVariables.battlefield.formations[Networking.player_info.player_id]	
	var vivosaurs: Dictionary[Zone, VivosaurBattle] = {
		Zone.AZ: formation.az,
		Zone.SZ1: formation.sz1,
		Zone.SZ2: formation.sz2
	}
	var vivosaur_sprites_btns: Dictionary[Zone, TextureButton] = {
		Zone.AZ: BattleNodes.opponent_vivosaur1_sprite_btn,
		Zone.SZ1: BattleNodes.opponent_vivosaur2_sprite_btn,
		Zone.SZ2: BattleNodes.opponent_vivosaur3_sprite_btn,
	}
	var zone_start_positions: Dictionary[Zone, Vector2] = {
		Zone.AZ: BattleNodes.player_az_start.global_position,
		Zone.SZ1: BattleNodes.player_sz1_start.global_position,
		Zone.SZ2: BattleNodes.player_sz2_start.global_position,
	}
	
	for zone in Zone.values():
		if vivosaurs[zone] != null:
			vivosaur_sprites_btns[zone].global_position = zone_start_positions[zone]
			vivosaur_sprites_btns[zone].texture_normal = load('res://client/assets/vivosaurs/%d/sprite/%d.png' % [vivosaurs[zone].vivosaur_info.id, vivosaurs[zone].vivosaur_info.id])
			vivosaur_sprites_btns[zone].get_node('LifeBar/Bg').texture = load('res://client/assets/lifebars/%d.png' % vivosaurs[zone].vivosaur_info.element)
			vivosaur_sprites_btns[zone].pressed.connect(VivosaurSignalHandlers.on_vivosaur_selected.bind(vivosaurs[zone], vivosaur_sprites_btns[zone], true))
			vivosaur_sprites_btns[zone].mouse_entered.connect(VivosaurSignalHandlers.on_vivosaur_hover.bind(vivosaurs[zone], vivosaur_sprites_btns[zone]))
			formation.az_sprite_btn = vivosaur_sprites_btns[zone]
		else:
			vivosaur_sprites_btns[zone].queue_free()

func add_opponent_vivosaurs():
	var formation = BattleVariables.battlefield.formations[Networking.opponent_info.player_id]	
	var vivosaurs: Dictionary[Zone, VivosaurBattle] = {
		Zone.AZ: formation.az,
		Zone.SZ1: formation.sz1,
		Zone.SZ2: formation.sz2
	}
	var vivosaur_sprites_btns: Dictionary[Zone, TextureButton] = {
		Zone.AZ: BattleNodes.opponent_vivosaur1_sprite_btn,
		Zone.SZ1: BattleNodes.opponent_vivosaur2_sprite_btn,
		Zone.SZ2: BattleNodes.opponent_vivosaur3_sprite_btn,
	}
	
	for zone in Zone.values():
		vivosaur_sprites_btns[zone].flip_h = false
		
		if vivosaurs[zone] != null:
			vivosaur_sprites_btns[zone].texture_normal = load('res://client/assets/vivosaurs/%d/sprite/%d.png' % [vivosaurs[zone].vivosaur_info.id, vivosaurs[zone].vivosaur_info.id])
			vivosaur_sprites_btns[zone].get_node('LifeBar/Bg').texture = load('res://client/assets/lifebars/%d.png' % vivosaurs[zone].vivosaur_info.element)
			vivosaur_sprites_btns[zone].pressed.connect(VivosaurSignalHandlers.on_vivosaur_selected.bind(vivosaurs[zone], vivosaur_sprites_btns[zone], true))
			vivosaur_sprites_btns[zone].mouse_entered.connect(VivosaurSignalHandlers.on_vivosaur_hover.bind(vivosaurs[zone], vivosaur_sprites_btns[zone]))
			formation.az_sprite_btn = vivosaur_sprites_btns[zone]
		else:
			vivosaur_sprites_btns[zone].queue_free()

func initialize_turn_start_ui():
	var icon_path = 'res://client/assets/player-icons'
	var icon_files = ResourceLoader.list_directory(icon_path)

	BattleNodes.player_icon.texture = load(icon_path + '/' + icon_files[Networking.player_info.icon_id])
	BattleNodes.player_name.text = Networking.player_info.display_name

	BattleNodes.opponent_icon.texture = load(icon_path + '/' + icon_files[Networking.player_info.icon_id])
	BattleNodes.opponent_name.text = Networking.opponent_info.display_name

func animate_entrance():
	var tween = create_tween()
	tween.tween_property(BattleNodes.player_vivosaur1_sprite_btn, 'global_position', BattleNodes.player_az.global_position, 0.1)
	tween.set_parallel()
	tween.tween_property(BattleNodes.player_vivosaur2_sprite_btn, 'global_position', BattleNodes.player_sz1.global_position, 0.1).set_delay(0.05)
	tween.tween_property(BattleNodes.player_vivosaur3_sprite_btn, 'global_position', BattleNodes.player_sz2.global_position, 0.1).set_delay(0.1)
	await tween.finished

func animate_who_goes_first():
	var _player_total_lp = BattleVariables.battlefield.formations[BattleVariables.player_id].get_total_lp()
	var _opponent_total_lp = BattleVariables.battlefield.formations[BattleVariables.opponent_id].get_total_lp()

	BattleNodes.player_total_lp.get_node('Lp').text = '%d' % _player_total_lp
	BattleNodes.opponent_total_lp.get_node('Lp').text = '%d' % _opponent_total_lp

	BattleNodes.player_total_lp.visible = true
	BattleNodes.opponent_total_lp.visible = true

	var tween = create_tween()
	tween.tween_property(BattleNodes.player_total_lp, "global_position", BattleNodes.player_total_lp_finish.global_position, 0.33)
	tween.set_parallel()
	tween.tween_property(BattleNodes.opponent_total_lp, "global_position", BattleNodes.opponent_total_lp_finish.global_position, 0.33)

	await tween.finished

	var first_attack: TextureRect
	if _player_total_lp > _opponent_total_lp:
		first_attack = BattleNodes.player_total_lp.get_node('FirstAttack')
	else:
		first_attack = BattleNodes.opponent_total_lp.get_node('FirstAttack')
	
	tween = create_tween()
	
	tween.tween_property(first_attack, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.set_parallel()
	tween.tween_property(first_attack, "scale", Vector2(2, 2), 0.2)

	await tween.finished
	await get_tree().create_timer(0.5).timeout

	BattleNodes.player_total_lp.queue_free()
	BattleNodes.opponent_total_lp.queue_free()
