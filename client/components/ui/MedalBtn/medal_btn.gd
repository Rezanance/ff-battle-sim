class_name MedalBtn extends TextureButton

const Owner = CommonTypes.Owner
const Screen = CommonTypes.Screen
const Location = MedalTypes.Location
const ActionEndStateArray = StateMachine.ActionEndStateArray
const ActionEndState = StateMachine.ActionEndState

var vivosaur_id: int
var screen: Screen
var medal_owner: Owner

func init(
	_vivosaur_id: int,
	_screen: Screen, 
	_medal_owner: Owner,
) -> void:
	vivosaur_id = _vivosaur_id
	screen = _screen
	medal_owner = _medal_owner

	texture_normal = UIUtils.load_medal_texture(vivosaur_id)

@onready var selected_animation: AnimatedSprite2D = $SelectedAnimation

func _ready() -> void:
	selected_animation.play()

func _reset_position(new_position: Vector2) -> void:
	global_position = new_position

func show_seleted_animation(cond: bool) -> void:
	selected_animation.visible = cond

func move(tween: Tween, new_position: Vector2, transition_time: float = 1.0) -> PropertyTweener:
	return tween.tween_property(
		self,
		'global_position',
		new_position, 
		transition_time
	).set_trans(Tween.TRANS_SPRING)
