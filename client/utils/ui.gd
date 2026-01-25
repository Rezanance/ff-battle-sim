class_name UIUtils


static var SkillScene: Resource = preload("res://client/common/skill_button/skill_button.tscn")

static func update_skills_shown(skills_container: VBoxContainer, skills: Array[Skill], _on_skill_clicked: Callable) -> void:
	clear_skills(skills_container)

	for skill: Skill in skills:
		var skill_node: SkillButton = SkillScene.instantiate()
		skill_node.initialize(skill, _on_skill_clicked) 
		skills_container.add_child(skill_node)
		
static func clear_skills(skills_container: VBoxContainer) -> void:
	for old_skill: Node in skills_container.get_children():
		old_skill.queue_free() 
		
static func reset_cursor_modulate(player_zones: Formation, opponent_zones: Formation):
	if player_zones.az_sprite_btn != null: 
		player_zones.az_sprite_btn.self_modulate = Color.hex(0xffffffff)
	if player_zones.sz1_sprite_btn != null: 
		player_zones.sz1_sprite_btn.self_modulate = Color.hex(0xffffffff)
	if player_zones.sz2_sprite_btn != null: 
		player_zones.sz2_sprite_btn.self_modulate = Color.hex(0xffffffff)
	if opponent_zones.az_sprite_btn != null: 
		opponent_zones.az_sprite_btn.self_modulate = Color.hex(0xffffffff)
	if opponent_zones.sz1_sprite_btn != null: 
		opponent_zones.sz1_sprite_btn.self_modulate = Color.hex(0xffffffff)
	if opponent_zones.sz2_sprite_btn != null: 
		opponent_zones.sz2_sprite_btn.self_modulate = Color.hex(0xffffffff)

	var player_az_cursor = player_zones.az_sprite_btn.get_node('Cursor') if player_zones.az_sprite_btn != null else null
	var player_sz1_cursor = player_zones.sz1_sprite_btn.get_node('Cursor') if player_zones.sz1_sprite_btn != null else null
	var player_sz2_cursor = player_zones.sz2_sprite_btn.get_node('Cursor') if player_zones.sz2_sprite_btn != null else null

	var opponent_az_cursor = opponent_zones.az_sprite_btn.get_node('Cursor') if opponent_zones.az_sprite_btn != null else null
	var opponent_sz1_cursor = opponent_zones.sz1_sprite_btn.get_node('Cursor') if opponent_zones.sz1_sprite_btn != null else null
	var opponent_sz2_cursor = opponent_zones.sz2_sprite_btn.get_node('Cursor') if opponent_zones.sz2_sprite_btn != null else null
	
	if player_az_cursor != null: 
		player_az_cursor.visible = false
	if player_sz1_cursor != null: 
		player_sz1_cursor.visible = false
	if player_sz2_cursor != null: 
		player_sz2_cursor.visible = false
		
	if opponent_az_cursor != null: 
		opponent_az_cursor.visible = false
	if opponent_sz1_cursor != null: 
		opponent_sz1_cursor.visible = false
	if opponent_sz2_cursor != null: 
		opponent_sz2_cursor.visible = false
