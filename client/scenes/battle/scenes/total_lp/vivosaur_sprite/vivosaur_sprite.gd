extends TextureButton
class_name VivosaurSprite

const UI_STEP = Battling.UI_STEP

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow: TextureRect = $Arrow
@onready var cursor: AnimatedSprite2D = $Cursor

var id: String
var is_targetable: bool = false

func _ready() -> void:
	cursor.play()
	pressed.connect(_on_pressed)

func pulse() -> void:
	animation_player.play("pulse")
	await animation_player.animation_finished

func _on_pressed() -> void:
	if is_targetable:
		cursor.visible = true
	animation_player.play("arrow")
	arrow.visible = true
