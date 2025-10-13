extends ColorRect

var VivosaurSprite = preload("res://battle/VivosaurSprite.tscn")

@onready var player_az_start: Control = $BattleWindow/PlayerVivosaurPositions/AZStart
@onready var player_sz1_start: Control = $BattleWindow/PlayerVivosaurPositions/SZ1Start
@onready var player_sz2_start: Control = $BattleWindow/PlayerVivosaurPositions/SZ2Start

@onready var player_az: Control = $BattleWindow/PlayerVivosaurPositions/AZ
@onready var player_sz1: Control = $BattleWindow/PlayerVivosaurPositions/SZ1
@onready var player_sz2: Control = $BattleWindow/PlayerVivosaurPositions/SZ2
@onready var player_ez: Control = $BattleWindow/PlayerVivosaurPositions/EZ

@onready var opponent_az: Control = $BattleWindow/OpponentVivosaurPositions/AZ
@onready var opponent_sz1: Control = $BattleWindow/OpponentVivosaurPositions/SZ1
@onready var opponent_sz2: Control = $BattleWindow/OpponentVivosaurPositions/SZ2
@onready var opponent_ez: Control = $BattleWindow/OpponentVivosaurPositions/EZ

@onready var player_vivosaur1_sprite: TextureButton = $BattleWindow/PlayerVivosaurPositions/VivosaurSpriteAZ
@onready var player_vivosaur2_sprite: TextureButton = $BattleWindow/PlayerVivosaurPositions/VivosaurSpriteSZ1
@onready var player_vivosaur3_sprite: TextureButton = $BattleWindow/PlayerVivosaurPositions/VivosaurSpriteSZ2

@onready var opponent_vivosaur1_sprite: TextureButton = $BattleWindow/OpponentVivosaurPositions/VivosaurSpriteAZ
@onready var opponent_vivosaur2_sprite: TextureButton = $BattleWindow/OpponentVivosaurPositions/VivosaurSpriteSZ1
@onready var opponent_vivosaur3_sprite: TextureButton = $BattleWindow/OpponentVivosaurPositions/VivosaurSpriteSZ2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_player_vivosaurs()
	add_opponent_vivosaurs()
	animate_entrance()

func add_player_vivosaurs():
	var vivosaur_az = Battle.battlefield.player_zones.az
	var vivosaur_sz1 = Battle.battlefield.player_zones.sz1
	var vivosaur_sz2 = Battle.battlefield.player_zones.sz2

	player_vivosaur1_sprite.global_position = player_az_start.global_position
	player_vivosaur2_sprite.global_position = player_sz1_start.global_position
	player_vivosaur3_sprite.global_position = player_sz2_start.global_position

	player_vivosaur1_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_az.vivosaur.id, vivosaur_az.vivosaur.id])
	player_vivosaur1_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_az.vivosaur.element)
	if vivosaur_sz1 != null:
		player_vivosaur2_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz1.vivosaur.id, vivosaur_sz1.vivosaur.id])
		player_vivosaur2_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz1.vivosaur.element)
	else:
		player_vivosaur2_sprite.queue_free()
	if vivosaur_sz2 != null:
		player_vivosaur3_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz2.vivosaur.id, vivosaur_sz2.vivosaur.id])
		player_vivosaur3_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz2.vivosaur.element)
	else:
		player_vivosaur3_sprite.queue_free()

func add_opponent_vivosaurs():
	var vivosaur_az = Battle.battlefield.opponent_zones.az
	var vivosaur_sz1 = Battle.battlefield.opponent_zones.sz1
	var vivosaur_sz2 = Battle.battlefield.opponent_zones.sz2
	
	opponent_vivosaur1_sprite.flip_h = false
	opponent_vivosaur1_sprite.global_position = opponent_az.global_position

	opponent_vivosaur2_sprite.flip_h = false
	opponent_vivosaur2_sprite.global_position = opponent_sz1.global_position
	
	opponent_vivosaur3_sprite.flip_h = false
	opponent_vivosaur3_sprite.global_position = opponent_sz2.global_position

	opponent_vivosaur1_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_az.vivosaur.id, vivosaur_az.vivosaur.id])
	opponent_vivosaur1_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_az.vivosaur.element)
	if vivosaur_sz1 != null:
		opponent_vivosaur2_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz1.vivosaur.id, vivosaur_sz1.vivosaur.id])
		opponent_vivosaur2_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz1.vivosaur.element)
	else:
		opponent_vivosaur2_sprite.queue_free()
	if vivosaur_sz2 != null:
		opponent_vivosaur3_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz2.vivosaur.id, vivosaur_sz2.vivosaur.id])
		opponent_vivosaur3_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz2.vivosaur.element)
	else:
		opponent_vivosaur3_sprite.queue_free()


func animate_entrance():
	var tween = create_tween()

	tween.tween_property(player_vivosaur1_sprite, 'global_position', player_az.global_position, 0.33).set_trans(Tween.TRANS_QUAD).set_delay(0.5)
	tween.tween_property(player_vivosaur2_sprite, 'global_position', player_sz1.global_position, 0.33).set_trans(Tween.TRANS_QUAD).set_delay(0.05)
	tween.tween_property(player_vivosaur3_sprite, 'global_position', player_sz2.global_position, 0.33).set_trans(Tween.TRANS_QUAD).set_delay(0.05)
