class_name TeamManager extends Node

const MedalBtnScene: Resource = preload("res://client/components/ui/MedalBtn/MedalBtn.tscn")
const Action = TeamSlots.Action
const MenuItem = ContextMenu.MenuItem

signal vivosaur_removed(vivosaur_id: int)

@export var allowed_actions: Array[Action]
@export var context_menu: ContextMenu
@export var team_slots: TeamSlots
@export var vivosaur_summary: VivosaurSummary
@export var fossilary_container: FossilaryContainer

var currently_selected_medal_btn: MedalBtn
var current_action: TeamSlots.Action

func _on_team_slot_clicked(team_slot: int) -> void:
	team_slots.perform_action(current_action, currently_selected_medal_btn, team_slot)

func _on_context_menu_item_clicked(action: TeamSlots.Action) -> void:
	current_action = action
	
	if action == TeamSlots.Action.REMOVE:
		assert(fossilary_container != null)
		team_slots.perform_action(action, currently_selected_medal_btn, -1)
		vivosaur_removed.emit(currently_selected_medal_btn.vivosaur_id)
		return
	team_slots.show_selectable_slots(action, currently_selected_medal_btn)

func _on_medal_gui_input(event: InputEvent, medal_btn: MedalBtn) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			context_menu.show_menu(event.global_position, medal_btn)
		unselect_previous_medal_btn()
		select_current_medal_btn(medal_btn)
		vivosaur_summary.update_summary(medal_btn.vivosaur_id)

func init(team: Team) -> void:
	init_team_slots(team)
	init_context_menu()
	init_fossilary_container(team)

func init_context_menu() -> void:
	var menu_items: Array[MenuItem] = []
	if Action.ASSIGN in allowed_actions:
		menu_items.append(ContextMenu.MenuItem.new(
			'Assign', 
			show_assign,
			_on_context_menu_item_clicked.bind(TeamSlots.Action.ASSIGN)
		))
	if Action.MOVE_SWAP in allowed_actions:
		menu_items.append(ContextMenu.MenuItem.new(
			'Move/Swap',
			show_move_swap,
			_on_context_menu_item_clicked.bind(TeamSlots.Action.MOVE_SWAP)
		))
	if Action.REMOVE in allowed_actions:
		menu_items.append(ContextMenu.MenuItem.new(
			'Remove',
			show_remove,
			_on_context_menu_item_clicked.bind(TeamSlots.Action.REMOVE)
		))
	context_menu.init(menu_items)

func init_team_slots(team: Team) -> void:
	team_slots.init(team, _on_medal_gui_input, allowed_actions, create_medal_btn)

func init_fossilary_container(team: Team) -> void:
	if fossilary_container != null:
		fossilary_container.init(team, create_medal_btn)

func show_assign(medal_btn: MedalBtn) -> bool:
	return not medal_btn.vivosaur_id in team_slots.team.slots_vivosaur_ids()

func show_move_swap(medal_btn: MedalBtn) -> bool:
	return medal_btn.vivosaur_id in team_slots.team.slots_vivosaur_ids()

func show_remove(medal_btn: MedalBtn) -> bool:
	return medal_btn.vivosaur_id in team_slots.team.slots_vivosaur_ids()

func create_medal_btn(_texture: Resource, vivosaur_id: int) -> MedalBtn:
	var medal_btn: MedalBtn = MedalBtnScene.instantiate()
	medal_btn.init(vivosaur_id, CommonTypes.Screen.TEAM_EDITOR, CommonTypes.Owner.PLAYER)
	medal_btn.gui_input.connect(_on_medal_gui_input.bind(medal_btn))
	return medal_btn
	
func unselect_previous_medal_btn() -> void:
	if currently_selected_medal_btn != null:
		currently_selected_medal_btn.get_node('SelectedAnimation').visible = false
	team_slots.hide_selectable_slots()

func select_current_medal_btn(medal_btn: MedalBtn) -> void:
	medal_btn.get_node('SelectedAnimation').visible = true
	currently_selected_medal_btn = medal_btn
	
