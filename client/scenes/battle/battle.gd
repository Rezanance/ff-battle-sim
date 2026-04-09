extends Node

signal event_queued()

@export var battling_component: BattlingComponent
@export var player_formation_ui: FormationUI
@export var opponent_formation_ui: FormationUI

class EventCallback:
	var event: Variant
	var callback: Callable
	
	func _init(_event: Variant, _callback: Callable) -> void:
		event = _event
		callback = _callback

var event_queue: Array[EventCallback] = []
var formations_ui: Dictionary[int, FormationUI] = {}

func _ready() -> void:
	formations_ui[Networking.player_info.player_id] = player_formation_ui
	formations_ui[Networking.opponent_info.player_id] = opponent_formation_ui
	
	ClientBattling.support_effects_applied.connect(queue_event.bind(_update_support_effects))
	ClientBattling.first_player_determined.connect(queue_event.bind(_show_who_goes_first))
	
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
			event_callback.callback.call(event_callback.event)
			await get_tree().create_timer(0.25).timeout
		else:
			await event_queued

func _update_support_effects(event: SupportEffectsAppliedEvent) -> void:
	var formation_ui: FormationUI = formations_ui[event.player_id]
	var target_formation_ui: FormationUI = formations_ui[event.target_player_id]
	var target_formation: Formation = Battling.formations[event.target_player_id]
	
	await formation_ui.vivosaur_sprite_zones[event.support_zone].pulse()
	
	var target_az: Vivosaur = target_formation.az
	target_az.attack_modifier += event.attack_modifier
	target_az.defense_modifier += event.defense_modifier
	target_az.accuracy_modifier += event.accuracy_modifier
	target_az.evasion_modifier += event.evasion_modifier
	
	var target_support_effects: TextureRect = target_formation_ui.support_effects
	format_support_modifier(target_support_effects, 'Atk', target_az.attack_modifier)
	format_support_modifier(target_support_effects, 'Def', target_az.defense_modifier)
	format_support_modifier(target_support_effects, 'Acc', target_az.accuracy_modifier)
	format_support_modifier(target_support_effects, 'Eva', target_az.evasion_modifier)

func format_support_modifier(
	support_effects: TextureRect, 
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
	
func _show_who_goes_first(event: FirstPlayerDeterminedEvent) -> void:
	var player1_formation_ui: FormationUI = formations_ui[event.player1_id]
	var player2_formation_ui: FormationUI = formations_ui[event.player2_id]
	
	var player1_total_lp_panel: Control = player1_formation_ui.total_lp_panel
	var player2_total_lp_panel: Control = player2_formation_ui.total_lp_panel
	
	player1_total_lp_panel.get_node('Lp').text = '%d' % event.player1_total_lp
	player2_total_lp_panel.get_node('Lp').text = '%d' % event.player2_total_lp
	
	player1_total_lp_panel.visible = true
	player2_total_lp_panel.visible = true
	
	var tween: Tween = create_tween()
	tween.tween_property(
		player1_total_lp_panel,
		"global_position", 
		player1_formation_ui.get_node('TotalLpFinish').global_position, 
		0.33
	)
	tween.set_parallel()
	tween.tween_property(
		player2_total_lp_panel, 
		"global_position", 
		player2_formation_ui.get_node('TotalLpFinish').global_position,
		0.33
	)
	await tween.finished
	
	var first_attack: TextureRect
	if event.player1_total_lp < event.player2_total_lp:
		first_attack = player1_total_lp_panel.get_node('FirstAttack')
	else:
		first_attack = player2_total_lp_panel.get_node('FirstAttack')
	
	tween = create_tween()
	
	tween.tween_property(first_attack, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.set_parallel()
	tween.tween_property(first_attack, "scale", Vector2(2, 2), 0.2)

	await tween.finished
	await get_tree().create_timer(0.5).timeout
	
	player1_total_lp_panel.queue_free()
	player2_total_lp_panel.queue_free()
