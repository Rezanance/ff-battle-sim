extends TextureButton
class_name MedalBtn

@onready var selected_animation: AnimatedSprite2D = $SelectedAnimation

var vivosaur_id: int

func _ready() -> void:
	selected_animation.play()

func _on_gui_input(
	event: InputEvent, 
	unselect_previous_medal_btn: Callable,
	select_current_medal_btn: Callable,
	show_context_menu: Callable,
	show_vivosaur_summary: Callable) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			show_context_menu.call(event.global_position)
		unselect_previous_medal_btn.call()
		select_current_medal_btn.call()
		show_vivosaur_summary.call()

func _reset_position(new_position: Vector2) -> void:
	global_position = new_position
