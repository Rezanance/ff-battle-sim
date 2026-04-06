extends TextureButton
class_name VivosaurSprite

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow: TextureRect = $Arrow
@onready var cursor: AnimatedSprite2D = $Cursor

func _ready() -> void:
	animation_player.play("arrow")
	cursor.play()

func pulse() -> void:
	animation_player.play("pulse")
	await animation_player.animation_finished
