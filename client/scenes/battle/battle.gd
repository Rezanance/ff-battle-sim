extends Node

signal event_queued()

@export var battling_component: BattlingComponent
@export var player_formation_ui: FormationUI
@export var opponent_formation_ui: FormationUI

var event_queue: Array[EventCallback] = []
var formations_ui: Dictionary[int, FormationUI] = {}

func _ready() -> void:
	formations_ui[Networking.player_info.player_id] = player_formation_ui
	formations_ui[Networking.opponent_info.player_id] = opponent_formation_ui
	
	ClientBattling.support_effects_applied.connect(queue_event.bind(update_support_effects))
	ClientBattling.first_player_determined.connect(queue_event.bind(show_who_goes_first))
	ClientBattling.turn_started.connect(queue_event.bind(start_turn))
	
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
	  
