extends Node

var is_transitioning: bool = false
var new_scene_path: String

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_dissolve_anim_finished)
	
func change_scene(path: String):
	is_transitioning = true
	$AnimationPlayer.play("dissolve")
	new_scene_path = path

func _dissolve_anim_finished(anim_name: StringName):
	if (is_transitioning and anim_name == 'dissolve'):
		get_tree().change_scene_to_file(new_scene_path)
		$AnimationPlayer.play_backwards(anim_name)
		is_transitioning = false
