extends Node
class_name FossilaryContainer

var MedalPlaceHolderScene: Resource = preload("res://client/team_editor/medal_placeholder.tscn")

var medal_placeholders: Dictionary[int, TextureRect] = {}
var create_medal_btn: Callable

func _on_team_manager_vivosaur_removed(vivosaur_id: int) -> void:
	var medal_placeholder = medal_placeholders[vivosaur_id]
	var medal_btn = create_medal_btn.call(medal_placeholder.texture, vivosaur_id)
	medal_placeholder.add_child(medal_btn)

func init(team: Team, _create_medal_btn: Callable) -> void:
	create_medal_btn = _create_medal_btn
	for vivosaur_id: int in Constants.fossilary:
		var slot: int = team.slots_vivosaur_ids().find(vivosaur_id)
		var medal_placeholder: TextureRect = add_medal_placeholder(vivosaur_id)
		if slot < 0:
			var medal_btn: MedalBtn = create_medal_btn.call(medal_placeholder.texture, vivosaur_id)
			medal_placeholder.add_child(medal_btn)
			
func create_medal_placeholder(_texture: Resource) -> TextureRect:
	var medal_placeholder: TextureRect = MedalPlaceHolderScene.instantiate()
	medal_placeholder.texture = _texture
	return medal_placeholder

func add_medal_placeholder(vivosaur_id: int) -> TextureRect:
	var _texture: Resource = UIUtils.load_medal_texture(vivosaur_id)
	var medal_placeholder: TextureRect = create_medal_placeholder(_texture)
	medal_placeholders[vivosaur_id] = medal_placeholder
	add_child(medal_placeholder)
	return medal_placeholder
