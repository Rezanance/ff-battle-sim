extends Node


func on_skill_clicked(event: InputEvent, skill: Skill, vivo_zone: Formation.Zone):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		BattleVariables.currently_selected_vivosaur_sprite_btn.get_node('Arrow').visible = false

		var player_zones = BattleVariables.battlefield.formations[BattleVariables.player_id]
		var player_az_cursor = player_zones.az_sprite_btn.get_node('Cursor') if player_zones.az_sprite_btn != null else null
		var player_sz1_cursor = player_zones.sz1_sprite_btn.get_node('Cursor') if player_zones.sz1_sprite_btn != null else null
		var player_sz2_cursor = player_zones.sz2_sprite_btn.get_node('Cursor') if player_zones.sz2_sprite_btn != null else null
		var opponent_zones = BattleVariables.battlefield.formations[BattleVariables.opponent_id]
		var opponent_az_cursor = opponent_zones.az_sprite_btn.get_node('Cursor') if opponent_zones.az_sprite_btn != null else null
		var opponent_sz1_cursor = opponent_zones.sz1_sprite_btn.get_node('Cursor') if opponent_zones.sz1_sprite_btn != null else null
		var opponent_sz2_cursor = opponent_zones.sz2_sprite_btn.get_node('Cursor') if opponent_zones.sz2_sprite_btn != null else null
		
		var player_cursors = [player_az_cursor, player_sz1_cursor, player_sz2_cursor]
		var opponent_cursors = [opponent_az_cursor, opponent_sz1_cursor, opponent_sz2_cursor]
		var player_sprite_btns = [player_zones.az_sprite_btn, player_zones.sz1_sprite_btn, player_zones.sz2_sprite_btn]
		var opponent_sprite_btns = [opponent_zones.az_sprite_btn, opponent_zones.sz1_sprite_btn, opponent_zones.sz2_sprite_btn]
		
		# Reset cursor visibility
		for cursor in player_cursors + opponent_cursors:
			if cursor != null: 
				cursor.visible = false

		match skill.target:
			Skill.Target.SELF:
				BattleVariables.selectable_targets = []
				for sprite_btn in player_sprite_btns + opponent_sprite_btns:
					if sprite_btn != null: 
						sprite_btn.self_modulate = Color.hex(0xffffff58)
				BattleVariables.currently_selected_vivosaur_sprite_btn.get_node('Cursor').visible = true
				BattleVariables.currently_selected_vivosaur_sprite_btn.self_modulate = Color.hex(0xffffffff)
			Skill.Target.ALL:
				BattleVariables.selectable_targets = []
				for cursor in player_cursors + opponent_cursors:
					if cursor != null: 
						cursor.visible = true
			Skill.Target.ALL_ALLIES:
				BattleVariables.selectable_targets = []
				for cursor in player_cursors:
					if cursor != null: 
						cursor.visible = true
				for sprite_btn in opponent_sprite_btns:
					if sprite_btn != null: 
						sprite_btn.self_modulate = Color.hex(0xffffff58)
			Skill.Target.ALL_ENEMIES:
				BattleVariables.selectable_targets = []
				for cursor in opponent_cursors:
					if cursor != null: 
						cursor.visible = true
				for sprite_btn in player_sprite_btns:
					if sprite_btn != null: 
						sprite_btn.self_modulate = Color.hex(0xffffff58)
			Skill.Target.ALLY:
				BattleVariables.selectable_targets = [player_zones.az_sprite_btn, player_zones.sz1_sprite_btn, player_zones.sz2_sprite_btn]
				for sprite_btn in opponent_sprite_btns:
					if sprite_btn != null: 
						sprite_btn.self_modulate = Color.hex(0xffffff58)
			Skill.Target.ALLY_EXCEPT_SELF:
				BattleVariables.selectable_targets = [
					player_zones.az_sprite_btn,
					player_zones.sz1_sprite_btn,
					player_zones.sz2_sprite_btn
				].filter(func(vivosaur_sprite_btn): return vivosaur_sprite_btn != BattleVariables.currently_selected_vivosaur_sprite_btn)
				for sprite_btn in opponent_sprite_btns:
					if sprite_btn != null: 
						sprite_btn.self_modulate = Color.hex(0xffffff58)
			Skill.Target.ENEMY:
				BattleVariables.selectable_targets = [opponent_zones.az_sprite_btn]
				for sprite_btn in player_sprite_btns:
					if sprite_btn != null: 
						sprite_btn.self_modulate = Color.hex(0xffffff58)

				if vivo_zone == Formation.Zone.AZ:
					BattleVariables.selectable_targets += [opponent_zones.sz1_sprite_btn, opponent_zones.sz2_sprite_btn]
				elif vivo_zone == Formation.Zone.SZ1 or vivo_zone == Formation.Zone.SZ2:
					if opponent_az_cursor != null: 
						opponent_az_cursor.visible = true
					if opponent_zones.sz1_sprite_btn != null: 
						opponent_zones.sz1_sprite_btn.self_modulate = Color.hex(0xffffff58)
					if opponent_zones.sz2_sprite_btn != null: 
						opponent_zones.sz2_sprite_btn.self_modulate = Color.hex(0xffffff58)

		for old_skill in BattleNodes.skills_container.get_children():
			old_skill.queue_free()
		
		BattleVariables.is_choosing_target = true

		BattleNodes.skill_back.visible = true
		BattleNodes.skill_ok.visible = true
