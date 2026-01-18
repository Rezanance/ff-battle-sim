extends Node
class_name FossilaryContainer

@onready var team_editor: TeamEditor = $'../../../'
@onready var team_slots: TeamSlots = $'../../../TeamSlots'

var MedalBtnScene: Resource = preload("res://client/team_editor/medal_btn.tscn")
var MedalPlaceHolderScene: Resource = preload("res://client/team_editor/medal_placeholder.tscn")

var medal_placeholders: Dictionary[int, TextureRect] = {}

func _on_team_slots_loaded() -> void:
	for vivosaur_id: int in Constants.fossilary:
		var _texture: Resource = load_medal_texture(vivosaur_id)
		var medal_placeholder: TextureRect = create_medal_placeholder(_texture)
		var medal_btn: MedalBtn = create_medal_btn(_texture, vivosaur_id)
		medal_placeholders[vivosaur_id] = medal_placeholder
		add_medal_btn(medal_btn, medal_placeholder,vivosaur_id)
		add_child(medal_placeholder)

func load_medal_texture(vivosaur_id: int) -> Resource:
	return load("res://client/assets/vivosaurs/%d/medal/%d (2).png" % [vivosaur_id, vivosaur_id])

func create_medal_btn(_texture: Resource, vivosaur_id: int) -> MedalBtn:
	var medal_btn: MedalBtn = MedalBtnScene.instantiate()
	medal_btn.texture_normal = _texture
	medal_btn.vivosaur_id = vivosaur_id
	medal_btn.gui_input.connect(medal_btn._on_gui_input.bind(
		team_editor.unselect_previous_medal_btn,
		team_editor.select_current_medal_btn.bind(medal_btn, vivosaur_id),
		team_editor.show_context_menu.bind(medal_btn),
		team_editor.show_vivosaur_summary.bind(vivosaur_id)))
	return medal_btn

func create_medal_placeholder(_texture: Resource) -> TextureRect:
	var medal_placeholder: TextureRect = MedalPlaceHolderScene.instantiate()
	medal_placeholder.texture = _texture
	return medal_placeholder

func add_medal_btn(medal_btn: MedalBtn, medal_placeholder: TextureRect, vivosaur_id: int) -> void:
	var slot: int = TeamEditing.editing_team.slots_vivosaur_ids().find(vivosaur_id)
	if slot != -1:
		team_slots.medal_btns[slot] = medal_btn
		medal_btn.global_position = team_slots.slots[slot].global_position + Vector2(0, 0)
		team_editor.add_child.call_deferred(medal_btn)
	else:
		medal_placeholder.add_child.call_deferred(medal_btn)
