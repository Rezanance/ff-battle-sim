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

@onready var player_support_effects_img: TextureRect = $BattleWindow/PlayerSupportEffects
@onready var player_atk_modifier: Label = $BattleWindow/PlayerSupportEffects/Atk
@onready var player_def_modifier: Label = $BattleWindow/PlayerSupportEffects/Def
@onready var player_acc_modifier: Label = $BattleWindow/PlayerSupportEffects/Acc
@onready var player_eva_modifier: Label = $BattleWindow/PlayerSupportEffects/Eva

@onready var opponent_support_effects_img: TextureRect = $BattleWindow/OpponentSupportEffects
@onready var opponent_atk_modifier: Label = $BattleWindow/OpponentSupportEffects/Atk
@onready var opponent_def_modifier: Label = $BattleWindow/OpponentSupportEffects/Def
@onready var opponent_acc_modifier: Label = $BattleWindow/OpponentSupportEffects/Acc
@onready var opponent_eva_modifier: Label = $BattleWindow/OpponentSupportEffects/Eva

@onready var player_total_lp: TextureRect = $BattleWindow/PlayerTotalLp
@onready var player_total_lp_finish: Control = $BattleWindow/PlayerTotalLpFinish
@onready var opponent_total_lp: TextureRect = $BattleWindow/OpponentTotalLp
@onready var opponent_total_lp_finish: Control = $BattleWindow/OpponentTotalLpFinish

@onready var player_turn: Control = $BattleWindow/PlayerTurn
@onready var player_turn_start: Control = $BattleWindow/PlayerTurnStart
@onready var player_icon: TextureRect = $BattleWindow/PlayerTurn/Icon
@onready var player_name: Label = $BattleWindow/PlayerTurn/Name

@onready var opponent_turn: Control = $BattleWindow/OpponentTurn
@onready var opponent_turn_start: Control = $BattleWindow/OpponentTurnStart
@onready var opponent_icon: TextureRect = $BattleWindow/OpponentTurn/Icon
@onready var opponent_name: Label = $BattleWindow/OpponentTurn/Name

@onready var player_fp: Label = $BattleWindow/PlayerFP
@onready var player_fp_delta: Label = $BattleWindow/PlayerFPDelta
@onready var opponent_fp: Label = $BattleWindow/OpponentFP
@onready var opponent_fp_delta: Label = $BattleWindow/OpponentFPDelta

var battlefield: DataTypes.Battlefield
var player_id
var opponent_id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_id = Battle.player_info.player_id
	opponent_id = Battle.opponent_info.player_id
	
	create_battlefield()
	add_player_vivosaurs()
	add_opponent_vivosaurs()
	initialize_turn_start_ui()
	await get_tree().create_timer(0.2).timeout

	await animate_entrance()
	await get_tree().create_timer(0.5).timeout

	await apply_support_effects(player_id)
	await apply_support_effects(opponent_id)
	await get_tree().create_timer(0.5).timeout

	await animate_who_goes_first()
	await get_tree().create_timer(0.5).timeout

	MultiplayerBattles.who_goes_first(Battle.battle_id)
	MultiplayerBattles.turn_started.connect(_on_turn_started)

func create_battlefield():
	var player_slot1 = Battle.player_team.slots[0]
	var player_slot2 = Battle.player_team.slots[1]
	var player_slot3 = Battle.player_team.slots[2]

	var _opponent_slot1 = Battle.opponent_team.slots[0]
	var _opponent_slot2 = Battle.opponent_team.slots[1]
	var _opponent_slot3 = Battle.opponent_team.slots[2]

	var zones: Dictionary[int, DataTypes.Zones] = {}
	zones[Battle.player_info.player_id] = DataTypes.Zones.new(
		DataTypes.VivosaurBattle.new(player_slot1) if player_slot1 != null else null,
		DataTypes.VivosaurBattle.new(player_slot2) if player_slot2 != null else null,
		DataTypes.VivosaurBattle.new(player_slot3) if player_slot3 != null else null,
	)
	zones[Battle.opponent_info.player_id] = DataTypes.Zones.new(
		DataTypes.VivosaurBattle.new(_opponent_slot1) if _opponent_slot1 != null else null,
		DataTypes.VivosaurBattle.new(_opponent_slot2) if _opponent_slot2 != null else null,
		DataTypes.VivosaurBattle.new(_opponent_slot3) if _opponent_slot3 != null else null,
	)
	battlefield = DataTypes.Battlefield.new(zones, true)

	battlefield.support_effects_applied.connect(display_support_effects)

func add_player_vivosaurs():
	var zones = battlefield.zones[Battle.player_info.player_id]
	var vivosaur_az = zones.az
	var vivosaur_sz1 = zones.sz1
	var vivosaur_sz2 = zones.sz2

	player_vivosaur1_sprite.global_position = player_az_start.global_position
	player_vivosaur2_sprite.global_position = player_sz1_start.global_position
	player_vivosaur3_sprite.global_position = player_sz2_start.global_position

	player_vivosaur1_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_az.vivosaur_info.id, vivosaur_az.vivosaur_info.id])
	player_vivosaur1_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_az.vivosaur_info.element)
	zones.az_sprite = player_vivosaur1_sprite
	if vivosaur_sz1 != null:
		player_vivosaur2_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz1.vivosaur_info.id, vivosaur_sz1.vivosaur_info.id])
		player_vivosaur2_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz1.vivosaur_info.element)
		zones.sz1_sprite = player_vivosaur2_sprite
	else:
		player_vivosaur2_sprite.queue_free()
	if vivosaur_sz2 != null:
		player_vivosaur3_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz2.vivosaur_info.id, vivosaur_sz2.vivosaur_info.id])
		player_vivosaur3_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz2.vivosaur_info.element)
		zones.sz2_sprite = player_vivosaur3_sprite
	else:
		player_vivosaur3_sprite.queue_free()

func add_opponent_vivosaurs():
	var zones = battlefield.zones[Battle.opponent_info.player_id]
	var vivosaur_az = zones.az
	var vivosaur_sz1 = zones.sz1
	var vivosaur_sz2 = zones.sz2
	
	opponent_vivosaur1_sprite.flip_h = false
	opponent_vivosaur1_sprite.global_position = opponent_az.global_position

	opponent_vivosaur2_sprite.flip_h = false
	opponent_vivosaur2_sprite.global_position = opponent_sz1.global_position
	
	opponent_vivosaur3_sprite.flip_h = false
	opponent_vivosaur3_sprite.global_position = opponent_sz2.global_position

	opponent_vivosaur1_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_az.vivosaur_info.id, vivosaur_az.vivosaur_info.id])
	opponent_vivosaur1_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_az.vivosaur_info.element)
	zones.az_sprite = opponent_vivosaur1_sprite
	if vivosaur_sz1 != null:
		opponent_vivosaur2_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz1.vivosaur_info.id, vivosaur_sz1.vivosaur_info.id])
		opponent_vivosaur2_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz1.vivosaur_info.element)
		zones.sz1_sprite = opponent_vivosaur2_sprite
	else:
		opponent_vivosaur2_sprite.queue_free()
	if vivosaur_sz2 != null:
		opponent_vivosaur3_sprite.texture_normal = load('res://vivosaur/%d/sprite/%d.png' % [vivosaur_sz2.vivosaur_info.id, vivosaur_sz2.vivosaur_info.id])
		opponent_vivosaur3_sprite.get_node('LifeBar/Bg').texture = load('res://common_assets/lifebars/%d.png' % vivosaur_sz2.vivosaur_info.element)
		zones.sz2_sprite = opponent_vivosaur3_sprite
	else:
		opponent_vivosaur3_sprite.queue_free()

func initialize_turn_start_ui():
	var icon_path = 'res://common_assets/player-icons'
	var icon_files = ResourceLoader.list_directory(icon_path)

	player_icon.texture = load(icon_path + '/' + icon_files[Battle.player_info.icon_id])
	player_name.text = Battle.player_info.display_name

	opponent_icon.texture = load(icon_path + '/' + icon_files[Battle.player_info.icon_id])
	opponent_name.text = Battle.opponent_info.display_name

func animate_entrance():
	var tween = create_tween()
	tween.tween_property(player_vivosaur1_sprite, 'global_position', player_az.global_position, 0.1)
	tween.set_parallel()
	tween.tween_property(player_vivosaur2_sprite, 'global_position', player_sz1.global_position, 0.1).set_delay(0.05)
	tween.tween_property(player_vivosaur3_sprite, 'global_position', player_sz2.global_position, 0.1).set_delay(0.1)
	await tween.finished


func apply_support_effects(id: int):
	await battlefield.apply_support_effects(id)

func display_support_effects(id: int, index: int):
	var support_sprites = battlefield.zones[id].get_support_zones_sprites()
	
	var tween = create_tween()
	player_atk_modifier.text = "%d" % (battlefield.zones[player_id].az_support_effects.atk * 100) + '%'
	player_def_modifier.text = "%d" % (battlefield.zones[player_id].az_support_effects.def * 100) + '%'
	player_acc_modifier.text = "%d" % (battlefield.zones[player_id].az_support_effects.acc * 100) + '%'
	player_eva_modifier.text = "%d" % (battlefield.zones[player_id].az_support_effects.eva * 100) + '%'

	opponent_atk_modifier.text = "%d" % (battlefield.zones[opponent_id].az_support_effects.atk * 100) + '%'
	opponent_def_modifier.text = "%d" % (battlefield.zones[opponent_id].az_support_effects.def * 100) + '%'
	opponent_acc_modifier.text = "%d" % (battlefield.zones[opponent_id].az_support_effects.acc * 100) + '%'
	opponent_eva_modifier.text = "%d" % (battlefield.zones[opponent_id].az_support_effects.eva * 100) + '%'
	
	tween.tween_property(support_sprites[index], 'scale', Vector2(1.2, 1.2), 0.1)
	tween.tween_property(support_sprites[index], 'scale', Vector2(1.0, 1.0), 0.1)
	await tween.finished
	await get_tree().create_timer(0.33).timeout
	battlefield.apply_next_support_effects.emit()

func animate_who_goes_first():
	var _player_total_lp = battlefield.zones[player_id].get_total_lp()
	var _opponent_total_lp = battlefield.zones[opponent_id].get_total_lp()

	player_total_lp.get_node('Lp').text = '%d' % _player_total_lp
	opponent_total_lp.get_node('Lp').text = '%d' % _opponent_total_lp

	player_total_lp.visible = true
	opponent_total_lp.visible = true

	var tween = create_tween()
	tween.tween_property(player_total_lp, "global_position", player_total_lp_finish.global_position, 0.33)
	tween.set_parallel()
	tween.tween_property(opponent_total_lp, "global_position", opponent_total_lp_finish.global_position, 0.33)

	await tween.finished

	var first_attack: TextureRect
	if _player_total_lp > _opponent_total_lp:
		first_attack = player_total_lp.get_node('FirstAttack')
	else:
		first_attack = opponent_total_lp.get_node('FirstAttack')
	
	tween = create_tween()
	
	tween.tween_property(first_attack, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.set_parallel()
	tween.tween_property(first_attack, "scale", Vector2(2, 2), 0.2)

	await tween.finished
	await get_tree().create_timer(0.5).timeout

	player_total_lp.queue_free()
	opponent_total_lp.queue_free()

func _on_turn_started(id: int):
	await animate_turn_start(id)
	await get_tree().create_timer(0.2).timeout

	await apply_support_effects(id)

	await recharge_fp(id)

func animate_turn_start(id: int):
	var tween = create_tween()
	var turn: Control
	var turn_start: Control
	if id == multiplayer.get_unique_id():
		turn = player_turn
		turn_start = player_turn_start
	else:
		turn = opponent_turn
		turn_start = opponent_turn_start
	
	tween.tween_property(turn, "position", Vector2(0, 0), 0.2)
	
	await tween.finished
	await get_tree().create_timer(0.33).timeout
	
	turn.position = turn_start.position

func recharge_fp(id: int):
	battlefield.recharge_fp(id)

	var fp: Label
	var fp_delta: Label

	if id == multiplayer.get_unique_id():
		fp = player_fp
		fp_delta = player_fp_delta
	else:
		fp = opponent_fp
		fp_delta = opponent_fp_delta
	
	var old_fp: int = int(fp.text)
	var delta_fp: int = battlefield.zones[id].fp - old_fp
	
	fp_delta.visible = true
	fp_delta.text = '+%d' % delta_fp

	for i in range(1, delta_fp + 1, 5):
		fp.text = '%d' % (old_fp + i)
		await get_tree().create_timer(0.0056).timeout
	
	fp.text = '%d' % (old_fp + delta_fp)
	fp_delta.visible = false
