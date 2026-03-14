extends Node
class_name FossilaryContainer

var MedalPlaceHolderScene: Resource = preload("res://client/team_editor/scenes/medal_placeholder.tscn")

var medal_placeholders: Dictionary[String, TextureRect] = {}
var create_medal_btn: Callable

func _on_team_manager_vivosaur_removed(vivosaur_id: String) -> void:
	var medal_placeholder: TextureRect = medal_placeholders[vivosaur_id]
	var medal_btn: MedalBtn = create_medal_btn.call(medal_placeholder.texture, vivosaur_id)
	medal_placeholder.add_child(medal_btn)

func init(team: Team, _create_medal_btn: Callable) -> void:
	create_medal_btn = _create_medal_btn
	
	for vivosaur_id: String in load_all_vivosaurs():
		var slot: int = team.slots_vivosaur_ids().find(vivosaur_id)
		var medal_placeholder: TextureRect = add_medal_placeholder(vivosaur_id)
		if slot < 0:
			var medal_btn: MedalBtn = create_medal_btn.call(medal_placeholder.texture, vivosaur_id)
			medal_placeholder.add_child(medal_btn)

func load_all_vivosaurs(path: String = 'res://core/data/vivosaurs') -> Array[String]:
	var vivosaur_res_files: PackedStringArray = ResourceLoader.list_directory(path)
	var all_vivosaur_ids: Array[String] = []
	for file_name: String in vivosaur_res_files:
		all_vivosaur_ids.append(file_name.replace('.tres', ''))
	return all_vivosaur_ids

func create_medal_placeholder(_texture: Resource) -> TextureRect:
	var medal_placeholder: TextureRect = MedalPlaceHolderScene.instantiate()
	medal_placeholder.texture = _texture
	return medal_placeholder

func add_medal_placeholder(vivosaur_id: String) -> TextureRect:
	var _texture: Resource = UIUtils.load_medal_texture(vivosaur_id)
	var medal_placeholder: TextureRect = create_medal_placeholder(_texture)
	medal_placeholders[vivosaur_id] = medal_placeholder
	add_child(medal_placeholder)
	return medal_placeholder
