extends Node
class_name BattleVariables

var battlefield: BattleField
var player_id: int
var opponent_id: int

var currently_selected_vivosaur: Vivosaur
var currently_selected_vivosaur_sprite_btn: TextureButton

var selectable_targets: Array[TextureButton]

var currently_selected_target: Vivosaur
var currently_selected_target_sprite_btn: TextureButton

var is_choosing_target: bool = false
