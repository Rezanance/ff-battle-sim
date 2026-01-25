extends Node
class_name FossilaryContainer

var MedalPlaceHolderScene: Resource = preload("res://client/team_editor/medal_placeholder.tscn")

var medal_placeholders: Dictionary[int, TextureRect] = {}

func create_medal_placeholder(_texture: Resource) -> TextureRect:
	var medal_placeholder: TextureRect = MedalPlaceHolderScene.instantiate()
	medal_placeholder.texture = _texture
	return medal_placeholder
