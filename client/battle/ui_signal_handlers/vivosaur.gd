extends Node


func on_vivosaur_selected(vivosaur: VivosaurBattle, vivosaur_sprite_btn: TextureButton, is_player_vivo: bool):
	if BattleVariables.currently_selected_vivosaur and BattleVariables.currently_selected_vivosaur_sprite_btn:
		BattleVariables.currently_selected_vivosaur_sprite_btn.get_node('Arrow').visible = false

	BattleVariables.currently_selected_vivosaur = vivosaur
	BattleVariables.currently_selected_vivosaur_sprite_btn = vivosaur_sprite_btn
	
	BattleVariables.currently_selected_vivosaur_sprite_btn.get_node('Arrow').visible = true
	UIUtils.show_vivosaur_summary(BattleNodes.vivosaur_summary, BattleVariables.currently_selected_vivosaur.vivosaur_info.id)

	var vivosaur_zone = BattleVariables.battlefield.formations[Networking.player_info.player_id].get_vivosaur_zone(vivosaur)
	if is_player_vivo and vivosaur_zone != Formation.Zone.EZ:
		UIUtils.update_skills_shown(
			BattleNodes.skills_container,
			BattleVariables.currently_selected_vivosaur.vivosaur_info.skills,
			SkillSignalHandlers.on_skill_clicked.bind(vivosaur_zone))
	else:
		UIUtils.clear_skills(BattleNodes.skills_container)

func on_vivosaur_hover(vivosaur: VivosaurBattle, vivosaur_sprite_btn: TextureButton):
	if BattleVariables.is_choosing_target and BattleVariables.vivosaur_sprite_btn in BattleVariables.selectable_targets:
		if BattleVariables.currently_selected_target and BattleVariables.currently_selected_target_sprite_btn:
			BattleVariables.currently_selected_target_sprite_btn.get_node('Cursor').visible = false
		
		BattleVariables.currently_selected_target = vivosaur
		BattleVariables.currently_selected_target_sprite_btn = vivosaur_sprite_btn
		vivosaur_sprite_btn.get_node('Cursor').visible = true
