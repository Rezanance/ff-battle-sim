extends Node
class_name FormationUI

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

var az_vivosaur_sprite: VivosaurSprite
var sz1_vivosaur_sprite: VivosaurSprite
var sz2_vivosaur_sprite: VivosaurSprite
var ez_vivosaur_sprite: VivosaurSprite = null

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	initialize_vivosaur_sprites()
	animate_vivosaur_entrance()
	
func initialize_vivosaur_sprites() -> void:
	var formation: Formation = Battling.player_formation if is_player_formation else Battling.opponent_formation
	var az: Vivosaur = formation.az
	var sz1: Vivosaur = formation.sz1
	var sz2: Vivosaur = formation.sz2
	
	az_vivosaur_sprite = vivosaur_sprite_1
	sz1_vivosaur_sprite = vivosaur_sprite_2
	sz2_vivosaur_sprite = vivosaur_sprite_3
	
	_initialize_sprite(az, az_vivosaur_sprite)
	_initialize_sprite(sz1, sz1_vivosaur_sprite)
	_initialize_sprite(sz2, sz2_vivosaur_sprite)

func _initialize_sprite(vivosaur: Vivosaur, sprite: VivosaurSprite) -> void:
	if vivosaur:
		var vivosaur_resource: VivosaurResource = load("res://core/data/vivosaurs/%s.tres" % vivosaur.vivosaur_info.id)
		sprite.texture_normal = vivosaur_resource.sprite
		sprite.get_node('LifeBar/Bg').texture = load('res://client/assets/lifebars/%d.png' % vivosaur.vivosaur_info.element)
	else:
		sprite.queue_free()

func animate_vivosaur_entrance() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(
		vivosaur_sprite_2, 
		'global_position', 
		sz1_position.global_position, 
		0.2
	)
	tween.set_parallel()
	tween.tween_property(
		vivosaur_sprite_1, 
		'global_position', 
		az_position.global_position, 
		0.2
	).set_delay(0.1)
	tween.tween_property(
		vivosaur_sprite_3, 
		'global_position', 
		sz2_position.global_position, 
		0.2
	).set_delay(0.2)
	await tween.finished
