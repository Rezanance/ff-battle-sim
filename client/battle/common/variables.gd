extends Node


var battlefield: BattleField
var player_id
var opponent_id

var currently_selected_vivosaur: VivosaurBattle
var currently_selected_vivosaur_sprite_btn: TextureButton

var selectable_targets: Array[TextureButton]

var currently_selected_target: VivosaurBattle
var currently_selected_target_sprite_btn: TextureButton

var is_choosing_target: bool = false
