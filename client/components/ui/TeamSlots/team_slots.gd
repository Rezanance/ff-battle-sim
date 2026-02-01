class_name TeamSlots extends TextureRect

enum SelectableSlots {ALL_EMPTY, ALL_EXCEPT_ONE}
enum Action {ASSIGN, MOVE_SWAP, REMOVE}

signal team_modified(team: Team)
signal slot_clicked(team_slot: int)

@onready var slots: Array[Slot] = [$AZ, $SZ1, $SZ2, $Extra1, $Extra2]
var allowed_actions: Array[Action]
var team: Team
var _on_medal_gui_input: Callable

func _ready() -> void:
	for i: int in range(len(slots)):
		slots[i].slot_clicked.connect(_on_slot_clicked.bind(i))

func _on_slot_clicked(team_slot: int) -> void:
	slot_clicked.emit(team_slot)

func init(_team: Team, __on_medal_gui_input: Callable, _allowed_actions: Array[Action], create_medal_btn: Callable) -> void:
	team = _team
	allowed_actions = _allowed_actions
	_on_medal_gui_input = __on_medal_gui_input
	
	add_team_slot_medals(_team, create_medal_btn)

func add_team_slot_medals(_team: Team, create_medal_btn: Callable) -> void:
	for slot: int in range(len(_team.slots)):
		if _team.slots[slot] == null:
			continue
		var vivosaur_id: int = _team.slots[slot].id
		var _texture: Resource = UIUtils.load_medal_texture(vivosaur_id)
		var medal_btn: MedalBtn = create_medal_btn.call(_texture, vivosaur_id)
		add_child(medal_btn)
		medal_btn.global_position = slots[slot].global_position

func show_selectable_slots(current_action: Action, selected_medal: MedalBtn) -> void:
	assert(current_action in allowed_actions, "Action not allowed")
	if current_action not in allowed_actions:
		return
	
	match current_action:
		Action.ASSIGN:
			for i: int in range(len(slots)):
				slots[i].visible = team.slots[i] == null
		Action.MOVE_SWAP:
			for i: int in range(len(slots)):
				slots[i].visible = selected_medal.vivosaur_id in team.slots_vivosaur_ids()
				var medal_btn: MedalBtn = slots[i].medal_btn
				if medal_btn != null:
					medal_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func hide_selectable_slots() -> void:
	for slot: Slot in slots:
		slot.hide()

func perform_action(action: Action, selected_medal_btn: MedalBtn, team_slot_clicked: int) -> void:
	match action:
		Action.ASSIGN:
			__assign_slot(selected_medal_btn, team_slot_clicked)
		Action.MOVE_SWAP:
			__move_swap_slots(selected_medal_btn, team_slot_clicked)
		Action.REMOVE:
			__remove_medal(selected_medal_btn)
	
func __assign_slot(selected_medal_btn: MedalBtn, team_slot: int) -> void:
	var duplicate_medal_btn: MedalBtn = selected_medal_btn.duplicate()
	add_child(duplicate_medal_btn)
	duplicate_medal_btn.init(
		selected_medal_btn.vivosaur_id, 
		selected_medal_btn.screen,
		selected_medal_btn.medal_owner 
	)
	duplicate_medal_btn.global_position = selected_medal_btn.global_position
	duplicate_medal_btn.selected_animation.visible = false
	duplicate_medal_btn.gui_input.connect(_on_medal_gui_input.bind(duplicate_medal_btn))
	selected_medal_btn.queue_free()
	
	var tween: Tween = create_tween() 
	duplicate_medal_btn.move(tween, slots[team_slot].global_position)
	
	hide_selectable_slots()
	
	team.slots[team_slot] = Constants.fossilary[selected_medal_btn.vivosaur_id]
	slots[team_slot].medal_btn = duplicate_medal_btn
	
	team_modified.emit(team)

func __move_swap_slots(selected_medal_btn: MedalBtn, team_slot: int) -> void:
	var selected_medal_team_slot: int = team.slots_vivosaur_ids().find(selected_medal_btn.vivosaur_id)
	var medal_btn_in_new_slot: MedalBtn = slots[team_slot].medal_btn
	slots[team_slot].medal_btn = slots[selected_medal_team_slot].medal_btn
	slots[selected_medal_team_slot].medal_btn = medal_btn_in_new_slot
	
	selected_medal_btn.selected_animation.visible = false
	
	var tween: Tween = create_tween()
	if medal_btn_in_new_slot != null: 
		medal_btn_in_new_slot.move(tween, slots[selected_medal_team_slot].global_position)
		tween.set_parallel() 
		team.slots[selected_medal_team_slot] = Constants.fossilary[medal_btn_in_new_slot.vivosaur_id]
		medal_btn_in_new_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		team.slots[selected_medal_team_slot] = null
	selected_medal_btn.move(tween, slots[team_slot].global_position)
	team.slots[team_slot] = Constants.fossilary[selected_medal_btn.vivosaur_id]
	selected_medal_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	
	hide_selectable_slots()
	
	team_modified.emit(team)

func __remove_medal(selected_medal_btn: MedalBtn) -> void:
	selected_medal_btn.selected_animation.visible = false

	var OFFSCREEN_POSITION: Vector2 = Vector2(selected_medal_btn.global_position.x + 1200, selected_medal_btn.global_position.y)
	var tween: Tween = create_tween()
	await selected_medal_btn.move(tween, OFFSCREEN_POSITION).finished
	selected_medal_btn.queue_free()
		
	var selected_medal_team_slot: int = team.slots_vivosaur_ids().find(selected_medal_btn.vivosaur_id)
	slots[selected_medal_team_slot].medal_btn = null
	team.slots[selected_medal_team_slot] = null
	
	team_modified.emit(team)
