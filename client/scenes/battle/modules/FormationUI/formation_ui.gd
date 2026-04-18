extends Node
class_name FormationUI

signal support_effects_updated()
signal first_player_revealed()

@export var total_lp_panel: TextureRect
@export var total_lp_panel_position: Control

@export var az_position: Control
@export var sz1_position: Control
@export var sz2_position: Control
@export var ez_position: Control

@export var vivosaur_sprite_1: VivosaurSprite
@export var vivosaur_sprite_2: VivosaurSprite
@export var vivosaur_sprite_3: VivosaurSprite

@export var support_effects: TextureRect

@export var fp_bg: TextureRect
@export var fp: Label
@export var fp_delta: Label

@export var turn_banner: Control
@export var turn_banner_start: Control

@export var is_player_formation: bool = true

@export var texture_manager: TextureManager

var vivosaur_sprite_zones: Array[VivosaurSprite] = [null, null, null, null]

func initialize() -> void:
	initialize_vivosaur_sprites()
	await animate_vivosaur_entrance()

func initialize_vivosaur_sprites() -> void:
	var formation: Formation
	if  is_player_formation :
		formation = Battling.formations[Networking.player_info.player_id] 
	else:
		formation=  Battling.formations[Networking.opponent_info.player_id] 
		
	var az: Vivosaur = formation.az
	var sz1: Vivosaur = formation.sz1
	var sz2: Vivosaur = formation.sz2
	
	vivosaur_sprite_zones[Formation.Zone.AZ] = vivosaur_sprite_1
	vivosaur_sprite_zones[Formation.Zone.SZ1] = vivosaur_sprite_2
	vivosaur_sprite_zones[Formation.Zone.SZ2] = vivosaur_sprite_3
	
	_initialize_sprite(az, vivosaur_sprite_1)
	_initialize_sprite(sz1, vivosaur_sprite_2)
	_initialize_sprite(sz2, vivosaur_sprite_3)

func _initialize_sprite(vivosaur: Vivosaur, sprite: VivosaurSprite) -> void:
	if vivosaur:
		var vivosaur_resource: VivosaurResource = load("res://core/data/vivosaurs/%s.tres" % vivosaur.vivosaur_info.id)
		sprite.texture_normal = vivosaur_resource.sprite
		sprite.get_node('LifeBar/Bg').texture = load('res://client/assets/lifebars/%d.png' % vivosaur.vivosaur_info.element)
	else:
		sprite.queue_free()

func initialize_turn_banner() -> void:
	var icon_id: int = Networking.player_info.icon_id if is_player_formation else Networking.opponent_info.icon_id
	var display_name: String = Networking.player_info.display_name if is_player_formation else Networking.opponent_info.display_name
	turn_banner.get_node('Icon').texture = load('res://client/assets/player-icons/%d.png' % icon_id)
	turn_banner.get_node('Name').text = display_name

func animate_vivosaur_entrance() -> void:
	var az_sprite: VivosaurSprite = vivosaur_sprite_zones[Formation.Zone.AZ]
	var sz1_sprite: VivosaurSprite = vivosaur_sprite_zones[Formation.Zone.SZ1]
	var sz2_sprite: VivosaurSprite = vivosaur_sprite_zones[Formation.Zone.SZ2]
	var tween: Tween = create_tween()
	if is_instance_valid(sz1_sprite):
		tween.tween_property(
			sz1_sprite, 
			'global_position', 
			sz1_position.global_position, 
			0.2
		)
	tween.set_parallel()
	tween.tween_property(
		az_sprite, 
		'global_position', 
		az_position.global_position, 
		0.2
	).set_delay(0.1)
	if is_instance_valid(sz2_sprite):
		tween.tween_property(
			sz2_sprite, 
			'global_position', 
			sz2_position.global_position, 
			0.2
		).set_delay(0.2)
	await tween.finished

func update_support_effects(
	target_az: Vivosaur
) -> void:
	_format_support_modifier('Atk', target_az.attack_modifier)
	_format_support_modifier('Def', target_az.defense_modifier)
	_format_support_modifier('Acc', target_az.accuracy_modifier)
	_format_support_modifier('Eva', target_az.evasion_modifier)
	
	support_effects_updated.emit()

func _format_support_modifier(
	node: String, 
	modifier: float
) -> void:
	var text: String
	var color: Color
	var percent: float = modifier * 100
	if percent >= 1:
		text = '+%d' % percent
		color = Color.AQUA
	elif percent <= -1:
		text = '%d' % percent
		color = Color.INDIAN_RED
	else:
		text = '-'
		color = Color.WHITE_SMOKE
	
	var modifier_label: Label = support_effects.get_node(node)
	modifier_label.text = text
	modifier_label.add_theme_color_override("font_color", color)
	

func show_who_goes_first(total_lp: int, is_first: bool) -> void:
	total_lp_panel.get_node('Lp').text = '%d' % total_lp
	total_lp_panel.visible = true
	
	var tween: Tween = create_tween()
	tween.tween_property(
		total_lp_panel,
		"global_position", 
		total_lp_panel_position.global_position, 
		0.33
	)
	await tween.finished
	
	var timeout: float = 0.5
	if is_first:
		timeout = 0.3
		tween = create_tween()
		var first_attack: TextureRect = total_lp_panel.get_node('FirstAttack')
		tween.tween_property(first_attack, "modulate", Color(1, 1, 1, 1), 0.1)
		tween.set_parallel()
		tween.tween_property(first_attack, "scale", Vector2(2, 2), 0.2)

		await tween.finished
		
	await get_tree().create_timer(timeout).timeout
	total_lp_panel.queue_free()
	first_player_revealed.emit()
	
func change_fp_banner(is_player_turn: bool) -> void:
	if is_player_turn and is_player_formation:
		fp_bg.texture = texture_manager.player_fp_bg_turn 
	elif is_player_turn and not is_player_formation:
		fp_bg.texture = texture_manager.opponent_fp_bg_turn
	elif not is_player_turn and is_player_formation:
		fp_bg.texture = texture_manager.player_fp_bg_not_turn
	else:
		fp_bg.texture = texture_manager.opponent_fp_bg_not_turn
		

func animate_turn_start() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(turn_banner, "position", Vector2(0, 0), 0.2)
	await tween.finished
	
	await get_tree().create_timer(0.33).timeout
	
	turn_banner.position = turn_banner_start.position
