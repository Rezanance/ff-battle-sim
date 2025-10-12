extends TextureRect

var VivosaurSprite = preload("res://battle/VivosaurSprite.tscn")

@onready var PlayerAZ: Control = $PlayerVivosaurPositions/AZ
@onready var PlayerSZ1: Control = $PlayerVivosaurPositions/SZ1
@onready var PlayerSZ2: Control = $PlayerVivosaurPositions/SZ2
@onready var PlayerEZ: Control = $PlayerVivosaurPositions/EZ

@onready var OpponentAZ: Control = $OpponentVivosaurPositions/AZ
@onready var OpponentSZ1: Control = $OpponentVivosaurPositions/SZ1
@onready var OpponentSZ2: Control = $OpponentVivosaurPositions/SZ2
@onready var OpponentEZ: Control = $OpponentVivosaurPositions/EZ

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_player_vivosaurs()
	add_opponent_vivosaurs()

func add_player_vivosaurs():
	add_vivosaurs(false)

func add_opponent_vivosaurs():
	add_vivosaurs(true)

func add_vivosaurs(opponent: bool):
	var vivosaur_sprite_az: TextureButton = VivosaurSprite.instantiate()
	var vivosaur_sprite_sz1: TextureButton = VivosaurSprite.instantiate()
	var vivosaur_sprite_sz2: TextureButton = VivosaurSprite.instantiate()
	
	add_child(vivosaur_sprite_az)
	add_child(vivosaur_sprite_sz1)
	add_child(vivosaur_sprite_sz2)
	
	var vivosaur_id_az
	var vivosaur_sz1
	var vivosaur_sz2
	if not opponent:
		vivosaur_id_az = Battle.battlefield.player1_zones.az.vivosaur.id
		vivosaur_sprite_az.global_position = PlayerAZ.global_position

		vivosaur_sz1 = Battle.battlefield.player1_zones.sz1.vivosaur
		vivosaur_sprite_sz1.global_position = PlayerSZ1.global_position
		
		vivosaur_sz2 = Battle.battlefield.player1_zones.sz2.vivosaur
		vivosaur_sprite_sz2.global_position = PlayerSZ2.global_position
	else:
		vivosaur_id_az = Battle.battlefield.player2_zones.az.vivosaur.id
		vivosaur_sprite_az.flip_h = false
		vivosaur_sprite_az.global_position = OpponentAZ.global_position

		vivosaur_sz1 = Battle.battlefield.player2_zones.sz1.vivosaur
		vivosaur_sprite_sz1.flip_h = false
		vivosaur_sprite_sz1.global_position = OpponentSZ1.global_position
		
		vivosaur_sz2 = Battle.battlefield.player2_zones.sz2.vivosaur
		vivosaur_sprite_sz2.flip_h = false
		vivosaur_sprite_sz2.global_position = OpponentSZ2.global_position

	vivosaur_sprite_az.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_id_az, vivosaur_id_az])
	if vivosaur_sz1 != null:
		vivosaur_sprite_sz1.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz1.id, vivosaur_sz1.id])
	else:
		vivosaur_sprite_sz1.queue_free()
	if vivosaur_sz2 != null:
		vivosaur_sprite_sz2.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz2.id, vivosaur_sz2.id])
	else:
		vivosaur_sprite_sz2.queue_free()
