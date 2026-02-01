extends Node
class_name TeamEditor

#const MedalBtnScene: Resource = preload("res://client/components/ui/MedalBtn/MedalBtn.tscn")

#@export var context_menu: ContextMenu
#@export var team_slots: TeamSlots
#@export var vivosaur_summary: VivosaurSummary
#@export var fossilary_container: FossilaryContainer
@export var team_manager: TeamManager
@export var team_name_input: LineEdit
@export var save_team_btn: SaveTeamBtn

var currently_selected_medal_btn: MedalBtn
var current_action: TeamSlots.Action

func _ready() -> void:
	#init_team_slots()
	#init_context_menu()
	#for vivosaur_id: int in Constants.fossilary:
		#add_medal(vivosaur_id)
	init_save_team_btn()
	init_team_manager()

func _on_team_name_changed(new_name: String) -> void:
	team_manager.team_slots.team.name = new_name
	save_team_btn._on_team_changed(
		new_name, 
		TeamEditing.editing_team
	)

func _on_team_slots_team_modified(team: Team) -> void:
	save_team_btn._on_team_changed(team_name_input.text, team)
#
#func _on_context_menu_item_clicked(action: TeamSlots.Action) -> void:
	#current_action = action
	#
	#if action == TeamSlots.Action.REMOVE:
		#var vivosaur_id: int = currently_selected_medal_btn.vivosaur_id
		#team_slots.perform_action(action, currently_selected_medal_btn, -1)
		#await get_tree().create_timer(1).timeout
		#var new_medal_btn: MedalBtn = create_medal_btn(fossilary_container.medal_placeholders[vivosaur_id].texture, vivosaur_id)
		#fossilary_container.medal_placeholders[vivosaur_id].add_child(new_medal_btn)
		#return
	#team_slots.show_selectable_slots(action, currently_selected_medal_btn)
#
#func _on_team_slot_clicked(team_slot: int) -> void:
	#team_slots.perform_action(current_action, currently_selected_medal_btn, team_slot)
#
#func _on_medal_gui_input(event: InputEvent, medal_btn: MedalBtn) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			#context_menu.show_menu(event.global_position, medal_btn)
		#unselect_previous_medal_btn()
		#select_current_medal_btn(medal_btn)
		#vivosaur_summary.update_summary(medal_btn.vivosaur_id)
#
#func init_context_menu() -> void:
	#context_menu.init([
		#ContextMenu.MenuItem.new(
			#'Assign', 
			#show_assign,
			#_on_context_menu_item_clicked.bind(TeamSlots.Action.ASSIGN)
		#),
		#ContextMenu.MenuItem.new(
			#'Move/Swap',
			#show_move_swap,
			#_on_context_menu_item_clicked.bind(TeamSlots.Action.MOVE_SWAP)
		#),
		#ContextMenu.MenuItem.new(
			#'Remove',
			#show_remove,
			#_on_context_menu_item_clicked.bind(TeamSlots.Action.REMOVE)
		#)
	#])
#
#func init_team_slots() -> void:
	#team_slots.init(TeamEditing.editing_team, _on_medal_gui_input)
#
#func add_medal(vivosaur_id: int) -> void:
	#var medal_placeholder: TextureRect = __add_medal_placeholder(vivosaur_id)
	#var medal_btn: MedalBtn = create_medal_btn(medal_placeholder.texture, vivosaur_id)
	#add_medal_btn_to_tree(medal_btn, medal_placeholder, vivosaur_id)

func init_save_team_btn() -> void:
	save_team_btn.pressed.connect(save_team_btn._on_pressed.bind(
		team_manager.team_slots,
	))
	save_team_btn._on_team_changed(
		team_name_input.text, 
		TeamEditing.editing_team
	)

func init_team_manager() -> void:
	team_manager.init(TeamEditing.editing_team)

#func show_assign(medal_btn: MedalBtn) -> bool:
	#return not medal_btn.vivosaur_id in team_slots.team.slots_vivosaur_ids()
#
#func show_move_swap(medal_btn: MedalBtn) -> bool:
	#return medal_btn.vivosaur_id in team_slots.team.slots_vivosaur_ids()
#
#func show_remove(medal_btn: MedalBtn) -> bool:
	#return medal_btn.vivosaur_id in team_slots.team.slots_vivosaur_ids()
#
#func create_medal_btn(_texture: Resource, vivosaur_id: int) -> MedalBtn:
	#var medal_btn: MedalBtn = MedalBtnScene.instantiate()
	#medal_btn.init(vivosaur_id, CommonTypes.Screen.TEAM_EDITOR, CommonTypes.Owner.PLAYER)
	#medal_btn.gui_input.connect(_on_medal_gui_input.bind(medal_btn))
	#return medal_btn
#
#func add_medal_btn_to_tree(medal_btn: MedalBtn, medal_placeholder: TextureRect, vivosaur_id: int) -> void:
	#var slot: int = TeamEditing.editing_team.slots_vivosaur_ids().find(vivosaur_id)
	#if slot >= 0:
		#medal_btn.global_position = team_slots.slots[slot].global_position
		#add_child(medal_btn)
		#return
	#medal_placeholder.add_child(medal_btn)
#
#func unselect_previous_medal_btn() -> void:
	#if currently_selected_medal_btn != null:
		#currently_selected_medal_btn.get_node('SelectedAnimation').visible = false
	#team_slots.hide_selectable_slots()
#
#func select_current_medal_btn(medal_btn: MedalBtn) -> void:
	#medal_btn.get_node('SelectedAnimation').visible = true
	#currently_selected_medal_btn = medal_btn
	#
#func __add_medal_placeholder(vivosaur_id: int) -> TextureRect:
	#var _texture: Resource = UIUtils.load_medal_texture(vivosaur_id)
	#var medal_placeholder: TextureRect = fossilary_container.create_medal_placeholder(_texture)
	#fossilary_container.medal_placeholders[vivosaur_id] = medal_placeholder
	#fossilary_container.add_child(medal_placeholder)
	#return medal_placeholder
	#
