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

var vivosaur_sprite_zones: Array[VivosaurSprite] = [null, null, null, null]

#func _ready() -> void:
	#initialize_vivosaur_sprites()
	#animate_vivosaur_entrance()

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
