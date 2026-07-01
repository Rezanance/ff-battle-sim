extends Node

const Target = Skill.Target
const Zone = Formation.Zone

signal event_queued()

@export var battling_component: BattlingComponent
@export var player_formation_ui: FormationUI
@export var opponent_formation_ui: FormationUI
@export var swap_to_ez_btn: TextureButton
@export var end_turn_btn: TextureButton
@export var back_btn: TextureButton
@export var ok_btn: TextureButton

var event_queue: Array[EventCallback] = []
var formations_ui: Dictionary[int, FormationUI] = {}

func _ready() -> void:
	var player_id: int = Networking.player_info.player_id
	var opponent_id: int = Networking.opponent_info.player_id
	formations_ui[player_id] = player_formation_ui
	formations_ui[opponent_id] = opponent_formation_ui
	
	player_formation_ui.vivosaur_selected.connect(select_vivosaur.bind(player_id))
	player_formation_ui.skill_clicked.connect(show_skill_targets)
	opponent_formation_ui.vivosaur_selected.connect(select_vivosaur.bind(opponent_id))
	
	end_turn_btn.pressed.connect(battling_component.notify_ending_turn)

	back_btn.pressed.connect(go_back_from_skill_step)
	
	ClientBattling.support_effects_applied.connect(queue_event.bind(update_support_effects))
	ClientBattling.first_player_determined.connect(queue_event.bind(show_who_goes_first))
	ClientBattling.turn_started.connect(queue_event.bind(start_turn))
	ClientBattling.fp_gained.connect(queue_event.bind(gain_fp))
	
	await get_tree().create_timer(0.25).timeout
	player_formation_ui.initialize()
	await opponent_formation_ui.initialize()
	
	battling_component.notify_battle_scene_loaded()
	
	process_events()

func queue_event(event: Variant, callback: Callable) -> void:
	event_queue.append(EventCallback.new(event, callback))
	event_queued.emit()

func process_events() -> void:
	while true:
		var event_callback: EventCallback = event_queue.pop_front()
		if event_callback:
			await event_callback.callback.call(event_callback.event)
		else:
			await event_queued

func update_support_effects(event: SupportEffectsAppliedEvent) -> void:
	var formation_ui: FormationUI = formations_ui[event.player_id]
	var target_formation_ui: FormationUI = formations_ui[event.target_player_id]
	var target_formation: Formation = Battling.formations[event.target_player_id]
	
	await formation_ui.vivosaur_sprite_zones[event.support_zone].pulse()
	
	var target_az: Vivosaur = target_formation.az
	target_az.attack_modifier += event.attack_modifier
	target_az.defense_modifier += event.defense_modifier
	target_az.accuracy_modifier += event.accuracy_modifier
	target_az.evasion_modifier += event.evasion_modifier
	
	target_formation_ui.update_support_effects(target_az)
	
func show_who_goes_first(event: FirstPlayerDeterminedEvent) -> void:
	var player1_formation_ui: FormationUI = formations_ui[event.player1_id]
	var player2_formation_ui: FormationUI = formations_ui[event.player2_id]
	
	var sg: SignalGroup = SignalGroup.new()
	player1_formation_ui.show_who_goes_first(
		event.player1_total_lp,
		event.first_player_id == event.player1_id
	)
	player2_formation_ui.show_who_goes_first(
		event.player2_total_lp,
		event.first_player_id == event.player2_id
	)
	
	await sg.all([
		player1_formation_ui.first_player_revealed,
		player2_formation_ui.first_player_revealed
	])
	
func start_turn(event: TurnStartedEvent) -> void:
	var is_player_turn: bool = event.player_id == Networking.player_info.player_id
	var formation_ui: FormationUI = formations_ui[event.player_id]
	
	player_formation_ui.change_fp_banner(is_player_turn)
	opponent_formation_ui.change_fp_banner(not is_player_turn)

	await formation_ui.animate_turn_start()
	
func gain_fp(event: FpGainedEvent) -> void:
	await formations_ui[event.player_id].animate_fp_gain(event)
	
func select_vivosaur(zone: Formation.Zone, player_id: int) -> void:
	var selection: VivosaurSelection = Battling.current_selection
	if selection:
		formations_ui[selection.player_id].vivosaur_sprite_zones[selection.zone].arrow.visible = false
	Battling.previous_selection = selection
	Battling.current_selection = VivosaurSelection.new(zone, player_id)

func show_skill_targets(skill: Skill) -> void:
	var ally_az: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.AZ]
	var ally_sz1: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.SZ1]
	var ally_sz2: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.SZ2]
	var ally_ez: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.EZ]

	var enemy_az: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.AZ]
	var enemy_sz1: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.SZ1]
	var enemy_sz2: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.SZ2]
	var enemy_ez: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.EZ]

	var ally_modulate: Color = Color(0, 0, 1, 1)
	var enemy_modulate: Color = Color(1, 0.5, 0.5, 0.5)

	back_btn.visible = true
	ok_btn.visible = true
	reset_targets()

	match skill.target:
		Target.ALL:
			if ally_az: ally_az.cursor.visible = true
			if ally_sz1: ally_sz1.cursor.visible = true
			if ally_sz2: ally_sz2.cursor.visible = true
			if ally_ez: ally_ez.cursor.visible = true

			if enemy_az: enemy_az.cursor.visible = true
			if enemy_sz1: enemy_sz1.cursor.visible = true
			if enemy_sz2: enemy_sz2.cursor.visible = true
			if enemy_ez: enemy_ez.cursor.visible = true
		Target.ALL_ALLIES:
			if ally_az: ally_az.cursor.visible = true
			if ally_sz1: ally_sz1.cursor.visible = true
			if ally_sz2: ally_sz2.cursor.visible = true
			if ally_ez: ally_ez.cursor.visible = true

			if ally_az: ally_az.self_modulate = ally_modulate
			if ally_sz1: ally_sz1.self_modulate = ally_modulate
			if ally_sz2: ally_sz2.self_modulate = ally_modulate
			if ally_ez: ally_ez.self_modulate = ally_modulate
		Target.ALL_ENEMIES:
			if enemy_az: enemy_az.cursor.visible = true
			if enemy_sz1: enemy_sz1.cursor.visible = true
			if enemy_sz2: enemy_sz2.cursor.visible = true
			if enemy_ez: enemy_ez.cursor.visible = true

			if enemy_az: enemy_az.self_modulate = enemy_modulate
			if enemy_sz1: enemy_sz1.self_modulate = enemy_modulate
			if enemy_sz2: enemy_sz2.self_modulate = enemy_modulate
			if enemy_ez: enemy_ez.self_modulate = enemy_modulate
		Target.ALLY:
			if ally_az:
				ally_az.self_modulate = ally_modulate
				ally_az.is_targetable = true
			if ally_sz1:
				ally_sz1.self_modulate = ally_modulate
				ally_sz1.is_targetable = true
			if ally_sz2:
				ally_sz2.self_modulate = ally_modulate
				ally_sz2.is_targetable = true
		Target.ALLY_AZ_AND_SZ:
			if ally_az: ally_az.cursor.visible = true
			if ally_sz1: ally_sz1.cursor.visible = true
			if ally_sz2: ally_sz2.cursor.visible = true

			if ally_az: ally_az.self_modulate = ally_modulate
			if ally_sz1: ally_sz1.self_modulate = ally_modulate
			if ally_sz2: ally_sz2.self_modulate = ally_modulate
		Target.ENEMY_AZ_AND_SZ:
			if enemy_az: enemy_az.cursor.visible = true
			if enemy_sz1: enemy_sz1.cursor.visible = true
			if enemy_sz2: enemy_sz2.cursor.visible = true

			if enemy_az: enemy_az.self_modulate = enemy_modulate
			if enemy_sz1: enemy_sz1.self_modulate = enemy_modulate
			if enemy_sz2: enemy_sz2.self_modulate = enemy_modulate
		Target.ALLY_EXCEPT_SELF:
			# TODO: enable cursors for other allies
			pass
		Target.ENEMY:
			if enemy_az:
				enemy_az.self_modulate = enemy_modulate
				enemy_az.is_targetable = true
			if enemy_sz1:
				enemy_sz1.self_modulate = enemy_modulate
				enemy_sz1.is_targetable = true
			if enemy_sz2:
				enemy_sz2.self_modulate = enemy_modulate
				enemy_sz2.is_targetable = true

		Target.SELF:
			player_formation_ui.vivosaur_sprite_zones[Battling.current_selection.zone].cursor.visible = true

func go_back_from_skill_step() -> void:
	reset_targets()
	back_btn.visible = false
	ok_btn.visible = false

func reset_targets() -> void:
	var ally_az: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.AZ]
	var ally_sz1: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.SZ1]
	var ally_sz2: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.SZ2]
	var ally_ez: VivosaurSprite = player_formation_ui.vivosaur_sprite_zones[Zone.EZ]

	var enemy_az: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.AZ]
	var enemy_sz1: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.SZ1]
	var enemy_sz2: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.SZ2]
	var enemy_ez: VivosaurSprite = opponent_formation_ui.vivosaur_sprite_zones[Zone.EZ]

	if ally_az:
		ally_az.self_modulate = Color.WHITE
		ally_az.is_targetable = false
		ally_az.cursor.visible = false
	if ally_sz1:
		ally_sz1.self_modulate = Color.WHITE
		ally_sz1.is_targetable = false
		ally_sz1.cursor.visible = false
	if ally_sz2:
		ally_sz2.self_modulate = Color.WHITE
		ally_sz2.is_targetable = false
		ally_sz2.cursor.visible = false
	if ally_ez:
		ally_ez.self_modulate = Color.WHITE
		ally_ez.is_targetable = false
		ally_ez.cursor.visible = false
	
	if enemy_az:
		enemy_az.self_modulate = Color.WHITE
		enemy_az.is_targetable = false
		enemy_az.cursor.visible = false
	if enemy_sz1:
		enemy_sz1.self_modulate = Color.WHITE
		enemy_sz1.is_targetable = false
		enemy_sz1.cursor.visible = false
	if enemy_sz2:
		enemy_sz2.self_modulate = Color.WHITE
		enemy_sz2.is_targetable = false
		enemy_sz2.cursor.visible = false
	if enemy_ez:
		enemy_ez.self_modulate = Color.WHITE
		enemy_ez.is_targetable = false
		enemy_ez.cursor.visible = false
