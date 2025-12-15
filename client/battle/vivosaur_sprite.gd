extends TextureButton


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow: TextureRect = $Arrow
@onready var cursor: AnimatedSprite2D = $Cursor

func _ready() -> void:
	animation_player.play("arrow")
	cursor.play()
