extends Node
class_name TeamEditor

var MedalBtnScene: Resource = preload("res://client/team_editor/medal_btn.tscn")

@onready var context_menu: ContextMenu = $ContextMenu
@onready var team_slots: TeamSlots = $TeamSlots
@onready var vivosaur_summary: VivosaurSummary = $VivosaurSummary
@onready var fossilary_container: FossilaryContainer = $TextureRect/ScrollContainer/FossilaryContainer
@onready var team_name_input: LineEdit = $TeamNameInput
@onready var save_team_btn: SaveTeamBtn = $SaveTeamBtn 

var currently_selected_medal_btn: MedalBtn
var currently_selected_vivosaur_id: int
var current_action: String

func _ready() -> void:
	init_context_menu()
	for vivosaur_id: int in Constants.fossilary:
		add_medal_btn(vivosaur_id)
	init_save_team_btn()

func _on_team_name_changed(new_name: String) -> void:
	save_team_btn._on_team_changed(new_name, team_slots.team)

func _on_team_slots_team_modified(team: Team) -> void:
	save_team_btn._on_team_changed(team_name_input.text, team)

func init_context_menu() -> void:
	context_menu.init([
		ContextMenu.MenuItem.new(
			'Assign', 
			show_assign.bind(team_slots),
			team_slots.show_selectable_slots.bind('Assign')
		),
		ContextMenu.MenuItem.new(
			'Move/Swap',
			show_move_swap.bind(team_slots),
			team_slots.show_selectable_slots.bind('Move/Swap')
		),
		ContextMenu.MenuItem.new(
			'Remove',
			show_remove.bind(team_slots),
			team_slots.remove_medal
		)
	])

func add_medal_btn(vivosaur_id: int) -> void:
	var _texture: Resource = load_medal_texture(vivosaur_id)
	
	var medal_placeholder: TextureRect = fossilary_container.create_medal_placeholder(_texture)
	fossilary_container.medal_placeholders[vivosaur_id] = medal_placeholder
	fossilary_container.add_child(medal_placeholder)
	
	var medal_btn: MedalBtn = create_medal_btn(_texture, vivosaur_id)
	add_medal_btn_to_child(medal_btn, medal_placeholder, vivosaur_id)

func init_save_team_btn() -> void:
	
	save_team_btn.pressed.connect(save_team_btn._on_pressed.bind(
		team_slots,
		team_name_input,
	))
	save_team_btn._on_team_changed(team_name_input.text, team_slots.team)

func show_assign(medal_btn: MedalBtn, _team_slots: TeamSlots) -> bool:
	return not medal_btn in _team_slots.medal_btns

func show_move_swap(medal_btn: MedalBtn, _team_slots: TeamSlots) -> bool:
	return medal_btn in _team_slots.medal_btns

func show_remove(medal_btn: MedalBtn, _team_slots: TeamSlots) -> bool:
	return medal_btn in _team_slots.medal_btns

func load_medal_texture(vivosaur_id: int) -> Resource:
	return load("res://client/assets/vivosaurs/%d/medal/%d (2).png" % [vivosaur_id, vivosaur_id])

func create_medal_btn(_texture: Resource, vivosaur_id: int) -> MedalBtn:
	var medal_btn: MedalBtn = MedalBtnScene.instantiate()
	medal_btn.texture_normal = _texture
	medal_btn.vivosaur_id = vivosaur_id
	medal_btn.gui_input.connect(medal_btn._on_gui_input.bind(
		unselect_previous_medal_btn,
		select_current_medal_btn.bind(medal_btn, vivosaur_id),
		context_menu.show_menu.bind(medal_btn),
		vivosaur_summary.update_summary.bind(vivosaur_id)))
	return medal_btn

func add_medal_btn_to_child(medal_btn: MedalBtn, medal_placeholder: TextureRect, vivosaur_id: int) -> void:
	var slot: int = TeamEditing.editing_team.slots_vivosaur_ids().find(vivosaur_id)
	if slot >= 0:
		team_slots.medal_btns[slot] = medal_btn
		medal_btn.global_position = team_slots.slots[slot].global_position + Vector2(0, 0)
		add_child(medal_btn)
		return
	medal_placeholder.add_child(medal_btn)

func unselect_previous_medal_btn() -> void:
	if currently_selected_medal_btn != null:
		currently_selected_medal_btn.get_node('SelectedAnimation').visible = false

func select_current_medal_btn(medal_btn: MedalBtn, vivosaur_id: int) -> void:
	medal_btn.get_node('SelectedAnimation').visible = true
	currently_selected_vivosaur_id = vivosaur_id
	currently_selected_medal_btn = medal_btn
